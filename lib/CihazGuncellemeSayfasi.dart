import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_tracking_app/DBHelper.dart';

class UpdateDevicePage extends StatefulWidget {
  final Map<String, dynamic> device;

  const UpdateDevicePage({super.key, required this.device});

  @override
  _UpdateDevicePageState createState() => _UpdateDevicePageState();
}

class _UpdateDevicePageState extends State<UpdateDevicePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _customerNameController;
  late TextEditingController _customerAddressController;
  late TextEditingController _customerPhoneController;
  late TextEditingController _customerEmailController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _serialNumberController;
  late TextEditingController _invoiceDateController;
  late TextEditingController _serviceFeeController;
  late TextEditingController _accessoriesController;
  late TextEditingController _damageDescriptionController;
  late TextEditingController _explanationDescriptionController;

  String? _imagePath;
  bool _isExternalService = false;

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController(text: widget.device['customerName']);
    _customerAddressController = TextEditingController(text: widget.device['address']);
    _customerPhoneController = TextEditingController(text: widget.device['phone']);
    _customerEmailController = TextEditingController(text: widget.device['email']);
    _brandController = TextEditingController(text: widget.device['brand']);
    _modelController = TextEditingController(text: widget.device['model']);
    _serialNumberController = TextEditingController(text: widget.device['serialNumber']);
    _invoiceDateController = TextEditingController(text: widget.device['invoiceDate']);
    _serviceFeeController = TextEditingController(text: widget.device['totalFee']?.toString() ?? '');
    _accessoriesController = TextEditingController(text: widget.device['accompanyingItems']);
    _damageDescriptionController = TextEditingController(text: widget.device['damageDescription']);
    _explanationDescriptionController = TextEditingController(text: widget.device['explanation']);
    _imagePath = widget.device['imagePath'];
    _isExternalService = (widget.device['isExternalService'] as int) == 1;
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _imagePath = null;
    });
  }

  Future<void> _updateDevice() async {
    if (_formKey.currentState?.validate() ?? false) {
      final dbHelper = DBHelper();
      await dbHelper.updateDevice(
        widget.device['id'],
        {
          'customerName': _customerNameController.text,
          'address': _customerAddressController.text,
          'phone': _customerPhoneController.text,
          'email': _customerEmailController.text,
          'brand': _brandController.text,
          'model': _modelController.text,
          'serialNumber': _serialNumberController.text,
          'invoiceDate': _invoiceDateController.text,
          'totalFee': double.tryParse(_serviceFeeController.text) ?? 0.0,
          'accompanyingItems': _accessoriesController.text,
          'damageDescription': _damageDescriptionController.text,
          'explanation': _explanationDescriptionController.text,
          'imagePath': _imagePath,
          'isExternalService': _isExternalService ? 1 : 0,
        },
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cihaz Güncelle', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Müşteri Bilgileri'),
              _buildTextField(_customerNameController, 'Müşteri Adı'),
              _buildTextField(_customerAddressController, 'Adres'),
              _buildTextField(_customerPhoneController, 'Telefon'),
              _buildTextField(_customerEmailController, 'E-posta'),
              const SizedBox(height: 16),

              _buildSectionTitle('Cihaz Bilgileri'),
              _buildTextField(_brandController, 'Marka'),
              _buildTextField(_modelController, 'Model'),
              _buildTextField(_serialNumberController, 'Seri Numarası'),
              _buildTextField(_invoiceDateController, 'Fatura Tarihi'),
              _buildTextField(_serviceFeeController, 'Toplam Ücret (TL)', keyboardType: TextInputType.number),
              _buildTextField(_accessoriesController, 'Cihazla Gelen Ürünler'),
              _buildTextField(_damageDescriptionController, 'Cihazla İlgili Şikayetler'),
              _buildTextField(_explanationDescriptionController, 'Açıklama'),
              const SizedBox(height: 16),

              _buildSwitch('Dış Servis', _isExternalService, (value) {
                setState(() {
                  _isExternalService = value;
                });
              }),

              const SizedBox(height: 16),
              _buildImageSection(),

              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _updateDevice,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green[800],
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: const Text('Güncelle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String labelText, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$labelText girin';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSwitch(String title, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildImageSection() {
    return _imagePath != null && File(_imagePath!).existsSync()
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.file(
            File(_imagePath!),
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text('Resmi Değiştir'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _removeImage,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
              child: const Text('Resmi Sil'),
            ),
          ],
        ),
      ],
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Resim Yüklenmedi!', style: TextStyle(color: Colors.red, fontSize: 16)),
        const SizedBox(height: 8.0),
        ElevatedButton(
          onPressed: _pickImage,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
          child: const Text('Resim Seç'),
        ),
      ],
    );
  }
}
