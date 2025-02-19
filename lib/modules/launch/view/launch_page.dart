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
import 'package:go_router/go_router.dart';
import 'package:mewe_maps/modules/launch/bloc/launch_state.dart';

import '../bloc/launch_bloc.dart';
import '../bloc/launch_event.dart';

class LaunchPage extends StatelessWidget {
  const LaunchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => LaunchBloc()..add(InitEvent()),
      child: BlocListener<LaunchBloc, LaunchState>(
        listener: (BuildContext context, LaunchState state) {
          if (state.user != null) {
            context.go('/map');
          } else {
            context.go('/login');
          }
        },
        child: Builder(builder: (context) => _buildPage(context)),
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    const body = Center(
      child: Text("Authenticating..."),
    );
    return const Scaffold(
      body: body,
    );
  }
}
