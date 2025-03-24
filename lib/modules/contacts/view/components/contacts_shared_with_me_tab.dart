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
import 'package:mewe_maps/models/user.dart';
import 'package:mewe_maps/modules/contacts/view/components/contacts_search_query_field.dart';

import '../../bloc/contacts_bloc.dart';
import 'contact_list_item.dart';

class ContactsSharedWithMeTab extends StatelessWidget {
  const ContactsSharedWithMeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactsBloc, ContactsState>(
      buildWhen: (previous, current) =>
          previous.contactLocationData != current.contactLocationData ||
          previous.error != current.error ||
          previous.contactsToRequestLocation != current.contactsToRequestLocation,
      builder: (context, state) {
        if (state.contactLocationData == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredContactsLocations = state.contactLocationData?.keys.toList() ?? [];
        final contactsToAskForLocation = state.contactsToRequestLocation?.keys.toList() ?? [];

        return RefreshIndicator(
          onRefresh: () async {
            context.read<ContactsBloc>().add(ReloadContactLocationData());
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
                    if (contactsToAskForLocation.isEmpty && filteredContactsLocations.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Empty'),
                        ),
                      ),
                    Expanded(
                        child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filteredContactsLocations.length + contactsToAskForLocation.length,
                      itemBuilder: (context, index) {
                        final isContactLocation = index < filteredContactsLocations.length;
                        final contact =
                            isContactLocation ? filteredContactsLocations[index] : contactsToAskForLocation[index - filteredContactsLocations.length];
                        return isContactLocation
                            ? ContactListItem(
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
                              )
                            : ContactListItem(
                                user: contact,
                                label: (state.contactsToRequestLocation![contact] ?? false) ? "Requested" : null,
                                trailing: state.contactsToRequestLocation![contact]!
                                    ? buildCancelRequestLocationButton(context, contact)
                                    : buildRequestLocationButton(context, contact),
                              );
                      },
                    ))
                  ],
                ),
        );
      },
    );
  }
}

IconButton buildRequestLocationButton(BuildContext context, User contact) {
  return IconButton(
    icon: const Icon(Icons.add),
    onPressed: () {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text("Request Location"),
            content: Text("Do you want to request location from ${contact.name}?"),
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
                  context.read<ContactsBloc>().add(AskForLocationClicked(contact));
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    },
  );
}

IconButton buildCancelRequestLocationButton(BuildContext context, User contact) {
  return IconButton(
    icon: const Icon(Icons.cancel_outlined),
    onPressed: () {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text("Cancel Request"),
            content: Text("Do you want to cancel the location request from ${contact.name}?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("NO"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<ContactsBloc>().add(CancelRequestForLocationClicked(contact));
                },
                child: const Text("YES"),
              ),
            ],
          );
        },
      );
    },
  );
}
