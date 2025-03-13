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
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:mewe_maps/models/user.dart';
import 'package:mewe_maps/modules/app/app_lifecycle_tracker.dart';
import 'package:mewe_maps/modules/contacts/view/contacts_page.dart';
import 'package:mewe_maps/modules/map/bloc/map_bloc.dart';
import 'package:mewe_maps/modules/map/view/components/loading_widget.dart';
import 'package:mewe_maps/modules/map/view/components/location_tracking_icon.dart';
import 'package:mewe_maps/modules/map/view/components/selected_user_bottom_view.dart';
import 'package:mewe_maps/modules/map/view/map_controller_manager.dart';
import 'package:mewe_maps/repositories/storage/storage_repository.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  static const SHOULD_SHOW_CONTACTS_ON_START_KEY = "shouldShowContactsOnStart";

  bool shouldShowContacts = StorageRepository.getFlag(SHOULD_SHOW_CONTACTS_ON_START_KEY, true);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => MapBloc(
        context.read(),
        context.read(),
        context.read(),
        context.read(),
      ),
      child: RepositoryProvider(
        create: (context) => _buildMapControllerManager(context),
        child: MultiBlocListener(
          listeners: [
            _buildAppVisibilityListener(),
            _buildTrackingListener(),
            _buildMyPositionListenerListener(),
            _buildContactsPositionsListener(),
            _buildSelectedUserListener(),
            _buildShowPermissionListener()
          ],
          child: BlocBuilder<MapBloc, MapState>(builder: (context, state) {
            if (state.mapInitialized && !state.showPermissionsRationale && shouldShowContacts) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showContactsModal(context).then((selectedUser) {
                  if (context.mounted && selectedUser != null) {
                    context.read<MapBloc>().add(UserSelectedFromContacts(selectedUser));
                  }
                });
                StorageRepository.setFlag(SHOULD_SHOW_CONTACTS_ON_START_KEY, false);
              });
            }
            return _buildPage(context, state);
          }),
        ),
      ),
    );
  }

  BlocListener<MapBloc, MapState> _buildTrackingListener() => BlocListener<MapBloc, MapState>(
        listenWhen: (previous, current) =>
            previous.trackingState != current.trackingState || previous.myPosition != current.myPosition || previous.selectedUser != current.selectedUser,
        listener: (context, state) {
          if (state.trackingState == TrackingState.myPosition) {
            context.read<MapControllerManager>().setTrackingUser(state.myPosition);
          } else if (state.trackingState == TrackingState.selectedUser) {
            context.read<MapControllerManager>().setTrackingUser(state.selectedUser);
          } else {
            context.read<MapControllerManager>().setTrackingUser(null);
          }
        },
      );

  BlocListener<MapBloc, MapState> _buildAppVisibilityListener() => BlocListener<MapBloc, MapState>(
        listenWhen: (previous, current) => previous.mapInitialized != current.mapInitialized && current.mapInitialized,
        listener: (context, state) {
          AppLifecycleTracker.addVisibilityCallback((isAppVisible) {
            if (isAppVisible) {
              context.read<MapBloc>().add(ObserveMyPosition());
            } else {
              context.read<MapBloc>().add(StopObservingMyPosition());
            }
          });
        },
      );

  BlocListener<MapBloc, MapState> _buildMyPositionListenerListener() => BlocListener<MapBloc, MapState>(
        listenWhen: (previous, current) => previous.myPosition != current.myPosition,
        listener: (context, state) {
          context.read<MapControllerManager>().setMyPosition(state.myPosition);
        },
      );

  BlocListener<MapBloc, MapState> _buildContactsPositionsListener() => BlocListener<MapBloc, MapState>(
        listenWhen: (previous, current) => previous.contactsPositions != current.contactsPositions,
        listener: (context, state) {
          context.read<MapControllerManager>().setContactsPositions(state.contactsPositions);
        },
      );

  BlocListener<MapBloc, MapState> _buildSelectedUserListener() => BlocListener<MapBloc, MapState>(
        listenWhen: (previous, current) => previous.selectedUser?.user != current.selectedUser?.user,
        listener: (context, state) {
          if (state.selectedUser != null) {
            context.read<MapControllerManager>().moveToUser(state.selectedUser!);
          }
        },
      );

  BlocListener<MapBloc, MapState> _buildShowPermissionListener() => BlocListener<MapBloc, MapState>(
      listenWhen: (previous, current) => previous.showPermissionsRationale != current.showPermissionsRationale && current.showPermissionsRationale,
      listener: (context, state) {
        _showPermissionsRationale(context);
      });

  MapControllerManager _buildMapControllerManager(BuildContext context) {
    return MapControllerManager(
      context.read(),
      onUserTap: (userPosition) => context.read<MapBloc>().add(UserClicked(userPosition)),
      onMapSingleTap: () => context.read<MapBloc>().add(CloseSelectedUser()),
    );
  }

  Widget _buildPage(BuildContext context, MapState state) {
    final mapWidget = OSMFlutter(
      controller: context.read<MapControllerManager>().mapController,
      onMapIsReady: (value) {
        if (value) context.read<MapBloc>().add(InitEvent());
      },
      osmOption: const OSMOption(
        showZoomController: true,
      ),
      onGeoPointClicked: (geoPoint) {
        context.read<MapControllerManager>().tapGeopoint(geoPoint);
      },
    );

    return Scaffold(
      body: Stack(
        children: [mapWidget, if (!state.mapInitialized) const LoadingWidget(), Positioned(bottom: 0, left: 0, right: 0, child: _buildBottom())],
      ),
    );
  }

  Future<User?> _showContactsModal(BuildContext context) async {
    setState(() {
      shouldShowContacts = false;
    });
    return await showModalBottomSheet<User>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const ContactsPage();
      },
    );
  }

  Widget _buildBottom() => Column(
      crossAxisAlignment: CrossAxisAlignment.end, children: [_trackingFloatingActionButton(), _contactsFloatingActionButton(), const SelectedUserBottomView()]);

  void _showPermissionsRationale(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Permissions Required"),
          content: const Text(
            "This app requires notifications and background location access "
            "to function properly. Please grant these permissions for the best experience.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("CANCEL"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<MapBloc>().add(RequestAllPermissions());
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Widget _contactsFloatingActionButton() => BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton(
              heroTag: "contacts_fab",
              onPressed: () {
                setState(() {
                  shouldShowContacts = true;
                });
              },
              child: const Icon(Icons.contacts),
            ),
          );
        },
      );

  Widget _trackingFloatingActionButton() => BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton(
              heroTag: "tracking_fab",
              onPressed: () {
                context.read<MapBloc>().add(TrackMyPositionClicked());
              },
              backgroundColor: Colors.white,
              child: LocationTrackingIcon(state.trackingState == TrackingState.myPosition),
            ),
          );
        },
      );
}
