import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:io';
import '../core/app_colors.dart';
import '../models/ingredient.dart';
import '../core/scan_history_provider.dart';
import '../l10n/generated/app_localizations.dart';
import 'recognition_result_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];
  bool _isRecognizing = false;

  Future<void> _pickImage(ImageSource source) async {
    if (_images.length >= 9) {
      Fluttertoast.showToast(msg: '最多支持9张图片');
      return;
    }

    try {
      if (source == ImageSource.gallery) {
        final List<XFile>? pickedFiles = await _picker.pickMultiImage(
          maxWidth: 1000,
          maxHeight: 1000,
          imageQuality: 85,
          limit: 9 - _images.length,
        );
        if (pickedFiles != null && pickedFiles.isNotEmpty) {
          setState(() {
            _images.addAll(pickedFiles.take(9 - _images.length));
          });
        }
      } else {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: 1000,
          maxHeight: 1000,
          imageQuality: 85,
        );
        if (pickedFile != null) {
          setState(() {
            _images.add(pickedFile);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(AppLocalizations.of(context)!.error, e.toString());
      }
    }
  }

  Future<void> _startRecognition() async {
    if (_images.isEmpty) return;

    setState(() {
      _isRecognizing = true;
    });

    try {
      final imagePaths = _images.map((img) => img.path).toList();
      final results = await LLMService.recognizeIngredients(imagePaths);

      if (mounted) {
        // Use the first image for the scan history thumbnail
        final thumbnailBytes = await _images[0].readAsBytes();

        Provider.of<ScanHistoryProvider>(context, listen: false).addEntry(
          imagePath: _images[0].path,
          thumbnailBytes: thumbnailBytes,
          ingredients: results,
        );

        setState(() {
          _isRecognizing = false;
        });

        // Navigate to the new Result Page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecognitionResultPage(
              ingredients: results,
              imagePaths: imagePaths,
            ),
          ),
        ).then((_) {
          // Optional: clear images when returning if needed
          // setState(() => _images = []);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRecognizing = false;
        });
        _showErrorDialog(AppLocalizations.of(context)!.error, e.toString());
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.restaurant_outlined,
                color: AppColors.primary, size: 30),
            const SizedBox(width: 8),
            Text(
              l10n.appTitle,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.orange[100],
              child: const Text('A',
                  style: TextStyle(color: Colors.orange, fontSize: 14)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(
                l10n.smartIdentification,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.cameraIntro,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              if (_isRecognizing)
                _buildLoadingState(l10n)
              else
                _buildUploadPlaceholder(l10n),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadPlaceholder(AppLocalizations l10n) {
    if (_images.isNotEmpty) {
      return Column(
        children: [
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length + (_images.length < 9 ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                if (index == _images.length) {
                  return GestureDetector(
                    onTap: () => _showPickerOptions(context),
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(16),
                      dashPattern: const [6, 3],
                      color: Colors.grey.shade400,
                      child: Container(
                        width: 150,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined,
                                color: AppColors.primary, size: 32),
                            SizedBox(height: 8),
                            Text('继续添加',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(_images[index].path),
                        width: 150,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => _images.removeAt(index)),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _startRecognition,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                '开始智能识别 (${_images.length}/9)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() => _images = []),
            child: const Text('清空重拍',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      );
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () => _pickImage(ImageSource.camera),
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(24),
            dashPattern: const [8, 4],
            color: Colors.grey.shade300,
            strokeWidth: 2,
            child: Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.primary,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.clickToUpload,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '支持多次拍照或多图识别（最多9张）',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => _pickImage(ImageSource.gallery),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[100],
            foregroundColor: AppColors.textSecondary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.photo_library_outlined, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.chooseFromAlbum,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            l10n.recognizing,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.countingIngredients,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _images.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_images[index].path),
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
