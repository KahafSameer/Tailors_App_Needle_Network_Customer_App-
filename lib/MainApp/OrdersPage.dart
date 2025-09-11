// ignore_for_file: file_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:needle_network_main/Data_Provider.dart';
import 'package:needle_network_main/MainApp/OrderInfo.dart';
import 'package:needle_network_main/ModalClasses/Orders.dart';
import 'package:needle_network_main/ModalClasses/TailorsData.dart';
import 'package:provider/provider.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<Orders>? orders = [];
  List<TailorsData>? tailors = [];
  @override
  void initState() {
    Provider.of<DataProvider>(context, listen: false).loadTailors();
    Provider.of<DataProvider>(context, listen: false).getOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    orders = Provider.of<DataProvider>(context).orders;
    tailors = Provider.of<DataProvider>(context).tailorsData;
    if (orders == null || tailors == null) {
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
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
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
                          color: Colors.blue.withOpacity(0.1),
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
                  const Icon(Icons.shopping_bag, color: Colors.blue, size: 28),
                  const SizedBox(width: 10),
                  const Text(
                    'Orders',
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
            orders!.isNotEmpty
                ? Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await Provider.of<DataProvider>(context, listen: false)
                            .getOrders();
                        setState(() {});
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: orders!.length,
                        itemBuilder: (context, index) {
                          DateTime dateTime =
                              DateTime.parse(orders![index].timeStamp!);
                          String formattedTime =
                              DateFormat.MMMMEEEEd().format(dateTime);
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderInfo(
                                      orders: orders![index],
                                      tailorsData: tailors!,
                                    ),
                                  ),
                                );
                              },
                              leading: Container(
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: orders![index].images![0],
                                    progressIndicatorBuilder:
                                        (context, url, progress) => Center(
                                      child: CircularProgressIndicator(
                                        value: progress.progress,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              title: Text(
                                orders![index].itemName.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Row(
                                children: [
                                  orders![index].status == 'Cancelled'
                                      ? const Icon(Icons.cancel,
                                          color: Colors.red, size: 18)
                                      : orders![index].status == 'Delivered'
                                          ? const Icon(Icons.check_circle,
                                              color: Colors.green, size: 18)
                                          : const Icon(Icons.pending_actions,
                                              color: Colors.orange, size: 18),
                                  const SizedBox(width: 6),
                                  orders![index].status == 'Cancelled'
                                      ? const Text('Cancelled',
                                          style: TextStyle(color: Colors.red))
                                      : orders![index].status == 'Delivered'
                                          ? const Text('Delivered',
                                              style: TextStyle(
                                                  color: Colors.green))
                                          : Text(
                                              '${orders![index].quantity} Pieces',
                                              style: const TextStyle(
                                                  color: Colors.orange)),
                                ],
                              ),
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
                : const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, color: Colors.grey, size: 60),
                          SizedBox(height: 12),
                          Text(
                            'No orders found',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
