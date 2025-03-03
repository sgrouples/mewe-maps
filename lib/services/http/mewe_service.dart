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
import 'package:retrofit/retrofit.dart';

part 'mewe_service.g.dart';

@RestApi()
abstract class MeWeService {
  factory MeWeService(Dio dio, {String baseUrl}) = _MeWeService;

  @GET('/api/v2/account/challenges-available')
  @FormUrlEncoded()
  Future<ChallengesResponse> getChallenges();

  @POST('/api/v2/auth/login')
  @FormUrlEncoded()
  Future<LoginWithPasswordResponse> loginByEmail(@Field() String username, @Field() String password);

  @POST('/api/v2/auth/login')
  @FormUrlEncoded()
  Future<LoginWithPasswordResponse> loginByNumber(@Field() String phoneNumber, @Field() String password);

  @POST('/api/v2/auth/login')
  @FormUrlEncoded()
  Future<LoginWithPasswordResponse> loginByEmailWithChallenge(
      @Field() String username, @Field() String password, @Field("challenge_provider") String challenge, @Field("session_token") String challengeToken);

  @POST('/api/v2/auth/login')
  @FormUrlEncoded()
  Future<LoginWithPasswordResponse> loginByNumberWithChallenge(
      @Field() String phoneNumber, @Field() String password, @Field("challenge_provider") String challenge, @Field("session_token") String challengeToken);

  @GET('/api/v2/following/followed')
  @FormUrlEncoded()
  Future<GetFollowedResponse> getFollowed();

  @GET('{nextPageUrl}')
  @FormUrlEncoded()
  Future<GetFollowedResponse> getFollowedNextPage(@Path("nextPageUrl") String nextPageUrl);
}
