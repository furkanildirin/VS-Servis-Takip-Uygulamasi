import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:service_tracking_app/CihazGuncellemeSayfasi.dart';
import 'CihazDetaySayfasi.dart';
import 'DBHelper.dart';

class KayitliCihazlarSayfasi extends StatefulWidget {
  const KayitliCihazlarSayfasi({super.key});

  @override
  _KayitliCihazlarSayfasiState createState() => _KayitliCihazlarSayfasiState();
}

class _KayitliCihazlarSayfasiState extends State<KayitliCihazlarSayfasi> {
  List<Map<String, dynamic>> devices = [];
  String searchQuery = '';
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      isLoading = true;
    });
    final dbHelper = DBHelper();
    try {
      List<Map<String, dynamic>> deviceList;
      if (searchQuery.isEmpty) {
        deviceList = await dbHelper.getDevices();
      } else {
        deviceList = await dbHelper.searchDevices(searchQuery);
      }
      setState(() {
        devices = deviceList;
        errorMessage = '';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Cihazlar yüklenirken bir hata oluştu.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool isDeviceOver15Days(String serviceArrivalDate) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    try {
      final DateTime serviceDate = dateFormat.parse(serviceArrivalDate);
      final DateTime currentDate = DateTime.now();
      final Duration difference = currentDate.difference(serviceDate);

      return difference.inDays >= 15;
    } catch (e) {
      print('Tarih formatı hatası: $e');
      return false;
    }
  }

  Future<void> _exportToExcel() async {
    final dbHelper = DBHelper();
    await dbHelper.exportRegisteredDevicesToExcel();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Excel dosyası başarıyla oluşturuldu!')),
    );
  }

  Future<void> _confirmDeleteDevice(int deviceId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Silme Onayı'),
        content: Text('Bu cihazı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Hayır'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Evet'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      final dbHelper = DBHelper();
      await dbHelper.deleteDevice(deviceId);
      _loadDevices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıtlı Cihazlar',style: TextStyle(fontWeight: FontWeight.bold,),),
        backgroundColor: Colors.teal,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Ara...',
                      prefixIcon: Icon(Icons.search, color: Colors.black), // Arama ikonunu ekledik
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                        _loadDevices();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : devices.isEmpty
          ? Center(child: Text(errorMessage.isNotEmpty ? errorMessage : 'Cihaz bulunamadı'))
          : Stack(
        children: [
          ListView.separated(
            padding: EdgeInsets.all(8.0),
            separatorBuilder: (context, index) => Divider(
              color: Colors.grey[300],
              thickness: 1.0,
            ),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              bool over15Days = isDeviceOver15Days(device['serviceArrivalDate'] ?? '');

              return Card(
                elevation: 1.0,
                margin: EdgeInsets.symmetric(vertical: 2.0),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                  title: Text(
                    device['customerName'] ?? 'Bilgi mevcut değil',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0, // Larger text size
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device['deviceType'] ?? 'Bilgi mevcut değil',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14.0, // Larger text size
                        ),
                      ),
                      if (over15Days)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Cihaz 15 Gündür Tamamlanmadı!',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14.0), // Larger text size
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (device['isExternalService'] == 1)
                        const Icon(Icons.output_sharp, color: Colors.red, size: 20.0),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue, size: 20.0),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateDevicePage(device: device),
                            ),
                          );
                          if (result == true) {
                            _loadDevices();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20.0),
                        onPressed: () => _confirmDeleteDevice(device['id']),
                      ),
                    ],
                  ),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CihazDetaySayfasi(device: device),
                      ),
                    );
                    if (result == true) {
                      _loadDevices();
                    }
                  },
                ),
              );
            },
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: ElevatedButton.icon(
              onPressed: _exportToExcel,
              icon: const Icon(Icons.file_download, color: Colors.white),
              label: const Text('Excel\'e Aktar'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
