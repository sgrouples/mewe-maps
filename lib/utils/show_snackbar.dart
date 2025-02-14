import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message, {bool longDuration = false}) {
  final snack = SnackBar(
    content: Center(child: Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white))),
    duration: longDuration ? const Duration(milliseconds: 5000) : const Duration(milliseconds: 2000),
    backgroundColor: Colors.green[900],
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
    dismissDirection: DismissDirection.horizontal,
  );
  ScaffoldMessenger.of(context).showSnackBar(snack);
}
