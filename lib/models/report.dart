import 'package:eusc_freaks/mixins/enum_formatted_name.dart';
import 'package:eusc_freaks/models/user.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pocketbase/pocketbase.dart';

part 'report.g.dart';

enum ReportReason with FormattedName {
  @JsonValue('hate_speech')
  hate_speech,
  @JsonValue('violence')
  violence,
  @JsonValue('nudity')
  nudity,
  @JsonValue('harassment')
  harassment,
  @JsonValue('spam')
  spam,
  @JsonValue('fake')
  fake,
  @JsonValue('other')
  other;

  factory ReportReason.fromName(String value) {
    return ReportReason.values.firstWhere((e) => e.toString() == value);
  }
}

enum ReportCollection {
  @JsonValue('user')
  user,
  @JsonValue('post')
  post,
  @JsonValue('comment')
  comment,
  @JsonValue('book')
  book,
}

@JsonSerializable()
class Report extends RecordModel {
  ReportReason reason;
  ReportCollection collection;
  String record;
  String? description;
  User? user;

  Report({
    required this.reason,
    required this.collection,
    required this.record,
    this.description,
    this.user,
  });

  factory Report.fromRecord(RecordModel record) {
    return Report.fromJson(record.toJson());
  }

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson({
        ...json,
        'user': json['expand']?['user'],
      });

  @override
  Map<String, dynamic> toJson() => _$ReportToJson(this);
}
