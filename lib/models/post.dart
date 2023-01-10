import 'package:eusc_freaks/models/comment.dart';
import 'package:eusc_freaks/models/user.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pocketbase/pocketbase.dart';
part 'post.g.dart';

@JsonSerializable()
class Post extends RecordModel {
  final String title;
  final String description;

  final User? user;
  final List<Comment> comments;

  Post({
    required this.title,
    required this.description,
    this.user,
    this.comments = const [],
  }) : super();

  factory Post.fromRecord(RecordModel record) {
    final json = record.toJson();
    return Post.fromJson(json);
  }

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson({
        ...json,
        "user": json["expand"]["user"],
        "comments": [...?json["expand"]["comments(post)"]],
      });

  @override
  Map<String, dynamic> toJson() => _$PostToJson(this);
}
