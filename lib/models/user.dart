import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';
import 'package:pocketbase/pocketbase.dart';
part 'user.g.dart';

class SessionObject {
  final int year;
  final int standard;
  final int serial;

  /// follows this pattern `^(20\d{2}-[1-12]{1,2}-[1-9][0-9]{0,3},?)+$`
  SessionObject({
    required this.year,
    required this.standard,
    required this.serial,
  })  : assert(year >= 2000 && year <= 2099),
        assert(standard >= 1 && standard <= 12),
        assert(serial >= 1 && serial <= 9999);

  factory SessionObject.fromString(String session) {
    final slopes = session.split("-");
    return SessionObject(
      year: int.parse(slopes[0]),
      standard: int.parse(slopes[1]),
      serial: int.parse(slopes[2]),
    );
  }

  @override
  String toString() {
    return "$year-$standard-$serial";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SessionObject &&
        other.year == year &&
        other.standard == standard &&
        other.serial == serial;
  }

  @override
  int get hashCode => year.hashCode ^ standard.hashCode ^ serial.hashCode;
}

@JsonSerializable(explicitToJson: true)
class User extends RecordModel {
  @JsonKey()
  final String username;
  @JsonKey()
  final String email;
  @JsonKey()
  final bool emailVisibility;
  @JsonKey()
  final bool verified;
  @JsonKey()
  final String? name;
  @JsonKey()
  final bool isMaster;
  @JsonKey()
  final String sessions;

  @JsonKey(ignore: true)
  final Set<SessionObject> sessionObjects;

  SessionObject? get currentSession {
    if (sessionObjects.isEmpty) return null;
    final currentYear = DateTime.now().year;
    return sessionObjects
            .firstWhereOrNull((element) => element.year == currentYear) ??
        sessionObjects.last;
  }

  User({
    required this.username,
    required this.email,
    required this.emailVisibility,
    required this.verified,
    required this.isMaster,
    required this.sessions,
    this.name,
  }) : sessionObjects = sessions.isEmpty
            ? {}
            : sessions
                .split(",")
                .map((e) => SessionObject.fromString(e))
                .toList()
                .sorted((a, b) => a.year.compareTo(b.year))
                .toSet();

  factory User.fromRecord(RecordModel record) => User.fromJson(record.toJson());

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
