import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hal_link.g.dart';

@JsonSerializable()
class HalLink extends Equatable {
  @JsonKey(name: "href")
  final String href;

  const HalLink({required this.href});

  @override
  List<Object?> get props => [href];

  factory HalLink.fromJson(Map<String, dynamic> json) => _$HalLinkFromJson(json);

  Map<String, dynamic> toJson() => _$HalLinkToJson(this);
}
