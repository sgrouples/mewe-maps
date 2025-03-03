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
import 'package:intl/intl.dart';
import 'package:mewe_maps/models/user.dart';
import 'package:mewe_maps/modules/common/view/components/user_avatar.dart';
import 'package:mewe_maps/modules/contacts/bloc/contacts_bloc.dart';
import 'package:mewe_maps/modules/contacts/view/components/contact_list_item.dart';
import 'package:mewe_maps/repositories/contacts/contacts_repository.dart';
import 'package:mewe_maps/repositories/location/sharing_location_repository.dart';
import 'package:mewe_maps/repositories/map/hidden_from_map_repository.dart';
import 'package:mewe_maps/repositories/storage/storage_repository.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => ContactsBloc(
        context.read<ContactsRepository>(),
        context.read<SharingLocationRepository>(),
        context.read<HiddenFromMapRepository>(),
      )..add(StartObservingData()),
      child: BlocBuilder<ContactsBloc, ContactsState>(
        builder: (context, state) => _buildPage(context, state),
      ),
    );
  }

  Widget _buildPage(BuildContext context, ContactsState state) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: DefaultTabController(
          length: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 100,
                child: AppBar(
                    title: const Text('Contacts'),
                    bottom: const TabBar(
                      dividerColor: Colors.transparent,
                      tabs: [
                        Tab(text: 'Share My Location'),
                        Tab(text: 'Shared With Me'),
                      ],
                    ),
                    actions: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop(StorageRepository.user);
                            },
                            icon: UserAvatar(
                              user: StorageRepository.user!,
                              radius: 15,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return AlertDialog(
                                    insetPadding: EdgeInsets.zero,
                                    title: const Text("Logout"),
                                    content: const Text("Are you sure?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          context.read<ContactsBloc>().add(LogOutClicked(context));
                                        },
                                        child: const Text('Yes, log me out'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('No'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Text('LOGOUT'),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ]),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildMySharingLocationList(),
                    _buildSharedWithMeList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMySharingLocationList() => BlocBuilder<ContactsBloc, ContactsState>(
      buildWhen: (previous, current) =>
          previous.shareMyPositionData != current.shareMyPositionData || previous.contacts != current.contacts || previous.error != current.error,
      builder: (context, state) {
        if (state.error.isNotEmpty) {
          return Center(child: Text(state.error, style: const TextStyle(color: Colors.red)));
        }

        return ListView.builder(
          itemCount: (state.shareMyPositionData?.length ?? 0) + (state.contacts?.length ?? 0),
          itemBuilder: (context, index) {
            if (index < (state.shareMyPositionData?.length ?? 0)) {
              final sharingData = state.shareMyPositionData![index];
              return ContactListItem(
                user: sharingData.contact,
                trailing: ContactSwitch(
                  value: true,
                  switchText: sharingData.sharedUntil.year == 9999 ? "Until I stop" : "Until ${DateFormat.Hm().format(sharingData.sharedUntil)}",
                  onChanged: (newValue) {
                    context.read<ContactsBloc>().add(ShareMyPositionStopped(sharingData.sharingSessionId));
                  },
                ),
              );
            } else {
              final contact = state.contacts![index - (state.shareMyPositionData?.length ?? 0)];
              return ContactListItem(
                  user: contact,
                  trailing: IconButton(
                    onPressed: () async {
                      final minutes = await showIntervalModal(context, contact);
                      if (context.mounted) {
                        if (minutes != null) {
                          context.read<ContactsBloc>().add(ShareMyPositionStarted(contact, minutes));
                        }
                      }
                    },
                    icon: const Icon(Icons.add),
                  ));
            }
          },
        );
      });

  Future<int?> showIntervalModal(BuildContext context, User contact) async {
    return await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Share for 5 minutes'),
              onTap: () {
                Navigator.of(context).pop(5);
              },
            ),
            ListTile(
              title: const Text('Share for 15 minutes'),
              onTap: () {
                Navigator.of(context).pop(15);
              },
            ),
            ListTile(
              title: const Text('Share for 1 hour'),
              onTap: () {
                Navigator.of(context).pop(60);
              },
            ),
            ListTile(
              title: const Text('Share for 3 hours'),
              onTap: () {
                Navigator.of(context).pop(180);
              },
            ),
            ListTile(
              title: const Text('Share until I stop'),
              onTap: () {
                Navigator.of(context).pop(TIME_INTERVAL_FOREVER);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSharedWithMeList() => BlocBuilder<ContactsBloc, ContactsState>(
      buildWhen: (previous, current) => previous.contactLocationData != current.contactLocationData || previous.error != current.error,
      builder: (context, state) {
        if (state.error.isNotEmpty) {
          return Center(child: Text(state.error, style: const TextStyle(color: Colors.red)));
        }

        return ListView.builder(
          itemCount: (state.contactLocationData?.length ?? 0),
          itemBuilder: (context, index) {
            final contact = state.contactLocationData?.keys.elementAt(index);
            if (contact == null) return const SizedBox.shrink();
            return ContactListItem(
              user: contact,
              onTapped: () {
                Navigator.of(context).pop(contact);
              },
              trailing: ContactSwitch(
                value: state.contactLocationData![contact]!,
                switchText: "Display on Map",
                onChanged: (newValue) {
                  context.read<ContactsBloc>().add(DisplayOnTheMapChanged(contact, newValue));
                },
              ),
            );
          },
        );
      });
}
