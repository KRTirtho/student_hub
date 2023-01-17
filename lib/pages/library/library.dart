import 'package:eusc_freaks/components/library/book_card.dart';
import 'package:eusc_freaks/components/scrolling/waypoint.dart';
import 'package:eusc_freaks/components/shared/root_app_bar.dart';
import 'package:eusc_freaks/models/book.dart';
import 'package:fl_query_hooks/fl_query_hooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:eusc_freaks/queries/books.dart';

class LibraryPage extends HookConsumerWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final controller = useScrollController();
    final booksQuery = useInfiniteQuery(
      job: booksInfiniteQueryJob,
      externalData: null,
    );

    final books =
        booksQuery.pages.expand<Book>((page) => page?.items ?? []).toList();

    return Scaffold(
      appBar: RooAppBar(),
      body: Waypoint(
        onTouchEdge: () {
          if (booksQuery.hasNextPage) booksQuery.fetchNextPage();
        },
        controller: controller,
        child: ListView.builder(
          controller: controller,
          padding: const EdgeInsets.all(8),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return BookCard(book: book);
          },
        ),
      ),
    );
  }
}
