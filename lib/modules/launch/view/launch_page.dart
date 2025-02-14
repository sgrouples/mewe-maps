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
