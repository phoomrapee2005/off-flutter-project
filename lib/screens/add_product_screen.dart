import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sellerNameController = TextEditingController();
  final _sellerPhoneController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();

  late String _category;
  late String _condition;
  XFile? _imageFile;
  bool _isLoading = false;

  final List<String> _categories = ['Mouse', 'Keyboard', 'Headphones', 'Mousepad', 'Others'];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _category = widget.product?.category ?? 'Mouse';
    _condition = widget.product?.condition ?? 'new';
    
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _sellerNameController.text = widget.product!.sellerName;
      _sellerPhoneController.text = widget.product!.sellerPhone;
      _brandController.text = widget.product!.brand;
      _modelNameController.text = widget.product!.modelName;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _quantityController.text = widget.product!.quantity.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sellerNameController.dispose();
    _sellerPhoneController.dispose();
    _brandController.dispose();
    _modelNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;//ตรวจสอบข้อมูลในฟอร์มก่อน
    if (_imageFile == null && widget.product == null) {//ตรวจสอบว่าเลือกรูปสินค้าหรือยัง
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a product image'),
          behavior: SnackBarBehavior.floating,//ถ้ายังไม่ได้เลือกรูป จะแสดงข้อความแจ้งเตือนว่า
        ),
      );
      return;
    }

    setState(() => _isLoading = true);//เปิดสถานะ loading

    final quantity = int.tryParse(_quantityController.text) ?? 0;//แปลงจำนวนสินค้าจากข้อความให้เป็นตัวเลข int
    final price = double.tryParse(_priceController.text) ?? 0.0;//แปลงราคาจากข้อความให้เป็นตัวเลขทศนิยม double

    final product = Product(
      id: widget.product?.id ?? const Uuid().v4(),//กำหนด id ของสินค้า จะไม่ซ้ำกัน
      name: _nameController.text,
      sellerName: _sellerNameController.text,
      sellerPhone: _sellerPhoneController.text,
      brand: _brandController.text,
      category: _category,
      modelName: _modelNameController.text,
      description: _descriptionController.text,
      condition: _condition,
      quantity: quantity,
      price: price,
      imagePath: _imageFile?.path ?? widget.product?.imagePath ?? '',
      createdAt: widget.product?.createdAt ?? DateTime.now(),
    );

    try {
      if (widget.product == null) {//ตรวจสอบว่าเป็นการเพิ่มสินค้าใหม่หรือไม่
        await Provider.of<ProductProvider>(context, listen: false).addProduct(product);//ส่งสินค้าไปให้ ProductProvider เพิ่มสินค้าใหม่
      } else {//ถ้า widget.product ไม่ใช่ null แปลว่าเป็นการ แก้ไขสินค้าเดิม
        await Provider.of<ProductProvider>(context, listen: false).updateProduct(product);//ส่งสินค้าไปให้ ProductProvider อัปเดตข้อมูลสินค้าเดิม
      }

      if (mounted) {
        Navigator.pop(context);//ปิดหน้านี้ และกลับไปหน้าก่อนหน้า
        ScaffoldMessenger.of(context).showSnackBar(//แสดงข้อความแจ้งผลลัพธ์
          SnackBar(
            content: Text(widget.product == null ? 'Product posted!' : 'Product updated!'),//ถ้าเพิ่มสินค้าใหม่ จะแสดง:
            behavior: SnackBarBehavior.floating,//ตั้งให้ SnackBar ลอย และใช้พื้นหลังสีเขียว เพื่อบอกว่าสำเร็จ
            backgroundColor: Colors.green[700],
          ),
        );
      }
    } catch (e) {//ถ้าเกิด error ระหว่างบันทึกสินค้า จะเข้ามาที่ส่วนนี้
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),//แสดงข้อความ error เป็น SnackBar สีแดง
        );
      }
    } finally {//ส่วนนี้จะทำงานเสมอ ไม่ว่าจะบันทึกสำเร็จหรือเกิด error
      if (mounted) setState(() => _isLoading = false);//ปิดสถานะ loading หลังจากทำงานเสร็จ
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Post' : 'New Post'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Image Picker Card
            _buildImagePicker(),
            const SizedBox(height: 32),

            _buildSectionHeader('Product Details', Icons.inventory_2_rounded),
            const SizedBox(height: 20),
            
            _buildTextField(
              controller: _nameController,
              label: 'Product Name',
              icon: Icons.shopping_bag_outlined,
              validator: (v) => v!.isEmpty ? 'Enter name' : null,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _brandController,
                    label: 'Brand',
                    icon: Icons.business_rounded,
                    validator: (v) => v!.isEmpty ? 'Enter brand' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _modelNameController,
                    label: 'Model',
                    icon: Icons.tag_rounded,
                    validator: (v) => v!.isEmpty ? 'Enter model' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    value: _category,
                    label: 'Category',
                    items: _categories,
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(
                    value: _condition,
                    label: 'Condition',
                    items: const ['new', 'used'],
                    onChanged: (v) => setState(() => _condition = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _priceController,
                    label: 'Price',
                    icon: Icons.payments_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Enter price' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _quantityController,
                    label: 'Quantity',
                    icon: Icons.stacked_bar_chart_rounded,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Enter quantity' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              icon: Icons.description_outlined,
              maxLines: 4,
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader('Seller Info', Icons.person_outline_rounded),
            const SizedBox(height: 20),

            _buildTextField(
              controller: _sellerNameController,
              label: 'Seller Name',
              icon: Icons.badge_outlined,
              validator: (v) => v!.isEmpty ? 'Enter seller name' : null,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _sellerPhoneController,
              label: 'Contact Phone',
              icon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Enter phone' : null,
            ),

            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                      )
                    : Text(
                        isEdit ? 'SAVE CHANGES' : 'POST PRODUCT',
                        style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
                      ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF4361EE)),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1A1C23)),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFF1F3F5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: _imageFile != null
              ? (kIsWeb
                  ? Image.network(_imageFile!.path, fit: BoxFit.cover)
                  : Image.file(File(_imageFile!.path), fit: BoxFit.cover))
              : (widget.product?.imagePath.isNotEmpty == true
                  ? (kIsWeb || widget.product!.imagePath.startsWith('http')
                      ? Image.network(widget.product!.imagePath, fit: BoxFit.cover)
                      : Image.file(File(widget.product!.imagePath), fit: BoxFit.cover))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.add_a_photo_rounded, size: 40, color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Upload Product Photo',
                          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
                        ),
                      ],
                    )),
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: value,
      items: items.map((i) => DropdownMenuItem(
        value: i, 
        child: Text(
          i[0].toUpperCase() + i.substring(1),
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        )
      )).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.layers_outlined, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      ),
    );
  }
}
