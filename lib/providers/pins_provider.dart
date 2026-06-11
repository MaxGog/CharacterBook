import 'package:flutter/material.dart';
import 'package:characterbook/services/pin_service.dart';

class PinsProvider extends ChangeNotifier {
  Set<String> _pinnedIds = {};

  Set<String> get pinnedIds => _pinnedIds;

  PinsProvider() {
    _loadPins();
  }

  Future<void> _loadPins() async {
    _pinnedIds = await PinService.loadPinnedIds();
    notifyListeners();
  }

  Future<void> togglePin(String id) async {
    final newPinned = await PinService.togglePinned(id);
    if (newPinned) {
      _pinnedIds.add(id);
    } else {
      _pinnedIds.remove(id);
    }
    notifyListeners();
  }

  Future<void> setPinned(String id, bool pinned) async {
    await PinService.setPinned(id, pinned);
    if (pinned) {
      _pinnedIds.add(id);
    } else {
      _pinnedIds.remove(id);
    }
    notifyListeners();
  }

  bool isPinned(String id) => _pinnedIds.contains(id);
}
