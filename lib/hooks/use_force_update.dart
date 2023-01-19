import 'package:flutter_hooks/flutter_hooks.dart';

void Function() useForceUpdate() {
  final state = useState(false);
  final mounted = useIsMounted();
  return () {
    if (mounted()) {
      state.value = !state.value;
    }
  };
}
