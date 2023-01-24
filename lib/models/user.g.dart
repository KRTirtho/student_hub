// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      username: json['username'] as String,
      email: json['email'] as String,
      emailVisibility: json['emailVisibility'] as bool,
      verified: json['verified'] as bool,
      isMaster: json['isMaster'] as bool,
      sessions: json['sessions'] as String,
      avatar: json['avatar'] as String,
      bannedUntil: parseDate(json['ban_until'] as String?),
      bannedBy: json['banned_by'] as String?,
      banReason: (json['ban_reason'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$UserBanReasonEnumMap, e))
              .toList() ??
          const [],
      name: json['name'] as String?,
    )
      ..id = json['id'] as String
      ..created = json['created'] as String
      ..updated = json['updated'] as String
      ..collectionId = json['collectionId'] as String
      ..collectionName = json['collectionName'] as String;

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'created': instance.created,
      'updated': instance.updated,
      'collectionId': instance.collectionId,
      'collectionName': instance.collectionName,
      'username': instance.username,
      'email': instance.email,
      'emailVisibility': instance.emailVisibility,
      'verified': instance.verified,
      'name': instance.name,
      'isMaster': instance.isMaster,
      'sessions': instance.sessions,
      'avatar': instance.avatar,
      'ban_until': instance.bannedUntil?.toIso8601String(),
      'ban_reason':
          instance.banReason.map((e) => _$UserBanReasonEnumMap[e]!).toList(),
      'banned_by': instance.bannedBy,
    };

const _$UserBanReasonEnumMap = {
  UserBanReason.hate_speech: 'hate_speech',
  UserBanReason.violence: 'violence',
  UserBanReason.nudity: 'nudity',
  UserBanReason.harassment: 'harassment',
  UserBanReason.spam: 'spam',
  UserBanReason.fake: 'fake',
};
