// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Report _$ReportFromJson(Map<String, dynamic> json) => Report(
      reason: $enumDecode(_$ReportReasonEnumMap, json['reason']),
      collection: $enumDecode(_$ReportCollectionEnumMap, json['collection']),
      record: json['record'] as String,
      description: json['description'] as String?,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    )
      ..id = json['id'] as String
      ..created = json['created'] as String
      ..updated = json['updated'] as String
      ..collectionId = json['collectionId'] as String
      ..collectionName = json['collectionName'] as String;

Map<String, dynamic> _$ReportToJson(Report instance) => <String, dynamic>{
      'id': instance.id,
      'created': instance.created,
      'updated': instance.updated,
      'collectionId': instance.collectionId,
      'collectionName': instance.collectionName,
      'reason': _$ReportReasonEnumMap[instance.reason]!,
      'collection': _$ReportCollectionEnumMap[instance.collection]!,
      'record': instance.record,
      'description': instance.description,
      'user': instance.user,
    };

const _$ReportReasonEnumMap = {
  ReportReason.hate_speech: 'hate_speech',
  ReportReason.violence: 'violence',
  ReportReason.nudity: 'nudity',
  ReportReason.harassment: 'harassment',
  ReportReason.spam: 'spam',
  ReportReason.fake: 'fake',
  ReportReason.other: 'other',
};

const _$ReportCollectionEnumMap = {
  ReportCollection.user: 'user',
  ReportCollection.post: 'post',
  ReportCollection.comment: 'comment',
  ReportCollection.book: 'book',
};
