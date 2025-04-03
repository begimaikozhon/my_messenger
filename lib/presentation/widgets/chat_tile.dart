import 'package:flutter/material.dart';
import 'package:my_messenger/core/helpers/date_utils_helper.dart';
import 'package:my_messenger/core/helpers/name_utils.dart';

class ChatTile extends StatelessWidget {
  final String initials;
  final Color avatarColor;
  final String name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isMe;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.initials,
    required this.avatarColor,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.isMe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    print('ChatTile: $name'); // 👈 добавь
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: NameUtils.getColorByName(name),
        radius: 26,
        child: Text(
          NameUtils.getInitials(name),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Gilroy',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      title: Text(
        name,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
      ),

      subtitle: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall,
          children: [
            if (isMe)
              TextSpan(
                text: 'Вы: ',
                style: const TextStyle(
                  color: const Color(0xFF2B333E),
                  fontSize: 12,
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w500,
                ),
              ),
            TextSpan(
              text: lastMessage,
              style: TextStyle(
                color: const Color(0xFF5D7A90),
                fontSize: 12,
                fontFamily: 'Gilroy',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),

      trailing: Text(
        DateUtilsHelper.formatChatTime(lastMessageTime),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
