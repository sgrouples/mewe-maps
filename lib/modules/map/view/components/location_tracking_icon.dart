import 'package:flutter/material.dart';

class LocationTrackingIcon extends StatelessWidget {
  final bool isSelected;

  const LocationTrackingIcon(this.isSelected, {super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(
      isSelected ? Icons.my_location : Icons.location_searching,
      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
    );
  }
}
