// ignore_for_file: file_names, must_be_immutable, unused_local_variable
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:needle_network_main/Data_Provider.dart';
import 'package:needle_network_main/ModalClasses/MessageData.dart';
import 'package:needle_network_main/ModalClasses/TailorsData.dart';
import 'package:provider/provider.dart';

import '../ModalClasses/UserData.dart';

class ChatPage extends StatefulWidget {
  TailorsData tailorsData;
  ChatPage({super.key, required this.tailorsData});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  UserData? userData;

  @override
  void initState() {
    Provider.of<DataProvider>(context, listen: false).loadUserData();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userData = Provider.of<DataProvider>(context).userData;
    final messageCont = TextEditingController();
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.blue,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.tailorsData.shopImage!),
            ),
            const SizedBox(width: 10),
            Text(
              widget.tailorsData.shopName.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: Provider.of<DataProvider>(context)
                  .getMessages(widget.tailorsData.docId!),
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  List<MessageData> messages = [];
                  for (var element in snapshot.data!) {
                    if (element.tailorId == widget.tailorsData.docId) {
                      messages.add(element);
                    }
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollController
                        .jumpTo(_scrollController.position.maxScrollExtent);
                  });
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      messages.sort(
                        (a, b) {
                          return a.timeStamp!.compareTo(b.timeStamp!);
                        },
                      );
                      DateTime dateTime =
                          DateTime.parse(snapshot.data![index].timeStamp!);
                      String formattedTime = DateFormat.jm().format(dateTime);

                      bool isMe = messages[index].receiverId ==
                          widget.tailorsData.docId!;

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          padding: const EdgeInsets.all(12),
                          constraints: const BoxConstraints(
                            maxWidth: 250,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.blue
                                : const Color.fromARGB(255, 131, 131, 131),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: isMe
                                  ? const Radius.circular(20)
                                  : Radius.zero,
                              bottomRight: !isMe
                                  ? const Radius.circular(20)
                                  : Radius.zero,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                messages[index].message.toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isMe ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                formattedTime,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isMe
                                      ? const Color.fromARGB(255, 171, 171, 171)
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: messageCont,
                    maxLines: 5,
                    minLines: 1,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromARGB(255, 255, 255, 255),
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  heroTag: 'chat_fab_${widget.tailorsData.docId}',
                  onPressed: () {
                    if (messageCont.text.isNotEmpty) {
                      MessageData messageData = MessageData(
                        customerPic: userData?.profilePic,
                        tailorPic: widget.tailorsData.shopImage,
                        message: messageCont.text,
                        customerName: userData?.name,
                        senderId: FirebaseAuth.instance.currentUser!.uid,
                        tailorName: widget.tailorsData.shopName,
                        receiverId: widget.tailorsData.docId,
                        tailorId: widget.tailorsData.docId,
                        customerId: FirebaseAuth.instance.currentUser!.uid,
                        timeStamp: DateTime.now().toString(),
                      );
                      Provider.of<DataProvider>(context, listen: false)
                          .sendMessage(messageData);
                      messageCont.text = '';
                    }
                  },
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.send,
                      color: Color.fromARGB(255, 255, 255, 255)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
