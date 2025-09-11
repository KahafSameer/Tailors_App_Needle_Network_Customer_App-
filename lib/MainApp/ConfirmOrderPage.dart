// ignore_for_file: file_names, must_be_immutable, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:needle_network_main/Data_Provider.dart';
import 'package:needle_network_main/ModalClasses/Orders.dart';
import 'package:needle_network_main/ModalClasses/Products.dart';
import 'package:needle_network_main/ModalClasses/TailorsData.dart';
import 'package:needle_network_main/ModalClasses/UserData.dart';
import 'package:provider/provider.dart';

class ConfirmOrderPage extends StatefulWidget {
  Products products;
  String category;
  TailorsData tailorData;
  ConfirmOrderPage({
    super.key,
    required this.products,
    required this.category,
    required this.tailorData,
  });

  @override
  State<ConfirmOrderPage> createState() => _ConfirmOrderPageState();
}

class _ConfirmOrderPageState extends State<ConfirmOrderPage> {
  UserData? userData;
  final requirementsCont = TextEditingController();
  final quantityCont = TextEditingController();
  final fkey = GlobalKey<FormState>();
  bool loading = false;
  @override
  void initState() {
    Provider.of<DataProvider>(context, listen: false).loadUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userData = Provider.of<DataProvider>(context).userData;
    final screenWidth = MediaQuery.of(context).size.width;
    if (userData == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F9FA), Color(0xFFE3E6F3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Form(
            key: fkey,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Container(
                            padding: EdgeInsets.all(8),
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
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.products.title ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color: Colors.blue,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 22),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: quantityCont,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Required';
                                  }
                                  if (int.parse(value) > 5) {
                                    return 'Can not order more than 5 pieces';
                                  }
                                  if (int.parse(value) < 1) {
                                    return 'Invalid Value';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                      Icons.confirmation_number,
                                      color: Colors.blue),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  hintText: 'Quantity',
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: requirementsCont,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.list_alt,
                                      color: Colors.blue),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  hintText: 'Describe your requirements',
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                ),
                                maxLines: 8,
                              ),
                              const SizedBox(height: 28),
                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    if (fkey.currentState!.validate()) {
                                      setState(() {
                                        loading = true;
                                      });
                                      Orders orders = Orders(
                                        category: widget.category,
                                        customerId: FirebaseAuth
                                            .instance.currentUser!.uid,
                                        sellerId: widget.tailorData.docId,
                                        images: widget.products.images,
                                        itemName: widget.products.title,
                                        requirements: requirementsCont.text,
                                        customerName: userData!.name,
                                        address: userData!.address,
                                        productId: widget.products.DocId!,
                                        status: 'Pending',
                                        timeStamp: DateTime.now().toString(),
                                        price: widget.products.price,
                                        quantity: quantityCont.text,
                                        orderType: 'Normal',
                                      );
                                      bool requested =
                                          await Provider.of<DataProvider>(
                                                  context,
                                                  listen: false)
                                              .sendOrderRequest(orders, null);
                                      if (requested) {
                                        setState(() {
                                          loading = false;
                                        });
                                        Navigator.pop(context);
                                      }
                                    }
                                  },
                                  icon: loading == false
                                      ? const Icon(Icons.check_circle_outline)
                                      : const SizedBox(
                                          height: 25,
                                          width: 25,
                                          child: CircularProgressIndicator(
                                              color: Colors.white),
                                        ),
                                  label: loading == false
                                      ? const Text('Confirm Order',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18))
                                      : const Text('   Please wait...',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
