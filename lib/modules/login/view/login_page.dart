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
import 'package:go_router/go_router.dart';
import 'package:mewe_maps/repositories/authentication/authentication_repository.dart';

import '../bloc/login_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => LoginBloc(
        context.read<AuthenticationRepository>(),
      ),
      child: BlocListener<LoginBloc, LoginState>(
        listenWhen: (previous, current) => current.user != null,
        listener: (BuildContext context, LoginState state) {
          if (state.user != null) {
            context.go('/map');
          }
        },
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) => _buildPage(context, state),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, LoginState state) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) => context.read<LoginBloc>().add(EmailOrPhoneNumberChanged(value)),
                decoration: const InputDecoration(labelText: "Email / Phone Number"),
              ),
              const SizedBox(height: 20),
              const Text("You will receive a MeWe Maps session request linked to your MeWe account. Please accept it to continue."),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  ElevatedButton(
                    onPressed: state.isLoading ? null : () => context.read<LoginBloc>().add(LoginSubmitted()),
                    child: const Text("Continue"),
                  ),
                  if (state.isLoading)
                    const Positioned(
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
              if (state.error.isNotEmpty) const SizedBox(height: 20),
              if (state.error.isNotEmpty) Text(state.error, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}
