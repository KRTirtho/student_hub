import 'package:student_hub/collections/pocketbase.dart';
import 'package:student_hub/models/post.dart';
import 'package:student_hub/models/user.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pocketbase/pocketbase.dart';
part 'comment.g.dart';

@JsonSerializable()
class Comment extends RecordModel {
  final String comment;
  final Post? post;
  final User? user;
  final List<String> media;
  final bool solve;

  Comment({
    required this.comment,
    required this.solve,
    this.media = const [],
    this.post,
    this.user,
  }) : super();

  List<Uri> getMediaURL([Size? size]) {
    assert(
      size?.height != double.infinity && size?.width != double.infinity,
      "Size cannot be infinite",
    );
    return media.map((e) {
      return pb.getFileUrl(
        this,
        e,
        thumb: size != null ? "${size.height}x${size.width}" : null,
      );
    }).toList();
  }

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
