import 'package:flutter/material.dart';
import '../core/recognition_service.dart';
import '../core/app_colors.dart';

class RecognitionSettingsPage extends StatefulWidget {
  const RecognitionSettingsPage({super.key});

  @override
  State<RecognitionSettingsPage> createState() =>
      _RecognitionSettingsPageState();
}

class _RecognitionSettingsPageState extends State<RecognitionSettingsPage> {
  RecognitionMode _currentMode = RecognitionMode.cloud;

  @override
  void initState() {
    super.initState();
    _currentMode = RecognitionService.mode;
  }

  Future<void> _setMode(RecognitionMode mode) async {
    await RecognitionService.setMode(mode);
    setState(() {
      _currentMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Recognition'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Choose how ingredient recognition works. Local mode works offline but may be less accurate. Cloud mode requires internet but provides better results.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[800],
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Mode options
            Text(
              'Recognition Mode',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),

            _buildModeCard(
              RecognitionMode.local,
              'Local (Offline)',
              'Runs entirely on your device. No internet required. Limited to common ingredients.',
              Icons.phone_android,
              Colors.green,
            ),
            const SizedBox(height: 12),

            _buildModeCard(
              RecognitionMode.cloud,
              'Cloud (Online)',
              'Uses AI service. Requires internet connection. Best accuracy for all ingredients.',
              Icons.cloud,
              Colors.blue,
            ),
            const SizedBox(height: 12),

            _buildModeCard(
              RecognitionMode.auto,
              'Auto',
              'Tries local recognition first. Falls back to cloud if needed for better accuracy.',
              Icons.auto_mode,
              Colors.orange,
            ),

            const SizedBox(height: 32),

            // Current status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Status',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatusRow(
                    'Local Model',
                    RecognitionService.isLocalAvailable,
                  ),
                  const SizedBox(height: 8),
                  _buildStatusRow(
                    'Cloud Service',
                    RecognitionService.isCloudConfigured,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(
    RecognitionMode mode,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    final isSelected = _currentMode == mode;
    return InkWell(
      onTap: () => _setMode(mode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 28)
            else
              Icon(Icons.circle_outlined, color: Colors.grey[400], size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool isAvailable) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isAvailable ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
        const Spacer(),
        Text(
          isAvailable ? 'Ready' : 'Not Ready',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isAvailable ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}
