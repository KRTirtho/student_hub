import 'package:eusc_freaks/components/image/universal_image.dart';
import 'package:eusc_freaks/hooks/use_redirect.dart';
import 'package:eusc_freaks/models/user.dart';
import 'package:eusc_freaks/providers/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_validator/form_validator.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:collection/collection.dart';

class SignupPage extends HookConsumerWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final usernameController = useTextEditingController();
    final nameController = useTextEditingController();
    final serialController = useTextEditingController();
    final year = useState<int?>(null);
    final standard = useState<int?>(null);
    final subject = useState<Subject?>(null);
    final isMaster = useState(false);
    final visibility = useState(false);
    final error = useState<String?>(null);
    final authNotifier = ref.watch(authenticationProvider.notifier);
    final user = ref.watch(authenticationProvider);
    final isLoading = useState(false);
    final mounted = useIsMounted();
    final formKey = GlobalKey<FormState>();

    useRedirect("/", user != null && user.verified);

    Widget body = SingleChildScrollView(
      padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: const UniversalImage(
                    path: "assets/logo.png",
                  ),
                ),
                const Gap(10),
                Center(
                  child: Text(
                    "Sign Up",
                    style: Theme.of(context).textTheme.headline3,
                  ),
                ),
                const Gap(20),
                TextFormField(
                  controller: nameController,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    label: Text("Name"),
                  ),
                ),
                const Gap(20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("What are you?"),
                ),
                DropdownButtonFormField<bool>(
                  value: isMaster.value,
                  onChanged: (value) {
                    if (value != null) {
                      isMaster.value = value;
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: false,
                      child: Text("I'm a Student"),
                    ),
                    DropdownMenuItem(
                      value: true,
                      child: Text("I'm a Teacher"),
                    ),
                  ],
                ),
                const Gap(10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(!isMaster.value ? "Session*" : "Job info*"),
                ),
                Row(
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 120),
                      child: DropdownButtonFormField<int>(
                        validator: (v) => v == null ? "Year is required" : null,
                        isExpanded: false,
                        value: year.value,
                        decoration: InputDecoration(
                          hintText: isMaster.value ? "Joining Year" : "Year",
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
                    const Gap(20),
                    if (!isMaster.value) ...[
                      const Spacer(),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 90),
                        child: DropdownButtonFormField<int>(
                          isExpanded: false,
                          validator: (v) =>
                              v == null ? "Class is required" : null,
                          decoration: const InputDecoration(hintText: "Class"),
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
                      const Spacer(),
                    ],
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 60),
                      child: TextFormField(
                        controller: serialController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: ValidationBuilder()
                            .regExp(
                              RegExp(r"^[1-9][0-9]{0,3}$"),
                              "Invalid ${isMaster.value ? "ID" : "roll"} (only 1-9999)",
                            )
                            .required()
                            .build(),
                        decoration: InputDecoration(
                          hintText: isMaster.value ? "ID" : "Roll",
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(10),
                if (isMaster.value)
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
                TextFormField(
                  controller: usernameController,
                  keyboardType: TextInputType.name,
                  validator: ValidationBuilder()
                      .regExp(
                        RegExp(r"^[a-z0-9]*$"),
                        "Only (a-z) and (0-9) are allowed",
                      )
                      .required("Username is required")
                      .build(),
                  decoration: const InputDecoration(
                    label: Text("Username"),
                  ),
                ),
                const Gap(10),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: ValidationBuilder()
                      .email()
                      .required("Email is required")
                      .build(),
                  decoration: const InputDecoration(
                    label: Text("Email"),
                  ),
                ),
                const Gap(20),
                TextFormField(
                  controller: passwordController,
                  obscureText: !visibility.value,
                  keyboardType:
                      visibility.value ? TextInputType.visiblePassword : null,
                  validator: ValidationBuilder()
                      .minLength(8, "Password must be more than 8 characters")
                      .required("Password is required")
                      .build(),
                  decoration: InputDecoration(
                    label: const Text("Password"),
                    suffix: IconButton(
                      icon: Icon(
                        !visibility.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => visibility.value = !visibility.value,
                    ),
                  ),
                ),
                const Gap(10),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: !visibility.value,
                  keyboardType:
                      visibility.value ? TextInputType.visiblePassword : null,
                  validator: (value) {
                    if (value != passwordController.text) {
                      return "Password doesn't match";
                    }
                    return ValidationBuilder()
                        .required("Confirm your password")
                        .build()(value);
                  },
                  decoration: InputDecoration(
                    label: const Text("Confirm Password"),
                    suffix: IconButton(
                      icon: Icon(
                        !visibility.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => visibility.value = !visibility.value,
                    ),
                  ),
                ),
                const Gap(10),
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
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(
                        40), // fromHeight use double.infinity as width and 40 is the height
                  ),
                  onPressed: isLoading.value
                      ? null
                      : () async {
                          try {
                            if (formKey.currentState?.validate() != true)
                              return;
                            isLoading.value = true;
                            final user = await authNotifier.signup(
                              name: nameController.text,
                              email: emailController.text,
                              username: usernameController.text,
                              password: passwordController.text,
                              passwordConfirm: confirmPasswordController.text,
                              session: SessionObject(
                                year: year.value!,
                                standard: standard.value,
                                serial: int.parse(serialController.text),
                                subject: subject.value,
                              ),
                              isMaster: isMaster.value,
                            );
                            if (user == null) {
                              error.value = "User already exists";
                              return;
                            }
                            formKey.currentState?.reset();
                            if (mounted()) error.value = null;
                          } on ClientException catch (e) {
                            error.value = e.response["message"];
                          } finally {
                            if (mounted()) {
                              isLoading.value = false;
                            }
                          }
                        },
                  child: const Text("Signup"),
                ),
                const Gap(10),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(
                        40), // fromHeight use double.infinity as width and 40 is the height
                  ),
                  onPressed: isLoading.value
                      ? null
                      : () {
                          if (GoRouter.of(context).canPop()) {
                            GoRouter.of(context).pop();
                          }
                          GoRouter.of(context).push("/login");
                        },
                  child: const Text("Login"),
                ),
                const Gap(30),
              ],
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(),
      body: body,
    );
  }
}
