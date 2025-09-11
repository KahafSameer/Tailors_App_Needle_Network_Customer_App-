import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:needle_network_main/Data_Provider.dart';
import 'package:needle_network_main/constants/appColors.dart';
import 'package:needle_network_main/repository/textGenModel.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final textCont = TextEditingController();
  final scrollCont = ScrollController();
  bool responseLoading = false;

  // List of messages to hide - add your specific messages here
  final List<String> _messagesToHide = [
    "You are an AI assistant inside a tailoring service app called 'Needle Network'",
    "ADDITIONAL RELEVANT INFORMATION:",
    "AVAILABLE TAILORS:",
    // Add more messages here that you want to hide
    // "YOUR SPECIFIC MESSAGE TEXT",
  ];

  // Function to check if message should be hidden
  bool _shouldHideMessage(String messageText) {
    for (String hideText in _messagesToHide) {
      if (messageText.contains(hideText)) {
        // Debug: Uncomment the line below to see which messages are being hidden
        print("Hiding message containing: $hideText");
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, _) {
        final chats = dataProvider.chats;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollCont.hasClients) {
            scrollCont.animateTo(
              scrollCont.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 255, 255),
                Color.fromARGB(255, 255, 255, 255)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 1.5,
              centerTitle: true,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/Nicon.png',
                    height: 32,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Needle Network Assistant',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF12182F),
                      fontFamily: 'jaro',
                      fontSize: 18,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              // actions: [
              //   PopupMenuButton(
              //     icon: const Icon(
              //       Icons.more_vert,
              //       color: AppColors.primaryColor,
              //     ),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(16),
              //     ),
              //     itemBuilder: (context) {
              //       return [
              //         PopupMenuItem(
              //           onTap: () {
              //             Provider.of<DataProvider>(context, listen: false)
              //                 .chats
              //                 .clear();
              //           },
              //           child: const Text('Clear Chat'),
              //         ),
              //       ];
              //     },
              //   ),
              // ],
            ),
            body: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                border: Border.all(color: Colors.black12, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  Expanded(
                    child: chats.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline,
                                    size: 64, color: Colors.grey),
                                SizedBox(height: 10),
                                Text(
                                  'Start your conversation',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollCont,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: chats.length,
                            itemBuilder: (context, index) {
                              final chat = chats[index];

                              // Check if message should be hidden
                              if (_shouldHideMessage(chat.parts[0].text)) {
                                return const SizedBox.shrink();
                              }
                              final isUser = chat.role == 'user';
                              final alignment = isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft;
                              final bgColor = isUser
                                  ? AppColors.primaryColor
                                  : Colors.grey[200];
                              final textColor =
                                  isUser ? Colors.white : Colors.black87;
                              final avatar = isUser
                                  ? const CircleAvatar(
                                      radius: 18,
                                      backgroundColor: AppColors.primaryColor,
                                      child: Icon(Icons.person,
                                          color: Colors.white),
                                    )
                                  : const CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Color(0xFFE3E6F3),
                                      child: Icon(Icons.smart_toy,
                                          color: AppColors.primaryColor),
                                    );

                              // TODO: Replace with real timestamp from chat model
                              DateTime msgTime = DateTime.now();
                              String timeStr = TimeOfDay.fromDateTime(msgTime)
                                  .format(context);

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: Row(
                                  mainAxisAlignment: isUser
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isUser) ...[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 4.0),
                                        child: avatar,
                                      ),
                                    ],
                                    Flexible(
                                      child: Align(
                                        alignment: alignment,
                                        child: Container(
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 4),
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: bgColor,
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.07),
                                                blurRadius: 8,
                                                offset: const Offset(2, 2),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: MarkdownBody(
                                                      data: chat.parts[0].text,
                                                      styleSheet:
                                                          MarkdownStyleSheet
                                                                  .fromTheme(
                                                                      Theme.of(
                                                                          context))
                                                              .copyWith(
                                                        p: TextStyle(
                                                          fontSize: 16,
                                                          color: textColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(Icons.copy,
                                                        size: 18,
                                                        color: isUser
                                                            ? Colors.white70
                                                            : Colors.black38),
                                                    tooltip: 'Copy',
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 4,
                                                            right: 0,
                                                            top: 0,
                                                            bottom: 0),
                                                    constraints:
                                                        const BoxConstraints(),
                                                    onPressed: () {
                                                      final data =
                                                          chat.parts[0].text;
                                                      Clipboard.setData(
                                                          ClipboardData(
                                                              text: data));
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Copied to clipboard!'),
                                                          duration: Duration(
                                                              seconds: 1),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                              if (timeStr.isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 6.0, right: 2.0),
                                                  child: Text(
                                                    timeStr,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: isUser
                                                          ? Colors.white70
                                                          : Colors.black45,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (isUser) ...[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 8.0, left: 4.0),
                                        child: avatar,
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: AppColors.primaryColor.withOpacity(0.08),
                            width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.07),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Container(
                                color: AppColors.primaryColor.withOpacity(0.06),
                                child: TextFormField(
                                  controller: textCont,
                                  minLines: 1,
                                  maxLines: 4,
                                  style: const TextStyle(fontSize: 16),
                                  decoration: InputDecoration(
                                    hintText: 'Type your message... ✍️',
                                    hintStyle: TextStyle(
                                        color: Colors.grey[500], fontSize: 15),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 18),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          responseLoading
                              ? const SizedBox(
                                  height: 40,
                                  width: 40,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : GestureDetector(
                                  onTap: () async {
                                    if (textCont.text.trim().isEmpty) return;
                                    setState(() => responseLoading = true);
                                    TextGenModel chat = TextGenModel(
                                      role: 'user',
                                      parts: [
                                        TextPartModel(
                                            text: textCont.text.trim()),
                                      ],
                                    );
                                    textCont.clear();
                                    await Provider.of<DataProvider>(context,
                                            listen: false)
                                        .sendChat(context, chat);
                                    setState(() => responseLoading = false);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.primaryColor,
                                          Color(0xFF6C63FF)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryColor
                                              .withOpacity(0.18),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const CircleAvatar(
                                      radius: 22,
                                      backgroundColor: Colors.transparent,
                                      child: Icon(Icons.send,
                                          color: Colors.white, size: 22),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
