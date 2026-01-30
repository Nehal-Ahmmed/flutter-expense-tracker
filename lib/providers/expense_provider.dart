import 'package:flutter/material.dart';
import 'package:untitled/helpers/database_helper.dart';
import 'package:untitled/models/transaction.dart';

class ExpenseProvider with ChangeNotifier {
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => [..._transactions];

  List<Transaction> get recentTransactions {
    final recent = [..._transactions];
    recent.sort((a, b) => b.date.compareTo(a.date));
    return recent.take(5).toList();
  }

  double get totalBalance => totalIncome - totalExpense;

  double get totalIncome {
    return _transactions
        .where((tx) => tx.type == TransactionType.income)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalExpense {
    return _transactions
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> fetchTransactions() async {
    _transactions = await DatabaseHelper.instance.readAllTransactions();
    notifyListeners();
  }

  Future<void> addTransaction(Transaction tx) async {
    await DatabaseHelper.instance.create(tx);
    _transactions.add(
      tx,
    ); // Optimistic update or refetch? Optimistic is faster UI
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await DatabaseHelper.instance.delete(id);
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
  }
}
