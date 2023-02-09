import 'package:catcher/catcher.dart';
import 'package:student_hub/collections/math_symbols_collection.dart';
import 'package:student_hub/collections/pocketbase.dart';
import 'package:student_hub/components/image/universal_image.dart';
import 'package:student_hub/components/markdown/format_markdown.dart';
import 'package:student_hub/components/markdown/markdown_input.dart';
import 'package:student_hub/components/scrolling/constrained_list_view.dart';
import 'package:student_hub/models/lol_file.dart';
import 'package:student_hub/models/post.dart';
import 'package:student_hub/providers/authentication_provider.dart';
import 'package:student_hub/queries/posts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_query/fl_query.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_validator/form_validator.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

class PostNewPage extends HookConsumerWidget {
  final String type;
  final Post? post;
  PostNewPage({
    Key? key,
    String? type,
    this.post,
  })  : assert(
          type == null || post == null,
          "Both type and post cannot be set",
        ),
        type = post?.type.name ??
            type ??
            "${PostType.question.name},${PostType.informative.name}",
        super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final titleController = useTextEditingController(text: post?.title);
    final descriptionController = useTextEditingController(
      text: post?.description,
    );
    final focusNode = useFocusNode();

    final mounted = useIsMounted();

    final error = useState<String?>(null);
    final updating = useState(false);
    final initialMedia =
        post?.getMediaURL().map((e) => LOLFile.fromUri(e, "image")).toList();
    final media = useState<List<LOLFile>>(initialMedia ?? []);

    final formKey = GlobalKey<FormState>();
    final types = type.split(",");
    final typeOfPost = useState(types.first);

    final isEditMode = post != null;

