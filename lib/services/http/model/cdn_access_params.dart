import 'package:json_annotation/json_annotation.dart';

part 'cdn_access_params.g.dart';

@JsonSerializable()
class CdnAccessParams {
  @JsonKey(name: 'CloudFront-Key-Pair-Id')
  String? cloudFrontKeyPairId;

  @JsonKey(name: 'CloudFront-Signature')
  String? cloudFrontSignature;

  @JsonKey(name: 'CloudFront-Policy')
  String? cloudFrontPolicy;

  CdnAccessParams({
    this.cloudFrontKeyPairId,
    this.cloudFrontSignature,
    this.cloudFrontPolicy,
  });

  String buildCdnCookie() {
    return 'CloudFront-Policy=$cloudFrontPolicy; CloudFront-Signature=$cloudFrontSignature; CloudFront-Key-Pair-Id=$cloudFrontKeyPairId;';
  }

  factory CdnAccessParams.fromJson(Map<String, dynamic> json) => _$CdnAccessParamsFromJson(json);

  Map<String, dynamic> toJson() => _$CdnAccessParamsToJson(this);
}
