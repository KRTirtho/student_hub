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
    };
