import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class TreatmentScreen extends StatefulWidget {
  final String diseaseType;
  final String stage; // "early" or "late"

  const TreatmentScreen({
    super.key,
    required this.diseaseType,
    required this.stage,
  });

  @override
  State<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends State<TreatmentScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _guideline;

  @override
  void initState() {
    super.initState();
    _loadGuideline();
  }

  Future<void> _loadGuideline() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data =
          await ApiService.getTreatment(widget.diseaseType, widget.stage);
      setState(() => _guideline = data);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Could not reach the server. Check your connection.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mintBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Treatment Guidelines'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.cyan))
            : _error != null
                ? _buildError()
                : _buildContent(),
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
              onPressed: _loadGuideline,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkBtn),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final stageLabel = widget.stage == 'late' ? 'Late Infection' : 'Early Infection';
    final recommendation = _guideline?['recommendation'] ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),

          // Disease description card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.cyan, size: 18),
                    const SizedBox(width: 6),
                    const Text('Disease',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cyan,
                        )),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.stage == 'late'
                            ? AppColors.highSeverity
                            : AppColors.cyan.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(stageLabel,
                          style: TextStyle(
                              fontSize: 11,
                              color: widget.stage == 'late'
                                  ? Colors.white
                                  : AppColors.cyanDark,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(widget.diseaseType,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Recommendation
          const Row(
            children: [
              Icon(Icons.check_circle_outline, color: AppColors.cyan, size: 20),
              SizedBox(width: 8),
              Text('Recommended Treatment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              recommendation,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textDark, height: 1.6),
            ),
          ),
          const SizedBox(height: 16),

          // Safety note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.orange.shade700, size: 18),
                    const SizedBox(width: 6),
                    Text('Safety Note',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.orange.shade700,
                        )),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Always wear protective gear including gloves and a mask when applying chemical treatments. Do not spray during peak sun hours or high winds.',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textGrey, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Return to Home
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (r) => false),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBtn,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back, size: 18),
                  SizedBox(width: 8),
                  Text('Return to Home',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          const Center(
            child: Text(
              'Consult with local agricultural experts if symptoms persist after treatment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11, color: AppColors.textLight, fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
