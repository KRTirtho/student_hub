import 'package:student_hub/collections/pocketbase.dart';
import 'package:student_hub/models/book_tags.dart';
import 'package:student_hub/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pocketbase/pocketbase.dart';

part 'book.g.dart';

@JsonSerializable()
class Book extends RecordModel {
  final String title;
  final String? bio;
  final String author;
  final User? user;
  final List<BookTag> tags;
  final String media;
  @JsonKey(name: 'external_url')
  final String? externalUrl;
  final String thumbnail;

  Book({
    required this.title,
    required this.author,
    required this.user,
    required this.tags,
    required this.media,
    required this.thumbnail,
    this.bio,
    this.externalUrl,
  });

  Uri getMediaURL() {
    return pb.getFileUrl(this, media);
  }

  Uri getThumbnailURL([Size? size]) {
    assert(
      size?.height != double.infinity && size?.width != double.infinity,
      "Infinity is not a valid size",
    );
    return pb.getFileUrl(
      this,
      thumbnail,
      thumb:
          size != null ? "${size.width.toInt()}x${size.height.toInt()}" : null,
    );
  }

  factory Book.fromRecord(RecordModel record) => Book.fromJson(record.toJson());

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson({
        ...json,
        'user': json['expand']?['user'],
        'tags': json['expand']?['tags']
      });

  @override
  Map<String, dynamic> toJson() => _$BookToJson(this);
}
