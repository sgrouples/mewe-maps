// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

import 'package:dio/dio.dart';
import 'package:mewe_maps/services/http/model/challenges_response.dart';
import 'package:mewe_maps/services/http/model/get_followed_response.dart';
import 'package:mewe_maps/services/http/model/login_with_password_response.dart';
import 'package:mewe_maps/services/http/model/signin_request.dart';
import 'package:mewe_maps/services/http/model/signin_response.dart';
import 'package:retrofit/http.dart' as http;
import 'package:retrofit/error_logger.dart';

part 'mewe_service.g.dart';

@http.RestApi()
abstract class MeWeService {
  factory MeWeService(Dio dio, {String baseUrl}) = _MeWeService;

  @http.GET('/api/v2/account/challenges-available')
  @http.FormUrlEncoded()
  Future<ChallengesResponse> getChallenges();

  @http.POST('/api/v2/auth/login')
  @http.FormUrlEncoded()
  Future<LoginWithPasswordResponse> loginByEmail(@http.Field() String username, @http.Field() String password);

  @http.POST('/api/v2/auth/login')
  @http.FormUrlEncoded()
  Future<LoginWithPasswordResponse> loginByNumber(@http.Field() String phoneNumber, @http.Field() String password);

  @http.POST('/api/v2/auth/login')
  @http.FormUrlEncoded()
  Future<LoginWithPasswordResponse> loginByEmailWithChallenge(@http.Field() String username, @http.Field() String password,
      @http.Field("challenge_provider") String challenge, @http.Field("session_token") String challengeToken);

  @http.POST('/api/v2/auth/login')
  @http.FormUrlEncoded()
  Future<LoginWithPasswordResponse> loginByNumberWithChallenge(@http.Field() String phoneNumber, @http.Field() String password,
      @http.Field("challenge_provider") String challenge, @http.Field("session_token") String challengeToken);

  @http.GET('/api/v2/following/followed')
  @http.FormUrlEncoded()
  Future<GetFollowedResponse> getFollowed();

  @http.GET('{nextPageUrl}')
  @http.FormUrlEncoded()
  Future<GetFollowedResponse> getFollowedNextPage(@http.Path("nextPageUrl") String nextPageUrl);

  @http.POST('/api/dev/signin')
  @http.Headers({"Content-Type": "application/json"})
  Future<SigninResponse> signIn(@http.Body() SigninRequest request, @http.Header("X-App-Id") String appId, @http.Header("X-Api-Key") String apiKey);
}
