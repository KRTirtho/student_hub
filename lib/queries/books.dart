import 'package:student_hub/collections/pocketbase.dart';
import 'package:student_hub/models/book.dart';
import 'package:student_hub/models/book_tags.dart';
import 'package:fl_query/fl_query.dart';
import 'package:pocketbase/pocketbase.dart';

final booksInfiniteQueryJob = InfiniteQueryJob<ResultList<Book>, void, int>(
  queryKey: "books-query",
  initialParam: 1,
  getNextPageParam: (lastPage, pages) =>
      lastPage.items.length < lastPage.perPage ? null : lastPage.page + 1,
  getPreviousPageParam: (firstPage, pages) => firstPage.page - 1,
  task: (queryKey, pageParam, externalData) async {
    final res = await pb.collection("books").getList(
          expand: "user,tags",
          page: pageParam,
          sort: "-created",
          perPage: 5,
        );

    return ResultList(
      items: res.items.map((r) => Book.fromRecord(r)).toList(),
      page: res.page,
      perPage: res.perPage,
      totalItems: res.totalItems,
      totalPages: res.totalPages,
    );
  },
);

final userBooksInfiniteQueryJob =
    InfiniteQueryJob.withVariableKey<ResultList<Book>, void, int>(
  preQueryKey: "user-books-query",
  initialParam: 1,
  getNextPageParam: (lastPage, pages) =>
      lastPage.items.length < lastPage.perPage ? null : lastPage.page + 1,
  getPreviousPageParam: (firstPage, pages) => firstPage.page - 1,
  task: (queryKey, pageParam, externalData) async {
    final res = await pb.collection("books").getList(
          filter: "user = '${getVariable(queryKey)}'",
          expand: "user,tags",
          page: pageParam,
          sort: "-created",
          perPage: 5,
        );

    return ResultList(
      items: res.items.map((r) => Book.fromRecord(r)).toList(),
      page: res.page,
      perPage: res.perPage,
      totalItems: res.totalItems,
      totalPages: res.totalPages,
    );
  },
);

final bookTagsQueryJob = QueryJob<List<BookTag>, void>(
  queryKey: "book-tags-query",
  refetchOnMount: true,
  task: (queryKey, externalData) async {
    final res = await pb.collection("book_tags").getFullList(sort: "-created");

    return res.map((r) => BookTag.fromRecord(r)).toList();
  },
);
