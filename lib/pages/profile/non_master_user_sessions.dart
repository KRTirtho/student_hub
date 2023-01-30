import 'package:catcher/catcher.dart';
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

class NonMasterUserSessions extends HookConsumerWidget {
  final User user;
  const NonMasterUserSessions(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final isEditMode = useState(false);
    final updating = useState(false);
    final error = useState<String?>(null);

    final tableStyle = Theme.of(context).textTheme.caption!;
    final tableHeaderStyle = tableStyle.copyWith(
      fontWeight: FontWeight.bold,
    );

    final serialController = useTextEditingController();
    final year = useState<int?>(null);
    final standard = useState<int?>(null);

    final formKey = GlobalKey<FormState>();

    final isOwner = ref.watch(authenticationProvider)?.id == user.id;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Sessions',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Form(
            key: formKey,
            child: Table(
              children: [
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Year',
                          style: tableHeaderStyle,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Class',
                          style: tableHeaderStyle,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Roll',
                          style: tableHeaderStyle,
                        ),
                      ),
                    ),
                  ],
                ),
                for (final session in user.sessionObjects)
                  TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            session.year.toString(),
                            style: tableStyle,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            session.standard.toString(),
                            style: tableStyle,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            session.serial.toString(),
                            style: tableStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (isEditMode.value)
                  TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: DropdownButtonFormField<int>(
                            validator: (v) =>
                                v == null ? "Year is required" : null,
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
                              for (int year = 2000;
                                  year <= DateTime.now().year;
                                  year++)
                                DropdownMenuItem(
                                  value: year,
                                  child: Center(child: Text(year.toString())),
                                ),
                            ],
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: DropdownButtonFormField<int>(
                            isExpanded: false,
                            validator: (v) =>
                                v == null ? "Class is required" : null,
                            decoration: const InputDecoration(
                              hintText: "Class",
                              isDense: true,
                            ),
                            value: standard.value,
                            onChanged: (value) {
                              if (value != null) {
                                standard.value = value;
                              }
                            },
                            items: [
                              for (int grade = 1; grade <= 12; grade++)
                                DropdownMenuItem(
                                  value: grade,
                                  child: Center(child: Text(grade.toString())),
                                ),
                            ],
                          ),
                        ),
                      ),
                      TableCell(
                        child: TextFormField(
                          controller: serialController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
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
                      ),
                    ],
                  )
              ],
            ),
          ),
          if (error.value != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                error.value!,
                style: Theme.of(context).textTheme.caption!.copyWith(
                      color: Theme.of(context).errorColor,
                    ),
              ),
            ),
          const Gap(8),
          if (isOwner)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isEditMode.value)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancel'),
                    onPressed: () {
                      isEditMode.value = false;
                    },
                  ),
                const Gap(8),
                ElevatedButton.icon(
                  icon: Icon(isEditMode.value
                      ? Icons.save_outlined
                      : Icons.add_outlined),
                  label: Text(!isEditMode.value ? 'Add Session' : 'Save'),
                  onPressed: updating.value
                      ? null
                      : () async {
                          if (!isEditMode.value) {
                            isEditMode.value = true;
                          } else {
                            if (formKey.currentState?.validate() != true) {
                              return;
                            }

                            updating.value = true;
                            try {
                              final session = SessionObject(
                                year: year.value!,
                                standard: standard.value!,
                                serial: int.parse(serialController.text),
                                subject: null,
                              );

                              final sessions = [
                                ...user.sessionObjects.map((e) => e.toString()),
                                session.toString(),
                              ].join(",");
                              await pb.collection('users').update(
                                user.id,
                                body: {'sessions': sessions},
                              );

                              isEditMode.value = false;
                              year.value = null;
                              standard.value = null;
                              error.value = null;
                              formKey.currentState?.reset();

                              ref
                                  .read(authenticationProvider.notifier)
                                  .refetch();
                            } on ClientException catch (e, stack) {
                              error.value = e.response["message"];
                              Catcher.reportCheckedError(error, stack);
                            } finally {
                              updating.value = false;
                            }
                          }
                        },
                ),
              ],
            ),
        ],
      ),
    );
  }
}
