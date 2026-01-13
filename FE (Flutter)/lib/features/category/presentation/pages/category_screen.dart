import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spartmay/core/constants/color_constants.dart';
import 'package:spartmay/core/utils/icon_utils.dart';
import 'package:spartmay/features/category/logic/category_provider.dart';
import 'package:spartmay/features/transaction/data/models/transaction_model.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.backgroundLight,
      appBar: AppBar(
        title: const Text("Quản lý danh mục", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: ColorPalette.primaryGreen,
          unselectedLabelColor: Colors.grey,
          indicatorColor: ColorPalette.primaryGreen,
          tabs: const [
            Tab(text: "Chi tiêu"),
            Tab(text: "Thu nhập"),
          ],
        ),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildCategoryList(provider.expenseCategories, provider),
              _buildCategoryList(provider.incomeCategories, provider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorPalette.primaryGreen,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddEditDialog(context),
      ),
    );
  }

  Widget _buildCategoryList(List<Category> categories, CategoryProvider provider) {
    if (categories.isEmpty) return const Center(child: Text("Chưa có danh mục nào"));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: ColorPalette.primaryGreen.withOpacity(0.1),
              child: Icon(IconUtils.getIconByName(cat.icon), color: ColorPalette.primaryGreen),
            ),
            title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: PopupMenuButton(
              onSelected: (value) {
                if (value == 'edit') _showAddEditDialog(context, category: cat);
                if (value == 'delete') _confirmDelete(context, provider, cat.id);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text("Sửa")),
                const PopupMenuItem(value: 'delete', child: Text("Xóa", style: TextStyle(color: Colors.red))),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- LOGIC ADD / EDIT DIALOG ---
  void _showAddEditDialog(BuildContext context, {Category? category}) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    String selectedIcon = category?.icon ?? 'fastfood';
    // Mặc định lấy loại theo tab đang đứng nếu thêm mới
    TransactionType selectedType = isEditing 
        ? category.type 
        : (_tabController.index == 0 ? TransactionType.EXPENSE : TransactionType.INCOME);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? "Sửa danh mục" : "Thêm danh mục mới",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  
                  // Nhập tên
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Tên danh mục", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),

                  // Chọn Icon (Grid nhỏ)
                  const Text("Chọn biểu tượng:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 100,
                    child: GridView.count(
                      crossAxisCount: 6,
                      children: ['fastfood', 'coffee', 'motorcycle', 'attach_money', 'shopping_cart', 'home', 'medical_services', 'school', 'balance', 'account_balance']
                          .map((iconName) => GestureDetector(
                                onTap: () => setModalState(() => selectedIcon = iconName),
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: selectedIcon == iconName ? ColorPalette.primaryGreen : Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(IconUtils.getIconByName(iconName), 
                                      color: selectedIcon == iconName ? Colors.white : Colors.grey, size: 20),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: ColorPalette.primaryGreen, padding: const EdgeInsets.all(16)),
                      onPressed: () async {
                        if (nameController.text.isEmpty) return;
                        final provider = context.read<CategoryProvider>();
                        
                        bool success;
                        if (isEditing) {
                          success = await provider.updateCategory(category.id, nameController.text, selectedIcon);
                        } else {
                          success = await provider.addCategory(nameController.text, selectedIcon, selectedType);
                        }

                        if (success && mounted) Navigator.pop(context);
                      },
                      child: Text(isEditing ? "Cập nhật" : "Thêm mới", style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, CategoryProvider provider, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xóa danh mục?"),
        content: const Text("Bạn có chắc muốn xóa không? Hành động này không thể hoàn tác."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              await provider.deleteCategory(id);
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}