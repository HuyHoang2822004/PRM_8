import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';

class AdminProductEditScreen extends StatefulWidget {
  const AdminProductEditScreen({super.key, this.product});

  final Product? product;

  @override
  State<AdminProductEditScreen> createState() => _AdminProductEditScreenState();
}

class _AdminProductEditScreenState extends State<AdminProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _priceController;
  late TextEditingController _salePriceController;
  late TextEditingController _imageController;
  late TextEditingController _stockController;
  late TextEditingController _descController;
  late TextEditingController _movementController;
  late TextEditingController _strapMatController;
  late TextEditingController _waterResController;
  late TextEditingController _warrantyController;
  late TextEditingController _strapsController;
  late TextEditingController _colorsController;

  @override
  void initState() {
    super.initState();
    final prod = widget.product;
    
    _nameController = TextEditingController(text: prod?.name ?? '');
    _brandController = TextEditingController(text: prod?.brand ?? '');
    _priceController = TextEditingController(text: prod?.price != null ? prod!.price.toString() : '');
    _salePriceController = TextEditingController(
      text: prod?.salePrice != null ? prod!.salePrice.toString() : '',
    );
    _imageController = TextEditingController(text: prod?.image ?? '');
    _stockController = TextEditingController(text: prod?.stock != null ? prod!.stock.toString() : '10');
    _descController = TextEditingController(text: prod?.description ?? '');
    _movementController = TextEditingController(text: prod?.movement ?? 'Automatic');
    _strapMatController = TextEditingController(text: prod?.strapMaterial ?? 'Leather');
    _waterResController = TextEditingController(text: prod?.waterResistance ?? '5ATM (50m)');
    _warrantyController = TextEditingController(text: prod?.warranty ?? '2 Years');
    
    // Join lists to comma-separated text
    _strapsController = TextEditingController(text: prod?.straps.join(', ') ?? 'Mặc định');
    _colorsController = TextEditingController(text: prod?.colors.join(', ') ?? 'Mặc định');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _salePriceController.dispose();
    _imageController.dispose();
    _stockController.dispose();
    _descController.dispose();
    _movementController.dispose();
    _strapMatController.dispose();
    _waterResController.dispose();
    _warrantyController.dispose();
    _strapsController.dispose();
    _colorsController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final provider = context.read<ProductProvider>();

    // Parse comma separated values
    final straps = _strapsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final colors = _colorsController.text
        .split(',')
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toList();

    final price = int.parse(_priceController.text.trim());
    final salePriceText = _salePriceController.text.trim();
    final salePrice = salePriceText.isNotEmpty ? int.parse(salePriceText) : null;
    final stock = int.parse(_stockController.text.trim());

    bool success = false;

    if (widget.product == null) {
      // Add Product Mode -> Find new ID
      // Set default ID to 1 if no products exist
      int newId = 1;
      if (provider.products.isNotEmpty) {
        newId = provider.products.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
      }

      final newProduct = Product(
        id: newId,
        name: _nameController.text.trim(),
        brand: _brandController.text.trim(),
        price: price,
        salePrice: salePrice,
        image: _imageController.text.trim(),
        description: _descController.text.trim(),
        strapMaterial: _strapMatController.text.trim(),
        movement: _movementController.text.trim(),
        waterResistance: _waterResController.text.trim(),
        warranty: _warrantyController.text.trim(),
        stock: stock,
        straps: straps,
        colors: colors,
      );

      success = await provider.addProduct(newProduct);
    } else {
      // Edit Product Mode
      final updatedProduct = Product(
        id: widget.product!.id,
        name: _nameController.text.trim(),
        brand: _brandController.text.trim(),
        price: price,
        salePrice: salePrice,
        image: _imageController.text.trim(),
        description: _descController.text.trim(),
        strapMaterial: _strapMatController.text.trim(),
        movement: _movementController.text.trim(),
        waterResistance: _waterResController.text.trim(),
        warranty: _warrantyController.text.trim(),
        stock: stock,
        straps: straps,
        colors: colors,
      );

      success = await provider.updateProduct(updatedProduct);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.product == null ? 'Đã thêm sản phẩm thành công!' : 'Đã cập nhật sản phẩm!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra khi lưu sản phẩm!')),
        );
      }
    }
  }

  Future<void> _deleteProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa sản phẩm này khỏi cửa hàng không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Đóng'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isSaving = true);
      final success = await context.read<ProductProvider>().deleteProduct(widget.product!.id);
      
      if (mounted) {
        setState(() => _isSaving = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa sản phẩm khỏi cửa hàng!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể xóa sản phẩm!')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'CHỈNH SỬA SẢN PHẨM' : 'THÊM SẢN PHẨM MỚI'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Xóa sản phẩm',
              onPressed: _isSaving ? null : _deleteProduct,
            ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Watch Info section
                    _buildSectionHeader('THÔNG TIN CƠ BẢN'),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _nameController,
                              label: 'Tên đồng hồ',
                              validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập tên' : null,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _brandController,
                              label: 'Thương hiệu (Brand)',
                              validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập thương hiệu' : null,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _priceController,
                                    label: 'Giá gốc (VNĐ)',
                                    keyboardType: TextInputType.number,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) return 'Vui lòng nhập giá';
                                      if (int.tryParse(val) == null) return 'Giá trị không hợp lệ';
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _salePriceController,
                                    label: 'Giá khuyến mãi (VNĐ)',
                                    keyboardType: TextInputType.number,
                                    validator: (val) {
                                      if (val != null && val.isNotEmpty) {
                                        if (int.tryParse(val) == null) return 'Giá trị không hợp lệ';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _stockController,
                                    label: 'Số lượng tồn kho',
                                    keyboardType: TextInputType.number,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) return 'Vui lòng nhập số lượng';
                                      if (int.tryParse(val) == null) return 'Không hợp lệ';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _imageController,
                              label: 'Link hình ảnh (URL)',
                              maxLines: 2,
                              validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập link ảnh' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Technical Specifications section
                    _buildSectionHeader('THÔNG SỐ KỸ THUẬT & PHÂN LOẠI'),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _movementController,
                              label: 'Bộ máy (Movement) - VD: Automatic, Quartz',
                              validator: (val) => val == null || val.trim().isEmpty ? 'Yêu cầu điền bộ máy' : null,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _strapMatController,
                              label: 'Chất liệu dây - VD: Thép không gỉ, Da, Cao su',
                              validator: (val) => val == null || val.trim().isEmpty ? 'Yêu cầu điền chất liệu' : null,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _waterResController,
                                    label: 'Chống nước (VD: 5ATM)',
                                    validator: (val) => val == null || val.trim().isEmpty ? 'Yêu cầu điền' : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _warrantyController,
                                    label: 'Bảo hành (VD: 2 Years)',
                                    validator: (val) => val == null || val.trim().isEmpty ? 'Yêu cầu điền' : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _colorsController,
                              label: 'Các màu vỏ (phân cách bằng dấu phẩy)',
                              helperText: 'VD: Titanium, Gold, Black',
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _strapsController,
                              label: 'Các loại dây thay thế (phân cách bằng dấu phẩy)',
                              helperText: 'VD: Sport Band, Leather Loop',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description section
                    _buildSectionHeader('MÔ TẢ SẢN PHẨM'),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildTextField(
                          controller: _descController,
                          label: 'Nội dung mô tả sản phẩm...',
                          maxLines: 5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _saveProduct,
                        child: Text(
                          isEdit ? 'LƯU THAY ĐỔI' : 'THÊM MỚI SẢN PHẨM',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 0.5,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 13.5),
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        alignLabelWithHint: true,
        labelStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        helperStyle: const TextStyle(fontSize: 10.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
