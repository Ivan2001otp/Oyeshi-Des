import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:oyeshi_des/config/onboarding/onboarding_model.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();
  bool _isInitialized = false;

  late FirebaseRemoteConfig _remoteConfig;
  Future<void> initialize() async {
    _remoteConfig = FirebaseRemoteConfig.instance;

    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 15),
        minimumFetchInterval: const Duration(minutes: 5),
      ),
    );

    await _fetchAndActivate();
  }

  Future<void> _fetchAndActivate() async {
    const maxTries = 3;
    for (int attempt = 1; attempt <= maxTries; attempt++) {
      try {
        await _remoteConfig.fetchAndActivate();
        _isInitialized = true;
        return;
      } catch (error) {
        if (attempt == maxTries) {
          rethrow;
        }

        await Future.delayed(
            Duration(seconds: 2 * attempt)); //exponential backoff
      }
    }
  }

  Future<OnboardingRemoteConfig?> getOnboardingConfig() async {
    if (!_isInitialized) {
      await initialize();
    }

    return _parseOnboardingConfig();
  }

  OnboardingRemoteConfig? _parseOnboardingConfig() {
    try {
      final jsonString =
          _remoteConfig.getString(dotenv.get("REMOTE_CONFIG_KEY"));

      if (jsonString.isEmpty) {
        debugPrint('Remote Config key "onboarding" is empty or not found');
        return null;
      }

      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final config = OnboardingRemoteConfig.fromJson(jsonData);

      return config.onboardingConfig.active ? config : null;
    } catch (error) {
      debugPrint('Error parsing onboarding config: $error');
      return null;
    }
  }
}
