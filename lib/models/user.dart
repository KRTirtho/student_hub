import 'package:eusc_freaks/collections/pocketbase.dart';
import 'package:eusc_freaks/mixins/enum_formatted_name.dart';
import 'package:flutter/animation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';
import 'package:pocketbase/pocketbase.dart';
part 'user.g.dart';

enum Subject with FormattedName {
  bangla,
  english,
  math,
  physics,
  chemistry,
  biology,
  ict,
  accounting,
  economics,
  religion,
  art,
  music,
  physical_education,
  social_studies,
  bushiness_studies,
  agriculture;

  static Subject? tryFromName(String name) {
    return Subject.values.firstWhereOrNull((element) => element.name == name);
  }
}

enum UserBanReason with FormattedName {
  @JsonValue('hate_speech')
  hate_speech,
  @JsonValue('violence')
  violence,
  @JsonValue('nudity')
  nudity,
  @JsonValue('harassment')
  harassment,
  @JsonValue('spam')
  spam,
  @JsonValue('fake')
  fake;

  factory UserBanReason.fromName(String value) {
    return UserBanReason.values.firstWhere((e) => e.toString() == value);
  }
}

class SessionObject {
  final int year;
  final int? standard;
  final int serial;
  final Subject? subject;

  /// follows this pattern
  ///  ```regex
  /// (^((20\d{2}-[1-12]{1,2}-[1-9][0-9]{0,3}),?)+$)|(^20\d{2}-(bangla|english|math
  /// |physics|chemistry|biology|ict|accounting|economics|religion|art|music|
  /// physical_education|social_studies|bushiness_studies|agriculture)
  /// -[1-9][0-9]{0,3}$)
  /// ```
  SessionObject({
    required this.year,
    required this.serial,
    required this.standard,
    required this.subject,
  })  : assert(year >= 2000 && year <= 2099),
        assert(standard == null || standard >= 1 && standard <= 12),
        assert(serial >= 1 && serial <= 9999);

  factory SessionObject.fromString(String session) {
    final slopes = session.split("-");
    return SessionObject(
      year: int.parse(slopes[0]),
      standard: int.tryParse(slopes[1]),
      subject: Subject.tryFromName(slopes[1]),
      serial: int.parse(slopes[2]),
    );
  }

  bool get isMaster => standard == null && subject != null;

  @override
  String toString() {
    return "$year-${standard ?? subject?.name}-$serial";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SessionObject &&
        other.year == year &&
        other.standard == standard &&
        other.serial == serial &&
        other.subject == subject;
  }

  @override
  int get hashCode =>
      year.hashCode ^ standard.hashCode ^ serial.hashCode ^ subject.hashCode;
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
  @JsonKey()
  final String avatar;
  @JsonKey(
    name: 'ban_until',
    fromJson: DateTime.tryParse,
  )
  final DateTime? bannedUntil;
  @JsonKey(name: 'ban_reason')
  final List<UserBanReason> banReason;

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
    required this.avatar,
    this.bannedUntil,
    this.banReason = const [],
    this.name,
  }) : sessionObjects = sessions.isEmpty
            ? {}
            : sessions
                .split(",")
                .map((e) => SessionObject.fromString(e))
                .toList()
                .sortedBy<num>((e) => e.year)
                .toSet();

  Uri getAvatarURL([Size? size]) {
    assert(
      size?.height != double.infinity && size?.width != double.infinity,
      "Size cannot be infinite",
    );
    return pb.getFileUrl(
      this,
      avatar,
      thumb:
          size != null ? "${size.width.toInt()}x${size.height.toInt()}" : null,
    );
  }

  bool get isBanned =>
      bannedUntil != null && bannedUntil!.isAfter(DateTime.now());

  factory User.fromRecord(RecordModel record) => User.fromJson(record.toJson());

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
