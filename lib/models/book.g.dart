// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Book _$BookFromJson(Map<String, dynamic> json) => Book(
      title: json['title'] as String,
      author: json['author'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      tags: (json['tags'] as List<dynamic>)
          .map((e) => BookTag.fromJson(e as Map<String, dynamic>))
          .toList(),
      media: json['media'] as String,
      bio: json['bio'] as String?,
      externalUrl: json['external_url'] as String?,
      thumbnail: json['thumbnail'] as String,
    )
      ..id = json['id'] as String
      ..created = json['created'] as String
      ..updated = json['updated'] as String
      ..collectionId = json['collectionId'] as String
      ..collectionName = json['collectionName'] as String;

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
      'id': instance.id,
      'created': instance.created,
      'updated': instance.updated,
      'collectionId': instance.collectionId,
      'collectionName': instance.collectionName,
      'title': instance.title,
      'bio': instance.bio,
      'author': instance.author,
      'user': instance.user,
      'tags': instance.tags,
      'media': instance.media,
      'external_url': instance.externalUrl,
      'thumbnail': instance.thumbnail,
    };
