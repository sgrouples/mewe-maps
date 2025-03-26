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
import 'package:mewe_maps/services/http/auth_constants.dart';
import 'package:mewe_maps/services/http/model/challenges_response.dart';
import 'package:mewe_maps/utils/logger.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
        listenWhen: (previous, current) => current.user != null || current.challenge != null,
        listener: (BuildContext context, LoginState state) {
          if (state.user != null) {
            context.go('/map');
          } else if (state.challenge != null) {
            if (state.challenge! == ChallengesResponse.challengeCaptcha) {
              _showCaptchaChallengeDialog(context);
            } else if (state.challenge! == ChallengesResponse.challengeArkose) {
              _showArkoseChallengeDialog(context);
            }
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
              Image.asset(
                'assets/icon/app_icon.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) => context.read<LoginBloc>().add(EmailOrPhoneNumberChanged(value)),
                decoration: const InputDecoration(labelText: "Email / Phone Number"),
              ),
              TextField(
                onChanged: (value) => context.read<LoginBloc>().add(PasswordChanged(value)),
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  ElevatedButton(
                    onPressed: state.isLoading ? null : () => context.read<LoginBloc>().add(LoginSubmitted()),
                    child: const Text("Login"),
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

  void _showCaptchaChallengeDialog(BuildContext context) {
    const challenge = ChallengesResponse.challengeCaptcha;
    final WebViewController controller = WebViewController();
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.addJavaScriptChannel(
      'challengeInitializedHandler',
      onMessageReceived: (JavaScriptMessage message) {
        Logger.log("Captcha", "onMessageReceived: ${message.message}");
      },
    );
    controller.addJavaScriptChannel(
      'challengeHandler',
      onMessageReceived: (JavaScriptMessage message) {
        Logger.log("Captcha", "onMessageReceived: ${message.message}");
        if (message.message != 'init') {
          context.read<LoginBloc>().add(ChallengeSubmitted(challenge, message.message));
          Navigator.of(context).pop();
        }
      },
    );
    controller.loadRequest(Uri.parse(AuthConfig.meweLoginChallengeCaptcha));
    _showChallengeDialog(context, controller, challenge);
  }

  void _showArkoseChallengeDialog(BuildContext context) {
    const challenge = ChallengesResponse.challengeArkose;
    final WebViewController controller = WebViewController();
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.addJavaScriptChannel(
      'FlutterCallback',
      onMessageReceived: (JavaScriptMessage message) {
        Logger.log("FlutterCallback", "onMessageReceived: ${message.message}");
        context.read<LoginBloc>().add(ChallengeSubmitted(challenge, message.message));
        Navigator.of(context).pop();
      },
    );
    controller.loadFlutterAsset("assets/html/arkose_login.html");
    _showChallengeDialog(context, controller, challenge);
  }

  void _showChallengeDialog(BuildContext context, WebViewController controller, String challenge) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: WebViewWidget(controller: controller),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<LoginBloc>().add(ChallengeSubmitted(challenge, null));
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
