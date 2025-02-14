import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'challenges_response.g.dart';

@JsonSerializable()
class ChallengesResponse extends Equatable {
  static const String challengeCaptcha = 'hCaptcha';
  static const String challengeArkose = 'arkose';

  final List<String> challenges;

  const ChallengesResponse({required this.challenges});

  @override
  List<Object?> get props => [challenges];

  factory ChallengesResponse.fromJson(Map<String, dynamic> json) => _$ChallengesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChallengesResponseToJson(this);
}
