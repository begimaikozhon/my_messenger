import 'package:hive/hive.dart';
import 'models/chat_model.dart';

class HiveBoxes {
  static Box<ChatModel> getChatsBox() => Hive.box<ChatModel>('chats');
}
