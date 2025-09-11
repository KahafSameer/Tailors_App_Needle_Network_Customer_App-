// ignore_for_file: file_names, use_build_context_synchronously
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:needle_network_main/Data_Provider.dart';
import 'package:needle_network_main/MainApp/ChatPage.dart';
import 'package:needle_network_main/ModalClasses/TailorsData.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  String _searchText = '';
  Future<void> _refreshMessages() async {
    setState(() {}); // Triggers StreamBuilder to rebuild
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 20, top: 40, right: 20, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Messages',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 33, 150, 243),
                    fontSize: 26,
                    letterSpacing: 0.5,
                  ),
                ),
                Icon(Icons.message_rounded,
                    color: Color.fromARGB(255, 33, 150, 243), size: 28),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search messages...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide:
                      BorderSide(color: Colors.grey.shade200, width: 1.2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide:
                      BorderSide(color: Colors.grey.shade200, width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(
                      color: Color.fromARGB(255, 33, 150, 243), width: 1.5),
                ),
              ),
              onChanged: (val) => setState(() => _searchText = val.trim()),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshMessages,
              child: StreamBuilder(
                stream: Provider.of<DataProvider>(context)
                    .getLastMessageOfEachUser(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Something went wrong!',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No messages yet.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }
                  final filtered = snapshot.data!
                      .where((msg) =>
                          msg.tailorName
                              .toString()
                              .toLowerCase()
                              .contains(_searchText.toLowerCase()) ||
                          msg.message
                              .toString()
                              .toLowerCase()
                              .contains(_searchText.toLowerCase()))
                      .toList();
                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 0),
                    itemBuilder: (context, index) {
                      DateTime dateTime =
                          DateTime.parse(filtered[index].timeStamp!);
                      String formattedTime = DateFormat.jm().format(dateTime);
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          elevation: 2,
                          shadowColor: Colors.blue.withOpacity(0.08),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () async {
                              await Provider.of<DataProvider>(context,
                                      listen: false)
                                  .loadTailorByUid(filtered[index].tailorId);
                              TailorsData? tailorsData =
                                  Provider.of<DataProvider>(context,
                                          listen: false)
                                      .tailor;
                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                withNavBar: false,
                                screen: ChatPage(tailorsData: tailorsData!),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8),
                              child: Row(
                                children: [
                                  Hero(
                                    tag: 'profile_${filtered[index].tailorId}',
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: CachedNetworkImage(
                                        imageUrl: filtered[index]
                                            .tailorPic
                                            .toString(),
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        progressIndicatorBuilder:
                                            (context, url, progress) =>
                                                SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                              value: progress.progress,
                                              strokeWidth: 2),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                filtered[index]
                                                    .tailorName
                                                    .toString(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 33, 150, 243),
                                                  fontSize: 17,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              formattedTime,
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 13),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          filtered[index].message.toString(),
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.black87),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
