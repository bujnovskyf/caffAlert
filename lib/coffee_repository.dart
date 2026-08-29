import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/coffee_log.dart';
import 'models/profile.dart';

abstract interface class CoffeeDataSource {
  Future<List<CoffeeLog>> fetchLogs(String userId);
  Future<Profile?> fetchProfile(String userId);
  Future<void> saveDisplayName(String userId, String? displayName);
  Future<CoffeeLog> addCoffee(String userId, DateTime createdAt);
  Future<CoffeeLog> updateCoffeeTime(int coffeeId, DateTime createdAt);
  Future<CoffeeLog?> deleteCoffee(int coffeeId);
  Future<CoffeeLog?> deleteLatestCoffee();
  void subscribeToLogs(String userId, Future<void> Function() onChange);
  Future<void> dispose();
}

class CoffeeRepository implements CoffeeDataSource {
  CoffeeRepository(this._client);

  final SupabaseClient _client;
  RealtimeChannel? _channel;

  @override
  Future<List<CoffeeLog>> fetchLogs(String userId) async {
    final response = await _client
        .from('coffee_logs')
        .select('id, user_id, created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .order('id', ascending: false);

    return (response as List<dynamic>)
        .map(
          (row) => CoffeeLog.fromJson(
            Map<String, dynamic>.from(row as Map<dynamic, dynamic>),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<Profile?> fetchProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select('id, display_name')
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return Profile.fromJson(response);
  }

  @override
  Future<void> saveDisplayName(String userId, String? displayName) async {
    await _client.from('profiles').upsert({
      'id': userId,
      'display_name': displayName,
    });
  }

  @override
  Future<CoffeeLog> addCoffee(String userId, DateTime createdAt) async {
    final response = await _client
        .from('coffee_logs')
        .insert({
          'user_id': userId,
          'created_at': createdAt.toUtc().toIso8601String(),
        })
        .select('id, user_id, created_at')
        .single();

    return CoffeeLog.fromJson(response);
  }

  @override
  Future<CoffeeLog> updateCoffeeTime(int coffeeId, DateTime createdAt) async {
    final response = await _client
        .from('coffee_logs')
        .update({'created_at': createdAt.toUtc().toIso8601String()})
        .eq('id', coffeeId)
        .select('id, user_id, created_at')
        .single();

    return CoffeeLog.fromJson(response);
  }

  @override
  Future<CoffeeLog?> deleteCoffee(int coffeeId) async {
    final response = await _client
        .from('coffee_logs')
        .delete()
        .eq('id', coffeeId)
        .select('id, user_id, created_at');
    final rows = response as List<dynamic>;
    if (rows.isEmpty) return null;
    return CoffeeLog.fromJson(
      Map<String, dynamic>.from(rows.first as Map<dynamic, dynamic>),
    );
  }

  @override
  Future<CoffeeLog?> deleteLatestCoffee() async {
    final response = await _client.rpc('delete_latest_coffee');
    final rows = response as List<dynamic>;
    if (rows.isEmpty) return null;
    return CoffeeLog.fromJson(
      Map<String, dynamic>.from(rows.first as Map<dynamic, dynamic>),
    );
  }

  @override
  void subscribeToLogs(
    String userId,
    Future<void> Function() onChange,
  ) {
    _channel = _client
        .channel('coffee_logs:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'coffee_logs',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (_, [__]) => onChange(),
        )
        .subscribe();
  }

  @override
  Future<void> dispose() async {
    final channel = _channel;
    if (channel != null) await _client.removeChannel(channel);
    _channel = null;
  }
}
