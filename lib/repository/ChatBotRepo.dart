// ignore_for_file: file_names

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:needle_network_main/repository/textGenModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:needle_network_main/ModalClasses/TailorsData.dart';
import 'package:needle_network_main/ModalClasses/Products.dart';
import 'package:needle_network_main/ModalClasses/Orders.dart';

class GigaChatRepo {
  static textGenRepo(BuildContext context, List<TextGenModel> chats) async {
    try {
      // Step 1: Get database context
      String databaseContext = await _getDatabaseContext();

      // Step 2: Add enhanced system prompt with database context
      chats.insert(
        0,
        TextGenModel(
          role: "user",
          parts: [
            TextPartModel(
              text:
                  "You are an AI assistant inside a tailoring service app called 'Needle Network'. Your job is to help customers with stitching-related questions, order status, measurements, cloth selection, and provide information about available tailors and products.\n\n"
                  "CURRENT DATABASE INFORMATION:\n$databaseContext\n\n"
                  "Use this information to provide accurate, helpful responses about:\n"
                  "- Available tailors and their specialties\n"
                  "- Product prices and availability\n"
                  "- Order status and tracking\n"
                  "- Tailor locations and contact info\n"
                  "- Service recommendations based on customer needs\n\n"
                  "Always reply in a friendly and helpful tone, focused only on tailoring and customer needs. Keep responses concise (2-4 lines) but informative.",
            ),
          ],
        ),
      );

      // Step 3: Get user's recent query context
      if (chats.length > 1) {
        String userQuery = chats.last.parts[0].text.toLowerCase();
        String specificContext = await _getSpecificContext(userQuery);
        if (specificContext.isNotEmpty) {
          chats.insert(
            1,
            TextGenModel(
              role: "user",
              parts: [
                TextPartModel(
                  text: "ADDITIONAL RELEVANT INFORMATION:\n$specificContext",
                ),
              ],
            ),
          );
        }
      }

      // Step 2: Make the POST request
      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=***REMOVED***',
        ),
        body: json.encode(
          {
            "contents": chats.map((e) => e.toMap()).toList(),
            "generationConfig": {
              "temperature": 0.7, // Balanced creativity
              "topK": 0,
              "topP": 0.95,
              "maxOutputTokens": 150, // Limit response length
              "stopSequences": []
            },
            "safetySettings": [
              {
                "category": "HARM_CATEGORY_HARASSMENT",
                "threshold": "BLOCK_MEDIUM_AND_ABOVE"
              },
              {
                "category": "HARM_CATEGORY_HATE_SPEECH",
                "threshold": "BLOCK_MEDIUM_AND_ABOVE"
              },
              {
                "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
                "threshold": "BLOCK_MEDIUM_AND_ABOVE"
              },
              {
                "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
                "threshold": "BLOCK_MEDIUM_AND_ABOVE"
              }
            ]
          },
        ),
      );

