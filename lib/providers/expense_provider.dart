import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  double _monthlyBudget = 0.0;
  double get monthlyBudget => _monthlyBudget;

  double get totalBalance => totalIncome - totalExpense;

  Future<void> loadBudget() async {
    final prefs = await SharedPreferences.getInstance();
    _monthlyBudget =
        prefs.getDouble('monthly_budget') ?? 2000.0; // Default goal
    notifyListeners();
  }

  Future<void> setBudget(double amount) async {
    _monthlyBudget = amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthly_budget', amount);
    notifyListeners();
  }

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
    print("Transactions loaded: ${_transactions.length}"); // Debugging log
    notifyListeners();
  }

  Future<void> addTransaction(Transaction tx) async {
    await DatabaseHelper.instance.createTransaction(tx);
    await fetchTransactions();

    print("Transaction added: ${tx.title}"); // Debugging log

  }

  Future<void> updateTransaction(Transaction tx) async{
    await DatabaseHelper.instance.updateTransaction(tx);
    await fetchTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await DatabaseHelper.instance.delete(id);
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
  }

  Map<int, double> get weeklySpending {
    Map<int, double> spending = {
      0: 0.0,
      1: 0.0,
      2: 0.0,
      3: 0.0,
      4: 0.0,
      5: 0.0,
      6: 0.0,
    };

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfNextWeek = startOfWeek.add(const Duration(days: 7));

    for (var tx in _transactions) {
      if (tx.type == TransactionType.expense) {
        final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
        final weekStart = DateTime(
          startOfWeek.year,
          startOfWeek.month,
          startOfWeek.day,
        );

        if (!txDate.isBefore(weekStart) && txDate.isBefore(startOfNextWeek)) {
          final dayIndex = tx.date.weekday - 1;
          spending[dayIndex] = (spending[dayIndex] ?? 0.0) + tx.amount;
        }
      }
    }
    return spending;
  }
}
