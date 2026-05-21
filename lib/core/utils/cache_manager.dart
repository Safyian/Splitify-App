// lib/core/utils/cache_manager.dart

class CacheManager {
  // Singleton — one instance shared across the whole app
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  // Stores when each key was last fetched
  final Map<String, DateTime> _timestamps = {};

  /// Is this data still fresh? (fetched within the TTL window)
  bool isFresh(String key, {Duration ttl = const Duration(minutes: 5)}) {
    final last = _timestamps[key];
    if (last == null) return false; // never fetched
    return DateTime.now().difference(last) < ttl;
  }

  /// Mark this key as just fetched right now
  void markFetched(String key) {
    _timestamps[key] = DateTime.now();
  }

  /// Force next fetch to hit the network for this key
  void invalidate(String key) {
    _timestamps.remove(key);
  }

  /// Invalidate multiple keys at once
  void invalidateAll(List<String> keys) {
    for (final key in keys) {
      _timestamps.remove(key);
    }
  }

  /// Wipe everything — call on logout
  void clear() {
    _timestamps.clear();
  }
}

/// All cache key names in one place — avoids typos
class CacheKeys {
  static const String summaries = 'groups_summaries';
  static const String friends = 'friends';
  static const String activity = 'activity';
  static const Duration groupExpensesTTL = Duration(seconds: 120);

  // Per-group keys — unique per group ID
  static String groupExpenses(String id) => 'expenses_$id';
  static String groupMembers(String id) => 'members_$id';
  static String groupBalances(String id) => 'balances_$id';
}
