import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/generated/app_localizations.dart';
import 'api_service.dart';

/// App update check service
/// Supports force update and optional update
class AppUpdateService {
  static const String _prefsKeyLastCheck = 'app_update_last_check';
  static const String _prefsKeySkippedVersion = 'app_update_skipped_version';
  static const Duration _checkInterval = Duration(hours: 24);

  /// Check if update check is needed (not checked in last 24 hours)
  static Future<bool> shouldCheckUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt(_prefsKeyLastCheck);
    if (lastCheck == null) return true;
    
    final lastCheckTime = DateTime.fromMillisecondsSinceEpoch(lastCheck);
    return DateTime.now().difference(lastCheckTime) > _checkInterval;
  }

  /// Update last check timestamp
  static Future<void> markChecked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKeyLastCheck, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get current app version
  static Future<String> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  /// Check for app update
  /// Returns null if no update needed, otherwise returns update info
  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final currentVersion = await getCurrentVersion();
      final platform = Platform.isIOS ? 'ios' : 'android';
      
      final updateData = await ApiService().checkVersion(platform, currentVersion);
      
      if (updateData != null) {
        final latestVersion = updateData['latest_version'];
        final forceUpdate = updateData['force_update'] ?? false;
        
        if (_shouldUpdate(currentVersion, latestVersion)) {
          final prefs = await SharedPreferences.getInstance();
          final skippedVersion = prefs.getString(_prefsKeySkippedVersion);
          
          if (!forceUpdate && skippedVersion == latestVersion) {
            return null; // User skipped this version
          }
          
          return UpdateInfo(
            version: latestVersion,
            forceUpdate: forceUpdate,
            updateUrl: updateData['update_url'],
            title: updateData['title'] ?? 'New Version Available',
            message: updateData['message'] ?? 'Version $latestVersion is now available.',
          );
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error checking for update: $e');
      return null;
    }
  }

  /// Compare versions to determine if update is needed
  static bool _shouldUpdate(String current, String latest) {
    final currentParts = current.split('.').map(int.parse).toList();
    final latestParts = latest.split('.').map(int.parse).toList();
    
    for (int i = 0; i < 3; i++) {
      final currentPart = i < currentParts.length ? currentParts[i] : 0;
      final latestPart = i < latestParts.length ? latestParts[i] : 0;
      
      if (latestPart > currentPart) return true;
      if (latestPart < currentPart) return false;
    }
    return false;
  }

  /// Mark version as skipped
  static Future<void> skipVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeySkippedVersion, version);
  }

  /// Open app store for update
  static Future<void> openUpdateUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}

/// Update information model
class UpdateInfo {
  final String version;
  final bool forceUpdate;
  final String updateUrl;
  final String title;
  final String message;

  UpdateInfo({
    required this.version,
    required this.forceUpdate,
    required this.updateUrl,
    required this.title,
    required this.message,
  });
}

/// Update dialog widget
class UpdateDialog extends StatelessWidget {
  final UpdateInfo updateInfo;
  final bool forceUpdate;

  const UpdateDialog({
    super.key,
    required this.updateInfo,
    this.forceUpdate = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return WillPopScope(
      onWillPop: () async => !forceUpdate,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.system_update,
                  size: 40,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              Text(
                updateInfo.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // Version info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'v${updateInfo.version}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Message
              Text(
                updateInfo.message,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Update button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _handleUpdate(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Update Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              // Skip button (only for optional updates)
              if (!forceUpdate) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => _handleSkip(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text(
                    'Skip This Version',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleUpdate(BuildContext context) async {
    try {
      await AppUpdateService.openUpdateUrl(updateInfo.updateUrl);
      if (!forceUpdate) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open store: $e')),
      );
    }
  }

  void _handleSkip(BuildContext context) async {
    await AppUpdateService.skipVersion(updateInfo.version);
    Navigator.of(context).pop();
  }
}

/// Check and show update dialog
Future<void> checkAndShowUpdateDialog(BuildContext context) async {
  // Check if we should check for updates (not checked in last 24 hours)
  if (!await AppUpdateService.shouldCheckUpdate()) {
    return;
  }

  final updateInfo = await AppUpdateService.checkForUpdate();
  if (updateInfo == null) return;

  await AppUpdateService.markChecked();

  if (context.mounted) {
    await showDialog(
      context: context,
      barrierDismissible: !updateInfo.forceUpdate,
      builder: (context) => UpdateDialog(
        updateInfo: updateInfo,
        forceUpdate: updateInfo.forceUpdate,
      ),
    );
  }
}