      // Step 3: Handle success response
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final candidates = responseBody['candidates'] as List<dynamic>;
        for (final candidate in candidates) {
          final chat = TextGenModel.fromMap(candidate);
          chats.add(chat);
        }
      } else {
        print("Error Code: ${response.statusCode}");
      }
    } catch (e) {
      log(e.toString());
      print("Error in catch block");
    }
  }

  // Get general database context for the chatbot
  static Future<String> _getDatabaseContext() async {
    try {
      StringBuffer context = StringBuffer();

      // Get tailors information
      QuerySnapshot tailorsSnapshot = await FirebaseFirestore.instance
          .collection('Business Info')
          .limit(5)
          .get();

      if (tailorsSnapshot.docs.isNotEmpty) {
        context.writeln("AVAILABLE TAILORS:");
        for (var doc in tailorsSnapshot.docs) {
          TailorsData tailor =
              TailorsData.fromMap(doc.data() as Map<String, dynamic>);
          context.writeln("- ${tailor.shopName} (${tailor.address})");
          List<String> services = [];
          if (tailor.suits == true) services.add("Suits");
          if (tailor.uniforms == true) services.add("Uniforms");
          if (tailor.sherwani == true) services.add("Sherwani");
          if (tailor.lahenga == true) services.add("Lahenga");
          if (services.isNotEmpty) {
            context.writeln("  Services: ${services.join(', ')}");
          }
          if (tailor.phoneNumber != null) {
            context.writeln("  Contact: ${tailor.phoneNumber}");
          }
        }
        context.writeln();
      }

      // Get user's orders if logged in
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
            .collection('Orders')
            .where('CustomerId', isEqualTo: user.uid)
            .limit(3)
            .get();

        if (ordersSnapshot.docs.isNotEmpty) {
          context.writeln("YOUR RECENT ORDERS:");
          for (var doc in ordersSnapshot.docs) {
            Orders order =
                Orders.fromMap(doc as DocumentSnapshot<Map<String, dynamic>>);
            context.writeln("- ${order.itemName} (Status: ${order.status})");
            if (order.price != null) {
              context.writeln("  Price: Rs. ${order.price}");
            }
          }
          context.writeln();
        }
      }

      return context.toString();
    } catch (e) {
      log("Error getting database context: $e");
      return "";
    }
  }

  // Get specific context based on user query
  static Future<String> _getSpecificContext(String userQuery) async {
    try {
      StringBuffer context = StringBuffer();

      // Check if user is asking about orders
      if (userQuery.contains('order') ||
          userQuery.contains('status') ||
          userQuery.contains('track')) {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
              .collection('Orders')
              .where('CustomerId', isEqualTo: user.uid)
              .orderBy('TimeStamp', descending: true)
              .limit(5)
              .get();

          if (ordersSnapshot.docs.isNotEmpty) {
            context.writeln("YOUR ORDERS:");
            for (var doc in ordersSnapshot.docs) {
              Orders order =
                  Orders.fromMap(doc as DocumentSnapshot<Map<String, dynamic>>);
              context.writeln("- ${order.itemName}: ${order.status}");
              if (order.price != null) {
                context.writeln("  Price: Rs. ${order.price}");
              }
              if (order.timeStamp != null) {
                context.writeln("  Date: ${order.timeStamp}");
              }
            }
          }
        }
      }

      // Check if user is asking about tailors or shops
      else if (userQuery.contains('tailor') ||
          userQuery.contains('shop') ||
          userQuery.contains('near')) {
        QuerySnapshot tailorsSnapshot = await FirebaseFirestore.instance
            .collection('Business Info')
            .limit(10)
            .get();

        if (tailorsSnapshot.docs.isNotEmpty) {
          context.writeln("AVAILABLE TAILORS:");
          for (var doc in tailorsSnapshot.docs) {
            TailorsData tailor =
                TailorsData.fromMap(doc.data() as Map<String, dynamic>);
            context.writeln("- ${tailor.shopName}");
            if (tailor.address != null) {
              context.writeln("  Location: ${tailor.address}");
            }
            if (tailor.phoneNumber != null) {
              context.writeln("  Phone: ${tailor.phoneNumber}");
            }

            List<String> services = [];
            if (tailor.suits == true) services.add("Suits");
            if (tailor.uniforms == true) services.add("Uniforms");
            if (tailor.sherwani == true) services.add("Sherwani");
            if (tailor.lahenga == true) services.add("Lahenga");
            if (services.isNotEmpty) {
              context.writeln("  Services: ${services.join(', ')}");
            }

            if (tailor.openingTime != null && tailor.closingTime != null) {
              context.writeln(
                  "  Hours: ${tailor.openingTime} - ${tailor.closingTime}");
            }
            context.writeln();
          }
        }
      }

      // Check if user is asking about products or prices
      else if (userQuery.contains('price') ||
          userQuery.contains('product') ||
          userQuery.contains('suit') ||
          userQuery.contains('dress')) {
        QuerySnapshot productsSnapshot = await FirebaseFirestore.instance
            .collection('AllItems')
            .limit(8)
            .get();

        if (productsSnapshot.docs.isNotEmpty) {
          context.writeln("AVAILABLE PRODUCTS:");
          for (var doc in productsSnapshot.docs) {
            Products product =
                Products.fromMap(doc as DocumentSnapshot<Map<String, dynamic>>);
            context.writeln("- ${product.title}");
            if (product.price != null) {
              if (product.discount != null && product.discount! > 0) {
                int discountedPrice = product.price! -
                    (product.price! * product.discount! ~/ 100);
                context.writeln(
                    "  Price: Rs. $discountedPrice (${product.discount}% off from Rs. ${product.price})");
              } else {
                context.writeln("  Price: Rs. ${product.price}");
              }
            }
            if (product.discription != null) {
              context.writeln("  Description: ${product.discription}");
            }
          }
        }
      }

      return context.toString();
    } catch (e) {
      log("Error getting specific context: $e");
      return "";
    }
  }
}
