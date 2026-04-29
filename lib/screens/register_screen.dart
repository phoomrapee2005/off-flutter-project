import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Please enter username';
    if (value.length <= 7) return 'Username must be more than 7 characters';
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])').hasMatch(value)) {
      return 'Must contain both uppercase and lowercase';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter password';
    if (value.length <= 7) return 'Password must be more than 7 characters';
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])').hasMatch(value)) {
      return 'Must contain both uppercase and lowercase';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter email';
    if (!value.endsWith('@gmail.com')) return 'Email must end with @gmail.com';
    return null;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
        final age = DateTime.now().year - picked.year;
        _ageController.text = age.toString();
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;//ตรวจสอบข้อมูลในฟอร์มก่อน เช่น username, password, email ว่ากรอกถูกต้องไหม ถ้ากรอกไม่ถูกต้อง จะหยุดทำงานทันที ไม่สมัครสมาชิกต่อ

    setState(() => _isLoading = true);

    final user = User(
      id: const Uuid().v4(),
      username: _usernameController.text,
      password: _passwordController.text,
      email: _emailController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phone: _phoneController.text,
      dob: _dobController.text,
      age: int.tryParse(_ageController.text) ?? 0,
      address: _addressController.text,
    );

    final error = await Provider.of<AuthProvider>(context, listen: false).register(user);//ส่งข้อมูล user ไปให้ AuthProvider สมัครสมาชิก ผลลัพธ์ที่ได้จะเก็บไว้ในตัวแปร error

    setState(() => _isLoading = false);

    if (mounted) {//เช็กว่าหน้านี้ยังเปิดอยู่ไหม
      if (error == null) {//เช็กว่าหน้านี้ยังเปิดอยู่ไหม
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Successful! Please login.')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(_usernameController, 'Username', Icons.person, validator: _validateUsername),
              const SizedBox(height: 16),
              _buildField(_passwordController, 'Password', Icons.lock, isPassword: true, validator: _validatePassword),
              const SizedBox(height: 16),
              _buildField(_emailController, 'Email', Icons.email, validator: _validateEmail),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildField(_firstNameController, 'First Name', Icons.badge)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField(_lastNameController, 'Last Name', Icons.badge)),
                ],
              ),
              const SizedBox(height: 16),
              _buildField(_phoneController, 'Phone Number', Icons.phone, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectDate,
                      child: IgnorePointer(
                        child: _buildField(_dobController, 'DOB (DD/MM/YYYY)', Icons.calendar_today),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildField(_ageController, 'Age', Icons.cake, keyboardType: TextInputType.number),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildField(_addressController, 'Address', Icons.home, maxLines: 3),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('REGISTER'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller, 
    String label, 
    IconData icon, {
    bool isPassword = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator ?? (v) => v!.isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}
