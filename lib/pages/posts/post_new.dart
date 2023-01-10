import 'package:eusc_freaks/collections/pocketbase.dart';
import 'package:eusc_freaks/providers/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_validator/form_validator.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

class PostNewPage extends HookConsumerWidget {
  const PostNewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final titleController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final formKey = GlobalKey<FormState>();
    final error = useState<String?>(null);

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Post"),
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
              onPressed: () async {
                try {
                  if (formKey.currentState!.validate()) {
                    await pb.collection("posts").create(body: {
                      "title": titleController.text,
                      "description": descriptionController.text,
                      "user": ref.read(authenticationProvider)?.id,
                    });
                    formKey.currentState!.reset();
                    // GoRouter.of(context).go("/post/${payload.id}");
                    // QueryBowl.of(context).getInfiniteQuery(postsInfiniteQuery.query)?.refetchPages();
                  }
                } on ClientException catch (e) {
                  error.value = e.response["message"];
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
