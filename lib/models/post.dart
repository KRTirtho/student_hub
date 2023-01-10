import 'package:eusc_freaks/models/user.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pocketbase/pocketbase.dart';
part 'post.g.dart';

@JsonSerializable()
class Post extends RecordModel {
  final String title;
  final String description;

  final User? user;

  Post({
    required this.title,
    required this.description,
    this.user,
  }) : super();

  factory Post.fromRecord(RecordModel record) {
    final map = record.toJson();
    return Post.fromJson({
      ...map,
      "user": map["user"] is String ? map["expand"]["user"] : null,
    });
  }

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PostToJson(this);
}
