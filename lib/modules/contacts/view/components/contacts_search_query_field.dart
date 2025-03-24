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

import '../../bloc/contacts_bloc.dart';

class ContactsSearchQueryField extends StatefulWidget {
  const ContactsSearchQueryField({super.key});

  @override
  State<ContactsSearchQueryField> createState() => _ContactsSearchQueryFieldState();
}

class _ContactsSearchQueryFieldState extends State<ContactsSearchQueryField> {
  final _controller = TextEditingController();

  @override
  void initState() {
    _controller.addListener(() {
      context.read<ContactsBloc>().add(SearchQueryChanged(_controller.text));
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContactsBloc, ContactsState>(
      listenWhen: (previous, current) => previous.query != current.query,
      listener: (context, state) {
        if (_controller.text != state.query) _controller.text = state.query;
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide.none,
            ),
            filled: true,
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
          ),
        ),
      ),
    );
  }
}
