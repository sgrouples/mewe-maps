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
import 'package:mewe_maps/models/user.dart';
import 'package:mewe_maps/services/http/model/get_followed_response.dart';
import 'package:mewe_maps/services/http/model/signin_request.dart';
import 'package:mewe_maps/services/http/model/signin_response.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart' as http;

part 'mewe_service.g.dart';

@http.RestApi()
abstract class MeWeService {
  factory MeWeService(Dio dio, {String baseUrl}) = _MeWeService;

  @http.GET('/api/v2/following/followed')
  @http.Headers({"Content-Type": "application/json"})
  Future<GetFollowedResponse> getFollowed();

  @http.GET('{nextPageUrl}')
  @http.Headers({"Content-Type": "application/json"})
  Future<GetFollowedResponse> getFollowedNextPage(@http.Path("nextPageUrl") String nextPageUrl);

  @http.POST('/api/dev/signin')
  @http.Headers({"Content-Type": "application/json"})
  Future<SigninResponse> signIn(@http.Body() SigninRequest request);

  @http.POST('/api/dev/me')
  @http.Headers({"Content-Type": "application/json"})
  Future<User> getMyUser();
}
