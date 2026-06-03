import 'package:shared_preferences/shared_preferences.dart';

class PinService {
  static const String _pinnedIdsKey = 'pinned_ids';

  static Future<Set<String>> loadPinnedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return Set<String>.from(prefs.getStringList(_pinnedIdsKey) ?? []);
  }

  static Future<void> savePinnedIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_pinnedIdsKey, ids.toList());
  }

  static Future<bool> isPinned(String id) async {
    final ids = await loadPinnedIds();
    return ids.contains(id);
  }

  static Future<void> setPinned(String id, bool pinned) async {
    final ids = await loadPinnedIds();
    if (pinned) {
      ids.add(id);
    } else {
      ids.remove(id);
    }
    await savePinnedIds(ids);
  }

  static Future<bool> togglePinned(String id) async {
    final ids = await loadPinnedIds();
    if (ids.contains(id)) {
      ids.remove(id);
      await savePinnedIds(ids);
      return false;
    }
    ids.add(id);
    await savePinnedIds(ids);
    return true;
  }
}
