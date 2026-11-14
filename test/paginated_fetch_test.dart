import 'package:caff_alert/paginated_fetch.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<List<int>> Function(int from, int to) pagedSource(
    List<int> rows,
    List<(int, int)> requests,
  ) {
    return (from, to) async {
      requests.add((from, to));
      if (from >= rows.length) return const [];
      final end = to + 1 > rows.length ? rows.length : to + 1;
      return rows.sublist(from, end);
    };
  }

  test('reads past the page size until the source is exhausted', () async {
    final rows = List.generate(2500, (index) => index);
    final requests = <(int, int)>[];

    final result = await fetchAllPages(pagedSource(rows, requests));

    expect(result, rows);
    expect(requests, [(0, 999), (1000, 1999), (2000, 2999)]);
  });

  test('stops after one request when the first page is short', () async {
    final requests = <(int, int)>[];

    final result = await fetchAllPages(
      pagedSource([1, 2, 3], requests),
      pageSize: 5,
    );

    expect(result, [1, 2, 3]);
    expect(requests, [(0, 4)]);
  });

  test('asks for one more page when rows fill pages exactly', () async {
    final requests = <(int, int)>[];

    final result = await fetchAllPages(
      pagedSource(List.generate(6, (index) => index), requests),
      pageSize: 3,
    );

    expect(result, hasLength(6));
    expect(requests, [(0, 2), (3, 5), (6, 8)]);
  });

  test('returns an empty list for an empty source', () async {
    final requests = <(int, int)>[];

    final result = await fetchAllPages(pagedSource([], requests));

    expect(result, isEmpty);
    expect(requests, [(0, 999)]);
  });

  test('rejects a non-positive page size', () {
    expect(
      () => fetchAllPages((from, to) async => <int>[], pageSize: 0),
      throwsArgumentError,
    );
  });
}
