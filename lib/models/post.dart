import 'package:eusc_freaks/models/comment.dart';
import 'package:eusc_freaks/models/user.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pocketbase/pocketbase.dart';
part 'post.g.dart';

enum PostType {
  @JsonValue('announcement')
  announcement,
  @JsonValue('question')
  question,
  @JsonValue('informative')
  informative;

  static PostType fromName(String type) {
    return PostType.values.firstWhere((element) {
      return element.name == type;
    });
  }
}

@JsonSerializable()
class Post extends RecordModel {
  final String title;
  final String description;

  final User? user;
  final List<Comment> comments;

  final PostType type;

  Post({
    required this.title,
    required this.description,
    required this.type,
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
