import 'dart:io';
import 'package:flutter/material.dart';
import 'CihazGuncellemeSayfasi.dart';
import 'FullEkranResim.dart'; 
import 'PdfService.dart'; 
import 'DBHelper.dart'; 
import 'Faturalandirma.dart'; 

class CihazDetaySayfasi extends StatelessWidget {
  final Map<String, dynamic> device;

  const CihazDetaySayfasi({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    File? _imageFile;
    if (device['imagePath'] != null && device['imagePath']!.isNotEmpty) {
      _imageFile = File(device['imagePath']);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cihaz Detayları', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            
            Expanded(
              child: ListView(
                children: [
                  // Müşteri Bilgileri Bölümü
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.teal),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Müşteri Bilgileri', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _buildDetailCard('Bayi Adı', device['dealershipName']),
                        _buildDetailCard('Müşteri Adı', device['customerName']),
                        _buildDetailCard('Adres', device['address']),
                        _buildDetailCard('Telefon', device['phone']),
                        _buildDetailCard('E-posta', device['email']),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Cihaz Bilgileri Bölümü
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.teal),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cihaz Bilgileri', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _buildDetailCard('Cihaz Türü', device['deviceType']),
                        _buildDetailCard('Marka', device['brand']),
                        _buildDetailCard('Model', device['model']),
                        _buildDetailCard('Seri Numarası', device['serialNumber']),
                        _buildDetailCard('Garanti Bilgisi', device['warrantyInfo']),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Detaylar Bölümü
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.teal),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Detaylar', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                            if (device['isCompleted'] == 1)
                              Text('Tamamlandı', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildDetailCard('Servis Numarası', device['id'].toString()),
                        _buildDetailCard('Fatura Tarihi', device['invoiceDate']),
                        _buildDetailCard('Genel Durum', device['overallCondition']),
                        _buildDetailCard('Servise Geliş Tarihi', device['serviceArrivalDate']),
                        _buildDetailCard('Servis Ücreti', '${device['totalFee']?.toStringAsFixed(2) ?? 'Bilgi mevcut değil'} TL'),
                        _buildDetailCard('Açıklama', device['explanation']),
                        _buildDetailCard('Cihazla Gelen Ürünler', device['accompanyingItems']),
                        _buildDetailCard('Cihazla İlgili Şikayetler', device['damageDescription']),
                        _buildDetailCard('Dış Servis', device['isExternalService'] == 1 ? 'Evet' : 'Hayır'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Butonlar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Sol alt butonlar
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final pdfService = PdfService();
                            await pdfService.generateAndPrintDeviceReport(device);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                          label: const Text('Servis Raporu', style: TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FaturalandirmaSayfasi(
                                  serviceNumber: device['id']?.toString() ?? '0',
                                  customerName: device['customerName'] ?? 'Belirtilmemiş',
                                  serialNumber: device['serialNumber'] ?? 'Belirtilmemiş',
                                  totalFee: device['totalFee']?.toDouble() ?? 0.0,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          icon: const Icon(Icons.receipt, color: Colors.white),
                          label: const Text('Faturalandır', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),

                  // Sağ alt butonlar
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_imageFile != null) ...[
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenImagePage(imageFile: _imageFile!),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            icon: const Icon(Icons.visibility, color: Colors.white),
                            label: const Text('Resmi Göster', style: TextStyle(fontSize: 12)),
                          ),
                        ] else ...[
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdateDevicePage(device: device),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            icon: const Icon(Icons.add_a_photo, color: Colors.white),
                            label: const Text('Resim Ekle', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: device['isCompleted'] == 1
                              ? null
                              : () async {
                            final dbHelper = DBHelper();
                            await dbHelper.updateDevice(device['id'], {'isCompleted': 1});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cihaz tamamlandı olarak işaretlendi')),
                            );

                            // Sayfayı yeniden yükle ve cihaz tamamlandı durumunu göster
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CihazDetaySayfasi(device: {...device, 'isCompleted': 1}),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: device['isCompleted'] == 1 ? Colors.grey : Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: Text(
                            device['isCompleted'] == 1 ? 'Tamamlandı' : 'Tamamlandı Olarak İşaretle',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value ?? 'Bilgi mevcut değil', softWrap: true),
          ),
        ],
      ),
    );
  }
}
