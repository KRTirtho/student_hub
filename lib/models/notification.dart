import 'package:eusc_freaks/mixins/enum_formatted_name.dart';
import 'package:eusc_freaks/models/comment.dart';
import 'package:eusc_freaks/models/post.dart';
import 'package:eusc_freaks/models/user.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pocketbase/pocketbase.dart';
part 'notification.g.dart';

enum NotificationCollection with FormattedName {
  posts,
  users,
  comments;

  factory NotificationCollection.fromName(String name) {
    return NotificationCollection.values.firstWhere((e) => e.name == name);
  }
}

@JsonSerializable()
class Notification extends RecordModel {
  String record;
  NotificationCollection collection;
  String message;
  User? user;
  bool viewed;

  Post? post;
  Comment? comment;

  Notification({
    required this.record,
    required this.collection,
    required this.message,
    this.user,
    this.viewed = false,
  });

  factory Notification.fromRecord(RecordModel record) =>
      Notification.fromJson(record.toJson());

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson({
        ...json,
        'user': json['expand']?['user'],
        'post': json['expand']?['post']?.first,
        'comment': json['expand']?['comment']?.first,
      });

  @override
  Map<String, dynamic> toJson() => _$NotificationToJson(this);
}
