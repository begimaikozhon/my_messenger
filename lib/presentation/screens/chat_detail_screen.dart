import 'package:contacts_service/contacts_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_messenger/core/helpers/name_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/hive_boxes.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/message_model.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;

  const ChatDetailScreen({super.key, required this.chatId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late ChatModel chat;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    chat = HiveBoxes.getChatsBox().get(widget.chatId)!;
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final msg = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      timestamp: DateTime.now(),
      isSentByMe: true,
    );

    setState(() {
      chat.messages.add(msg);
      chat.save();
      _controller.clear();

      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
  }

  void _onAttachPressed() {
    final attachments = [
      {
        'icon': Icons.photo,
        'label': 'Gallery',
        'color': Colors.blue,
        'onTap': _pickImage,
      },
      {
        'icon': Icons.insert_drive_file,
        'label': 'File',
        'color': Colors.blue.shade400,
        'onTap': _pickDocument,
      },
      {
        'icon': Icons.location_on,
        'label': 'Location',
        'color': Colors.green,
        'onTap': _pickLocation,
      },
      {
        'icon': Icons.contacts,
        'label': 'Contact',
        'color': Colors.orange,
        'onTap': _pickContact,
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            child: SizedBox(
              height: 90, // фиксированная высота
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: attachments.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (_, index) {
                  final item = attachments[index];
                  return _buildAttachmentButton(
                    icon: item['icon'] as IconData,
                    label: item['label'] as String,
                    color: item['color'] as Color,
                    onTap: item['onTap'] as VoidCallback,
                  );
                },
              ),
            ),
          ),
    );
  }

  Widget _buildAttachmentButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            child: Icon(icon, size: 28, color: Colors.white),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final msg = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: '',
        imagePath: file.path,
        timestamp: DateTime.now(),
        isSentByMe: true,
      );
      setState(() {
        chat.messages.add(msg);
        chat.save();
      });
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null) {
      final file = result.files.single;
      final msg = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Документ: ${file.name}',
        timestamp: DateTime.now(),
        isSentByMe: true,
      );
      setState(() {
        chat.messages.add(msg);
        chat.save();
      });
    }
  }

  Future<void> _pickMusic() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      final file = result.files.single;
      final msg = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Музыка: ${file.name}',
        timestamp: DateTime.now(),
        isSentByMe: true,
      );
      setState(() {
        chat.messages.add(msg);
        chat.save();
      });
    }
  }

  Future<void> _pickContact() async {
    final permission = await Permission.contacts.request();
    if (!permission.isGranted) return;

    final contacts = await ContactsService.getContacts();
    if (contacts.isNotEmpty) {
      final contact = contacts.first;
      final msg = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Контакт: ${contact.displayName}',
        timestamp: DateTime.now(),
        isSentByMe: true,
      );
      setState(() {
        chat.messages.add(msg);
        chat.save();
      });
    }
  }

  Future<void> _pickLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    final position = await Geolocator.getCurrentPosition();
    final msg = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: 'Геолокация: ${position.latitude}, ${position.longitude}',
      timestamp: DateTime.now(),
      isSentByMe: true,
    );
    setState(() {
      chat.messages.add(msg);
      chat.save();
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = chat.messages;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: NameUtils.getColorByName(chat.name),
              child: Text(
                NameUtils.getInitials(chat.name),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat.name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  "В сети",
                  style: TextStyle(
                    color: Color(0xFF5D7A90),
                    fontSize: 12,
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final reversedIndex = messages.length - 1 - index;
                final msg = messages[reversedIndex];
                final showDate = _shouldShowDateReversed(
                  messages,
                  reversedIndex,
                );

                return Column(
                  crossAxisAlignment:
                      msg.isSentByMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                  children: [
                    if (showDate) _buildDateDivider(msg.timestamp),
                    _buildMessageBubble(msg),
                  ],
                );
              },
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildDateDivider(DateTime timestamp) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const Expanded(
              child: Divider(
                color: Color(0xFF9DB6CA),
                thickness: 1,
                endIndent: 8,
              ),
            ),
            Text(
              _formatDate(timestamp),
              style: const TextStyle(
                color: const Color(0xFF9DB6CA),
                fontSize: 14,
                fontFamily: 'Gilroy',
                fontWeight: FontWeight.w500,
              ),
            ),
            const Expanded(
              child: Divider(color: Color(0xFF9DB6CA), thickness: 1, indent: 8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel msg) {
    return Align(
      alignment: msg.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color:
              msg.isSentByMe
                  ? const Color(0xFF3BEC78)
                  : const Color(0xFFEDF2F6),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(21),
            topRight: Radius.circular(21),
            bottomLeft: Radius.circular(msg.isSentByMe ? 21 : 0),
            bottomRight: Radius.circular(msg.isSentByMe ? 0 : 21),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (msg.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  msg.imagePath!,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            if (msg.text.isNotEmpty)
              Text(
                msg.text,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            SizedBox(width: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat.Hm().format(msg.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF5D7A90),
                  ),
                ),
                if (msg.isSentByMe) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.done_all,
                    size: 16,
                    color: Color(0xFF1B1B1B),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    final isTextNotEmpty = _controller.text.trim().isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            // 📎 Контейнер со скрепкой
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEDF2F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.attach_file, color: Colors.black87),
                onPressed: _onAttachPressed,
              ),
            ),
            const SizedBox(width: 8),

            // 📝 Поле ввода
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF2F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _controller,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Сообщение",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // 🎤 или ✈️ в зависимости от ввода
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEDF2F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(
                  isTextNotEmpty ? Icons.send : Icons.mic_outlined,
                  color: Colors.black87,
                ),
                onPressed:
                    isTextNotEmpty
                        ? _sendMessage
                        : () {
                          // TODO: voice recording
                        },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowDateReversed(List<MessageModel> messages, int index) {
    if (index == 0) return true; // самое новое сообщение внизу
    final prev = messages[index - 1];
    final curr = messages[index];
    return !isSameDay(prev.timestamp, curr.timestamp);
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    if (isSameDay(now, dt)) return "Сегодня";
    return DateFormat('dd.MM.yy').format(dt);
  }
}
