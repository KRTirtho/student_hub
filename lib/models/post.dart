import 'package:eusc_freaks/collections/pocketbase.dart';
import 'package:eusc_freaks/models/user.dart';
import 'package:flutter/material.dart';
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
  final List<String> comments;

  final PostType type;
  final List<String> media;

  Post({
    required this.title,
    required this.description,
    required this.type,
    this.user,
    this.media = const [],
    this.comments = const [],
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
        thumb: size != null
            ? "${size.width.toInt()}x${size.height.toInt()}"
            : null,
      );
    }).toList();
  }

  factory Post.fromRecord(RecordModel record) {
    final json = record.toJson();
    return Post.fromJson(json);
  }

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson({
        ...json,
        "user": json["expand"]["user"],
      });

  @override
  Map<String, dynamic> toJson() => _$PostToJson(this);
}
