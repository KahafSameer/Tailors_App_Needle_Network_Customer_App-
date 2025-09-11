// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:needle_network_main/Data_Provider.dart';
import 'package:provider/provider.dart';

import '../ModalClasses/Notifications.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Notifications> notifications = [];
  @override
  void initState() {
    Provider.of<DataProvider>(context, listen: false).getNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    notifications = Provider.of<DataProvider>(context).notifications;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F9FA), Color(0xFFE3E6F3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Enhanced Header
            Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 30),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
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
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.notifications_active,
                      color: Colors.blue, size: 28),
                  const SizedBox(width: 10),
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: Colors.blue,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            notifications.isNotEmpty
                ? Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await Provider.of<DataProvider>(context, listen: false)
                            .getNotification();
                        setState(() {});
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          notifications.sort(
                            (b, a) {
                              return a.timeStamp!.compareTo(b.timeStamp!);
                            },
                          );
                          DateTime dateTime =
                              DateTime.parse(notifications[index].timeStamp!);
                          String formattedTime =
                              DateFormat('E, h:mm a').format(dateTime);
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              leading: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(Icons.notifications,
                                    color: Colors.blue, size: 28),
                              ),
                              title: Text(
                                notifications[index].title!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(notifications[index].subtitle!),
                              trailing: Text(
                                formattedTime,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 13),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.notifications_off,
                            color: Colors.grey, size: 60),
                        const SizedBox(height: 12),
                        const Text(
                          'No new notifications',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            await Provider.of<DataProvider>(context,
                                    listen: false)
                                .getNotification();
                            setState(() {});
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.refresh,
                              color: Colors.blue,
                              size: 28,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
