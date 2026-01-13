import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spartmay/main_screen.dart';
import '../../../../core/constants/color_constants.dart';
import '../../logic/auth_provider.dart';
import '../widgets/auth_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      
      final success = await authProvider.register(
        _fullNameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tạo tài khoản thành công!"), backgroundColor: ColorPalette.primaryGreen,),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? "Đăng ký thất bại"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColorPalette.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Tạo tài khoản',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: ColorPalette.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bắt đầu quản lý tài chính cùng Spartmay',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: ColorPalette.textGrey,
                        ),
                  ),
                  const SizedBox(height: 32),

                  AuthField(
                    controller: _fullNameController,
                    label: 'Họ và tên',
                    icon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                       if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập họ tên';
                      }
                      return null;
                    },
                  ),

                  AuthField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                     validator: (value) {
                       if (value == null || value.isEmpty) return 'Vui lòng nhập email';
                       if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                         return 'Email không hợp lệ';
                       }
                       return null;
                     },
                  ),

                  AuthField(
                    controller: _passwordController,
                    label: 'Mật khẩu',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    textInputAction: TextInputAction.next, 
                    validator: (value) {
                       if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
                       if (value.length < 6) return 'Mật khẩu phải từ 6 ký tự';
                      return null;
                    },
                  ),

                  AuthField(
                    controller: _confirmPasswordController,
                    label: 'Nhập lại mật khẩu',
                    icon: Icons.lock_reset,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                       if (value == null || value.isEmpty) return 'Vui lòng nhập lại mật khẩu';
                       if (value != _passwordController.text) {
                         return 'Mật khẩu không khớp';
                       }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _handleRegister,
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('ĐĂNG KÝ'),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Đã có tài khoản? ',
                        style: TextStyle(color: ColorPalette.textGrey),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Đăng nhập',
                          style: TextStyle(
                            color: ColorPalette.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}