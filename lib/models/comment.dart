import 'package:eusc_freaks/models/post.dart';
import 'package:eusc_freaks/models/user.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pocketbase/pocketbase.dart';
part 'comment.g.dart';

@JsonSerializable()
class Comment extends RecordModel {
  final String comment;
  final Post? post;
  final User? user;

  Comment({
    required this.comment,
    this.post,
    this.user,
  }) : super();

  factory Comment.fromRecord(RecordModel record) {
    final map = record.toJson();

    return Comment.fromJson(map);
  }

  factory Comment.fromJson(Map<String, dynamic> map) {
    return _$CommentFromJson({
      ...map,
      "post": map["expand"]?["post"],
      "user": map["expand"]?["user"],
    });
  }

  @override
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
