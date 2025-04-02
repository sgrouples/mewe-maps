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
import 'package:mewe_maps/modules/common/view/components/interval_dialog.dart';
import 'package:mewe_maps/modules/contacts/bloc/contacts_bloc.dart';

import 'contact_list_item.dart';
import 'contacts_search_query_field.dart';

class ContactsMySharingLocationTab extends StatelessWidget {
  const ContactsMySharingLocationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactsBloc, ContactsState>(
      buildWhen: (previous, current) =>
          previous.shareMyPositionData != current.shareMyPositionData ||
          previous.contactsToShareWith != current.contactsToShareWith ||
          previous.error != current.error,
      builder: (context, state) {
        if (state.contactsToShareWith == null && state.shareMyPositionData == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final contactsToShareWith = state.contactsToShareWith?.toList() ?? [];
        final shareMyPositionData = state.shareMyPositionData?.toList() ?? [];

        return RefreshIndicator(
          onRefresh: () async {
            context.read<ContactsBloc>().add(ReloadContacts());
          },
          child: state.error.isNotEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          state.error,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    const ContactsSearchQueryField(),
                    if (contactsToShareWith.isEmpty && shareMyPositionData.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Empty'),
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: shareMyPositionData.length + contactsToShareWith.length,
                        itemBuilder: (context, index) {
                          if (index < shareMyPositionData.length) {
                            final sharingData = shareMyPositionData[index];
                            return ContactListItem(
                              user: sharingData.contact,
                              onTapped: () {
                                Navigator.of(context).pop(sharingData.contact);
                              },
                              trailing: ContactSwitch(
                                value: true,
                                switchText: sharingData.sharedUntil.year == 9999 ? "Until I stop" : "Until ${DateFormat.Hm().format(sharingData.sharedUntil)}",
                                onChanged: (newValue) {
                                  context.read<ContactsBloc>().add(ShareMyPositionStopped(sharingData.sharingSessionId));
                                },
                              ),
                            );
                          } else {
                            final contact = contactsToShareWith[index - shareMyPositionData.length];
                            return ContactListItem(
                              user: contact,
                              onTapped: () {
                                Navigator.of(context).pop(contact);
                              },
                              trailing: IconButton(
                                onPressed: () async {
                                  final minutes = await showIntervalModal(context, contact);
                                  if (context.mounted && minutes != null) {
                                    context.read<ContactsBloc>().add(ShareMyPositionStarted(contact, minutes));
                                  }
                                },
                                icon: const Icon(Icons.add),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
