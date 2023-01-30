import 'package:catcher/catcher.dart';
import 'package:fl_query/fl_query.dart';

class CrashlyticsQueryBuilder<T extends Object, Outside>
    extends QueryBuilder<T, Outside> {
  CrashlyticsQueryBuilder({
    super.key,
    required super.job,
    required super.externalData,
    required super.builder,
    super.onData,
    final QueryListener<dynamic>? onError,
  }) : super(
          onError: (error) {
            Catcher.reportCheckedError(error, StackTrace.current);
            onError?.call(error);
          },
        );
}

class CrashlyticsInfiniteQueryBuilder<T extends Object, Outside,
        PageParam extends Object>
    extends InfiniteQueryBuilder<T, Outside, PageParam> {
  CrashlyticsInfiniteQueryBuilder({
    super.key,
    required super.job,
    required super.externalData,
    required super.builder,
    super.onData,
    final InfiniteQueryListeners<dynamic, PageParam>? onError,
  }) : super(
          onError: (error, pageParam, pages) {
            Catcher.reportCheckedError(error, StackTrace.current);
            onError?.call(error, pageParam, pages);
          },
        );
}
