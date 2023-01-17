import 'package:eusc_freaks/collections/pocketbase.dart';
import 'package:eusc_freaks/hooks/use_pdf_thumbnail.dart';
import 'package:eusc_freaks/models/book_tags.dart';
import 'package:eusc_freaks/providers/authentication_provider.dart';
import 'package:eusc_freaks/queries/books.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_query/fl_query.dart';
import 'package:fl_query_hooks/fl_query_hooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_validator/form_validator.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' hide ClientException;
import 'package:http_parser/http_parser.dart';
import 'package:pdfx/pdfx.dart';
import 'package:pocketbase/pocketbase.dart';

class BookNewPage extends HookConsumerWidget {
  const BookNewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final bookTags = useQuery(job: bookTagsQueryJob, externalData: null);

    final titleController = useTextEditingController();
    final bioController = useTextEditingController();
    final authorController = useTextEditingController();
    final externalUrlController = useTextEditingController();

    final selectedTags = useState<Set<BookTag>>({});
    final media = useState<PlatformFile?>(null);
    final updating = useState(false);
    final error = useState<String?>(null);

    final mounted = useIsMounted();

    final formKey = GlobalKey<FormState>();

    final unselectedTags =
        bookTags.data?.where((e) => !selectedTags.value.contains(e));

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Book"),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_outlined),
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: titleController,
              validator: ValidationBuilder().required().build(),
              decoration: const InputDecoration(
                labelText: "Title",
              ),
            ),
            const Gap(10),
            TextFormField(
              controller: authorController,
              validator: ValidationBuilder().required().build(),
              decoration: const InputDecoration(
                labelText: "Authors",
              ),
            ),
            const Gap(10),
            TextFormField(
              controller: bioController,
              maxLines: 4,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: "Bio",
                hintText: "A short description of the book",
              ),
            ),
            const Gap(10),
            TextFormField(
              controller: externalUrlController,
              validator: ValidationBuilder().url().build(),
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: "External Publication URL",
              ),
            ),
            const Gap(20),
            Text(
              "Book",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            const Gap(5),
            if (media.value == null)
              SizedBox(
                height: 100,
                child: MaterialButton(
                  color: Theme.of(context).cardColor,
                  elevation: 0,
                  focusElevation: 0,
                  hoverElevation: 0,
                  highlightElevation: 0,
                  disabledElevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  onPressed: updating.value
                      ? null
                      : () async {
                          final files = await FilePicker.platform.pickFiles(
                            allowMultiple: false,
                            dialogTitle: "Select PDF book",
                            type: FileType.custom,
                            withData: true,
                            allowedExtensions: ["pdf"],
                          );

                          if (files == null) return;
                          if (files.files.first.size > 40000000) {
                            error.value = "File size must be less than 40MB";
                            return;
                          }
                          media.value = files.files.first;
                        },
                  child: const Icon(
                    Icons.file_present_outlined,
                    size: 40,
                  ),
                ),
              )
            else ...[
              HookBuilder(builder: (context) {
                final document = useMemoized(
                  () => media.value?.bytes != null
                      ? PdfDocument.openData(media.value!.bytes!)
                      : null,
                  [media],
                );

                final thumbnail = usePdfThumbnail(document);
                return SizedBox(
                  height: 200,
                  child: InkWell(
                    onTap: () {
                      GoRouter.of(context).push(
                        "/media/pdf",
                        extra: document,
                      );
                    },
                    child: FutureBuilder<PdfPageImage?>(
                        future: thumbnail,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          print("Size ${snapshot.data!.bytes.length}");
                          return Image.memory(
                            snapshot.data!.bytes,
                            fit: BoxFit.contain,
                          );
                        }),
                  ),
                );
              }),
              const Gap(10),
              Row(
                children: [
                  Text(
                    media.value!.name,
                    style: Theme.of(context).textTheme.caption,
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => media.value = null,
                    color: Colors.red[400],
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            ],
            const Gap(20),
            Text(
              "Tags",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            const Gap(10),
            if (!bookTags.hasData)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final tag in selectedTags.value)
                    Chip(
                      label: Text(tag.tag),
                      onDeleted: () {
                        selectedTags.value = {
                          ...selectedTags.value,
                        }..remove(tag);
                      },
                    ),
                  PopupMenuButton(
                    itemBuilder: (context) {
                      return [
                        for (final tag in unselectedTags)
                          PopupMenuItem(
                            value: tag,
                            child: Chip(
                              label: Text(tag.tag),
                            ),
                          ),
                      ];
                    },
                    enabled: unselectedTags!.isNotEmpty,
                    onSelected: (tag) {
                      selectedTags.value = {
                        ...selectedTags.value,
                        tag,
                      };
                    },
                    icon: const Icon(Icons.tag_outlined),
                  ),
                ],
              ),
            if (error.value != null) ...[
              const Gap(10),
              Text(
                error.value!,
                style: Theme.of(context).textTheme.caption!.copyWith(
                      color: Colors.red[400],
                    ),
              )
            ],
            const Gap(20),
            ElevatedButton(
              onPressed: updating.value || !bookTags.hasData
                  ? null
                  : () async {
                      if (formKey.currentState?.validate() != true) return;
                      if (media.value == null) {
                        error.value = "Please select a book";
                        return;
                      }
                      if (selectedTags.value.isEmpty) {
                        error.value = "Please select at least one tag";
                        return;
                      }
                      updating.value = true;
                      final thumb = await getPdfThumbnail(
                        PdfDocument.openData(media.value!.bytes!),
                      );
                      try {
                        await pb.collection("books").create(
                          body: {
                            "title": titleController.text,
                            "bio": bioController.text,
                            "author": authorController.text,
                            "external_url": externalUrlController.text,
                            "tags": selectedTags.value.length == 1
                                ? selectedTags.value.first.id
                                : selectedTags.value.map((e) => e.id).toList(),
                            "user": ref.read(authenticationProvider)?.id,
                          },
                          files: [
                            MultipartFile.fromBytes(
                              "media",
                              media.value!.bytes!,
                              filename: media.value!.name,
                              contentType: MediaType("application", "pdf"),
                            ),
                            MultipartFile.fromBytes(
                              "thumbnail",
                              thumb!.bytes,
                              filename:
                                  "${media.value!.name}.thumbnail.${thumb.format.name}",
                              contentType:
                                  MediaType("image", thumb.format.name),
                            ),
                          ],
                        );
                        formKey.currentState?.reset();
                        media.value = null;
                        error.value = null;
                        if (mounted()) {
                          final query = QueryBowl.of(context)
                              .getInfiniteQuery(booksInfiniteQueryJob.queryKey);
                          await query?.refetch();
                          GoRouter.of(context).pop();
                        }
                      } on ClientException catch (e) {
                        error.value = e.response["message"];
                      } finally {
                        updating.value = false;
                      }
                    },
              child: const Text("Publish"),
            ),
          ],
        ),
      ),
    );
  }
}
