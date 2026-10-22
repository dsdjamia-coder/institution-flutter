import 'package:shared_preferences/shared_preferences.dart';

class NavigationPreferencesService {
  static final Map<String, List<String>> _memoryCache = {};

  static const String _prefix = 'custom_pinned_tabs_';

  /// Fetch pinned tab IDs for a portal on this device
  static Future<List<String>> getPinnedTabs(
    String portalId,
    List<String> defaultTabs,
  ) async {
    if (_memoryCache.containsKey(portalId) && _memoryCache[portalId]!.isNotEmpty) {
      return _memoryCache[portalId]!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('$_prefix$portalId');
      if (saved != null && saved.isNotEmpty) {
        _memoryCache[portalId] = saved;
        return saved;
      }
    } catch (_) {
      // Graceful fallback to default/memory
    }

    _memoryCache[portalId] = List.from(defaultTabs);
    return defaultTabs;
  }

  /// Save up to 4 custom pinned tab IDs for this device
  static Future<bool> setPinnedTabs(
    String portalId,
    List<String> tabIds,
  ) async {
    // Enforce max 4 tabs
    final toSave = tabIds.take(4).toList();
    _memoryCache[portalId] = toSave;

    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setStringList('$_prefix$portalId', toSave);
    } catch (_) {
      return false;
    }
  }
}
