import 'package:flutter/material.dart';
import '../theme.dart';
import 'treatment_screen.dart';
import 'home_screen.dart';

/// Short descriptions shown under the disease name. Backend only sends
/// the disease name/stage/confidence — these blurbs live on the app side.
const Map<String, String> _diseaseDescriptions = {
  'Leaf Curl':
      'Leaves curl and pucker, usually spread by whitefly. Left untreated it can stunt the whole plant.',
  'Cercospora Spot':
      'Commonly known as frog-eye spot, caused by the fungus Cercospora capsici.',
  'Yellowing':
      'Leaves lose their green colour, often linked to nutrient deficiency or root stress.',
  'Bacterial Spot':
      'Water-soaked spots that turn brown/black, spread by splashing water and wet leaves.',
};

class ResultScreen extends StatelessWidget {
  /// The JSON returned by POST /api/diagnose — see Diagnosis.to_dict()
  /// in the Flask backend: {is_healthy, disease_type, stage, confidence, ...}
  final Map<String, dynamic> diagnosis;

  const ResultScreen({super.key, required this.diagnosis});

  @override
  Widget build(BuildContext context) {
    final bool isHealthy = diagnosis['is_healthy'] == true;
    final String diseaseName =
        isHealthy ? 'Healthy Leaf' : (diagnosis['disease_type'] ?? 'Unknown');
    final String diseaseDesc = isHealthy
        ? 'No signs of disease detected. Keep up the good care!'
        : (_diseaseDescriptions[diagnosis['disease_type']] ??
            'Detected by the AI model.');
    final String stage = isHealthy
        ? '-'
        : (diagnosis['stage'] == 'late' ? 'Late Infection' : 'Early Infection');
    final double confidence = (diagnosis['confidence'] as num? ?? 0).toDouble();

    DateTime createdAt;
    try {
      createdAt = createdAt = DateTime.parse(diagnosis['created_at']).toUtc().toLocal();
    } catch (_) {
      createdAt = DateTime.now();
    }
    final String scanDate =
        '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    final String scanTime =
        '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.mintBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Diagnosis Result'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),

              // AI label + Identified badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('AI SCAN RESULT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cyan,
                        letterSpacing: 0.8,
                      )),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(isHealthy ? 'Healthy' : 'Identified',
                        style:
                            const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Disease name
              Text(
                diseaseName,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(diseaseDesc,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textGrey, height: 1.5)),
              const SizedBox(height: 14),

              if (!isHealthy)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(label: 'Stage: $stage'),
                  ],
                ),
              const SizedBox(height: 16),

              // Analyzed sample card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Analyzed Sample',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        )),
                    SizedBox(height: 4),
                    Text(
                      'Image processed successfully with high clarity.',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textGrey, height: 1.4),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.shield_outlined,
                            color: AppColors.cyan, size: 16),
                        SizedBox(width: 6),
                        Text('CONFIDENCE SCORE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cyan,
                              letterSpacing: 0.5,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Confidence level
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('AI Confidence Level',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  Text(
                    '${(confidence * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: confidence.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: AppColors.divider,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cyan),
                ),
              ),
              const SizedBox(height: 16),

              const Divider(color: AppColors.divider),
              const SizedBox(height: 12),

              // Scan date & time
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 16, color: AppColors.textGrey),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SCAN DATE',
                          style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textGrey,
                              letterSpacing: 0.5)),
                      Text(scanDate,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          )),
                    ],
                  ),
                  const SizedBox(width: 24),
                  const Icon(Icons.access_time_outlined,
                      size: 16, color: AppColors.textGrey),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SCAN TIME',
                          style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textGrey,
                              letterSpacing: 0.5)),
                      Text(scanTime,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          )),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (!isHealthy)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cyan.withOpacity(0.2)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: AppColors.cyan, size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Early detection and quick action can prevent up to 80% of crop loss from spreading.',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textGrey,
                              height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // View Treatment button (hidden for healthy leaves)
              if (!isHealthy)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TreatmentScreen(
                          diseaseType: diagnosis['disease_type'],
                          stage: diagnosis['stage'],
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBtn,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.description_outlined, size: 18),
                    label: const Text('View Treatment Recommendation',
                        style:
                            TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              if (!isHealthy) const SizedBox(height: 10),

              // Back to Home
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (r) => false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyan,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Back to Home',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 14),

              const Center(
                child: Text(
                  'Disclaimer: AI diagnosis is for guidance. Consult a local agricultural expert for critical decisions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textLight,
                      fontStyle: FontStyle.italic,
                      height: 1.5),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cyan.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 12,
              color: AppColors.cyanDark,
              fontWeight: FontWeight.w500)),
    );
  }
}
