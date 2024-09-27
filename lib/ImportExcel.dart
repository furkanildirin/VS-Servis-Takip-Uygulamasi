import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:service_tracking_app/DBHelper.dart';

class ImportExcelPage extends StatefulWidget {
  @override
  _ImportExcelPageState createState() => _ImportExcelPageState();
}

class _ImportExcelPageState extends State<ImportExcelPage> {
  String statusMessage = '';

  Future<void> _importFromExcel() async {
    try {
      // Dosya seçiciyle excel dosyasını seçme
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        var bytes = file.readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);

        final dbHelper = DBHelper();

        // Excel dosyasındaki her satırı oku ve veritabanına ekle
        for (var table in excel.tables.keys) {
          for (var row in excel.tables[table]!.rows.skip(1)) {
            String id = row[0] != null ? row[0]!.value.toString() : '';
            String dealershipName = row[1] != null ? row[1]!.value.toString() : '';
            String customerName = row[2] != null ? row[2]!.value.toString() : '';
            String address = row[3] != null ? row[3]!.value.toString() : '';
            String phone = row[4] != null ? row[4]!.value.toString() : '';
            String email = row[5] != null ? row[5]!.value.toString() : '';
            String deviceType = row[6] != null ? row[6]!.value.toString() : '';
            String brand = row[7] != null ? row[7]!.value.toString() : '';
            String model = row[8] != null ? row[8]!.value.toString() : '';
            String serialNumber = row[9] != null ? row[9]!.value.toString() : '';
            String invoiceDate = row[10] != null ? row[10]!.value.toString() : '';
            String warrantyInfo = row[11] != null ? row[11]!.value.toString() : '';
            String overallCondition = row[12] != null ? row[12]!.value.toString() : '';
            String serviceArrivalDate = row[13] != null ? row[13]!.value.toString() : '';
            String totalFee = row[14] != null ? row[14]!.value.toString() : '';
            String explanation = row[15] != null ? row[15]!.value.toString() : '';
            String accompanyingItems = row[16] != null ? row[16]!.value.toString() : '';
            String damageDescription = row[17] != null ? row[17]!.value.toString() : '';
            String imagePath = row[18] != null ? row[18]!.value.toString() : '';
            String isExternalService = row[19] != null ? row[19]!.value.toString() : 'No';
            String isCompleted = row[20] != null ? row[20]!.value.toString() : 'No';

            // Veritabanına ekle
            await dbHelper.insertDevice({
              'id': id,
              'dealershipName': dealershipName,
              'customerName': customerName,
              'address': address,
              'phone': phone,
              'email': email,
              'deviceType': deviceType,
              'brand': brand,
              'model': model,
              'serialNumber': serialNumber,
              'invoiceDate': invoiceDate,
              'warrantyInfo': warrantyInfo,
              'overallCondition': overallCondition,
              'serviceArrivalDate': serviceArrivalDate,
              'totalFee': totalFee,
              'explanation': explanation,
              'accompanyingItems': accompanyingItems,
              'damageDescription': damageDescription,
              'imagePath': imagePath,
              'isExternalService': isExternalService == 'Yes' ? 1 : 0,
              'isCompleted': isCompleted == 'Yes' ? 1 : 0,
            });
          }
        }

        setState(() {
          statusMessage = 'Excel dosyasından veri başarıyla yüklendi!';
        });
      } else {
        setState(() {
          statusMessage = 'Excel dosyası seçilmedi.';
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = 'Bir hata oluştu: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Excel\'den Veri Yükle',style: TextStyle(fontWeight: FontWeight.bold,)),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Excel Dosyasından Veri Yükle',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Excel dosyanız aşağıdaki formatta olmalıdır. İlk satır başlıklar olmalı ve her satır cihaz bilgilerini içermelidir:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Table(
                border: TableBorder.all(color: Colors.black),
                columnWidths: const <int, TableColumnWidth>{
                  0: FixedColumnWidth(100),
                  1: FlexColumnWidth(),
                  2: FlexColumnWidth(),
                },
                children: [
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Müşteri Adı', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Cihaz Türü', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('123'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('John Doe'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Laptop'),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _importFromExcel,
                icon: Icon(Icons.file_upload),
                label: Text('Excel\'den Yükle'),
              ),
              SizedBox(height: 20),
              Text(
                statusMessage,
                style: TextStyle(color: Colors.green, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
