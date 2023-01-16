import 'package:eusc_freaks/collections/pocketbase.dart';
import 'package:eusc_freaks/models/post.dart';
import 'package:eusc_freaks/providers/authentication_provider.dart';
import 'package:eusc_freaks/queries/posts.dart';
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
import 'package:pocketbase/pocketbase.dart';

class PostNewPage extends HookConsumerWidget {
  final String type;
  PostNewPage({
    Key? key,
    String? type,
  })  : type = type ?? "${PostType.question.name},${PostType.informative.name}",
        super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final titleController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final formKey = GlobalKey<FormState>();
    final error = useState<String?>(null);
    final updating = useState(false);
    final mounted = useIsMounted();
    final types = type.split(",");
    final typeOfPost = useState(types.first);
    final media = useState<List<PlatformFile>>([]);

    return Scaffold(
      appBar: AppBar(
        title: Text("New ${typeOfPost.value}"),
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
              validator:
                  ValidationBuilder().required("Title is required").build(),
              decoration: const InputDecoration(
                labelText: "Title",
              ),
            ),
            const Gap(10),
            TextFormField(
              maxLines: 5,
              controller: descriptionController,
              validator: ValidationBuilder()
                  .required("Description is required")
                  .build(),
              decoration: const InputDecoration(
                labelText: "Description",
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),
            if (types.length > 1) ...[
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
                onChanged: (value) {
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
                          child: Image.memory(
                            file.bytes!,
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
                                    .sublist(0, 6 - media.value.length),
                              ];
                            } else {
                              media.value = [...media.value, ...files.files];
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
                        if (formKey.currentState!.validate() &&
                            media.value.length <= 6) {
                          final userID = ref.read(authenticationProvider)?.id;
                          final post = Post.fromRecord(
                            await pb.collection("posts").create(
                              body: {
                                "title": titleController.text,
                                "description": descriptionController.text,
                                "user": userID,
                                "type": typeOfPost.value,
                              },
                              files: media.value
                                  .map(
                                    (e) => MultipartFile.fromBytes(
                                      'media',
                                      e.bytes!,
                                      filename: e.name,
                                      contentType: MediaType(
                                        'image',
                                        e.extension!,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          );
                          formKey.currentState?.reset();
                          error.value = null;
                          media.value = [];
                          if (mounted()) {
                            GoRouter.of(context).go("/posts/${post.id}");
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
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
