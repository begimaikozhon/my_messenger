import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_messenger/core/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../data/hive_boxes.dart';
import '../../data/models/chat_model.dart';
import '../widgets/chat_tile.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'Чаты',
          style: TextStyle(
            color: const Color(0xFF2B333E),
            fontSize: 32,
            fontFamily: 'Gilroy',
            fontWeight: FontWeight.w600,
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(
        //       Theme.of(context).brightness == Brightness.dark
        //           ? Icons.light_mode
        //           : Icons.dark_mode,
        //     ),
        //     onPressed: () {
        //       context.read<ThemeProvider>().toggleTheme();
        //     },
        //   ),
        // ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              showCursor: false,
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                prefixIcon: Image.asset('assets/icons/Search_s.png'),
                hintText: 'Поиск',
                hintStyle: TextStyle(
                  color: const Color(0xFF9DB6CA),
                  fontSize: 16,
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w500,
                ),
                filled: true,
                fillColor: Color(0xffEDF2F6),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: HiveBoxes.getChatsBox().listenable(),
              builder: (context, Box<ChatModel> box, _) {
                final allChats = box.values.toList();
                allChats.sort(
                  (a, b) =>
                      b.lastMessage?.timestamp.compareTo(
                        a.lastMessage?.timestamp ?? DateTime(0),
                      ) ??
                      0,
                );

                final filteredChats =
                    allChats.where((chat) {
                      return chat.name.toLowerCase().contains(_searchQuery);
                    }).toList();

                if (filteredChats.isEmpty) {
                  return const Center(child: Text('Чатов не найдено'));
                }

                return ListView.builder(
                  itemCount: filteredChats.length,
                  itemBuilder: (context, index) {
                    final chat = filteredChats[index];
                    final lastMsg = chat.lastMessage;

                    return Dismissible(
                      key: ValueKey(chat.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => chat.delete(),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: ChatTile(
                        initials: chat.name,
                        avatarColor: Colors.deepPurpleAccent,
                        name: chat.name,
                        lastMessage: lastMsg?.text ?? '',
                        lastMessageTime: lastMsg?.timestamp ?? DateTime.now(),
                        isMe: lastMsg?.isSentByMe ?? false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatDetailScreen(chatId: chat.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
