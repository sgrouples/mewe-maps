import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mewe_maps/models/user.dart';
import 'package:mewe_maps/models/user_position.dart';
import 'package:mewe_maps/modules/common/view/components/user_avatar.dart';
import 'package:mewe_maps/modules/map/bloc/map_bloc.dart';
import 'package:mewe_maps/modules/map/view/components/location_tracking_icon.dart';
import 'package:mewe_maps/utils/show_snackbar.dart';

class SelectedUserBottomView extends StatelessWidget {
  const SelectedUserBottomView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      buildWhen: (previous, current) =>
      previous.selectedUser != current.selectedUser ||
          previous.trackingState != current.trackingState ||
          previous.contactsPositions.length != current.contactsPositions.length,
      builder: (context, state) {
        if (state.selectedUser == null) {
          return const SizedBox.shrink();
        }
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: _buildContainer(context, state),
            ),
            _buildTrackingButton(context, state),
            if (state.contactsPositions.length > 1)
              Positioned(
                  top: 120,
                  left: 0,
                  right: 0,
                  child: _buildLeftRightButtons(context, state)),
            _buildAvatar(state, context),
          ],
        );
      },
    );
  }

  Container _buildContainer(BuildContext context, MapState state) {
    UserPosition userPosition = state.selectedUser!;
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
      decoration: _containerDecoration(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _closeButton(context),
          _buildName(state.selectedUser!.user),
          const SizedBox(height: 16),
          _buildCoordinates(userPosition, context),
          if (state.selectedUser!.shareUntil != null)
            _buildLabel(
                "Share until: ${DateFormat('HH:mm:ss').format(state.selectedUser!.shareUntil!)}",
                context),
          _buildLabel(
              "Update time: ${DateFormat('HH:mm:ss').format(state.selectedUser!.timestamp)}",
              context),
          _buildActions(state, context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Row _buildActions(MapState state, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (!state.selectedUser!.user.isMe())
          TextButton(
            onPressed: () {
              context.read<MapBloc>().add(NavigateClicked(state.selectedUser!));
            },
            child: const Text('Navigate'),
          ),
        TextButton(
          onPressed: () {
            context.read<MapBloc>().add(OpenMeWeClicked(state.selectedUser!));
          },
          child: const Text('Open MeWe Profile'),
        ),
      ],
    );
  }

  Center _buildLabel(String text, BuildContext context) {
    return Center(
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: Colors.grey[600]),
      ),
    );
  }

  Align _closeButton(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
          onPressed: () {
            context.read<MapBloc>().add(CloseSelectedUser());
          },
          icon: const Icon(Icons.close)),
    );
  }

  BoxDecoration _containerDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    );
  }

  Align _buildAvatar(MapState state, BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(100),
            topRight: Radius.circular(100),
          ),
        ),
        child: Center(
          child: UserAvatar(
            user: state.selectedUser!.user,
            radius: 36,
          ),
        ),
      ),
    );
  }

  Widget _buildCoordinates(UserPosition userPosition, BuildContext context) {
    final cordsText =
        '${userPosition.geoPoint.latitude.toStringAsFixed(5)}, ${userPosition.geoPoint.longitude.toStringAsFixed(5)}';
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: cordsText));
        showSnackBar(context, 'Coordinates copied to clipboard');
      },
      child: Text(
        cordsText,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
      ),
    );
  }

  Widget _buildName(User user) {
    return Text(
      user.isMe() ? "${user.name} (You)" : user.name,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildLeftRightButtons(BuildContext context, MapState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              context.read<MapBloc>().add(PreviousUserClicked());
            },
            icon: const Icon(Icons.chevron_left, size: 32, color: Colors.grey),
          ),
          IconButton(
            onPressed: () {
              context.read<MapBloc>().add(NextUserClicked());
            },
            icon: const Icon(Icons.chevron_right, size: 32, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingButton(BuildContext context, MapState state) {
    return Positioned(
      top: 40,
      left: 16,
      child: IconButton(
        onPressed: () =>
            context.read<MapBloc>().add(TrackSelectedUserClicked()),
        icon: LocationTrackingIcon(
            state.trackingState == TrackingState.selectedUser),
      ),
    );
  }
}
