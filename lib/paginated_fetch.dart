/// Number of rows requested per page from the Supabase REST API.
///
/// Must not exceed the API `max_rows` setting (1000 by default), otherwise a
/// capped page would look like the last one and history would be truncated.
const supabasePageSize = 1000;

/// Fetches every row by requesting consecutive inclusive `[from, to]` ranges
/// until a page comes back shorter than [pageSize].
///
/// The query behind [fetchPage] must use a stable, unique ordering so pages
/// neither overlap nor skip rows.
Future<List<T>> fetchAllPages<T>(
  Future<List<T>> Function(int from, int to) fetchPage, {
  int pageSize = supabasePageSize,
}) async {
  if (pageSize <= 0) {
    throw ArgumentError.value(pageSize, 'pageSize', 'must be positive');
  }

  final rows = <T>[];
  while (true) {
    final from = rows.length;
    final page = await fetchPage(from, from + pageSize - 1);
    rows.addAll(page);
    if (page.length < pageSize) return rows;
  }
}
