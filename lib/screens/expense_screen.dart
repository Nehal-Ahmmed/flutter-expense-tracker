import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:untitled/models/transaction.dart';
import 'package:untitled/providers/expense_provider.dart';
import 'package:untitled/utils/theme.dart';
import 'package:untitled/widgets/add%20transaction/add_ExpenseTransaction_item.dart';
import 'package:untitled/widgets/add%20transaction/add_incomeTransactionItem.dart';
import 'package:untitled/widgets/dashboard/transaction_item.dart';
import 'package:untitled/screens/transaction_detail_screen.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  TransactionType? _filterType;
  String _searchQuery = '';
  DateTimeRange? _dateRange;

  //old bottom sheet
  void _openAddIncomeTransactionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return const AddIncomeTransactionModal();
      },
    );
  }

  //new navigator for adding transactions
  void _openAddExpenseTransactionScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddExpenseTransactionModelItem()),
    ).then((_) {
      Provider.of<ExpenseProvider>(context, listen: false).fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final allTransactions = expenseProvider.transactions;

    // Apply filters
    final transactions = allTransactions.where((tx) {
      if (_filterType != null && tx.type != _filterType) return false;
      if (_searchQuery.isNotEmpty &&
          !tx.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        return false;
      if (_dateRange != null) {
        if (tx.date.isBefore(_dateRange!.start) ||
            tx.date.isAfter(_dateRange!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }
      return true;
    }).toList();

    // Sort by date desc
    transactions.sort((a, b) => b.date.compareTo(a.date));

    // Group transactions
    final groupedTransactions = <String, List<Transaction>>{};
    for (var tx in transactions) {
      final dateKey = _getDateKey(tx.date);
      if (!groupedTransactions.containsKey(dateKey)) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(tx);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Expenses', style: GoogleFonts.outfit(fontWeight: FontWeight.bold),),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openAddIncomeTransactionBottomSheet(context),
          ),
        ],
      ),
      floatingActionButton: PopupMenuButton<TransactionType>(
        offset: const Offset(0, -140),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        onSelected: (TransactionType type){
          if(type == TransactionType.expense){
            _openAddExpenseTransactionScreen(context);
          }else{
            _openAddIncomeTransactionBottomSheet(context);
          }
        },
        child: FloatingActionButton(
          onPressed: null,
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),

        itemBuilder: (BuildContext context) =>
            <PopupMenuEntry<TransactionType>>[
              PopupMenuItem<TransactionType>(
                value: TransactionType.expense,
                child: ListTile(
                  leading: const Icon(Icons.arrow_downward, color: Colors.red),
                  title: Text('Expense', style: GoogleFonts.outfit()),
                ),
              ),
              const PopupMenuDivider(),

              PopupMenuItem<TransactionType>(
                value: TransactionType.income,
                child: ListTile(
                  leading: const Icon(Icons.arrow_upward, color: Colors.green),
                  title: Text('Income', style: GoogleFonts.outfit()),
                ),
              ),
            ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search transactions...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: _dateRange != null
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).cardColor,
                    foregroundColor: _dateRange != null
                        ? Colors.white
                        : Theme.of(context).iconTheme.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.calendar_month),
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDateRange: _dateRange,
                    );
                    if (picked != null) {
                      setState(() {
                        _dateRange = picked;
                      });
                    } else if (_dateRange != null) {
                      setState(() {
                        _dateRange = null;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('All', null),
                const SizedBox(width: 8),
                _buildFilterChip('Income', TransactionType.income),
                const SizedBox(width: 8),
                _buildFilterChip('Expense', TransactionType.expense),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Transaction List
          Expanded(
            child: transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: GoogleFonts.outfit(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: groupedTransactions.length,
                    itemBuilder: (context, index) {
                      final dateKey = groupedTransactions.keys.elementAt(index);
                      final txs = groupedTransactions[dateKey]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 4,
                            ),
                            child: Text(
                              dateKey,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                          ...txs.map(
                            (tx) => Dismissible(
                              key: ValueKey(tx.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              onDismissed: (direction) {
                                expenseProvider.deleteTransaction(tx.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Transaction deleted'),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      onPressed: () {
                                        expenseProvider.addTransaction(tx);
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: InkWell(
                                onTap: () {

                                  final bool isIncome = tx.type == TransactionType.income;

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => !isIncome
                                          ? AddExpenseTransactionModelItem(transaction: tx,)
                                          : TransactionDetailScreen(transaction: tx)
                                    ),
                                  ).then((_){
                                    Provider.of<ExpenseProvider>(context,listen: false).fetchTransactions();
                                  });
                                },
                                child: TransactionItem(transaction: tx),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      return 'Today';
    } else if (checkDate == yesterday) {
      return 'Yesterday';
    } else {
      return Util.formatDate(
        date,
      ); // Need to ensure Util.formatDate exists or use DateFormat
    }
  }

  Widget _buildFilterChip(String label, TransactionType? type) {
    return ChoiceChip(
      label: Text(label),
      selected: _filterType == type,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filterType = type;
          });
        }
      },
      selectedColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(),
      showCheckmark: false,
    );
  }
}

class Util {
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
