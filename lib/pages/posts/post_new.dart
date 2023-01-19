import 'package:eusc_freaks/collections/math_symbols_collection.dart';
import 'package:eusc_freaks/collections/pocketbase.dart';
import 'package:eusc_freaks/components/image/universal_image.dart';
import 'package:eusc_freaks/hooks/use_force_update.dart';
import 'package:eusc_freaks/models/post.dart';
import 'package:eusc_freaks/providers/authentication_provider.dart';
import 'package:eusc_freaks/queries/posts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_query/fl_query.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_validator/form_validator.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' hide ClientException;
import 'package:http_parser/http_parser.dart';
import 'package:markdown_editable_textinput/markdown_text_input.dart';
import 'package:path/path.dart';
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

    final forceUpdate = useForceUpdate();
    final mounted = useIsMounted();

    final error = useState<String?>(null);
    final updating = useState(false);
    final media = useState<List<String>>([
      ...?post?.getMediaURL().map((e) => e.toString()),
    ]);
    final deletingMedias = useState<List<String>>([]);

    final description = useRef<String>(post?.description ?? "");

    final formKey = GlobalKey<FormState>();
    final types = type.split(",");
    final typeOfPost = useState(types.first);

    final isEditMode = post != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Edit Post" : "New ${typeOfPost.value}"),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_outlined),
        ),
      ),
      body: Stack(
        children: [
          Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
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
                    return MarkdownTextInput(
                      (value) {
                        description.value = value;
                      },
                      description.value,
                      maxLines: 5,
                      validators: ValidationBuilder()
                          .required("Description is required")
                          .build(),
                      label: "Description",
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
                  style: Theme.of(context).textTheme.subtitle1?.copyWith(
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
                                path: file,
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
                                if (isEditMode) {
                                  deletingMedias.value = [
                                    ...deletingMedias.value,
                                    basename(file),
                                  ];
                                }
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
                                final files =
                                    await FilePicker.platform.pickFiles(
                                  allowMultiple: true,
                                  dialogTitle: "Select post media",
                                  type: FileType.image,
                                );
                                if (files == null) return;
                                if ((files.count + media.value.length) > 6) {
                                  error.value =
                                      "You can only upload up to 6 files";
                                  media.value = [
                                    ...media.value,
                                    ...files.files
                                        .sublist(0, 6 - media.value.length)
                                        .map((e) => e.path)
                                        .whereType<String>()
                                  ];
                                } else {
                                  media.value = [
                                    ...media.value,
                                    ...files.files
                                        .map((e) => e.path)
                                        .whereType<String>()
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
                        .caption
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
                              final userID =
                                  ref.read(authenticationProvider)?.id;

                              final body = {
                                "title": titleController.text,
                                "description": description.value,
                                if (!isEditMode) "user": userID,
                                if (!isEditMode) "type": typeOfPost.value,
                              };

                              RecordModel rec;
                              if (!isEditMode) {
                                rec = await pb.collection("posts").create(
                                      body: body,
                                      files: await Future.wait(
                                        media.value.map(
                                          (e) async =>
                                              await MultipartFile.fromPath(
                                            'media',
                                            e,
                                            filename: basename(e),
                                            contentType: MediaType(
                                                'image', extension(e)),
                                          ),
                                        ),
                                      ),
                                    );
                              } else {
                                final newMedias = media.value
                                    .where((e) => !e.startsWith("http"));
                                rec = await pb.collection("posts").update(
                                      post!.id,
                                      body: {
                                        ...body,
                                        if (deletingMedias.value.isNotEmpty &&
                                            newMedias.isEmpty)
                                          "media-": deletingMedias.value,
                                      },
                                      files: await Future.wait(
                                        newMedias.map(
                                          (e) => MultipartFile.fromPath(
                                            'media',
                                            e,
                                            filename: basename(e),
                                            contentType: MediaType(
                                              'image',
                                              extension(e),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                if (deletingMedias.value.isNotEmpty &&
                                    newMedias.isNotEmpty) {
                                  rec = await pb.collection("posts").update(
                                    post!.id,
                                    body: {
                                      "media-": deletingMedias.value,
                                    },
                                  );
                                }
                              }

                              formKey.currentState?.reset();
                              error.value = null;
                              media.value = [];
                              deletingMedias.value = [];
                              if (mounted()) {
                                GoRouter.of(context).go("/posts/${rec.id}");
                                QueryBowl.of(context)
                                    .getInfiniteQuery(
                                      postsInfiniteQueryJob(type).queryKey,
                                    )
                                    ?.refetchPages();
                              }
                            }
                          } on ClientException catch (e) {
                            error.value = e.response["message"];
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 50,
              color: Theme.of(context).cardColor,
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
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: () {
                          description.value += mathOperators[index].key;
                          forceUpdate();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
              ),
            ),
          )
        ],
      ),
    );
  }
}
