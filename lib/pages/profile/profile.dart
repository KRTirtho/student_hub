import 'package:eusc_freaks/collections/pocketbase.dart';
import 'package:eusc_freaks/components/image/avatar.dart';
import 'package:eusc_freaks/components/library/book_card.dart';
import 'package:eusc_freaks/components/posts/post_card.dart';
import 'package:eusc_freaks/components/report/report_dialog.dart';
import 'package:eusc_freaks/components/scrolling/waypoint.dart';
import 'package:eusc_freaks/components/user/ban_dialog.dart';
import 'package:eusc_freaks/models/report.dart';
import 'package:eusc_freaks/pages/profile/master_user_sessions.dart';
import 'package:eusc_freaks/pages/profile/non_master_user_sessions.dart';
import 'package:eusc_freaks/providers/authentication_provider.dart';
import 'package:eusc_freaks/queries/books.dart';
import 'package:eusc_freaks/queries/posts.dart';
import 'package:eusc_freaks/queries/user.dart';
import 'package:eusc_freaks/utils/change_notifier_listenable_builder.dart';
import 'package:eusc_freaks/utils/snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_query_hooks/fl_query_hooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

class ProfilePage extends HookConsumerWidget {
  final String userId;
  const ProfilePage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final controller = useScrollController();
    final authUser = ref.watch(authenticationProvider);
    final userQuery = useQuery(
      job: userQueryJob(userId),
      externalData: authUser,
    );
    final mounted = useIsMounted();
    final isOwner =
        userId == "authenticated" || userQuery.data?.id == authUser?.id;

    Future<void> updateProfilePicture() async {
      final file = await FilePicker.platform.pickFiles(
          dialogTitle: "Select an profile picture",
          type: FileType.custom,
          allowedExtensions: ['jpg', 'png', 'jpeg'],
          withData: true);
      if (file == null || file.files.isEmpty) {
        return;
      }

      await pb.collection('users').update(
        userQuery.data!.id,
        files: [
          MultipartFile.fromBytes(
            'avatar',
            file.files.first.bytes!,
            filename: file.files.first.name,
            contentType: MediaType(
              'image',
              file.files.first.extension!,
            ),
          ),
        ],
      );
      await ref.read(authenticationProvider.notifier).refetch();
      if (mounted()) {
        showSnackbar(
          context,
          'Profile picture updated. Restart the app to see the changes',
        );
      }
    }

