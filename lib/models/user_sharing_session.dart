
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_sharing_session.g.dart';

@JsonSerializable()
class UserSharingSession extends Equatable {

  @JsonKey(name: "id")
  final int id;

  @JsonKey(name: "recipient_id")
  final String recipientId;

  @JsonKey(name: "recipient_user_data")
  final String recipientDataRaw;

  @JsonKey(name: "share_until")
  final DateTime shareUntil;

  @JsonKey(name: "is_precise")
  final bool isPrecise;

  @override
  List<Object?> get props => [id, recipientId, recipientDataRaw, shareUntil, isPrecise];

  const UserSharingSession({required this.id, required this.recipientId, required this.recipientDataRaw, required this.shareUntil, required this.isPrecise});

  factory UserSharingSession.fromJson(Map<String, dynamic> json) => _$UserSharingSessionFromJson(json);

  Map<String, dynamic> toJson() => _$UserSharingSessionToJson(this);

}
