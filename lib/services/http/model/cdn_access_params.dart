// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cdn_access_params.g.dart';

@JsonSerializable()
class CdnAccessParams extends Equatable {
  @JsonKey(name: 'CloudFront-Key-Pair-Id')
  final String? cloudFrontKeyPairId;

  @JsonKey(name: 'CloudFront-Signature')
  final String? cloudFrontSignature;

  @JsonKey(name: 'CloudFront-Policy')
  final String? cloudFrontPolicy;

  const CdnAccessParams({
    this.cloudFrontKeyPairId,
    this.cloudFrontSignature,
    this.cloudFrontPolicy,
  });

  @override
  List<Object?> get props => [cloudFrontKeyPairId, cloudFrontSignature, cloudFrontPolicy];

  String buildCdnCookie() {
    return 'CloudFront-Policy=$cloudFrontPolicy; CloudFront-Signature=$cloudFrontSignature; CloudFront-Key-Pair-Id=$cloudFrontKeyPairId;';
  }

  factory CdnAccessParams.fromJson(Map<String, dynamic> json) => _$CdnAccessParamsFromJson(json);

  Map<String, dynamic> toJson() => _$CdnAccessParamsToJson(this);
}
