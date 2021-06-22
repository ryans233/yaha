import 'package:flutter/foundation.dart';
import 'package:yaha/db/table/app_settings_table.dart';
import 'package:yaha/repo/preferences_repository.dart';

class AppSettingsModel with ChangeNotifier {
  AppSettingsModel() {
    refreshAppSettings();
  }

  PreferencesRepository prefRepo = PreferencesRepository.instance;
  AppSettings settings = AppSettings();

  get amountStoriesPerLoad => settings.amountStoriesPerLoad;

  set amountStoriesPerLoad(int value) =>
      setSettings(AppSettings.columnAmountStoriesPerLoad, value);

  setSettings(String key, dynamic value) {
    prefRepo.set(key, value).then((_) => refreshAppSettings());
  }

  refreshAppSettings() async {
    settings = await prefRepo.getSettings();
    notifyListeners();
  }
}
