import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'PdfServiceFatura.dart'; 

class FaturalandirmaSayfasi extends StatefulWidget {
  final double totalFee;
  final String serviceNumber;
  final String customerName;
  final String serialNumber;

  const FaturalandirmaSayfasi({
    Key? key,
    required this.totalFee,
    required this.serviceNumber,
    required this.customerName,
    required this.serialNumber,
  }) : super(key: key);

  @override
  _FaturalandirmaSayfasiState createState() => _FaturalandirmaSayfasiState();
}

class _FaturalandirmaSayfasiState extends State<FaturalandirmaSayfasi> {
  final _vatController = TextEditingController();
  final List<Map<String, dynamic>> _parts = [];
  final _laborCostController = TextEditingController();
  bool _includeVat = false;

  @override
  void dispose() {
    _vatController.dispose();
    _laborCostController.dispose();
    super.dispose();
  }

  double _calculateTotal() {
    double partsTotal = _parts.fold(0.0, (sum, part) => sum + (part['price'] ?? 0.0));
    double laborCost = double.tryParse(_laborCostController.text) ?? 0.0;
    return partsTotal + laborCost + widget.totalFee;
  }

  double _calculateVat(double amount, double rate) {
    return amount * (rate / 100);
  }

  Future<void> _generateInvoice() async {
    final vatRateText = _vatController.text;
    final vatRate = double.tryParse(vatRateText);

    if (vatRate == null && _includeVat) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Geçerli bir KDV oranı girin.')),
      );
      return;
    }

    final totalAmount = _calculateTotal();
    double vatAmount = 0.0;
    if (_includeVat && vatRate != null) {
      vatAmount = _calculateVat(totalAmount, vatRate);
    }
    final finalAmount = totalAmount + vatAmount;

    final pdfService = PdfServiceFatura();
    final invoiceData = {
      'totalFee': widget.totalFee,
      'vatRate': vatRate,
      'serviceNumber': widget.serviceNumber,
      'customerName': widget.customerName,
      'serialNumber': widget.serialNumber,
      'parts': _parts,
      'laborCost': double.tryParse(_laborCostController.text) ?? 0.0,
      'includeVat': _includeVat,
      'finalAmount': finalAmount,
    };

    try {
      await pdfService.generateAndPrintInvoice(invoiceData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fatura başarıyla oluşturuldu!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fatura oluşturulurken bir hata oluştu: $e')),
      );
    }
  }

  void _addPart() {
    setState(() {
      _parts.add({'name': '', 'price': 0.0, 'vat': 0.0});
    });
  }

  void _removePart(int index) {
    setState(() {
      _parts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fatura Oluştur', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Servis Ücreti: ${widget.totalFee.toStringAsFixed(2)} TL',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Servis Numarası: ${widget.serviceNumber}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Müşteri Adı: ${widget.customerName}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Seri Numarası: ${widget.serialNumber}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _laborCostController,
              decoration: InputDecoration(
                labelText: 'Servis Bedeli (TL)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _vatController,
              decoration: InputDecoration(
                labelText: 'KDV Oranı (%)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            SizedBox(height: 20),
            Text('Değişen Parçalar:'),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _parts.length,
                itemBuilder: (context, index) {
                  final part = _parts[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(labelText: 'Parça Adı'),
                              onChanged: (value) {
                                setState(() {
                                  part['name'] = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              decoration: InputDecoration(labelText: 'Fiyat (TL)'),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  part['price'] = double.tryParse(value) ?? 0.0;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              decoration: InputDecoration(labelText: 'KDV (%)'),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  part['vat'] = double.tryParse(value) ?? 0.0;
                                });
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => _removePart(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addPart,
                    icon: Icon(Icons.add),
                    label: Text('Parça Ekle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text('KDV Hesapla:'),
                Switch(
                  value: _includeVat,
                  onChanged: (value) {
                    setState(() {
                      _includeVat = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _generateInvoice,
                icon: Icon(Icons.print),
                label: Text('Fatura Oluştur'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
