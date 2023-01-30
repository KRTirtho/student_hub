import 'package:catcher/catcher.dart';
import 'package:eusc_freaks/collections/pocketbase.dart';
import 'package:eusc_freaks/components/image/universal_image.dart';
import 'package:eusc_freaks/components/scrolling/constrained_list_view.dart';
import 'package:eusc_freaks/hooks/use_crashlytics_query.dart';
import 'package:eusc_freaks/hooks/use_pdf_thumbnail.dart';
import 'package:eusc_freaks/models/book.dart';
import 'package:eusc_freaks/models/book_tags.dart';
import 'package:eusc_freaks/models/lol_file.dart';
import 'package:eusc_freaks/providers/authentication_provider.dart';
import 'package:eusc_freaks/queries/books.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_query/fl_query.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_validator/form_validator.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' hide ClientException;
import 'package:http_parser/http_parser.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:path/path.dart';
import 'package:pdfx/pdfx.dart';
import 'package:pocketbase/pocketbase.dart';

class BookNewPage extends HookConsumerWidget {
  final Book? book;
  const BookNewPage({
    Key? key,
    this.book,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final bookTags =
        useCrashlyticsQuery(job: bookTagsQueryJob, externalData: null);

    final titleController = useTextEditingController(text: book?.title);
    final bioController = useTextEditingController(text: book?.bio);
    final authorController = useTextEditingController(text: book?.author);
    final externalUrlController =
        useTextEditingController(text: book?.externalUrl);
    final controller = useScrollController();

    final selectedTags = useRef<List<BookTag>>([
      ...?book?.tags,
    ]);
    final initialMedia = book != null
        ? LOLFile.fromUri(book!.getMediaURL(), "application")
        : null;
    final media = useState<LOLFile?>(initialMedia);
    final updating = useState(false);
    final error = useState<String?>(null);

    final mounted = useIsMounted();

    final formKey = GlobalKey<FormState>();

    final isEditMode = book != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Edit Book" : "New Book"),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_outlined),
        ),
      ),
      body: Form(
        key: formKey,
        child: ConstrainedListView(
          controller: controller,
          constraints: const BoxConstraints(maxWidth: 600),
          alignment: Alignment.center,
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
            if (media.value != null) ...[
              HookBuilder(builder: (context) {
                final document = useMemoized(
                  () => (isEditMode && media.value == initialMedia) ||
                          media.value == null
                      ? null
                      : PdfDocument.openData(media.value!.bytes!),
                  [media],
                );

                final thumbnail = usePdfThumbnail(
                  isEditMode && media.value == initialMedia ? null : document,
                );
                return SizedBox(
                  height: 200,
                  child: InkWell(
                    onTap: () {
                      GoRouter.of(context).push(
                        "/media/pdf",
                        extra: document ?? initialMedia?.path,
                      );
                    },
                    child: isEditMode && media.value == initialMedia
                        ? UniversalImage(
                            path: book!
                                .getThumbnailURL(const Size(0, 200))
                                .toString(),
                            fit: BoxFit.contain,
                          )
                        : FutureBuilder<PdfPageImage?>(
                            future: thumbnail,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
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
                    media.value?.name ?? "",
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
            ] else
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
                          media.value = LOLFile.fromPlatformFile(
                            files.files.first,
                            "application",
                          );
                        },
                  child: const Icon(
                    Icons.file_present_outlined,
                    size: 40,
                  ),
                ),
              ),
            const Gap(20),
            Text(
              "Tags #",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            const Gap(10),
            if (!bookTags.hasData)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              MultiSelectBottomSheetField(
                onConfirm: (selection) {
                  selectedTags.value = selection.cast<BookTag>();
                },
                listType: MultiSelectListType.CHIP,
                searchable: true,
                initialValue: selectedTags.value,
                validator: (values) {
                  if (values == null || values.isEmpty) {
                    return "Please select at least one tag";
                  }
                  return null;
                },
                separateSelectedItems: true,
                buttonText: Text(
                  "Select Tags",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                buttonIcon: const Icon(Icons.tag_outlined),
                items: bookTags.data?.map((e) {
                      return MultiSelectItem(e, e.tag);
                    }).toList() ??
                    [],
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
                      try {
                        final body = {
                          "title": titleController.text,
                          "bio": bioController.text,
                          "author": authorController.text,
                          "external_url": externalUrlController.text,
                        };

                        final hasChangeMedia =
                            (isEditMode && media.value != initialMedia) ||
                                !isEditMode;
                        final thumb = hasChangeMedia
                            ? await getPdfThumbnail(
                                PdfDocument.openData(media.value!.bytes!),
                              )
                            : null;

                        if (isEditMode) {
                          await pb.collection("books").update(
                                book!.id,
                                body: {
                                  ...body,
                                  "tags": selectedTags.value
                                      .map((e) => e.id)
                                      .toList(),
                                },
                                files: hasChangeMedia
                                    ? [
                                        await media.value!
                                            .toMultipartFile("media"),
                                        MultipartFile.fromBytes(
                                          "thumbnail",
                                          thumb!.bytes,
                                          filename:
                                              "${basename(media.value!.name)}.thumbnail.${thumb.format.name}",
                                          contentType: MediaType(
                                              "image", thumb.format.name),
                                        ),
                                      ]
                                    : [],
                              );
                        } else {
                          final bookRec = Book.fromRecord(
                            await pb.collection("books").create(
                              body: {
                                ...body,
                                "user": ref.read(authenticationProvider)?.id,
                                "tags": selectedTags.value.first.id
                              },
                              files: [
                                await media.value!.toMultipartFile("media"),
                                MultipartFile.fromBytes(
                                  "thumbnail",
                                  thumb!.bytes,
                                  filename:
                                      "${basename(media.value!.name)}.thumbnail.${thumb.format.name}",
                                  contentType:
                                      MediaType("image", thumb.format.name),
                                ),
                              ],
                              expand: "tags",
                            ),
                          );
                          // Workaround for a bug in the backend
                          if (selectedTags.value.length > 1) {
                            await pb.collection("books").update(
                              bookRec.id,
                              body: {
                                "tags": [
                                  ...bookRec.tags.map((e) => e.id).toList(),
                                  ...selectedTags.value
                                      .map((e) => e.id)
                                      .toList()
                                      .sublist(1)
                                ]
                              },
                            );
                          }
                        }

                        formKey.currentState?.reset();
                        media.value = null;
                        error.value = null;
                        if (mounted()) {
                          final query = QueryBowl.of(context)
                              .getInfiniteQuery(booksInfiniteQueryJob.queryKey);
                          await query?.refetch();
                          GoRouter.of(context).pop();
                        }
                      } on ClientException catch (e, stackTrace) {
                        error.value = e.response["message"];
                        Catcher.reportCheckedError(error, stackTrace);
                      } finally {
                        updating.value = false;
                      }
                    },
              child: updating.value
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.grey[600],
                      ),
                    )
                  : Text(isEditMode ? "Update" : "Publish"),
            ),
          ],
        ),
      ),
    );
  }
}
