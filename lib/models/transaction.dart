import 'package:flutter/material.dart';
import 'package:untitled/models/category.dart';

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final CategoryType category;

  // Computed properties for easy UI access
  IconData get icon => category.icon;
  Color get color => category.color;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type
          .toString()
          .split('.')
          .last, // Store as string 'income' or 'expense'
      'category': category
          .toString()
          .split('.')
          .last, // Store as string 'food', etc.
    };
  }

  static Transaction fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      category: CategoryType.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
      ),
    );
  }
}
