import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _items = [];
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ApiService.getHistory(from: _fromDate, to: _toDate);
      setState(() => _items = data);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(
          () => _error = 'Could not reach the server. Check your connection.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = (isFrom ? _fromDate : _toDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _fromDate = picked;
      } else {
        _toDate = picked;
      }
    });
    _loadHistory();
  }

  void _clearFilter() {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });
    _loadHistory();
  }

  String _fmt(DateTime? d) => d == null ? '--' : '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mintBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Disease History'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDate(isFrom: true),
                      icon: const Icon(Icons.calendar_today_outlined, size: 14),
                      label: Text('From: ${_fmt(_fromDate)}',
                          style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDate(isFrom: false),
                      icon: const Icon(Icons.calendar_today_outlined, size: 14),
                      label: Text('To: ${_fmt(_toDate)}',
                          style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                  if (_fromDate != null || _toDate != null) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      tooltip: 'Clear filter',
                      onPressed: _clearFilter,
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.cyan))
                  : _error != null
                      ? _buildError()
                      : _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 12),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textGrey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHistory,
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.darkBtn),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_items.isEmpty) {
      return const Center(
        child: Text('No diagnoses yet — scan a leaf to get started.',
            style: TextStyle(color: AppColors.textGrey)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            'RECENT DIAGNOSES (${_items.length})',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textGrey,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadHistory,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _items[index] as Map<String, dynamic>;
                return _HistoryCard(item: item);
              },
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: const Column(
            children: [
              DashedDivider(),
              SizedBox(height: 14),
              Text(
                'Keep your history updated to track treatment effectiveness over the growing season.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: AppColors.textGrey, height: 1.5),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _HistoryCard({required this.item});

  bool get _isHealthy => item['is_healthy'] == true;
  String get _stageType => item['stage'] ?? 'early';

  Color get _stageBg {
    if (_isHealthy) return AppColors.earlyStage;
    return _stageType == 'late'
        ? AppColors.advancedStage
        : AppColors.earlyStage;
  }

  Color get _stageTextColor {
    if (_isHealthy) return AppColors.textDark;
    return _stageType == 'late' ? AppColors.advancedText : AppColors.textDark;
  }

  String get _name => _isHealthy
      ? 'HEALTHY'
      : (item['disease_type'] ?? 'Unknown').toString().toUpperCase();

  String get _stageLabel {
    if (_isHealthy) return '-';
    return _stageType == 'late' ? 'Late Stage' : 'Early Stage';
  }

  String get _confidenceLabel {
    final c = (item['confidence'] as num? ?? 0).toDouble();
    return '${(c * 100).toStringAsFixed(0)}%';
  }

  String get _dateLabel {
    try {
      final d = DateTime.parse(item['created_at']).toUtc().toLocal();
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => ResultScreen(diagnosis: item))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        letterSpacing: 0.3,
                      )),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 12, color: AppColors.textGrey),
                      const SizedBox(width: 4),
                      Text(_dateLabel,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textGrey)),
                    ],
                  ),
                  if (!_isHealthy) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _stageBg,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: _stageTextColor.withOpacity(0.2)),
                      ),
                      child: Text(_stageLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: _stageTextColor,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_confidenceLabel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cyan,
                    )),
                const SizedBox(height: 24),
                const Icon(Icons.chevron_right,
                    color: AppColors.textGrey, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const double dashWidth = 6;
      const double dashSpace = 4;
      final count =
          (constraints.constrainWidth() / (dashWidth + dashSpace)).floor();
      return Row(
        children: List.generate(
          count,
          (_) => Container(
            width: dashWidth,
            height: 1,
            margin: const EdgeInsets.only(right: dashSpace),
            color: AppColors.divider,
          ),
        ),
      );
    });
  }
}