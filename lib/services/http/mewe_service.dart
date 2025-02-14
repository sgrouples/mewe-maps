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
  Future<LoginWithPasswordResponse> loginByEmailWithChallenge(@Field() String username, @Field() String password,
      @Field("challenge_provider") String challenge, @Field("session_token") String challengeToken);

  @POST('/api/v2/auth/login')
  @FormUrlEncoded()
  Future<LoginWithPasswordResponse> loginByNumberWithChallenge(@Field() String phoneNumber, @Field() String password,
      @Field("challenge_provider") String challenge, @Field("session_token") String challengeToken);

  @GET('/api/v2/following/followed')
  @FormUrlEncoded()
  Future<GetFollowedResponse> getFollowed();

  @GET('{nextPageUrl}')
  @FormUrlEncoded()
  Future<GetFollowedResponse> getFollowedNextPage(@Path("nextPageUrl") String nextPageUrl);
}
