// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
      record: json['record'] as String,
      collection:
          $enumDecode(_$NotificationCollectionEnumMap, json['collection']),
      message: json['message'] as String,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      viewed: json['viewed'] as bool? ?? false,
    )
      ..id = json['id'] as String
      ..created = json['created'] as String
      ..updated = json['updated'] as String
      ..collectionId = json['collectionId'] as String
      ..collectionName = json['collectionName'] as String;

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created': instance.created,
      'updated': instance.updated,
      'collectionId': instance.collectionId,
      'collectionName': instance.collectionName,
      'record': instance.record,
      'collection': _$NotificationCollectionEnumMap[instance.collection]!,
      'message': instance.message,
      'user': instance.user,
      'viewed': instance.viewed,
    };

const _$NotificationCollectionEnumMap = {
  NotificationCollection.posts: 'posts',
  NotificationCollection.users: 'users',
  NotificationCollection.comments: 'comments',
};
