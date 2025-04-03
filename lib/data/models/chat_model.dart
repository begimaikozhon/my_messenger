import 'package:hive/hive.dart';
import 'message_model.dart';

part 'chat_model.g.dart';

@HiveType(typeId: 0)
class ChatModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String avatar; // путь к изображению или первая буква

  @HiveField(3)
  List<MessageModel> messages;

  ChatModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.messages,
  });

  MessageModel? get lastMessage => messages.isNotEmpty ? messages.last : null;

  DateTime? get lastMessageTime =>
      lastMessage?.timestamp;
}
