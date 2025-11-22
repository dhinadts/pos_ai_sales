import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsServiceProvider = Provider<SettingsService>(
  (ref) => SettingsService(),
);

class SettingsService {
  Future<void> init() async {}

  Future<void> onTapped() async {}
}
