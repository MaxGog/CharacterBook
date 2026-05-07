import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class AutoBackupProvider extends ChangeNotifier {
  final Box<bool> box;
  bool _isEnabled;

  AutoBackupProvider(this.box)
      : _isEnabled = box.get('auto_cloud_backup', defaultValue: false) ?? false;

  bool get isEnabled => _isEnabled;

  void setEnabled(bool value) {
    if (_isEnabled == value) return;
    _isEnabled = value;
    box.put('auto_cloud_backup', value);
    notifyListeners();
  }
}
