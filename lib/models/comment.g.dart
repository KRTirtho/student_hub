// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      comment: json['comment'] as String,
      post: json['post'] == null
          ? null
          : Post.fromJson(json['post'] as Map<String, dynamic>),
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    )
      ..id = json['id'] as String
      ..created = json['created'] as String
      ..updated = json['updated'] as String
      ..collectionId = json['collectionId'] as String
      ..collectionName = json['collectionName'] as String;

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'id': instance.id,
      'created': instance.created,
      'updated': instance.updated,
      'collectionId': instance.collectionId,
      'collectionName': instance.collectionName,
      'comment': instance.comment,
      'post': instance.post,
      'user': instance.user,
    };
