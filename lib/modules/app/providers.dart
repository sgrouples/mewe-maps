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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mewe_maps/repositories/authentication/authentication_repository.dart';
import 'package:mewe_maps/repositories/contacts/contacts_repository.dart';
import 'package:mewe_maps/repositories/location/my_location_repository.dart';
import 'package:mewe_maps/repositories/location/sharing_location_repository.dart';
import 'package:mewe_maps/repositories/map/hidden_from_map_repository.dart';
import 'package:mewe_maps/services/http/auth_constants.dart';
import 'package:mewe_maps/services/http/auth_interceptor.dart';
import 'package:mewe_maps/services/http/image_downloader.dart';
import 'package:mewe_maps/services/http/mewe_service.dart';
import 'package:mewe_maps/utils/logger.dart';

List<RepositoryProvider> repositoryProviders = [
  RepositoryProvider<MeWeService>(
    create: (context) => MeWeService(
      Dio()
        ..interceptors.addAll([
          LogInterceptor(
            requestBody: true,
            responseBody: true,
            logPrint: (o) => {
              if (Logger.LOG_DIO) {Logger.log("LogInterceptor", o.toString())}
            },
          ),
          AuthInterceptor(),
        ]),
      baseUrl: AuthConfig.meweHost,
    ),
  ),
  RepositoryProvider<AuthenticationRepository>(
    create: (context) => MeWeAuthenticationRepository(
      RepositoryProvider.of<MeWeService>(context),
    ),
  ),
  RepositoryProvider<ImageDownloader>(
    create: (context) => ImageDownloader(),
  ),
  RepositoryProvider<ContactsRepository>(
      create: (context) => MeWeContactsRepository(
            RepositoryProvider.of<MeWeService>(context),
          )),
  RepositoryProvider<SharingLocationRepository>(create: (context) => FirestoreSharingLocationRepository()),
  RepositoryProvider<MyLocationRepository>(create: (context) => MyLocationRepositoryImpl()),
  RepositoryProvider<HiddenFromMapRepository>(create: (context) => MemoryHiddenFromMapRepository()),
];
