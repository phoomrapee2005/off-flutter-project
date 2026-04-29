import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();//สร้าง key สำหรับควบคุม Form ใช้ตรวจสอบว่าผู้ใช้กรอก username/password ครบไหม
  final _usernameController = TextEditingController();//ใช้ควบคุมและอ่านข้อความจากช่อง username
  final _passwordController = TextEditingController();//ใช้ควบคุมและอ่านข้อความจากช่อง password
  bool _isLoading = false; //ใช้บอกว่าตอนนี้กำลัง login อยู่หรือไม่

  Future<void> _login() async {//สร้างฟังก์ชัน _login()
    if (!_formKey.currentState!.validate()) return; //ตรวจสอบข้อมูลในฟอร์มก่อน ถ้า username หรือ password ว่าง จะหยุดทำงานทันที ไม่ส่งข้อมูลไป login

    setState(() => _isLoading = true);//เปิดสถานะ loading

    final success = await Provider.of<AuthProvider>(context, listen: false).login(//ส่ง username และ password ไปให้ AuthProvider.login() ตรวจสอบ
      _usernameController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);//ปิดสถานะ loading หลังจาก login เสร็จแล้ว

    if (mounted) {//เช็กว่าหน้า Login ยังอยู่บนหน้าจอไหม
      if (success) {//ถ้า login สำเร็จ
      } else {//ถ้า login ไม่สำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid username or password'), backgroundColor: Colors.red),//แสดงข้อความแจ้งเตือนสีแดงว่า username หรือ password ไม่ถูกต้อง
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_cart_outlined, size: 80, color: Color(0xFF1A1C23)),
                const SizedBox(height: 16),
                Text(
                  'Click & Clack',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => v!.isEmpty ? 'Please enter username' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) => v!.isEmpty ? 'Please enter password' : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('LOGIN'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text('Don\'t have an account? Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
