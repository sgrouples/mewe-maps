import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String text;

  const LoadingWidget({super.key, this.text = "MeWe Maps"});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor.withAlpha(200),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icon/app_icon.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 32),
            Text(text),
          ],
        ),
      ),
    );
  }
}
