import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:mewe_maps/modules/contacts/view/contacts_page.dart';
import 'package:mewe_maps/modules/map/bloc/map_bloc.dart';
import 'package:mewe_maps/modules/map/view/components/loading_widget.dart';
import 'package:mewe_maps/modules/map/view/components/selected_user_bottom_view.dart';
import 'package:mewe_maps/repositories/map/map_controller_repository.dart';
import 'package:mewe_maps/repositories/storage/storage_repository.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  AppLifecycleListener? _appLifecycleListener;

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
      child: BlocListener<MapBloc, MapState>(
        listenWhen: (previous, current) => previous.showPermissionsRationale != current.showPermissionsRationale && current.showPermissionsRationale,
        listener: (context, state) {
          _showPermissionsRationale(context);
        },
        child: BlocBuilder<MapBloc, MapState>(builder: (context, state) {
          if (state.mapInitialized && shouldShowContacts) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showContactsModal(context);
              StorageRepository.setFlag(SHOULD_SHOW_CONTACTS_ON_START_KEY, false);
            });
          }

          _appLifecycleListener ??= AppLifecycleListener(
            onResume: () => context.read<MapBloc>().add(ObserveMyPosition()),
            onPause: () => context.read<MapBloc>().add(StopObservingMyPosition()),
            onDetach: () => context.read<MapBloc>().add(StopObservingMyPosition()),
          );

          return _buildPage(context, state);
        }),
      ),
    );
  }

  @override
  void dispose() {
    _appLifecycleListener?.dispose();
    super.dispose();
  }

  Widget _buildPage(BuildContext context, MapState state) {
    final mapControllerRepository = context.read<MapControllerRepository>();
    final mapController = mapControllerRepository.mapController;
    final mapWidget = OSMFlutter(
      controller: mapController,
      onMapIsReady: (value) {
        if (value) context.read<MapBloc>().add(InitEvent());
      },
      osmOption: const OSMOption(
        showZoomController: true,
      ),
      onGeoPointClicked: (geoPoint) {
        context.read<MapBloc>().add(GeopointClicked(geoPoint));
      },
    );

    return Scaffold(
      body: Stack(
        children: [mapWidget, if (!state.mapInitialized) const LoadingWidget(), Positioned(bottom: 0, left: 0, right: 0, child: _buildBottom())],
      ),
    );
  }

  void _showContactsModal(BuildContext context) {
    showModalBottomSheet(
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

    setState(() {
      shouldShowContacts = false;
    });
  }

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

  Widget _buildBottom() => Column(crossAxisAlignment: CrossAxisAlignment.end, children: [_floatingActionButton(), const SelectedUserBottomView()]);

  Widget _floatingActionButton() => BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton(
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
}
