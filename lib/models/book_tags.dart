import 'package:student_hub/models/user.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pocketbase/pocketbase.dart';

part 'book_tags.g.dart';

@JsonSerializable()
class BookTag extends RecordModel {
  final String tag;
  final User? user;

  BookTag({
    required this.tag,
    this.user,
  });

  factory BookTag.fromRecord(RecordModel record) =>
      BookTag.fromJson(record.toJson());

  factory BookTag.fromJson(Map<String, dynamic> json) => _$BookTagFromJson({
        ...json,
        'user': json['expand']?['user'],
      });

  @override
  Map<String, dynamic> toJson() => _$BookTagToJson(this);

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is BookTag &&
          runtimeType == other.runtimeType &&
          tag == other.tag &&
          user == other.user &&
          id == other.id &&
          created == other.created &&
          updated == other.updated;

  @override
  int get hashCode =>
      tag.hashCode ^
      user.hashCode ^
      id.hashCode ^
      created.hashCode ^
      updated.hashCode;
}
