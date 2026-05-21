import 'package:flutter/material.dart';

class ExpenseIconHelper {
  ExpenseIconHelper._();

  static IconData resolve(String? description, {bool isSettlement = false}) {
    if (isSettlement) return Icons.account_balance_wallet_outlined;
    return _resolveIcon(description ?? '');
  }

  static IconData _resolveIcon(String description) {
    final words = description
        .toLowerCase()
        .split(RegExp(r'[^a-z]+'))
        .where((w) => w.length > 1)
        .toSet();

    const rules = [
      (
        <String>{
          'restaurant', 'food', 'lunch', 'dinner', 'breakfast', 'cafe',
          'coffee', 'tea', 'pizza', 'burger', 'sushi', 'biryani', 'eat',
          'meal', 'snack', 'drink', 'drinks', 'bar', 'dine', 'takeaway',
          'takeout', 'bbq', 'grill',
        },
        Icons.restaurant_outlined,
      ),
      (
        <String>{
          'grocery', 'groceries', 'supermarket', 'market', 'vegetable',
          'vegetables', 'fruit', 'fruits', 'bread', 'milk', 'eggs',
          'dairy', 'store',
        },
        Icons.local_grocery_store_outlined,
      ),
      (
        <String>{
          'meat', 'chicken', 'beef', 'pork', 'mutton', 'fish', 'seafood',
          'prawns', 'shrimp', 'lamb',
        },
        Icons.set_meal_outlined,
      ),
      (
        <String>{'fuel', 'petrol', 'diesel', 'refuel', 'filling', 'cng'},
        Icons.local_gas_station_outlined,
      ),
      (
        <String>{
          'uber', 'taxi', 'cab', 'ride', 'bus', 'train', 'metro', 'subway',
          'ticket', 'toll', 'parking', 'carpool', 'auto', 'rickshaw',
          'flight', 'airline', 'transport', 'ferry',
        },
        Icons.directions_car_outlined,
      ),
      (
        <String>{
          'rent', 'house', 'flat', 'apartment', 'hotel', 'airbnb', 'hostel',
          'stay', 'lease', 'mortgage', 'room', 'accommodation',
        },
        Icons.home_outlined,
      ),
      (
        <String>{
          'internet', 'wifi', 'broadband', 'fiber', 'data', 'phone',
          'mobile', 'sim', 'recharge', 'topup', 'postpaid', 'prepaid',
          'subscription', 'streaming',
        },
        Icons.wifi_outlined,
      ),
      (
        <String>{
          'electricity', 'electric', 'power', 'water', 'gas', 'bill',
          'bills', 'utility', 'utilities', 'maintenance', 'sewage', 'council',
        },
        Icons.bolt_outlined,
      ),
      (
        <String>{
          'movie', 'cinema', 'netflix', 'disney', 'hbo', 'spotify', 'music',
          'concert', 'show', 'event', 'game', 'gaming', 'esports', 'sports',
          'gym', 'fitness', 'workout', 'yoga', 'cricket', 'football',
        },
        Icons.sports_esports_outlined,
      ),
      (
        <String>{
          'shopping', 'clothes', 'clothing', 'amazon', 'flipkart', 'order',
          'delivery', 'shop', 'mall', 'fashion', 'shoes', 'accessories',
          'gadget', 'electronics',
        },
        Icons.shopping_bag_outlined,
      ),
      (
        <String>{
          'medicine', 'doctor', 'hospital', 'pharmacy', 'health', 'medical',
          'dental', 'clinic', 'prescription', 'chemist', 'test', 'lab',
          'surgery', 'physiotherapy',
        },
        Icons.local_hospital_outlined,
      ),
      (
        <String>{
          'book', 'books', 'course', 'tuition', 'school', 'college',
          'university', 'education', 'study', 'class', 'lesson',
          'stationery', 'fees',
        },
        Icons.menu_book_outlined,
      ),
    ];

    for (final (keywords, icon) in rules) {
      if (words.any(keywords.contains)) return icon;
    }
    return Icons.receipt_long_outlined;
  }
}
