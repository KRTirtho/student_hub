import 'package:eusc_freaks/components/image/universal_image.dart';
import 'package:eusc_freaks/providers/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_validator/form_validator.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

class SignupPage extends HookConsumerWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final usernameController = useTextEditingController();
    final nameController = useTextEditingController();
    final visibility = useState(false);
    final error = useState<String?>(null);
    final authNotifier = ref.watch(authenticationProvider.notifier);
    final user = ref.watch(authenticationProvider);
    final formKey = GlobalKey<FormState>();

    useEffect(
      () {
        if (user != null && user.verified) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            GoRouter.of(context).go("/");
          });
        }
        return null;
      },
      [user],
    );

    Widget body = SingleChildScrollView(
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: formKey,
        child: Column(
          children: [
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: const UniversalImage(
                path: "assets/logo.jpg",
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
              onPressed: () async {
                try {
                  if (formKey.currentState?.validate() != true) return;
                  final user = await authNotifier.signup(
                    name: nameController.text,
                    email: emailController.text,
                    username: usernameController.text,
                    password: passwordController.text,
                    passwordConfirm: confirmPasswordController.text,
                  );
                  if (user == null) {
                    error.value = "User already exists";
                    return;
                  }
                  formKey.currentState?.reset();
                  error.value = null;
                } on ClientException catch (e) {
                  error.value = e.response["message"];
                }
              },
              child: const Text("Signup"),
            ),
            const Gap(10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(
                    40), // fromHeight use double.infinity as width and 40 is the height
              ),
              onPressed: () {
                if (GoRouter.of(context).canPop()) {
                  GoRouter.of(context).pop();
                }
                GoRouter.of(context).push("/login");
              },
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(),
      extendBodyBehindAppBar: true,
      body: body,
    );
  }
}
