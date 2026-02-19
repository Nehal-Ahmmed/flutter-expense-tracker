import 'package:flutter/material.dart';
import 'package:untitled/models/category.dart';

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String? desc;
  final List<Goods>? goods;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    this.desc,
    this.goods,
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
      'desc': desc,
      'goods': goods?.map((x) => x.toMap()).toList(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      desc: map['desc'],
      goods: map['goods'] != null
          ? List<Goods>.from(map['goods']?.map((x) => Goods.fromMap(x)))
          : null,
    );
  }
}

class Goods {
  final String id;
  final String? name;
  final double price;
  final int? quantity;
  final String? desc;
  final DateTime? date;
  final CategoryType? category;

  Goods({
    required this.id,
    this.name,
    required this.price,
    this.quantity,
    this.desc,
    this.date,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'desc': desc,
      'date': date?.toIso8601String(),
      'category': category?.toString().split('.').last,
    };
  }

  factory Goods.fromMap(Map<String, dynamic> map) {
    return Goods(
      id: map['id'],
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'],
      desc: map['desc'],
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      category: map['category'] != null
          ? CategoryType.values.byName(map['category'])
          : null,
    );
  }

  void operator [](String other) {}
}