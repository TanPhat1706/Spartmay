import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spartmay/core/constants/color_constants.dart';
import 'package:spartmay/features/transaction/data/models/transaction_model.dart';
import 'package:spartmay/features/transaction/logic/transaction_provider.dart';
import 'package:spartmay/features/wallet/logic/wallet_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transactionToEdit;

  const AddTransactionScreen({super.key, this.transactionToEdit});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  int? _selectedWalletId;
  int? _selectedCategoryId;

  bool get isEditing => widget.transactionToEdit != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().fetchCategories();
      context.read<WalletProvider>().fetchWallets();
    });

    if (isEditing) {
      final tx = widget.transactionToEdit!;
      _amountController.text = tx.amount.abs().toString().replaceAll(RegExp(r'.0$'), ''); 
      _noteController.text = tx.note;
      _selectedDate = tx.date;
      _selectedWalletId = tx.wallet.id;
      
      int tabIndex = tx.category.type == TransactionType.INCOME ? 1 : 0;
      _tabController.animateTo(tabIndex);
      _selectedCategoryId = tx.category.id;
    }

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        if (!isEditing || (isEditing && _tabController.index != (widget.transactionToEdit!.category.type == TransactionType.INCOME ? 1 : 0))) {
             setState(() {
               _selectedCategoryId = null;
             });
        }
      }
    });
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    // 1. Validate form
    if (_amountController.text.isEmpty || _selectedWalletId == null || _selectedCategoryId == null) {
      _showSnackBar("Vui lòng nhập đủ thông tin (Số tiền, Ví, Danh mục)", isError: true);
      return;
    }

    double amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    if (amount <= 0) {
      _showSnackBar("Số tiền phải lớn hơn 0", isError: true);
      return;
    }

    final transactionProvider = context.read<TransactionProvider>();
    final walletProvider = context.read<WalletProvider>();

    bool success = false;
    dynamic result; // Biến lưu kết quả để trả về (dùng cho Edit)

    // 2. Gọi Provider xử lý logic
    // Lưu ý: Provider đã tự động gọi notifyListeners(), Dashboard lắng nghe sẽ tự update.
    if (isEditing) {
      final updatedTx = await transactionProvider.updateTransaction(
        id: widget.transactionToEdit!.id,
        amount: amount,
        note: _noteController.text.trim(),
        categoryId: _selectedCategoryId!,
        walletId: _selectedWalletId!,
        date: _selectedDate,
        walletProvider: walletProvider, // Truyền vào để cập nhật số dư
      );
      
      success = updatedTx != null;
      result = updatedTx;
      
    } else {
      success = await transactionProvider.addTransaction(
        amount: amount,
        note: _noteController.text.trim(),
        categoryId: _selectedCategoryId!,
        walletId: _selectedWalletId!,
        date: _selectedDate,
        walletProvider: walletProvider, // Truyền vào để cập nhật số dư
      );
    }

    // 3. Xử lý kết quả UI
    if (!mounted) return;

    if (success) {
      Navigator.pop(context, result); // Đóng màn hình, trả về kết quả (nếu có)
      _showSnackBar(isEditing ? "Cập nhật thành công!" : "Thêm giao dịch thành công!");
    } else {
      _showSnackBar("Có lỗi xảy ra, vui lòng thử lại", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating, // Hiển thị kiểu nổi đẹp hơn
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Bọc GestureDetector để ẩn bàn phím khi bấm ra ngoài
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? "Sửa giao dịch" : "Thêm giao dịch"),
          backgroundColor: ColorPalette.primaryGreen,
          foregroundColor: Colors.white,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [Tab(text: "CHI TIÊU"), Tab(text: "THU NHẬP")],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: Consumer2<TransactionProvider, WalletProvider>(
          builder: (context, transactionProvider, walletProvider, child) {
            final currentCategories = _tabController.index == 0
                ? transactionProvider.expenseCategories
                : transactionProvider.incomeCategories;
    
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 1. Số tiền
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      fontSize: 40, fontWeight: FontWeight.bold,
                      color: _tabController.index == 0 ? Colors.red : Colors.green,
                    ),
                    decoration: const InputDecoration(
                      labelText: '  Số tiền',
                      prefixText: 'đ ',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const Divider(thickness: 1),
                  const SizedBox(height: 20),
    
                  // 2. Chọn Ví
                  DropdownButtonFormField<int>(
                    value: _selectedWalletId,
                    decoration: const InputDecoration(
                      labelText: 'Chọn ví', 
                      prefixIcon: Icon(Icons.account_balance_wallet, color: ColorPalette.textGrey),
                    ),
                    items: walletProvider.wallets.map((w) => DropdownMenuItem(
                      value: w.id,
                      child: Text(
                        "${w.name} (${NumberFormat("#,###").format(w.balance)} đ)",
                        overflow: TextOverflow.ellipsis,
                      ),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedWalletId = val),
                  ),
    
                  const SizedBox(height: 20),
    
                  // 3. Chọn Danh Mục
                  DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    hint: Text(currentCategories.isEmpty ? "Đang tải..." : "Chọn danh mục"),
                    decoration: const InputDecoration(
                      labelText: 'Danh mục', 
                      prefixIcon: Icon(Icons.category, color: ColorPalette.textGrey),
                    ),
                    items: currentCategories.map((cat) => DropdownMenuItem(
                      value: cat.id,
                      child: Text(cat.name),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedCategoryId = val),
                  ),
    
                  const SizedBox(height: 20),
    
                  // 4. Ghi chú
                  TextField(
                    controller: _noteController,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú',
                      prefixIcon: Icon(Icons.note, color: ColorPalette.textGrey),
                    ),
                  ),
    
                  const SizedBox(height: 20),
    
                  // 5. Chọn ngày (Dùng InputDecorator để giống hệt TextField)
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(primary: ColorPalette.primaryGreen),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Ngày giao dịch',
                        prefixIcon: Icon(Icons.calendar_today, color: ColorPalette.textGrey),
                      ),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
    
                  const SizedBox(height: 40),
    
                  // 6. Nút Lưu
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      onPressed: transactionProvider.isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      child: transactionProvider.isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            isEditing ? "CẬP NHẬT" : "LƯU GIAO DỊCH", 
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                          ),
                    ),
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}