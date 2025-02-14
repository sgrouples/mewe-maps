import 'package:flutter/material.dart';
import 'package:mewe_maps/models/user.dart';
import 'package:mewe_maps/modules/common/view/components/user_avatar.dart';

class ContactListItem extends StatelessWidget {
  final User user;
  final VoidCallback? onTapped;
  final Widget? trailing;

  ContactListItem({
    super.key,
    required this.user,
    this.trailing,
    this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: UserAvatar(
        user: user,
      ),
      title: Text(user.name),
      subtitle: Text(
        user.publicLinkId,
        style: const TextStyle(
          fontSize: 12.0,
          color: Colors.grey,
        ),
      ),
      trailing: trailing,
      onTap: onTapped,
    );
  }
}

class ContactSwitch extends StatelessWidget {

  final bool value;
  final String switchText;
  final ValueChanged<bool> onChanged;

  const ContactSwitch({super.key,required this.value, required this.switchText, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          switchText,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(0),
          child: Transform.scale(
            scale: 0.7,
            child: Switch(
              value: value,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