    return Scaffold(
      appBar: GoRouter.of(context).canPop()
          ? AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              actions: [
                PopupMenuButton(
                  onSelected: (value) {
                    switch (value) {
                      case 'report':
                        showDialog(
                          context: context,
                          builder: (context) {
                            return ReportDialog(
                              collection: ReportCollection.user,
                              recordId: userQuery.data!.id,
                            );
                          },
                        );
                        break;
                      case 'ban':
                        showDialog(
                          context: context,
                          builder: (context) {
                            return BanDialog(
                              user: userQuery.data!,
                            );
                          },
                        );
                        break;
                      default:
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem(
                        value: 'report',
                        child: ListTile(
                          leading: Icon(Icons.report),
                          title: Text('Report'),
                        ),
                      ),
                      if (userQuery.data?.isMaster != true &&
                          authUser?.isMaster == true)
                        const PopupMenuItem(
                          value: 'ban',
                          child: ListTile(
                            leading: Icon(Icons.block_outlined),
                            iconColor: Colors.deepOrange,
                            title: Text("Ban user"),
                          ),
                        )
                    ];
                  },
                ),
              ],
            )
          : null,
      extendBodyBehindAppBar: true,
      body: !userQuery.hasData
          ? const Center(child: CircularProgressIndicator())
          : HookBuilder(builder: (context) {
              final tabController = useTabController(initialLength: 2);

              final userPostsQuery = useInfiniteQuery(
                job: userPostsInfiniteQueryJob(userQuery.data!.id),
                externalData: null,
              );
              final userBooksQuery = useInfiniteQuery(
                job: userBooksInfiniteQueryJob(userQuery.data!.id),
                externalData: null,
              );
              final posts = userPostsQuery.pages
                  .map((page) => page?.items ?? [])
                  .expand((element) => element)
                  .toList();

              final books = userBooksQuery.pages
                  .map((page) => page?.items ?? [])
                  .expand((element) => element)
                  .toList();

              final avatarURL = userQuery.data!.getAvatarURL();
              return Waypoint(
                controller: controller,
                onTouchEdge: () {
                  if (userPostsQuery.hasNextPage) {
                    userPostsQuery.fetchNextPage();
                  }
                },
                child: RefreshIndicator(
                  onRefresh: userPostsQuery.refetchPages,
                  child: SingleChildScrollView(
                    controller: controller,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Column(
                          children: [
                            const Gap(50),
                            Stack(
                              children: [
                                Center(
                                  child: Avatar(
                                    user: userQuery.data!,
                                    radius: 50,
                                    tag: avatarURL,
                                    onTap: () {
                                      GoRouter.of(context).push(
                                        '/media/image',
                                        extra: [avatarURL],
                                      );
                                    },
                                  ),
                                ),
                                if (isOwner)
                                  Positioned.fill(
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                                Icons.image_outlined),
                                            color: Colors.black,
                                            style: IconButton.styleFrom(
                                              backgroundColor: Colors.white60,
                                            ),
                                            onPressed: updateProfilePicture,
                                          ),
                                          const Gap(5),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.delete_outline),
                                            color: Colors.red[400],
                                            style: IconButton.styleFrom(
                                              backgroundColor: Colors.white60,
                                            ),
                                            onPressed: () async {
                                              await pb
                                                  .collection('users')
                                                  .update(
                                                userQuery.data!.id,
                                                body: {
                                                  'avatar': null,
                                                },
                                              );
                                              await ref
                                                  .read(authenticationProvider
                                                      .notifier)
                                                  .refetch();
                                              if (mounted()) {
                                                showSnackbar(
                                                  context,
                                                  'Profile picture removed. Restart the app to see the changes',
                                                  backgroundColor:
                                                      Colors.red[400],
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const Gap(20),
                            if (userQuery.data!.name != null)
                              Center(
                                child: Text(
                                  userQuery.data!.name!,
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                            const Gap(70),
                            if (userQuery.data!.isBanned) ...[
                              Text(
                                'This user is banned for ${userQuery.data!.banReason.map((e) => e.formattedName).join(', ')} for ${userQuery.data!.bannedUntil!.difference(DateTime.now()).inDays} days',
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    ?.copyWith(
                                      color: Colors.red[400],
                                    ),
                              ),
                              const Gap(10),
                            ],
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.7),
                                  width: 1.5,
                                ),
                              ),
                              elevation: 0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    title: const Text('Email'),
                                    subtitle: Text(userQuery.data!.email),
                                  ),
                                  ListTile(
                                    title: const Text('Username'),
                                    subtitle: Text(userQuery.data!.username),
                                  ),
                                  if (!userQuery.data!.isMaster)
                                    NonMasterUserSessions(userQuery.data!)
                                  else
                                    MasterUserSessions(userQuery.data!),
                                ],
                              ),
                            ),
                            const Gap(10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: TabBar(
                                  controller: tabController,
                                  isScrollable: true,
                                  tabs: const [
                                    Tab(text: "Posts"),
                                    Tab(text: "Books"),
                                  ],
                                ),
                              ),
                            ),
                            const Gap(10),
                            ChangeNotifierListenableBuilder(
                              notifier: tabController,
                              builder: (context, tabController) {
                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  transitionBuilder: (Widget child,
                                      Animation<double> animation) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(1, 0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: [
                                    ListView.separated(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: posts.length,
                                      separatorBuilder: (context, index) =>
                                          const Gap(10),
                                      itemBuilder: (context, index) {
                                        return PostCard(post: posts[index]);
                                      },
                                    ),
                                    ListView.separated(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: books.length,
                                      separatorBuilder: (context, index) =>
                                          const Gap(10),
                                      itemBuilder: (context, index) {
                                        return BookCard(book: books[index]);
                                      },
                                    ),
                                  ][tabController.index],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
    );
  }
}
