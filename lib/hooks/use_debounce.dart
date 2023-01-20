import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';

T useDebounce<T>(T value, [double delay = 500]) {
  final debounced = useState<T>(value);

  useEffect(() {
    final timer = Timer(Duration(milliseconds: delay.toInt()), () {
      debounced.value = value;
    });

    return () => timer.cancel();
  }, [value, delay]);

  return debounced.value;
}
