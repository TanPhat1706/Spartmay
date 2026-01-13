import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spartmay/core/constants/color_constants.dart';
import 'package:spartmay/features/wallet/data/models/wallet_model.dart';
import 'package:spartmay/features/wallet/logic/wallet_provider.dart';

class WalletFormSheet extends StatefulWidget {
  final Wallet? walletToEdit;

  const WalletFormSheet({super.key, this.walletToEdit});

  @override
  State<WalletFormSheet> createState() => _WalletFormSheetState();
}

class _WalletFormSheetState extends State<WalletFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  late WalletType _selectedType;
  late bool _includeInTotal;
  bool _isSubmitting = false;

  bool get isEditing => widget.walletToEdit != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.walletToEdit?.name ?? '');
    // Nếu là edit thì hiển thị balance, nếu mới thì trống
    _balanceController = TextEditingController(text: widget.walletToEdit?.balance.toString() ?? '');
    _selectedType = widget.walletToEdit?.type ?? WalletType.CASH;
    _includeInTotal = widget.walletToEdit?.includeInTotal ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final provider = context.read<WalletProvider>();
    final newWallet = Wallet(
      id: widget.walletToEdit?.id,
      name: _nameController.text,
      balance: double.tryParse(_balanceController.text) ?? 0.0,
      type: _selectedType,
      includeInTotal: _includeInTotal,
    );

    bool success;
    if (isEditing) {
      success = await provider.updateWallet(widget.walletToEdit!.id!, newWallet);
    } else {
      success = await provider.addWallet(newWallet);
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context); // Đóng BottomSheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? "Cập nhật thành công!" : "Tạo ví thành công!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Xử lý Padding để đẩy form lên khi có bàn phím (ViewInsets)
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20, left: 20, right: 20
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? "Cập nhật ví" : "Thêm ví mới",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Input Tên
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên ví', border: OutlineInputBorder()),
              validator: (val) => val!.isEmpty ? 'Nhập tên ví' : null,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),

            // Input Số dư
            TextFormField(
              controller: _balanceController,
              keyboardType: TextInputType.number,
              // Nếu đang edit thì thường không cho sửa số dư ban đầu, 
              // nhưng nếu logic của em cho phép thì cứ để true
              enabled: !isEditing, 
              style: TextStyle(
                color: isEditing ? Colors.grey.shade600 : ColorPalette.textDark,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                labelText: isEditing ? 'Số dư hiện tại (Không thể sửa)' : 'Số dư ban đầu',
                border: const OutlineInputBorder(),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: isEditing ? const Icon(Icons.lock, color: Colors.grey, size: 18) : null,
              ),
              validator: (val) => val!.isEmpty ? 'Nhập số dư' : null,
            ),
            const SizedBox(height: 12),

            // Dropdown Loại ví
            DropdownButtonFormField<WalletType>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Loại ví', border: OutlineInputBorder()),
              items: WalletType.values.map((type) => DropdownMenuItem(
                value: type,
                child: Row(children: [Icon(type.icon, size: 18), const SizedBox(width: 8), Text(type.displayName)]),
              )).toList(),
              onChanged: (val) => setState(() => _selectedType = val!),
            ),
            
            // Switch
            SwitchListTile(
              title: const Text("Tính vào tổng tài sản"),
              value: _includeInTotal,
              activeColor: ColorPalette.primaryGreen,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) => setState(() => _includeInTotal = val),
            ),

            const SizedBox(height: 20),
            
            // Nút Lưu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: ColorPalette.primaryGreen),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(isEditing ? "LƯU THAY ĐỔI" : "TẠO VÍ", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}