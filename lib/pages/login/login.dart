import 'package:eusc_freaks/components/image/universal_image.dart';
import 'package:eusc_freaks/hooks/use_redirect.dart';
import 'package:eusc_freaks/providers/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_validator/form_validator.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final visibility = useState(false);
    final formKey = GlobalKey<FormState>();
    final authNotifier = ref.watch(authenticationProvider.notifier);
    final user = ref.watch(authenticationProvider);
    final mounted = useIsMounted();
    final error = useState(false);

    useRedirect("/", user != null);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
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
                  "Login",
                  style: Theme.of(context).textTheme.headline3,
                ),
              ),
              const Gap(20),
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
              const Gap(10),
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
                  isDense: true,
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
              if (error.value)
                Text(
                  "Failed to Login. User doesn't exist",
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      ?.copyWith(color: Colors.red),
                ),
              const Gap(20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(
                    40,
                  ), // fromHeight use double.infinity as width and 40 is the height
                ),
                onPressed: () async {
                  try {
                    if (formKey.currentState?.validate() != true) return;
                    final user = await authNotifier.login(
                      emailController.text,
                      passwordController.text,
                    );
                    if (user == null) {
                      error.value = true;
                      return;
                    }
                    formKey.currentState?.reset();
                    error.value = false;
                    if (mounted()) GoRouter.of(context).go("/");
                  } on Exception {
                    error.value = true;
                  }
                },
                child: const Text("Login"),
              ),
              const Gap(10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(
                    40,
                  ), // fromHeight use double.infinity as width and 40 is the height
                ),
                onPressed: () {
                  if (GoRouter.of(context).canPop()) GoRouter.of(context).pop();
                  GoRouter.of(context).push("/signup");
                },
                child: const Text("Signup"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
