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
import 'package:mewe_maps/modules/common/view/components/interval_dialog.dart';

import '../../bloc/map_bloc.dart';

class LocationRequestsList extends StatelessWidget {
  const LocationRequestsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      buildWhen: (old, current) => old.locationRequests != current.locationRequests,
      builder: (context, state) => ListView.builder(
        itemCount: state.locationRequests.length,
        itemBuilder: (context, index) {
          final request = state.locationRequests.keys.elementAt(index);
          final user = state.locationRequests[request]!;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.surface,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                title: Text(user.name),
                subtitle: const Text("Request to see your location"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => context.read<MapBloc>().add(RespondForLocationRequest(request, user, null)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () async {
                        final interval = await showIntervalModal(context, user);
                        if (context.mounted && interval != null) {
                          context.read<MapBloc>().add(RespondForLocationRequest(request, user, interval));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
