import 'package:hive/hive.dart';

part 'message_model.g.dart';

@HiveType(typeId: 1)
class MessageModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String text;

  @HiveField(2)
  DateTime timestamp;

  @HiveField(3)
  bool isSentByMe;

  @HiveField(4)
  String? imagePath; // путь к фото, если есть

  MessageModel({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isSentByMe,
    this.imagePath,
  });
}
