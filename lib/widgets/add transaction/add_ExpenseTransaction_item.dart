import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:untitled/models/category.dart';
import 'package:untitled/models/transaction.dart';
import 'package:untitled/providers/expense_provider.dart';
import 'package:untitled/services/pdf/ExpensePdfService.dart';
import 'package:untitled/services/pdf/Final_pdf_service.dart';
import 'package:untitled/utils/theme.dart';
import 'package:uuid/uuid.dart';

class AddExpenseTransactionModelItem extends StatefulWidget {
  final Transaction? transaction;

  const AddExpenseTransactionModelItem({super.key, this.transaction});

  @override
  State<AddExpenseTransactionModelItem> createState() =>
      _AddExpenseTransactionModelItemState();
}

class _AddExpenseTransactionModelItemState
    extends State<AddExpenseTransactionModelItem> {
  final List<Map<String, dynamic>> _allGoods = [];
  final TextEditingController _titleController = TextEditingController(
    text: 'New Expense',
  );
  final FocusNode _titleFocusNode = FocusNode();
  bool _isFirstLoad = true;
  Transaction? _viewTransaction;

  @override
  void initState() {
    super.initState();
    _viewTransaction = widget.transaction;

    if (_viewTransaction != null) {
      _titleController.text = _viewTransaction!.title;
      _isFirstLoad = false;
      _allGoods.clear();
      for (var item in _viewTransaction!.goods ?? []) {
        _allGoods.add({
          'title': item.name,
          'desc': item.desc,
          'quantity': item.quantity,
          'unitPrice': item.price,
          'cost': item.price * (item.quantity ?? 1),
          'category': item.category,
        });
      }
    }

    if (_isFirstLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _titleFocusNode.requestFocus();
        _titleController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _titleController.text.length,
        );
        _isFirstLoad = false;
      });
    }
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _showAddGoodsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const GoodsInputForm(),
    ).then((newGood) {
      if (newGood != null) {
        setState(() {
          _allGoods.add(newGood);
        });
      }
    });
  }

  void _saveFullTransaction() async {
    final enteredTitle = _titleController.text.trim();
    if (_allGoods.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add some items first')));
      return;
    }

    double totalAmount = _allGoods.fold(0, (sum, item) => sum + item['cost']);

    final newTransaction = Transaction(
      id: const Uuid().v4(),
      title: enteredTitle,
      amount: totalAmount,
      date: DateTime.now(),
      type: TransactionType.expense,
      goods: _allGoods
          .map(
            (item) =>
            Goods(
              id: const Uuid().v4(),
              name: item['title'],
              desc: item['desc'],
              price: item['unitPrice'],
              quantity: item['quantity'],
              category: item['category'],
            ),
      )
          .toList(),
    );

    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    await provider.addTransaction(newTransaction);

    setState(() {
      _viewTransaction = newTransaction;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction Saved Successfully!')),
    );
  }

  void _SavePdfServiceForExpense() async {
    if (_viewTransaction != null) {
      Expensepdfservice.savePdf(_viewTransaction!);
    }
  }

  void _SharePdfServiceForExpense() async {
    if (_viewTransaction != null) {
      Expensepdfservice.sharePdf(_viewTransaction!);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool _isViewMode = _viewTransaction != null;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme
            .of(context)
            .scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: TextField(
            controller: _titleController,
            focusNode: _titleFocusNode,
            enabled: !_isViewMode,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: context.lightBlack,
            ),
            decoration: InputDecoration(
              hintText: 'Enter Title',
              border: InputBorder.none,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.primaryColor),
              ),
            ),
          ),
          actions: [
            if(_isViewMode)
              Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        _SavePdfServiceForExpense();
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                    ),
                    IconButton(
                      onPressed: () {
                        _SharePdfServiceForExpense();
                      },
                      icon: const Icon(Icons.share),
                    ),
                  ]
              ),

            if (!_isViewMode)
              IconButton(
                onPressed: _saveFullTransaction,
                icon: const Icon(Icons.check_circle, color: Colors.green),
              ),
          ],
        ),
        floatingActionButton: _isViewMode
            ? null
            : FloatingActionButton(
          onPressed: _showAddGoodsSheet,
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: _allGoods.isEmpty
            ? Center(
          child: Text(
            'No items added yet!\nClick + to add goods.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: Colors.grey),
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      headingRowColor: WidgetStateProperty.all(
                        AppTheme.primaryColor,
                      ),
                      showCheckboxColumn: false,
                      columns: const [
                        DataColumn(
                          label: Text(
                            'Title',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Desc',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Qty',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Unit price',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Category',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      rows: _allGoods.map((item) {
                        return DataRow(
                          onSelectChanged:
                              (_) {}, // রো ক্লিকযোগ্য করার জন্য
                          cells: [
                            DataCell(Text(item['title'] ?? '')),
                            DataCell(Text(item['desc'] ?? '')),
                            DataCell(
                              Text(item['quantity']?.toString() ?? '1'),
                            ),
                            DataCell(
                              Text('${item['unitPrice'] ?? 0} TK'),
                            ),
                            // ফিক্সড: unitPrice দেখানো হয়েছে
                            DataCell(Text('${item['cost'] ?? 0} TK')),
                            DataCell(
                              Text(
                                (item['category'] as CategoryType).name,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Summary',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      'Total Items',
                      '${_allGoods.length}',
                    ),
                    _buildSummaryRow(
                      'Total Quantity',
                      '${_allGoods.fold(
                          0, (sum, item) => sum + (item['quantity'] as int))}',
                    ),
                    const Divider(),
                    _buildSummaryRow(
                      'Grand Total',
                      '${_allGoods
                          .fold(0.0, (sum, item) => sum + item['cost'])
                          .toStringAsFixed(2)} TK',
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.grey[700])),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class GoodsInputForm extends StatefulWidget {
  const GoodsInputForm({super.key});

  @override
  State<GoodsInputForm> createState() => _GoodsInputFormState();
}

class _GoodsInputFormState extends State<GoodsInputForm> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  int _qty = 1;
  String _desc = '';
  double _price = 0.0;
  CategoryType _selectedCategory = CategoryType.other;

  final List<CategoryType> expenseCategories = [
    CategoryType.shopping,
    CategoryType.food,
    CategoryType.transport,
    CategoryType.entertainment,
    CategoryType.health,
    CategoryType.bills,
    CategoryType.other,
  ];

  final _qtyFocus = FocusNode();
  final _priceFocus = FocusNode();

  void _saveLocal() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.of(context).pop({
        'title': _title,
        'desc': _desc,
        'quantity': _qty,
        'unitPrice': _price,
        'cost': _qty * _price,
        'category': _selectedCategory,
      });
    }
  }

  @override
  void dispose() {
    _qtyFocus.dispose();
    _priceFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery
            .of(context)
            .viewInsets
            .bottom + 20,
        top: 25,
        left: 20,
        right: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Item Details',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<CategoryType>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: expenseCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Icon(category.icon, color: category.color, size: 20),
                        const SizedBox(width: 8),
                        Text(category.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_qtyFocus),
                validator: (val) => val!.isEmpty ? 'Please enter name' : null,
                onSaved: (val) => _title = val!,
              ),
              const SizedBox(height: 15),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => _desc = val ?? '',
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      focusNode: _qtyFocus,
                      decoration: const InputDecoration(
                        labelText: 'Qty',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (val) => _qty = int.tryParse(val!) ?? 1,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      focusNode: _priceFocus,
                      decoration: const InputDecoration(
                        labelText: 'Unit Price',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (val) => _price = double.tryParse(val!) ?? 0.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _saveLocal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: const Text(
                      "Add Item",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
