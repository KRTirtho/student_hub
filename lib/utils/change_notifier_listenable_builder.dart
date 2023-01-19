import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ChangeNotifierListenableBuilder<T extends ChangeNotifier>
    extends HookWidget {
  final T notifier;
  final Widget Function(BuildContext context, T notifier) builder;
  const ChangeNotifierListenableBuilder({
    Key? key,
    required this.notifier,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final update = useState(false);
    final mounted = useIsMounted();

    useEffect(() {
      listener() {
        if (mounted()) update.value = !update.value;
      }

      notifier.addListener(listener);
      return () {
        notifier.removeListener(listener);
      };
    }, [notifier]);

    return builder(context, notifier);
  }
}
