import 'package:eusc_freaks/models/user.dart';
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
}
