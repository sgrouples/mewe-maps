import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contact_sharing_data.g.dart';

@JsonSerializable()
class ContactSharingData extends Equatable {

  @JsonKey(name: "id")
  final int id;

  @JsonKey(name: "owner_user_data")
  final String userDataRaw;

  @JsonKey(name: "share_until")
  final DateTime shareUntil;

  @JsonKey(name: "owner_id")
  final String contactId;

  @JsonKey(name: "shared_data")
  final SharedData data;

  @override
  List<Object?> get props => [id, userDataRaw, data, shareUntil, contactId];

  const ContactSharingData({required this.id,  required this.userDataRaw, required this.data, required this.shareUntil, required this.contactId});

  factory ContactSharingData.fromJson(Map<String, dynamic> json) => _$ContactSharingDataFromJson(json);

  Map<String, dynamic> toJson() => _$ContactSharingDataToJson(this);

}

@JsonSerializable()
class SharedData extends Equatable {
  @JsonKey(name: "location_data")
  final String positionDataRaw;

  @JsonKey(name: "updated_at")
  final DateTime updatedAt;

  @override
  List<Object?> get props => [positionDataRaw, updatedAt];

  const SharedData({required this.positionDataRaw, required this.updatedAt});

  factory SharedData.fromJson(Map<String, dynamic> json) => _$SharedDataFromJson(json);

  Map<String, dynamic> toJson() => _$SharedDataToJson(this);
}
