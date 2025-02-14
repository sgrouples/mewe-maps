import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mewe_maps/models/user.dart';

part 'followed.g.dart';

@JsonSerializable()
class Followed extends Equatable {
  @JsonKey(name: "user")
  final User user;

  @JsonKey(name: "follower")
  final bool? follower;

  const Followed({required this.user, required this.follower});

  @override
  List<Object?> get props => [user, follower];

  factory Followed.fromJson(Map<String, dynamic> json) => _$FollowedFromJson(json);

  Map<String, dynamic> toJson() => _$FollowedToJson(this);
}
