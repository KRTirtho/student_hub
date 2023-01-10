import 'package:json_annotation/json_annotation.dart';
import 'package:pocketbase/pocketbase.dart';
part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class User extends RecordModel {
  @JsonKey()
  final String username;
  @JsonKey()
  final String email;
  @JsonKey()
  final bool emailVisibility;
  @JsonKey()
  final bool verified;

  User({
    required this.username,
    required this.email,
    required this.emailVisibility,
    required this.verified,
  });

  factory User.fromRecord(RecordModel record) => User.fromJson(record.toJson());

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
