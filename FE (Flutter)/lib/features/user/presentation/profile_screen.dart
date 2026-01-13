import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:spartmay/core/constants/color_constants.dart';
import 'package:spartmay/core/utils/dialog_utils.dart'; 
import 'package:spartmay/features/auth/presentation/pages/login_screen.dart';
import 'package:spartmay/features/user/logic/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUser();
    });
  }

  void _logout(BuildContext context) async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'auth_token');
    
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.backgroundLight,
      // 1. Thêm AppBar
      appBar: AppBar(
        title: const Text("Hồ sơ cá nhân", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: ColorPalette.primaryGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: ColorPalette.primaryGreen)
            );
          }

          if (provider.error != null) {
             return Center(child: Text("Lỗi: ${provider.error}"));
          }

          final user = provider.user;
          if (user == null) return const Center(child: Text("Không tải được thông tin"));

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context, user),
                const SizedBox(height: 20),
                _buildMenuSection(context),
                const SizedBox(height: 20),
                _buildLogoutButton(context),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, var user) {
    return Container(
      // 2. Điều chỉnh padding: Bỏ top: 60 vì đã có AppBar
      padding: const EdgeInsets.only(top: 20, bottom: 30, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ColorPalette.primaryGreen, width: 3),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: ColorPalette.primaryGreen.withOpacity(0.1),
              backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                  ? Text(
                      user.initials,
                      style: const TextStyle(
                        fontSize: 32, 
                        fontWeight: FontWeight.bold, 
                        color: ColorPalette.primaryGreen
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            user.fullName,
            style: const TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.bold, 
              color: ColorPalette.textDark
            ),
          ),
          const SizedBox(height: 4),
          
          Text(
            user.email,
            style: const TextStyle(fontSize: 14, color: ColorPalette.textGrey),
          ),
          const SizedBox(height: 8),
          
          // 3. Logic hiển thị Role
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
             decoration: BoxDecoration(
               color: Colors.blue.withOpacity(0.1),
               borderRadius: BorderRadius.circular(20)
             ),
             child: Text(
               // Nếu role là USER thì hiện 'Người dùng thử', ngược lại hiện nguyên gốc
               user.role == 'USER' ? 'Người dùng thử' : user.role,
               style: const TextStyle(
                 color: Colors.blue, 
                 fontWeight: FontWeight.bold, 
                 fontSize: 12
               ),
             ),
          )
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildMenuItem(Icons.help_outline, "Trợ giúp & Phản hồi", () {
            DialogUtils.showComingSoon(context);
          }),
          _buildMenuItem(Icons.language_outlined, "Thay đổi ngôn ngữ", () {
            DialogUtils.showComingSoon(context);
          }),
          _buildMenuItem(Icons.currency_exchange_outlined, "Thay đổi tiền tệ", () {
            DialogUtils.showComingSoon(context);
          }),
          _buildMenuItem(Icons.file_download_outlined, "Xuất dữ liệu chi tiêu", () {
            DialogUtils.showComingSoon(context);
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100, 
            blurRadius: 5, 
            offset: const Offset(0, 2)
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ColorPalette.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: ColorPalette.primaryGreen),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () => _logout(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.red.withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text(
            "Đăng xuất",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}