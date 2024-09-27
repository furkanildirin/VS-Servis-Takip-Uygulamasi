import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'DBHelper.dart';

class YeniCihazEkle extends StatefulWidget {
  const YeniCihazEkle({super.key});

  @override
  _YeniCihazEkleSayfasiState createState() => _YeniCihazEkleSayfasiState();
}

class _YeniCihazEkleSayfasiState extends State<YeniCihazEkle> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerAddressController =
      TextEditingController();
  final TextEditingController _customerPhoneController =
      TextEditingController();
  final TextEditingController _customerEmailController =
      TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _productTypeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _serialNumberController = TextEditingController();
  final TextEditingController _invoiceDateController = TextEditingController();
  final TextEditingController _serviceFeeController = TextEditingController();
  final TextEditingController _accessoriesController = TextEditingController();
  final TextEditingController _damageDescriptionController =
      TextEditingController();
  final TextEditingController _explanationDescriptionController =
      TextEditingController();
  final TextEditingController _dealershipController = TextEditingController();

  DateTime _serviceArrivalDate = DateTime.now();
  String _selectedWarranty = 'Garantili';
  String _selectedCondition = 'Yeni';

  bool _isExternalService = false;
  PlatformFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    _invoiceDateController.text =
        DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _serviceArrivalDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _serviceArrivalDate) {
      setState(() {
        _serviceArrivalDate = pickedDate;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  void _addDevice() async {
    final formState = _formKey.currentState;
    if (formState != null && formState.validate()) {
      final device = {
        'dealershipName': _dealershipController.text,
        'customerName': _customerNameController.text,
        'address': _customerAddressController.text,
        'phone': _customerPhoneController.text,
        'email': _customerEmailController.text,
        'deviceType': _productTypeController.text,
        'brand': _brandController.text,
        'model': _modelController.text,
        'serialNumber': _serialNumberController.text,
        'invoiceDate': _invoiceDateController.text,
        'warrantyInfo': _selectedWarranty,
        'overallCondition': _selectedCondition,
        'serviceArrivalDate':
            DateFormat('dd/MM/yyyy HH:mm').format(_serviceArrivalDate),
        'totalFee': double.tryParse(_serviceFeeController.text) ?? 0.0,
        'explanation': _explanationDescriptionController.text,
        'accompanyingItems': _accessoriesController.text,
        'damageDescription': _damageDescriptionController.text,
        'imagePath': _selectedFile?.path ?? '',
        'isExternalService': _isExternalService ? 1 : 0,
      };

      await DBHelper().insertDevice(device);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Cihaz Ekle',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 1250, minHeight: 940),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double availableWidth = constraints.maxWidth;
                        final bool isWideScreen = availableWidth > 600;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildSection(
                                'Müşteri Bilgileri', textTheme, colorScheme),
                            _buildResponsiveRow(
                              isWideScreen,
                              [
                                _buildTextFieldWithController(
                                    _customerNameController,
                                    'Müşteri Adı',
                                    textTheme,
                                    colorScheme),
                                _buildTextFieldWithController(
                                    _customerAddressController,
                                    'Adres',
                                    textTheme,
                                    colorScheme),
                              ],
                            ),
                            _buildResponsiveRow(
                              isWideScreen,
                              [
                                _buildTextFieldWithController(
                                    _customerPhoneController,
                                    'Telefon',
                                    textTheme,
                                    colorScheme,
                                    keyboardType: TextInputType.phone),
                                _buildTextFieldWithController(
                                    _customerEmailController,
                                    'E-posta',
                                    textTheme,
                                    colorScheme,
                                    keyboardType: TextInputType.emailAddress),
                              ],
                            ),
                            _buildSection(
                                'Cihaz Bilgileri', textTheme, colorScheme),
                            _buildResponsiveRow(
                              isWideScreen,
                              [
                                _buildTextFieldWithController(
                                    _dealershipController,
                                    'Bayi Adı',
                                    textTheme,
                                    colorScheme),
                                _buildTextFieldWithController(
                                    _productTypeController,
                                    'Cihaz Türü',
                                    textTheme,
                                    colorScheme),
                              ],
                            ),
                            _buildResponsiveRow(
                              isWideScreen,
                              [
                                _buildTextFieldWithController(_brandController,
                                    'Marka', textTheme, colorScheme),
                                _buildTextFieldWithController(_modelController,
                                    'Model', textTheme, colorScheme),
                              ],
                            ),
                            _buildResponsiveRow(
                              isWideScreen,
                              [
                                _buildTextFieldWithController(
                                    _serialNumberController,
                                    'Seri Numarası',
                                    textTheme,
                                    colorScheme),
                                _buildTextFieldWithController(
                                    _invoiceDateController,
                                    'Fatura Tarihi',
                                    textTheme,
                                    colorScheme,
                                    onTap: _pickDate),
                              ],
                            ),
                            _buildResponsiveRow(
                              isWideScreen,
                              [
                                _buildDropdown(
                                    _selectedWarranty,
                                    'Garanti Bilgisi',
                                    ['Garantili', 'Garantisiz'], (newValue) {
                                  setState(() {
                                    _selectedWarranty = newValue!;
                                  });
                                }, textTheme, colorScheme),
                                _buildDropdown(
                                    _selectedCondition,
                                    'Genel Durum',
                                    ['Yeni', 'İkinci El'], (newValue) {
                                  setState(() {
                                    _selectedCondition = newValue!;
                                  });
                                }, textTheme, colorScheme),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextFieldWithController(
                                      _damageDescriptionController,
                                      'Cihazla İlgili Şikayetler',
                                      textTheme,
                                      colorScheme,
                                      maxLines: 3),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextFieldWithController(
                                      _explanationDescriptionController,
                                      'Açıklama',
                                      textTheme,
                                      colorScheme,
                                      maxLines: 3),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextFieldWithController(
                                      _accessoriesController,
                                      'Cihazla Gelen Ürünler',
                                      textTheme,
                                      colorScheme,
                                      maxLines: 3),
                                ),
                              ],
                            ),
                            _buildResponsiveRow(
                              isWideScreen,
                              [
                                _buildTextFieldWithController(
                                    _serviceFeeController,
                                    'Servis Ücreti (TL)',
                                    textTheme,
                                    colorScheme,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Bu alan gereklidir';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Geçerli bir sayı girin';
                                  }
                                  return null;
                                }),
                                _buildExternalServiceSwitch(
                                    textTheme, colorScheme),
                              ],
                            ),
                            const Spacer(),
                            _buildFileUploadSection(textTheme, colorScheme),
                          ],
                        );
                      },
                    ),
                  ),
                  _buildButtonSection(textTheme, colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
      String title, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: textTheme.titleLarge?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildResponsiveRow(bool isWideScreen, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: isWideScreen
            ? children.map((child) => Expanded(child: child)).toList()
            : children
                .map((child) => Expanded(
                    child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: child)))
                .toList(),
      ),
    );
  }

  Widget _buildTextFieldWithController(
    TextEditingController controller,
    String labelText,
    TextTheme textTheme,
    ColorScheme colorScheme, {
    TextInputType keyboardType = TextInputType.text,
    void Function()? onTap,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
          labelStyle:
              textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
        ),
        keyboardType: keyboardType,
        onTap: onTap,
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown(
      String selectedValue,
      String labelText,
      List<String> items,
      ValueChanged<String?> onChanged,
      TextTheme textTheme,
      ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
          labelStyle:
              textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
        ),
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExternalServiceSwitch(
      TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Text('Dış Servis',
              style:
                  textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface)),
          Switch(
            value: _isExternalService,
            onChanged: (value) {
              setState(() {
                _isExternalService = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploadSection(TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label:
                  Text(_selectedFile == null ? 'Dosya Ekle' : 'Dosya Seçildi'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(120, 40),
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonSection(TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.bottomRight,
        child: ElevatedButton.icon(
          onPressed: _addDevice,
          icon: const Icon(Icons.save),
          label: const Text('Cihazı Kaydet'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.purple,
            minimumSize: const Size(150, 40),
          ),
        ),
      ),
    );
  }
}
