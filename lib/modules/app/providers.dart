
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mewe_maps/repositories/authentication/authentication_repository.dart';
import 'package:mewe_maps/repositories/contacts/contacts_repository.dart';
import 'package:mewe_maps/repositories/location/my_location_repository.dart';
import 'package:mewe_maps/repositories/location/sharing_location_repository.dart';
import 'package:mewe_maps/repositories/map/hidden_from_map_repository.dart';
import 'package:mewe_maps/repositories/map/map_controller_repository.dart';
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
            logPrint: (o) => Logger.log("LogInterceptor", o.toString()),
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
  RepositoryProvider<MapControllerRepository>(
    create: (context) => MapControllerRepository(
      RepositoryProvider.of<ImageDownloader>(context),
    ),
  ),
  RepositoryProvider<ContactsRepository>(
      create: (context) => MeWeContactsRepository(
        RepositoryProvider.of<MeWeService>(context),
      )),
  RepositoryProvider<SharingLocationRepository>(
      create: (context) => SupabaseSharingLocationRepository()),
  RepositoryProvider<MyLocationRepository>(
      create: (context) => MyLocationRepositoryImpl()),
  RepositoryProvider<HiddenFromMapRepository>(
      create: (context) => MemoryHiddenFromMapRepository()),
];
