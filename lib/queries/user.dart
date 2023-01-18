import 'package:eusc_freaks/collections/pocketbase.dart';
import 'package:eusc_freaks/models/user.dart';
import 'package:fl_query/fl_query.dart';

final userQueryJob = QueryJob.withVariableKey<User, User?>(
  preQueryKey: 'user',
  refetchOnExternalDataChange: true,
  task: (queryKey, authUser) async {
    if (getVariable(queryKey) == "authenticated" && authUser != null) {
      return authUser;
    }
    final record = await pb.collection('users').getOne(
          getVariable(queryKey),
        );
    return User.fromRecord(record);
  },
);
