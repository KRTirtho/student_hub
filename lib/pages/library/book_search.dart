import 'package:eusc_freaks/collections/pocketbase.dart';
import 'package:eusc_freaks/components/library/book_card.dart';
import 'package:eusc_freaks/components/scrolling/constrained_list_view.dart';
import 'package:eusc_freaks/hooks/use_debounce.dart';
import 'package:eusc_freaks/models/book.dart';
import 'package:eusc_freaks/models/book_tags.dart';
import 'package:eusc_freaks/queries/books.dart';
import 'package:fl_query_hooks/fl_query_hooks.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:collection/collection.dart';

class BookSearchPage extends HookConsumerWidget {
  final List<BookTag>? initialTags;
  const BookSearchPage({
    Key? key,
    this.initialTags,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final controller = useScrollController();

    final isSearch = useState(false);

    final selectedTags = useState<List<BookTag>>(initialTags ?? <BookTag>[]);
    final searchText = useState<String>("");

    final selectedDebouncedTags = useDebounce(selectedTags.value, 500);
    final searchTextDebounced = useDebounce(searchText.value, 500);

    final books = useState<List<Book>>([]);

    final tagsQuery = useQuery(job: bookTagsQueryJob, externalData: null);

    useEffect(() {
      if (isSearch.value) return null;
      if (selectedDebouncedTags.isEmpty) {
        books.value = [];
        return null;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        books.value = await pb
            .collection("books")
            .getFullList(
              filter: selectedDebouncedTags
                  .map((e) => "tags ~ '${e.id}'")
                  .toList()
                  .join(" || "),
              expand: "user,tags",
              sort: "-created",
            )
            .then(
              (value) => value.map((e) => Book.fromRecord(e)),
            )
            .then(
              (value) => value
                  .sortedBy<num>(
                    (e) => e.tags
                        .where(
                          (element) => selectedDebouncedTags
                              .map((e) => e.id)
                              .contains(element.id),
                        )
                        .length,
                  )
                  .reversed
                  .toList(),
            );
      });
      return null;
    }, [selectedDebouncedTags, isSearch]);

    useEffect(() {
      if (!isSearch.value) return null;
      if (searchTextDebounced.isEmpty && isSearch.value) {
        books.value = [];
        return null;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        books.value = await pb
            .collection("books")
            .getFullList(
              filter:
                  "title ~ '$searchTextDebounced' || author ~ '$searchTextDebounced' || bio ~ '$searchTextDebounced' || tags.tag ~ '$searchTextDebounced' || user.name ~ '$searchTextDebounced'",
              expand: "user,tags",
              sort: "-created",
            )
            .then(
              (value) => value.map((e) => Book.fromRecord(e)).toList(),
            );
      });
      return null;
    }, [searchTextDebounced, isSearch]);

    final sortedTags = tagsQuery.data
            ?.map((e) => MultiSelectItem<BookTag?>(e, e.tag))
            .sortedBy((e) => e.value!.tag) ??
        [];
    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: const Offset(0, 0),
            ).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
          child: isSearch.value
              ? ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: TextField(
                    key: const Key("search"),
                    onChanged: (value) {
                      searchText.value = value;
                    },
                    decoration: const InputDecoration(
                      hintText: "Search...",
                      border: UnderlineInputBorder(),
                      enabledBorder: UnderlineInputBorder(),
                    ),
                  ),
                )
              : const Text(
                  key: Key("title"),
                  "Search Books",
                ),
        ),
        actions: [
          IconButton(
            icon: isSearch.value
                ? const Icon(Icons.close)
                : const Icon(Icons.search),
            onPressed: () {
              isSearch.value = !isSearch.value;
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(isSearch.value ? 0 : 50),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isSearch.value
                ? const SizedBox.shrink(key: Key("search"))
                : !tagsQuery.hasData
                    ? const Center(
                        key: Key("loading"),
                        child: CircularProgressIndicator(),
                      )
                    : ScrollConfiguration(
                        key: const Key("tags"),
                        behavior: const ScrollBehavior().copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                          },
                        ),
                        child: MultiSelectChipField(
                          showHeader: false,
                          onTap: (tags) {
                            selectedTags.value =
                                tags.whereType<BookTag>().toList();
                          },
                          initialValue: selectedTags.value,
                          decoration: const BoxDecoration(),
                          chipShape: const StadiumBorder(),
                          chipColor: Theme.of(context).cardColor,
                          selectedChipColor: Theme.of(context).primaryColor,
                          textStyle: Theme.of(context).textTheme.bodyMedium,
                          icon: Icon(
                            Icons.check,
                            color: Theme.of(context).cardColor,
                          ),
                          selectedTextStyle: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(color: Theme.of(context).cardColor),
                          items: selectedTags.value.length == 1 &&
                                  initialTags != null &&
                                  selectedTags.value == initialTags
                              ? sortedTags.sortedBy<num>(
                                  (e) => selectedTags.value.contains(e.value)
                                      ? -1
                                      : 1,
                                )
                              : sortedTags,
                        ),
                      ),
          ),
        ),
      ),
      body: ConstrainedListView.separated(
        constraints: const BoxConstraints(maxWidth: 600),
        alignment: Alignment.center,
        controller: controller,
        padding: const EdgeInsets.all(8),
        itemCount: books.value.length,
        physics: const AlwaysScrollableScrollPhysics(),
        separatorBuilder: (context, index) => const Gap(10),
        itemBuilder: (context, index) {
          final book = books.value[index];
          return BookCard(book: book);
        },
      ),
    );
  }
}
