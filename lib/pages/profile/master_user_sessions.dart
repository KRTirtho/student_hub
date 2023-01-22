import 'package:collection/collection.dart';
import 'package:eusc_freaks/collections/pocketbase.dart';
import 'package:eusc_freaks/models/user.dart';
import 'package:eusc_freaks/providers/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_validator/form_validator.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

class MasterUserSessions extends HookConsumerWidget {
  final User user;
  const MasterUserSessions(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final isOwner = ref.watch(authenticationProvider)?.id == user.id;

    final error = useState<String?>(null);
    final updating = useState(false);
    final isEditMode = useState(false);

    final serialController = useTextEditingController(
      text: user.currentSession?.serial.toString(),
    );
    final year = useState<int?>(
      user.currentSession?.year,
    );
    final subject = useState<Subject?>(
      user.currentSession?.subject,
    );

    final formKey = GlobalKey<FormState>();

    return Stack(
      children: [
        Form(
          key: formKey,
          child: Padding(
            padding: EdgeInsets.all(isEditMode.value ? 16 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isEditMode.value) ...[
                  const Gap(30),
                  Text(
                    "Year",
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  DropdownButtonFormField<int>(
                    validator: (v) => v == null ? "Year is required" : null,
                    isExpanded: false,
                    value: year.value,
                    decoration: const InputDecoration(
                      hintText: "Year",
                      isDense: true,
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        year.value = value;
                      }
                    },
                    items: [
                      for (int year = 2000; year <= DateTime.now().year; year++)
                        DropdownMenuItem(
                          value: year,
                          child: Center(child: Text(year.toString())),
                        ),
                    ],
                  ),
                  const Gap(10),
                  Text(
                    "Subject",
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  DropdownButtonFormField<Subject>(
                    isExpanded: false,
                    validator: (v) => v == null ? "Subject is required" : null,
                    decoration: const InputDecoration(hintText: "Subject"),
                    value: subject.value,
                    onChanged: (value) {
                      if (value != null) {
                        subject.value = value;
                      }
                    },
                    items: [
                      for (final subject in Subject.values.sorted(
                        (a, b) => a.name.compareTo(b.name),
                      ))
                        DropdownMenuItem(
                          value: subject,
                          child: Center(child: Text(subject.formattedName)),
                        ),
                    ],
                  ),
                  const Gap(10),
                  Text(
                    "ID No.",
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  TextFormField(
                    controller: serialController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: ValidationBuilder()
                        .regExp(
                          RegExp(r"^[1-9][0-9]{0,3}$"),
                          "Invalid roll (only 1-9999)",
                        )
                        .required()
                        .build(),
                    decoration: const InputDecoration(
                      hintText: "Roll",
                      isDense: true,
                    ),
                  ),
                  if (error.value != null)
                    Text(
                      error.value!,
                      style: Theme.of(context).textTheme.caption?.copyWith(
                            color: Theme.of(context).errorColor,
                          ),
                    ),
                ] else ...[
                  ListTile(
                    title: const Text('Subject'),
                    subtitle: Text(
                      user.currentSession?.subject?.formattedName ?? "",
                    ),
                  ),
                  ListTile(
                    title: const Text('Joining Year'),
                    subtitle: Text(
                      user.currentSession?.year.toString() ?? "",
                    ),
                  ),
                  ListTile(
                    title: const Text('ID No.'),
                    subtitle: Text(
                      user.currentSession?.serial.toString() ?? "",
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
        if (isOwner)
          Container(
            alignment: Alignment.topRight,
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isEditMode.value)
                  IconButton(
                    onPressed: updating.value
                        ? null
                        : () {
                            isEditMode.value = false;
                          },
                    icon: const Icon(Icons.cancel_outlined),
                  ),
                ElevatedButton.icon(
                  onPressed: updating.value
                      ? null
                      : () async {
                          if (!isEditMode.value) {
                            isEditMode.value = true;
                            year.value = user.currentSession?.year;
                            subject.value = user.currentSession?.subject;
                            serialController.text =
                                user.currentSession?.serial.toString() ?? "";
                          } else {
                            if (formKey.currentState?.validate() != true) {
                              return;
                            }

                            updating.value = true;
                            try {
                              final session = SessionObject(
                                year: year.value!,
                                standard: null,
                                serial: int.parse(serialController.text),
                                subject: subject.value,
                              );

                              await pb.collection('users').update(
                                user.id,
                                body: {'sessions': session.toString()},
                              );

                              isEditMode.value = false;
                              year.value = null;
                              subject.value = null;
                              error.value = null;
                              formKey.currentState?.reset();

                              ref
                                  .read(authenticationProvider.notifier)
                                  .refetch();
                            } on ClientException catch (e) {
                              error.value = e.response["message"];
                            } finally {
                              updating.value = false;
                            }
                          }
                        },
                  icon: Icon(isEditMode.value
                      ? Icons.save_outlined
                      : Icons.edit_outlined),
                  label: Text(!isEditMode.value ? 'Edit' : 'Save'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
