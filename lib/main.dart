import 'package:flutter/material.dart';
import 'package:mewe_maps/isolates.dart';
import 'package:mewe_maps/modules/app/view/app_page.dart';
import 'package:mewe_maps/services/workmanager/workmanager.dart';

void main() async {
  await initializeIsolate();
  await initializeNotPreciseBackgroundSharing();

  runApp(const RestartWidget(child: AppPage()));
}

class RestartWidget extends StatefulWidget {
  final Widget child;

  const RestartWidget({super.key, required this.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<RestartWidgetState>()?.restartApp();
  }

  @override
  RestartWidgetState createState() => RestartWidgetState();
}

class RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
