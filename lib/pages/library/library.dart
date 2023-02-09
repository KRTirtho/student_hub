import 'package:student_hub/components/library/book_card.dart';
import 'package:student_hub/components/scrolling/constrained_list_view.dart';
import 'package:student_hub/components/scrolling/waypoint.dart';
import 'package:student_hub/components/shared/root_app_bar.dart';
import 'package:student_hub/models/book.dart';
import 'package:student_hub/utils/crashlytics_query_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:student_hub/queries/books.dart';

class LibraryPage extends HookConsumerWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final controller = useScrollController();

    return CrashlyticsInfiniteQueryBuilder(
        job: booksInfiniteQueryJob,
        externalData: null,
        builder: (context, booksQuery) {
          final books = booksQuery.pages
              .expand<Book>((page) => page?.items ?? [])
              .toList();
          return Scaffold(
            appBar: RooAppBar(
              actions: [
                IconButton(
                  icon: const Icon(Icons.search_rounded),
                  onPressed: () {
                    GoRouter.of(context).push("/library/search");
                  },
                ),
                const AppNotificationButton(),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {
                    GoRouter.of(context).push("/settings");
                  },
                )
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => GoRouter.of(context).push("/library/new"),
              child: const Icon(Icons.menu_book_rounded),
            ),
            body: Waypoint(
              onTouchEdge: () {
                if (booksQuery.hasNextPage) booksQuery.fetchNextPage();
              },
              controller: controller,
              child: RefreshIndicator(
                onRefresh: () async {
                  await booksQuery.refetch();
                },
                child: ConstrainedListView.separated(
                  controller: controller,
                  constraints: const BoxConstraints(maxWidth: 600),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(8),
                  itemCount: books.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  separatorBuilder: (context, index) => const Gap(10),
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return BookCard(book: book);
                  },
                ),
              ),
            ),
          );
        });
  }
}
