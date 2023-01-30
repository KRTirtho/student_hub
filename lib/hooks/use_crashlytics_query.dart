import 'package:catcher/catcher.dart';
import 'package:fl_query/fl_query.dart';
import 'package:fl_query_hooks/fl_query_hooks.dart';

Query<T, Outside> useCrashlyticsQuery<T extends Object, Outside>({
  required QueryJob<T, Outside> job,
  required Outside externalData,
  QueryListener<T>? onData,
  QueryListener<dynamic>? onError,
  List<Object?>? keys,
}) {
  return useQuery<T, Outside>(
    job: job,
    externalData: externalData,
    onData: onData,
    onError: (error) {
      Catcher.reportCheckedError(error, StackTrace.current);
      onError?.call(error);
    },
    keys: keys,
  );
}

InfiniteQuery<T, Outside, PageParam> useCrashlyticsInfiniteQuery<
    T extends Object, Outside, PageParam extends Object>({
  required InfiniteQueryJob<T, Outside, PageParam> job,
  required Outside externalData,

  /// Called when the query returns new data, on query
  /// refetch or query gets expired
  final InfiniteQueryListeners<T, PageParam>? onData,

  /// Called when the query returns error
  final InfiniteQueryListeners<dynamic, PageParam>? onError,
  List<Object?>? keys,
}) {
  return useInfiniteQuery<T, Outside, PageParam>(
    job: job,
    externalData: externalData,
    onData: onData,
    onError: (error, pageParam, pages) {
      Catcher.reportCheckedError(error, StackTrace.current);
      onError?.call(error, pageParam, pages);
    },
    keys: keys,
  );
}
