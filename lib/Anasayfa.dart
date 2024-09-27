import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'HakkindaSayfasi.dart';
import 'YeniCihazEkleSayfasi.dart';
import 'KayitliCihazlarSayfasi.dart';
import 'UygulamaAyarlari.dart';
import 'DBHelper.dart';
import 'DestekSayfasi.dart';
import 'TamamlananCihazlarSayfasi.dart';
import 'ImportExcel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<int>? deviceCountFuture;

  @override
  void initState() {
    super.initState();
    deviceCountFuture = _loadDeviceCount();
  }

  Future<int> _loadDeviceCount() async {
    final dbHelper = DBHelper();
    return await dbHelper.getDeviceCount();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final vescomTextColor = brightness == Brightness.dark ? Colors.white : Colors.blueGrey[800];
    final containerColor = brightness == Brightness.dark ? Colors.black : Colors.teal.shade50;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Sayfa', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
      ),
      drawer: _buildDrawer(vescomTextColor),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
                children: [
                  _buildActionButton(
                    context,
                    icon: Icons.add,
                    title: 'Yeni Cihaz Ekle',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const YeniCihazEkle()),
                    ),
                  ),
                  _buildActionButton(
                    context,
                    icon: Icons.devices,
                    title: 'Kayıtlı Cihazlar',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const KayitliCihazlarSayfasi()),
                    ),
                  ),
                  _buildActionButton(
                    context,
                    icon: Icons.check_circle,
                    title: 'Tamamlanan Cihazlar',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TamamlanmisCihazlarSayfasi()),
                    ),
                  ),
                  _buildActionButton(
                    context,
                    icon: Icons.settings,
                    title: 'Ayarlar',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AppSettingsPage()),
                    ),
                  ),
                  _buildActionButton(
                    context,
                    icon: Icons.support,
                    title: 'Destek',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DestekSayfasi()),
                    ),
                  ),
                  _buildActionButton(
                    context,
                    icon: Icons.info,
                    title: 'Hakkında',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HakkindaSayfasi()),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: containerColor,
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'VES',
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: vescomTextColor,
                        ),
                      ),
                      TextSpan(
                        text: 'COM',
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: vescomTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: onTap,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.teal),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(fontSize: 16, color: Colors.teal)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(Color? vescomTextColor) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.teal,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: vescomTextColor,
                fontSize: 24,
              ),
            ),
          ),
          FutureBuilder<int>(
            future: deviceCountFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ListTile(
                  leading: Icon(Icons.devices),
                  title: Text('Kayıtlı Cihazlar'),
                  subtitle: Text('Yükleniyor...'),
                );
              } else if (snapshot.hasError) {
                return ListTile(
                  leading: const Icon(Icons.error),
                  title: const Text('Kayıtlı Cihazlar'),
                  subtitle: Text('Hata: ${snapshot.error}'),
                );
              } else {
                return ListTile(
                  leading: const Icon(Icons.devices),
                  title: Text('Kayıtlı Cihazlar', style: TextStyle(color: vescomTextColor)),
                  subtitle: Text('Cihaz Sayısı: ${snapshot.data}', style: TextStyle(color: vescomTextColor)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const KayitliCihazlarSayfasi()),
                    );
                  },
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle),
            title: const Text('Tamamlanan Cihazlar'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TamamlanmisCihazlarSayfasi()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Yeni Cihaz Ekle'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const YeniCihazEkle()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: const Text('Excel\'den Veri Yükle'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ImportExcelPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Ayarlar'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AppSettingsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.support),
            title: const Text('Destek'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DestekSayfasi()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Hakkında'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HakkindaSayfasi()),
              );
            },
          ),
        ],
      ),
    );
  }
}
