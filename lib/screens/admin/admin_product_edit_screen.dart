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

class CustomSpecRow {
  final TextEditingController keyController;
  final TextEditingController valController;

  CustomSpecRow({required String key, required String value})
      : keyController = TextEditingController(text: key),
        valController = TextEditingController(text: value);

  void dispose() {
    keyController.dispose();
    valController.dispose();
  }
}

class _AdminProductEditScreenState extends State<AdminProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _priceController;
  late TextEditingController _salePriceController;
  late TextEditingController _stockController;
  late TextEditingController _descController;
  late TextEditingController _movementController;
  late TextEditingController _strapMatController;
  late TextEditingController _waterResController;
  late TextEditingController _warrantyController;
  late TextEditingController _colorController;
  late TextEditingController _strapController;
  final List<TextEditingController> _imageControllers = [];
  final List<CustomSpecRow> _customSpecs = [];

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
    _stockController = TextEditingController(text: prod?.stock != null ? prod!.stock.toString() : '10');
    _descController = TextEditingController(text: prod?.description ?? '');
    _movementController = TextEditingController(text: prod?.movement ?? 'Automatic');
    _strapMatController = TextEditingController(text: prod?.strapMaterial ?? 'Leather');
    _waterResController = TextEditingController(text: prod?.waterResistance ?? '5ATM (50m)');
    _warrantyController = TextEditingController(text: prod?.warranty ?? '2 Years');
    _colorController = TextEditingController(
      text: (prod != null && prod.colors.isNotEmpty) ? prod.colors.first : '',
    );
    _strapController = TextEditingController(
      text: (prod != null && prod.straps.isNotEmpty) ? prod.straps.first : '',
    );
    
    if (prod != null && prod.images != null && prod.images!.isNotEmpty) {
      for (final img in prod.images!) {
        _imageControllers.add(TextEditingController(text: img));
      }
    } else if (prod?.image != null && prod!.image.isNotEmpty) {
      _imageControllers.add(TextEditingController(text: prod.image));
    }
    
    if (_imageControllers.isEmpty) {
      _imageControllers.add(TextEditingController());
    }

    if (prod != null && prod.customSpecs != null && prod.customSpecs!.isNotEmpty) {
      prod.customSpecs!.forEach((key, val) {
        _customSpecs.add(CustomSpecRow(key: key, value: val));
      });
    } else {
      _customSpecs.add(CustomSpecRow(key: 'Giới tính', value: ''));
      _customSpecs.add(CustomSpecRow(key: 'Kính đồng hồ', value: ''));
      _customSpecs.add(CustomSpecRow(key: 'Đường kính mặt', value: ''));
      _customSpecs.add(CustomSpecRow(key: 'Tính năng nổi bật', value: ''));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _salePriceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    _movementController.dispose();
    _strapMatController.dispose();
    _waterResController.dispose();
    _warrantyController.dispose();
    _colorController.dispose();
    _strapController.dispose();
    for (final ctrl in _imageControllers) {
      ctrl.dispose();
    }
    for (final row in _customSpecs) {
      row.dispose();
    }
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final provider = context.read<ProductProvider>();

    final price = int.parse(_priceController.text.trim());
    final salePriceText = _salePriceController.text.trim();
    final salePrice = salePriceText.isNotEmpty ? int.parse(salePriceText) : null;
    final stock = int.parse(_stockController.text.trim());

    final List<String> colors = [_colorController.text.trim()];
    final List<String> straps = [_strapController.text.trim()];
    final List<String> images = [];

    for (final ctrl in _imageControllers) {
      final url = ctrl.text.trim();
      if (url.isNotEmpty) {
        images.add(url);
      }
    }

    final mainImage = images.isNotEmpty ? images.first : '';

    final Map<String, String> customSpecs = {};
    for (final row in _customSpecs) {
      final key = row.keyController.text.trim();
      final val = row.valController.text.trim();
      if (key.isNotEmpty && val.isNotEmpty) {
        customSpecs[key] = val;
      }
    }

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
        image: mainImage,
        description: _descController.text.trim(),
        strapMaterial: _strapMatController.text.trim(),
        movement: _movementController.text.trim(),
        waterResistance: _waterResController.text.trim(),
        warranty: _warrantyController.text.trim(),
        stock: stock,
        straps: straps,
        colors: colors,
        images: images,
        customSpecs: customSpecs,
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
        image: mainImage,
        description: _descController.text.trim(),
        strapMaterial: _strapMatController.text.trim(),
        movement: _movementController.text.trim(),
        waterResistance: _waterResController.text.trim(),
        warranty: _warrantyController.text.trim(),
        stock: stock,
        straps: straps,
        colors: colors,
        images: images,
        customSpecs: customSpecs,
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
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _colorController,
                                    label: 'Màu sắc (Ví dụ: Đen)',
                                    validator: (val) => val == null || val.trim().isEmpty ? 'Yêu cầu điền màu' : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _strapController,
                                    label: 'Loại dây đeo (Ví dụ: Dây nhựa)',
                                    validator: (val) => val == null || val.trim().isEmpty ? 'Yêu cầu điền loại dây' : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Detailed Options and Images Section
                    _buildSectionHeader('DANH SÁCH HÌNH ẢNH SẢN PHẨM'),
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        'Bạn có thể nhập nhiều link hình ảnh cho sản phẩm này. Ô đầu tiên sẽ là Ảnh chính đại diện của sản phẩm.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                      ),
                    ),
                    Column(
                      children: List.generate(_imageControllers.length, (index) {
                        final controller = _imageControllers[index];
                        final isMain = index == 0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: controller,
                                  label: isMain ? 'Link hình ảnh chính (Bắt buộc)' : 'Link hình ảnh phụ #${index}',
                                  maxLines: 2,
                                  validator: isMain
                                      ? (val) => val == null || val.trim().isEmpty ? 'Yêu cầu nhập link ảnh chính' : null
                                      : null,
                                ),
                              ),
                              if (!isMain) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _imageControllers[index].dispose();
                                      _imageControllers.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          setState(() {
                            _imageControllers.add(TextEditingController());
                          });
                        },
                        icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                        label: const Text('THÊM HÌNH ẢNH MỚI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Technical Specifications section
                    _buildSectionHeader('THÔNG SỐ KỸ THUẬT SẢN PHẨM'),
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
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Custom Specs Section
                    _buildSectionHeader('THÔNG SỐ TÙY CHỈNH BỔ SUNG (GIỚI TÍNH, MẶT KÍNH, TÍNH NĂNG...)'),
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'Bạn có thể tự do thêm bớt các thông số tùy chỉnh khác cho sản phẩm này (Ví dụ: Giới tính, Chất liệu mặt kính, Chức năng đặc biệt).',
                        style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
                      ),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            ...List.generate(_customSpecs.length, (index) {
                              final row = _customSpecs[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: _buildTextField(
                                        controller: row.keyController,
                                        label: 'Tên thông số (VD: Giới tính)',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      flex: 5,
                                      child: _buildTextField(
                                        controller: row.valController,
                                        label: 'Giá trị (VD: Unisex)',
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          _customSpecs[index].dispose();
                                          _customSpecs.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _customSpecs.add(CustomSpecRow(key: '', value: ''));
                                  });
                                },
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('THÊM THÔNG SỐ KHÁC', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                              ),
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
