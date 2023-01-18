import 'package:auto_size_text/auto_size_text.dart';
import 'package:eusc_freaks/components/image/avatar.dart';
import 'package:eusc_freaks/components/image/universal_image.dart';
import 'package:eusc_freaks/models/book.dart';
import 'package:eusc_freaks/providers/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:readmore/readmore.dart';
import 'package:timeago/timeago.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BookCard extends HookConsumerWidget {
  final Book book;
  const BookCard({
    Key? key,
    required this.book,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final mediaUrl = book.getMediaURL().toString();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AutoSizeText(
                    book.title,
                    maxLines: 2,
                    minFontSize: 14,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Gap(10),
                Text(
                  format(
                    DateTime.parse(book.created),
                  ),
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
            const Gap(5),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Writen by ",
                    style: Theme.of(context).textTheme.caption?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  TextSpan(
                    text: book.author,
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        ?.copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const Gap(20),
            if (book.bio?.isNotEmpty == true) ...[
              ReadMoreText(
                "${book.bio!} ",
                trimLines: 3,
                trimMode: TrimMode.Line,
                trimCollapsedText: 'Show more',
                trimExpandedText: 'Show less',
                moreStyle: Theme.of(context).textTheme.caption,
                lessStyle: Theme.of(context).textTheme.caption,
              ),
              const Gap(20),
            ],
            SizedBox(
              height: 400,
              width: double.infinity,
              child: InkWell(
                onTap: () {
                  GoRouter.of(context).push('/media/pdf', extra: mediaUrl);
                },
                child: UniversalImage(
                  path: book.getThumbnailURL(const Size(0, 400)).toString(),
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
            const Gap(20),
            if (book.externalUrl != null)
              Wrap(
                spacing: 3,
                children: [
                  Text(
                    "Was originally published at:",
                    style: Theme.of(context).textTheme.caption?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  InkWell(
                    onTap: () => launchUrlString(
                      book.externalUrl!,
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Text(
                      book.externalUrl!,
                      style: Theme.of(context).textTheme.caption?.copyWith(
                            color: Colors.blue,
                          ),
                    ),
                  ),
                ],
              ),
            const Gap(10),
            Text(
              "Uploaded by ",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Gap(5),
            Row(
              children: [
                Avatar(user: book.user, radius: 12),
                const Gap(5),
                Flexible(
                  child: InkWell(
                    onTap: () {
                      if (book.user.id ==
                          ref.read(authenticationProvider)?.id) {
                        GoRouter.of(context).go(
                          "/profile/authenticated",
                        );
                      } else {
                        GoRouter.of(context).push(
                          "/profile/${book.user.id}",
                        );
                      }
                    },
                    child: AutoSizeText(
                      book.user.name ?? '',
                      maxLines: 2,
                      minFontSize: 14,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(10),
            const Text("Tags#"),
            const Gap(5),
            Row(
              children: [
                Wrap(
                  spacing: 5,
                  children: [
                    for (final tag in book.tags)
                      MaterialButton(
                        elevation: 0,
                        focusElevation: 0,
                        hoverElevation: 0,
                        highlightElevation: 0,
                        disabledElevation: 0,
                        color: Theme.of(context).cardColor,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        height: 30,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onPressed: () {},
                        child: Text(tag.tag),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
