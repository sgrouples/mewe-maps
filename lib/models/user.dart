import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mewe_maps/models/hal_links.dart';
import 'package:mewe_maps/repositories/storage/storage_repository.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Equatable {
  @JsonKey(name: "id")
  final String userId;

  @JsonKey(name: "name")
  final String name;

  @JsonKey(name: "publicLinkId")
  final String publicLinkId;

  @JsonKey(name: "_links")
  final HalLinks halLinks;

  const User({required this.userId, required this.name, required this.publicLinkId, required this.halLinks});

  bool isMe() {
    return userId == StorageRepository.user?.userId;
  }

  @override
  List<Object?> get props => [userId, name, publicLinkId, halLinks];

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
