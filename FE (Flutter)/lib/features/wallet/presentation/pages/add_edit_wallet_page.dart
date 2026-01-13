import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spartmay/core/constants/color_constants.dart';
import 'package:spartmay/features/wallet/data/models/wallet_model.dart';
import 'package:spartmay/features/wallet/logic/wallet_provider.dart';

class AddEditWalletPage extends StatefulWidget {
  final Wallet? wallet;

  const AddEditWalletPage({super.key, this.wallet});

  @override
  State<AddEditWalletPage> createState() => _AddEditWalletPageState();
}

class _AddEditWalletPageState extends State<AddEditWalletPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _balanceController;

  WalletType _selectedType = WalletType.CASH;
  bool _includeInTotal = true;
  bool _isLoading = false;

  bool get isEditing => widget.wallet != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.wallet?.name ?? '');
    // Nếu đang edit thì hiển thị số dư, thêm mới thì để trống cho user nhập
    _balanceController = TextEditingController(text: widget.wallet?.balance.toString() ?? '');
    
    if (isEditing) {
      _selectedType = widget.wallet!.type;
      _includeInTotal = widget.wallet!.includeInTotal;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _saveWallet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = context.read<WalletProvider>();
    final name = _nameController.text.trim();
    final balance = double.tryParse(_balanceController.text.replaceAll(',', '')) ?? 0.0;

    final newWalletData = Wallet(
      id: widget.wallet?.id,
      name: name,
      balance: balance,
      type: _selectedType,
      includeInTotal: _includeInTotal,
    );

    bool success;
    if (isEditing) {
      success = await provider.updateWallet(widget.wallet!.id!, newWalletData);
    } else {
      success = await provider.addWallet(newWalletData);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // Trả về true để màn hình trước biết là đã update thành công
      Navigator.pop(context, true); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? "Có lỗi xảy ra"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.backgroundLight,
      appBar: AppBar(
        title: Text(isEditing ? "Chỉnh sửa ví" : "Thêm ví mới"),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Tên ví
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: "Tên ví",
                  hintText: "VD: Tiền mặt, VCB...",
                  prefixIcon: Icon(Icons.account_balance_wallet, color: ColorPalette.textGrey),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? "Vui lòng nhập tên ví" : null,
              ),
              const SizedBox(height: 20),

              // 2. Số dư
              TextFormField(
                controller: _balanceController,
                keyboardType: TextInputType.number,
                // Nếu logic của em cho phép sửa số dư thì để enable, không thì disable
                enabled: !isEditing, 
                decoration: InputDecoration(
                  labelText: isEditing ? "Số dư hiện tại (Không thể sửa)" : "Số dư ban đầu",
                  prefixIcon: const Icon(Icons.attach_money, color: ColorPalette.textGrey),
                  suffixText: "đ",
                  filled: isEditing, // Xám ô nhập nếu đang edit
                  fillColor: isEditing ? Colors.grey.shade100 : Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Nhập số dư";
                  if (double.tryParse(value) == null) return "Phải là số";
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 3. Loại ví (Dropdown)
              DropdownButtonFormField<WalletType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: "Loại ví",
                  prefixIcon: Icon(Icons.category, color: ColorPalette.textGrey),
                ),
                items: WalletType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(type.icon, size: 18, color: ColorPalette.primaryGreen),
                        const SizedBox(width: 10),
                        Text(type.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
              const SizedBox(height: 20),

              // 4. Switch Include Total
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: SwitchListTile(
                  title: const Text("Tính vào tổng tài sản", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Hiển thị số tiền ví này ở màn hình chính"),
                  value: _includeInTotal,
                  activeColor: ColorPalette.primaryGreen,
                  onChanged: (val) => setState(() => _includeInTotal = val),
                ),
              ),

              const SizedBox(height: 30),

              // 5. Button Save
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveWallet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          isEditing ? "LƯU THAY ĐỔI" : "TẠO VÍ NGAY",
                          style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}