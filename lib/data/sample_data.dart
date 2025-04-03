import 'models/chat_model.dart';
import 'models/message_model.dart';
import 'hive_boxes.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

Future<void> createSampleChats() async {
  final box = HiveBoxes.getChatsBox();

  if (box.isNotEmpty) return; // чтобы не дублировать при каждом запуске

  final now = DateTime.now();

  final chats = [
    ChatModel(
      id: uuid.v4(),
      name: 'Виктор Власов',
      avatar: 'VV',
      messages: [
        MessageModel(
          id: uuid.v4(),
          text: 'Уже сделал?',
          timestamp: now.subtract(const Duration(days: 1)), // Вчера
          isSentByMe: true,
        ),
      ],
    ),
    ChatModel(
      id: uuid.v4(),
      name: 'Саша Алексеев',
      avatar: 'CA',
      messages: [
        MessageModel(
          id: uuid.v4(),
          text: 'Я готов',
          timestamp: DateTime(2022, 1, 12, 14, 30), // 12.01.22
          isSentByMe: false,
        ),
      ],
    ),
    ChatModel(
      id: uuid.v4(),
      name: 'Пётр Жаринов',
      avatar: 'ПЖ',
      messages: [
        MessageModel(
          id: uuid.v4(),
          text: 'Я вышел',
          timestamp: now.subtract(const Duration(minutes: 2)), // 2 минуты назад
          isSentByMe: true,
        ),
      ],
    ),
    ChatModel(
      id: uuid.v4(),
      name: 'Алина Жукова',
      avatar: 'АЖ',
      messages: [
        MessageModel(
          id: uuid.v4(),
          text: 'Я вышел',
          timestamp: DateTime(
            now.year,
            now.month,
            now.day,
            9,
            23,
          ), // Сегодня 09:23
          isSentByMe: true,
        ),
      ],
    ),
  ];

  for (var chat in chats) {
    await box.put(chat.id, chat);
    print("Добавлен чат: ${chat.name}");
  }
}
