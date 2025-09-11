// ignore_for_file: unused_local_variable, file_names

import 'package:flutter/material.dart';
import 'package:needle_network_main/Data_Provider.dart';
import 'package:needle_network_main/MainApp/ChatPage.dart';
import 'package:needle_network_main/MainApp/CustomOrderPage.dart';
import 'package:needle_network_main/MainApp/TailorProductsPage.dart';
import 'package:needle_network_main/ModalClasses/TailorsData.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

import '../ModalClasses/Products.dart';

class TailorInfoPage extends StatefulWidget {
  final TailorsData tailorsData;

  const TailorInfoPage({Key? key, required this.tailorsData}) : super(key: key);

  @override
  State<TailorInfoPage> createState() => _TailorInfoPageState();
}

class _TailorInfoPageState extends State<TailorInfoPage> {
  List<Products> allProducts = [];
  bool? productsLoaded;
  @override
  void initState() {
    Provider.of<DataProvider>(context, listen: false)
        .loadProducts(widget.tailorsData.docId!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    allProducts = Provider.of<DataProvider>(context).products;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 40),
                      child: InkWell(
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
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 40),
                      child: Text(
                        widget.tailorsData.shopName.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20, top: 40),
                        child: InkWell(
                          onTap: () {
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: ChatPage(tailorsData: widget.tailorsData),
                              withNavBar: false,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.message,
                                color: Colors.white,
                                size: 25,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Shop Image Card
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 14, bottom: 10),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.network(
                            widget.tailorsData.shopImage.toString(),
                            height: 220,
                            width: screenWidth,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    // Location Card
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Card(
                        color: Colors.blue,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.white, size: 32),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Location',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14)),
                                    Text(
                                      widget.tailorsData.address.toString(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Open Hours Card
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.access_time,
                                      color: Colors.blue, size: 22),
                                  SizedBox(width: 8),
                                  Text('Open hours',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17)),
                                ],
                              ),
                              widget.tailorsData.open24Hours == false
                                  ? Text(
                                      '${widget.tailorsData.openingTime} to ${widget.tailorsData.closingTime}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87),
                                    )
                                  : const Text('24 hours open',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Services Header
                    const Padding(
                      padding: EdgeInsets.only(
                          left: 20, top: 20, right: 20, bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.design_services,
                              color: Colors.blue, size: 22),
                          SizedBox(width: 8),
                          Text('Services',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ),
                    // Services Card
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 8),
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            children: [
                              if (widget.tailorsData.pantCoat == true)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, left: 10, right: 10),
                                  child: SizedBox(
                                    height: 30,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          List<Products> selectedProduct =
                                              allProducts
                                                  .where((element) =>
                                                      element.pantCoat == true)
                                                  .toList();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TailorProductsPage(
                                                tailorsData: widget.tailorsData,
                                                products: selectedProduct,
                                                title: 'Pant Coat',
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text('Pant Coat'),
                                      ),
                                    ),
                                  ),
                                ),
                              if (widget.tailorsData.lahenga == true)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, left: 10, right: 10),
                                  child: SizedBox(
                                    height: 30,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          List<Products> selectedProduct =
                                              allProducts
                                                  .where((element) =>
                                                      element.lahenga == true)
                                                  .toList();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TailorProductsPage(
                                                tailorsData: widget.tailorsData,
                                                products: selectedProduct,
                                                title: 'Lahenga',
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text('Lahenga'),
                                      ),
                                    ),
                                  ),
                                ),
                              if (widget.tailorsData.sherwani == true)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, left: 10, right: 10),
                                  child: SizedBox(
                                    height: 30,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          List<Products> selectedProduct =
                                              allProducts
                                                  .where((element) =>
                                                      element.sherwani == true)
                                                  .toList();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TailorProductsPage(
                                                tailorsData: widget.tailorsData,
                                                products: selectedProduct,
                                                title: 'Sherwani',
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text('Sherwani'),
                                      ),
                                    ),
                                  ),
                                ),
                              if (widget.tailorsData.suits == true)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, left: 10, right: 10),
                                  child: SizedBox(
                                    height: 30,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          List<Products> selectedProduct =
                                              allProducts
                                                  .where((element) =>
                                                      element.suit == true)
                                                  .toList();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TailorProductsPage(
                                                tailorsData: widget.tailorsData,
                                                products: selectedProduct,
                                                title: 'Suit',
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text('Suits'),
                                      ),
                                    ),
                                  ),
                                ),
                              if (widget.tailorsData.uniforms == true)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, left: 10, right: 10),
                                  child: SizedBox(
                                    height: 30,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          List<Products> selectedProduct =
                                              allProducts
                                                  .where((element) =>
                                                      element.uniform == true)
                                                  .toList();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TailorProductsPage(
                                                tailorsData: widget.tailorsData,
                                                products: selectedProduct,
                                                title: 'Uniform',
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text('Uniforms'),
                                      ),
                                    ),
                                  ),
                                ),
                              if (widget.tailorsData.waistCoat == true)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, left: 10, right: 10),
                                  child: SizedBox(
                                    height: 30,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          List<Products> selectedProduct =
                                              allProducts
                                                  .where((element) =>
                                                      element.waistCoat == true)
                                                  .toList();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TailorProductsPage(
                                                tailorsData: widget.tailorsData,
                                                products: selectedProduct,
                                                title: 'WaistCoat',
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text('WaistCoats'),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Audience Header
                    const Padding(
                      padding: EdgeInsets.only(
                          left: 20, top: 20, right: 20, bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.people, color: Colors.blue, size: 22),
                          SizedBox(width: 8),
                          Text('Audience',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ),
                    // Audience Card
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20),
                      child: Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 8),
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            children: [
                              if (widget.tailorsData.men == true)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, left: 10, right: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Men',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (widget.tailorsData.women == true)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, left: 10, right: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Women',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (widget.tailorsData.children == true)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, left: 10, right: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Children',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (widget.tailorsData.elders == true)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, left: 10, right: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Elders',
                                        style: TextStyle(
                                          color: Colors.white,
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
                    // Divider
                    const Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 10,
                        bottom: 10,
                      ),
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                    // Custom Order Button
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 10,
                        bottom: 20,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: SizedBox(
                          width: screenWidth,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              textStyle: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CustomOrderPage(
                                    tailorsData: widget.tailorsData,
                                  ),
                                ),
                              );
                            },
                            child: const Text('Custom order',
                                style: TextStyle(color: Colors.white)),
                          ),
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
    );
  }
}
