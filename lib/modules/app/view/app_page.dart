// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mewe_maps/modules/app/providers.dart';

import '../bloc/app_bloc.dart';
import '../bloc/app_event.dart';
import '../router.dart';

class AppPage extends StatelessWidget {
  const AppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: repositoryProviders,
      child: buildPage(context),
    );
  }

  Widget buildPage(BuildContext context) {
    const lightColorScheme = ColorScheme.light(
      primary: Colors.green,
      secondary: Colors.green,
    );

    const darkColorScheme = ColorScheme.dark(
      primary: Colors.green,
      secondary: Colors.green,
    );

    final app = MaterialApp.router(
      theme: ThemeData(
        colorScheme: lightColorScheme,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: darkColorScheme,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );

    return BlocProvider(
      create: (context) => AppBloc()..add(InitEvent()),
      child: Builder(builder: (context) => app),
    );
  }
}
