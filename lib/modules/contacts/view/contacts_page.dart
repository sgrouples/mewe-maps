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
import 'package:mewe_maps/modules/common/view/components/user_avatar.dart';
import 'package:mewe_maps/modules/contacts/bloc/contacts_bloc.dart';
import 'package:mewe_maps/modules/contacts/view/components/contacts_my_sharing_location_tab.dart';
import 'package:mewe_maps/modules/contacts/view/components/contacts_shared_with_me_tab.dart';
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
          child: Builder(builder: (context) {
            final controller = DefaultTabController.of(context);
            controller.addListener(() {
              if (!controller.indexIsChanging) {
                context.read<ContactsBloc>().add(SearchQueryChanged(""));
              }
            });

            return Column(
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
                const Expanded(
                  child: TabBarView(
                    children: [
                      ContactsMySharingLocationTab(),
                      ContactsSharedWithMeTab(),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
