import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mewe_maps/models/followed.dart';
import 'package:mewe_maps/models/hal_links.dart';

part 'get_followed_response.g.dart';

@JsonSerializable()
class GetFollowedResponse extends Equatable {
  final List<Followed> list;

  @JsonKey(name: "_links")
  final HalLinks? halLinks;

  const GetFollowedResponse({
    required this.list,
    this.halLinks,
  });

  @override
  List<Object?> get props => [list, halLinks];

  factory GetFollowedResponse.fromJson(Map<String, dynamic> json) => _$GetFollowedResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetFollowedResponseToJson(this);
}
