// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$PostTypeEnumMap, json['type']),
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      comments: (json['comments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    )
      ..id = json['id'] as String
      ..created = json['created'] as String
      ..updated = json['updated'] as String
      ..collectionId = json['collectionId'] as String
      ..collectionName = json['collectionName'] as String;

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'id': instance.id,
      'created': instance.created,
      'updated': instance.updated,
      'collectionId': instance.collectionId,
      'collectionName': instance.collectionName,
      'title': instance.title,
      'description': instance.description,
      'user': instance.user,
      'comments': instance.comments,
      'type': _$PostTypeEnumMap[instance.type]!,
    };

const _$PostTypeEnumMap = {
  PostType.announcement: 'announcement',
  PostType.question: 'question',
  PostType.informative: 'informative',
};