    final controller = useScrollController();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Edit Post" : "New ${typeOfPost.value}"),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_outlined),
        ),
      ),
      body: Form(
        key: formKey,
        child: ConstrainedListView(
          padding: const EdgeInsets.all(16),
          controller: controller,
          constraints: const BoxConstraints(maxWidth: 600),
          alignment: Alignment.center,
          children: [
            TextFormField(
              controller: titleController,
              validator:
                  ValidationBuilder().required("Title is required").build(),
              decoration: const InputDecoration(
                labelText: "Title",
              ),
            ),
            const Gap(10),
            HookBuilder(
              builder: (context) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      MarkdownTextInput(
                        maxLines: 5,
                        focusNode: focusNode,
                        controller: descriptionController,
                        actions: const [
                          MarkdownType.bold,
                          MarkdownType.italic,
                          MarkdownType.strikethrough,
                          MarkdownType.title,
                          MarkdownType.link,
                          MarkdownType.list,
                          MarkdownType.code,
                          MarkdownType.codeblock,
                          MarkdownType.blockquote,
                        ],
                        validator: ValidationBuilder()
                            .required("Description is required")
                            .build(),
                        decoration: const InputDecoration(
                          hintText: "Description",
                        ),
                      ),
                      const Divider(height: 1, thickness: 1),
                      const Gap(10),
                      SizedBox(
                        height: 40,
                        child: ScrollConfiguration(
                          behavior: const ScrollBehavior().copyWith(
                            dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                            },
                          ),
                          child: ListView.builder(
                            itemCount: mathOperators.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) => Material(
                              type: MaterialType.transparency,
                              child: InkWell(
                                onTap: () {
                                  final cursorPosition =
                                      descriptionController.selection.start;
                                  final newText =
                                      descriptionController.text.replaceRange(
                                    cursorPosition,
                                    descriptionController.selection.end,
                                    mathOperators[index].key,
                                  );
                                  descriptionController.text = newText;
                                  focusNode.requestFocus();
                                  descriptionController.selection =
                                      TextSelection.fromPosition(
                                    TextPosition(
                                      offset: cursorPosition +
                                          mathOperators[index].key.length,
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    mathOperators[index].key,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
            ...[
              const Gap(20),
              const Text("Type of post"),
              DropdownButtonFormField<String>(
                value: typeOfPost.value,
                items: [
                  for (final type in types)
                    DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ),
                ],
                onChanged: isEditMode || types.length == 1
                    ? null
                    : (value) {
                        if (value != null) typeOfPost.value = value;
                      },
              )
            ],
            const Gap(20),
            Text(
              "Media",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Gap(10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                for (final file in media.value)
                  Stack(
                    children: [
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: UniversalImage(
                            path: file.universalPath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: IconButton(
                          onPressed: () {
                            error.value = null;
                            media.value = media.value
                                .where((element) => element != file)
                                .toList();
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white54,
                          ),
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red[400],
                          ),
                        ),
                      ),
                    ],
                  ),
                SizedBox(
                  width: 100,
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
                              allowMultiple: true,
                              dialogTitle: "Select post media",
                              type: FileType.image,
                              withData: true,
                            );
                            if (files == null) return;
                            if ((files.count + media.value.length) > 6) {
                              error.value = "You can only upload up to 6 files";
                              media.value = [
                                ...media.value,
                                ...files.files
                                    .sublist(0, 6 - media.value.length)
                                    .map(
                                      (e) => LOLFile.fromPlatformFile(
                                        e,
                                        "image",
                                      ),
                                    )
                              ];
                            } else {
                              media.value = [
                                ...media.value,
                                ...files.files.map(
                                  (e) => LOLFile.fromPlatformFile(
                                    e,
                                    "image",
                                  ),
                                )
                              ];
                            }
                          },
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(20),
            if (error.value != null)
              Text(
                error.value!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.red),
              ),
            const Gap(20),
            ElevatedButton(
              onPressed: updating.value
                  ? null
                  : () async {
                      updating.value = true;
                      try {
                        if (formKey.currentState?.validate() == true &&
                            media.value.length <= 6) {
                          final userID = ref.read(authenticationProvider)?.id;

                          final body = {
                            "title": titleController.text,
                            "description": descriptionController.text,
                            if (!isEditMode) "user": userID,
                            if (!isEditMode) "type": typeOfPost.value,
                          };

                          RecordModel rec;
                          if (!isEditMode) {
                            rec = await pb.collection("posts").create(
                                  body: body,
                                  files: await Future.wait(
                                    media.value.map(
                                      (e) => e.toMultipartFile("media"),
                                    ),
                                  ),
                                );
                          } else {
                            final newMedias = media.value
                                .where((e) => e.bytes != null)
                                .toList();
                            final deletingMedias = initialMedia
                                    ?.where((e) => !media.value.contains(e))
                                    .map((e) => e.name)
                                    .toList() ??
                                [];
                            if (deletingMedias.isNotEmpty &&
                                newMedias.isNotEmpty) {
                              rec = await pb.collection("posts").update(
                                post!.id,
                                body: {
                                  "media-": deletingMedias,
                                },
                              );
                            }
                            rec = await pb.collection("posts").update(
                                  post!.id,
                                  body: {
                                    ...body,
                                    if (deletingMedias.isNotEmpty &&
                                        newMedias.isEmpty)
                                      "media-": deletingMedias,
                                  },
                                  files: await Future.wait(
                                    newMedias.map(
                                      (e) => e.toMultipartFile("media"),
                                    ),
                                  ),
                                );
                          }

                          formKey.currentState?.reset();
                          error.value = null;
                          media.value = Post.fromRecord(rec)
                              .getMediaURL()
                              .map((e) => LOLFile.fromUri(e, "image"))
                              .toList();
                          if (mounted()) {
                            GoRouter.of(context).go("/posts/${rec.id}");
                            QueryBowl.of(context)
                                .getInfiniteQuery(
                                  postsInfiniteQueryJob(type).queryKey,
                                )
                                ?.refetchPages();
                          }
                        }
                      } on ClientException catch (e, stackTrace) {
                        error.value = e.response["message"];
                        Catcher.reportCheckedError(error, stackTrace);
                      } finally {
                        updating.value = false;
                      }
                    },
              child: Text(isEditMode ? "Update" : "Submit"),
            ),
            const Gap(100),
          ],
        ),
      ),
    );
  }
}
