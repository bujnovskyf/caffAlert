import 'package:caff_alert/coffee_repository.dart';
import 'package:caff_alert/coffee_stats_provider.dart';
import 'package:caff_alert/models/coffee_log.dart';
import 'package:caff_alert/models/profile.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCoffeeDataSource implements CoffeeDataSource {
  _FakeCoffeeDataSource({List<CoffeeLog>? logs}) : logs = logs ?? [];

  final List<CoffeeLog> logs;
  Profile? profile;
  Future<void> Function()? onChange;

  @override
  Future<CoffeeLog> addCoffee(String userId, DateTime createdAt) async {
    final log = CoffeeLog(
      id: logs.length + 1,
      userId: userId,
      createdAt: createdAt,
    );
    logs.insert(0, log);
    return log;
  }

  @override
  Future<CoffeeLog> updateCoffeeTime(int coffeeId, DateTime createdAt) async {
    final index = logs.indexWhere((log) => log.id == coffeeId);
    final updated = CoffeeLog(
      id: logs[index].id,
      userId: logs[index].userId,
      createdAt: createdAt,
    );
    logs[index] = updated;
    return updated;
  }

  @override
  Future<CoffeeLog?> deleteCoffee(int coffeeId) async {
    final index = logs.indexWhere((log) => log.id == coffeeId);
    if (index == -1) return null;
    return logs.removeAt(index);
  }

  @override
  Future<CoffeeLog?> deleteLatestCoffee() async {
    return logs.isEmpty ? null : logs.removeAt(0);
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<List<CoffeeLog>> fetchLogs(String userId) async => List.of(logs);

  @override
  Future<Profile?> fetchProfile(String userId) async => profile;

  @override
  Future<void> saveDisplayName(String userId, String? displayName) async {
    profile = Profile(id: userId, displayName: displayName);
  }

  @override
  void subscribeToLogs(String userId, Future<void> Function() onChange) {
    this.onChange = onChange;
  }
}

void main() {
  test('adds and removes coffee while keeping one source of truth', () async {
    final now = DateTime.utc(2026, 8, 28, 10);
    final source = _FakeCoffeeDataSource();
    final provider = CoffeeStatsProvider(
      userId: 'user-1',
      repository: source,
      now: () => now,
    );
    addTearDown(provider.dispose);

    await provider.refresh();
    expect(provider.isReady, isTrue);

    expect(await provider.addCoffee(), isTrue);
    expect(provider.logs, hasLength(1));
    expect(provider.remaining, const Duration(hours: 4));

    expect(await provider.removeLatestCoffee(), isTrue);
    expect(provider.logs, isEmpty);
    expect(provider.isReady, isTrue);
  });

  test('saves optional display name', () async {
    final source = _FakeCoffeeDataSource();
    final provider = CoffeeStatsProvider(
      userId: 'user-1',
      repository: source,
      now: () => DateTime.utc(2026, 8, 28),
    );
    addTearDown(provider.dispose);

    expect(await provider.saveDisplayName('  Ada  '), isTrue);
    expect(provider.profile?.displayName, 'Ada');

    expect(await provider.saveDisplayName('   '), isTrue);
    expect(provider.profile?.displayName, isNull);
  });

  test('corrects every coffee from the last 24 hours', () async {
    final now = DateTime.utc(2026, 8, 28, 10);
    final source = _FakeCoffeeDataSource(
      logs: [
        CoffeeLog(
          id: 1,
          userId: 'user-1',
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
        CoffeeLog(
          id: 2,
          userId: 'user-1',
          createdAt: now.subtract(const Duration(hours: 10)),
        ),
        CoffeeLog(
          id: 3,
          userId: 'user-1',
          createdAt: now.subtract(const Duration(hours: 25)),
        ),
      ],
    );
    final provider = CoffeeStatsProvider(
      userId: 'user-1',
      repository: source,
      now: () => now,
    );
    addTearDown(provider.dispose);
    await provider.refresh();

    expect(provider.editableCoffees.map((coffee) => coffee.id), [1, 2]);
    final editableCoffee = provider.editableCoffees.last;
    expect(
      await provider.updateCoffeeTime(
        editableCoffee,
        now.subtract(const Duration(hours: 3)),
      ),
      isTrue,
    );
    expect(source.logs[1].createdAt, now.subtract(const Duration(hours: 3)));
    expect(await provider.removeCoffee(editableCoffee), isTrue);
    expect(source.logs.map((coffee) => coffee.id), isNot(contains(2)));
    expect(
      await provider.updateCoffeeTime(
        source.logs.last,
        now.subtract(const Duration(hours: 25)),
      ),
      isFalse,
    );
  });
}
