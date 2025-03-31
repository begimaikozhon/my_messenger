import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/chat_model.dart';
import 'data/models/message_model.dart';
import 'presentation/screens/chat_list_screen.dart'; // стартовый экран

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Hive
  await Hive.initFlutter();

  // Регистрация адаптеров
  Hive.registerAdapter(ChatModelAdapter());
  Hive.registerAdapter(MessageModelAdapter());

  // Открытие боксов
  await Hive.openBox<ChatModel>('chats');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Messenger Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ChatListScreen(), // Стартовый экран
    );
  }
}
