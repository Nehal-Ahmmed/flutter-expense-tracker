import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:untitled/providers/expense_provider.dart';
import 'package:untitled/providers/navigation_provider.dart';
import 'package:untitled/utils/theme.dart';
import 'package:untitled/widgets/app_drawer.dart';
import 'package:untitled/widgets/dashboard/summary_card.dart';
import 'package:untitled/widgets/dashboard/transaction_item.dart';
import 'package:untitled/widgets/dashboard/premium_bar_chart.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final recentTransactions = expenseProvider.recentTransactions;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back,', style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey),
            ),
            Text(
              'User Name',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart Section
            Text(
              'Spending Analysis',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            PremiumBarChart(weeklySpending: expenseProvider.weeklySpending),
            const SizedBox(height: 24),

            // Financial Insights
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Insights',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    expenseProvider.transactions.isEmpty
                        ? 'Start adding transactions to see insights.'
                        : 'Your top spending category this week is Shopping}.', // Simplified logic for demo
                    style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Budget Progress
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Monthly Budget',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          _showEditBudgetDialog(
                            context,
                            expenseProvider,
                          ); // Need to implement this
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '\$${expenseProvider.totalExpense.toStringAsFixed(0)} / \$${expenseProvider.monthlyBudget.toStringAsFixed(0)}',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value:
                        (expenseProvider.totalExpense /
                                (expenseProvider.monthlyBudget == 0
                                    ? 1
                                    : expenseProvider.monthlyBudget))
                            .clamp(0.0, 1.0),
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${((expenseProvider.totalExpense / (expenseProvider.monthlyBudget == 0 ? 1 : expenseProvider.monthlyBudget)) * 100).toStringAsFixed(1)}% used',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Summary Cards
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SummaryCard(
                    title: 'Total Balance',
                    amount:
                        '\$${expenseProvider.totalBalance.toStringAsFixed(2)}',
                    icon: Icons.account_balance_wallet,
                    color: AppTheme.primaryColor,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(width: 16),
                  SummaryCard(
                    title: 'Income',
                    amount:
                        '\$${expenseProvider.totalIncome.toStringAsFixed(2)}',
                    icon: Icons.arrow_upward,
                    color: Colors.green,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(width: 16),
                  SummaryCard(
                    title: 'Expenses',
                    amount:
                        '\$${expenseProvider.totalExpense.toStringAsFixed(2)}',
                    icon: Icons.arrow_downward,
                    color: Colors.red,
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent Transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Provider.of<NavigationProvider>(
                      context,
                      listen: false,
                    ).setIndex(1);
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentTransactions.length,
              itemBuilder: (context, index) {
                return TransactionItem(transaction: recentTransactions[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBudgetDialog(BuildContext context, ExpenseProvider provider) {
    final controller = TextEditingController(
      text: provider.monthlyBudget.toStringAsFixed(0),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Set Monthly Budget',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: '\$ ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text) ?? 0.0;
              provider.setBudget(val);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
