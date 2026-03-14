import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _nickname = 'Cook Master';
  String _email = 'cook@example.com';
  String? _avatarPath;

  // 默认头像 URL，选择一个和厨房/美食相关的
  final String _defaultAvatarUrl =
      'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?w=200&auto=format&fit=crop&q=60';

  String get nickname => _nickname;
  String get email => _email;
  String? get avatarPath => _avatarPath;
  String get defaultAvatarUrl => _defaultAvatarUrl;

  void updateProfile(
      {required String nickname, required String email, String? avatarPath}) {
    _nickname = nickname;
    _email = email;
    if (avatarPath != null) {
      _avatarPath = avatarPath;
    }
    notifyListeners();
  }
}
