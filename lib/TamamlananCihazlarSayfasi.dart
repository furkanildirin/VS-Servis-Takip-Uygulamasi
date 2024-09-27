import 'package:flutter/material.dart';
import 'package:service_tracking_app/CihazDetaySayfasi.dart';
import 'package:service_tracking_app/DBHelper.dart';

class TamamlanmisCihazlarSayfasi extends StatefulWidget {
  const TamamlanmisCihazlarSayfasi({super.key});

  @override
  _TamamlanmisCihazlarSayfasiState createState() => _TamamlanmisCihazlarSayfasiState();
}

class _TamamlanmisCihazlarSayfasiState extends State<TamamlanmisCihazlarSayfasi> {
  List<Map<String, dynamic>> devices = [];
  String searchQuery = '';
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCompletedDevices();
  }

  Future<void> _loadCompletedDevices() async {
    setState(() {
      isLoading = true;
    });
    final dbHelper = DBHelper();
    try {
      List<Map<String, dynamic>> deviceList;
      if (searchQuery.isEmpty) {
        deviceList = await dbHelper.fetchCompletedDevices();
      } else {
        deviceList = await dbHelper.searchCompletedDevices(searchQuery);
      }
      setState(() {
        devices = deviceList;
        errorMessage = '';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Tamamlanmış cihazlar yüklenirken bir hata oluştu: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteDevice(int id) async {
    final dbHelper = DBHelper();
    try {
      await dbHelper.deleteDevice(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cihaz silindi')),
      );
      _loadCompletedDevices(); // Listeyi güncelle
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cihaz silinirken bir hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tamamlanmış Cihazlar', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Ara...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.black), // Siyah arama ikonu
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _loadCompletedDevices(); // Arama yapıldığında cihazları yeniden yükle
                });
              },
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : devices.isEmpty
          ? Center(child: Text(errorMessage.isNotEmpty ? errorMessage : 'Cihaz bulunamadı'))
          : ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return ListTile(
            title: Text(
              device['customerName'] ?? 'Bilgi mevcut değil',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            subtitle: Text(
              device['deviceType'] ?? 'Bilgi mevcut değil',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Cihazı Sil'),
                    content: Text('${device['customerName']} adlı cihazı silmek istediğinize emin misiniz?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Dialogu kapat
                        },
                        child: const Text('İptal'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await _deleteDevice(device['id']);
                          Navigator.pop(context); // Dialogu kapat
                        },
                        child: const Text('Sil'),
                      ),
                    ],
                  ),
                );
              },
            ),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CihazDetaySayfasi(device: device),
                ),
              );
              if (result == true) {
                _loadCompletedDevices(); // Veri yenilemesi
              }
            },
          );
        },
      ),
    );
  }
}
