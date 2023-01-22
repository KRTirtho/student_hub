import 'package:collection/collection.dart';
import 'package:eusc_freaks/collections/pocketbase.dart';
import 'package:eusc_freaks/components/posts/post_card.dart';
import 'package:eusc_freaks/components/scrolling/constrained_list_view.dart';
import 'package:eusc_freaks/components/scrolling/waypoint.dart';
import 'package:eusc_freaks/components/user/user_card.dart';
import 'package:eusc_freaks/hooks/use_debounce.dart';
import 'package:eusc_freaks/models/post.dart';
import 'package:eusc_freaks/models/user.dart';
import 'package:eusc_freaks/utils/change_notifier_listenable_builder.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

class PostSearchPage extends HookConsumerWidget {
  const PostSearchPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final controller = useScrollController();
    final searchController = useTextEditingController();

    final tabController = useTabController(initialLength: 2);

    final searchText = useState<String>("");

    final searchTextDebounced = useDebounce(searchText.value, 500);

    return Scaffold(
      appBar: AppBar(
        actions: const [Gap(16)],
        title: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: TextField(
            onChanged: (value) {
              searchText.value = value;
            },
            controller: searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Search Posts...",
              prefixIcon: Icon(Icons.search),
              border: UnderlineInputBorder(),
              enabledBorder: UnderlineInputBorder(),
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: ScrollConfiguration(
            key: const Key("tags"),
            behavior: const ScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              },
            ),
            child: ChangeNotifierListenableBuilder(
                notifier: tabController,
                builder: (context, _) {
                  return Row(
                    children: ["Posts", "Users"]
                        .mapIndexed(
                          (i, e) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ChoiceChip(
                              label: Text(e),
                              selected: tabController.index == i,
                              shape: const StadiumBorder(),
                              labelStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: tabController.index == i
                                        ? Theme.of(context).backgroundColor
                                        : null,
                                  ),
                              onSelected: (value) {
                                if (value) {
                                  tabController.index = i;
                                }
                              },
                            ),
                          ),
                        )
                        .toList(),
                  );
                }),
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          HookBuilder(builder: (context) {
            final postResults = useState<List<ResultList<Post>>>([]);

            final currentPage = useState(1);

            useEffect(() {
              if (searchTextDebounced.isEmpty) {
                postResults.value = [];
                return null;
              }
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                postResults.value = [
                  ...postResults.value,
                  await pb
                      .collection("posts")
                      .getList(
                        filter:
                            "title ~ '$searchTextDebounced' || description ~ '$searchTextDebounced' || user.name ~ '$searchTextDebounced'",
                        expand: "user",
                        page: currentPage.value,
                        sort: "-created",
                        perPage: 10,
                      )
                      .then(
                        (value) => ResultList<Post>(
                          items: value.items
                              .map((e) => Post.fromRecord(e))
                              .toList(),
                          page: value.page,
                          perPage: value.perPage,
                          totalItems: value.totalItems,
                          totalPages: value.totalPages,
                        ),
                      )
                ];
              });
              return null;
            }, [searchTextDebounced, currentPage.value]);

            final posts =
                postResults.value.expand((element) => element.items).toList();

            return Waypoint(
              controller: controller,
              onTouchEdge: () {
                if (postResults.value.isEmpty ||
                    currentPage.value >= postResults.value.last.totalPages ||
                    postResults.value.last.items.length <
                        postResults.value.last.perPage) return;
                currentPage.value = postResults.value.last.page + 1;
              },
              child: ConstrainedListView.separated(
                controller: controller,
                constraints: const BoxConstraints(maxWidth: 600),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                itemCount: posts.length,
                physics: const AlwaysScrollableScrollPhysics(),
                separatorBuilder: (context, index) => const Gap(10),
                itemBuilder: (context, index) {
                  return PostCard(post: posts[index]);
                },
              ),
            );
          }),
          HookBuilder(builder: (context) {
            final userResults = useState<List<ResultList<User>>>([]);

            final currentPage = useState(1);

            useEffect(() {
              if (searchTextDebounced.isEmpty) {
                userResults.value = [];
                return null;
              }
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                userResults.value = [
                  ...userResults.value,
                  await pb
                      .collection("users")
                      .getList(
                        filter:
                            "name ~ '$searchTextDebounced' || username ~ '$searchTextDebounced' || sessions ~ '$searchTextDebounced'",
                        page: currentPage.value,
                        sort: "@random",
                        perPage: 10,
                      )
                      .then(
                        (value) => ResultList<User>(
                          items: value.items
                              .map((e) => User.fromRecord(e))
                              .toList(),
                          page: value.page,
                          perPage: value.perPage,
                          totalItems: value.totalItems,
                          totalPages: value.totalPages,
                        ),
                      )
                ];
              });
              return null;
            }, [searchTextDebounced, currentPage.value]);

            final users =
                userResults.value.expand((element) => element.items).toList();
            return Align(
              alignment: Alignment.topCenter,
              child: Waypoint(
                controller: controller,
                onTouchEdge: () {
                  if (userResults.value.isEmpty ||
                      currentPage.value >= userResults.value.last.totalPages ||
                      userResults.value.last.items.length <
                          userResults.value.last.perPage) return;
                  currentPage.value = userResults.value.last.page + 1;
                },
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: users.map((e) => UserCard(user: e)).toList(),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
