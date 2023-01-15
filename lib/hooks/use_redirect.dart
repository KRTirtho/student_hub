import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

void useRedirect(String path, [bool condition = true]) {
  final context = useContext();

  useEffect(() {
    if (condition) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        GoRouter.of(context).go(path);
      });
    }
    return;
  }, [condition, path]);
}
