import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Ayarlar.dart';
import '../DBHelper.dart'; // DBHelper sınıfını import et

class AppSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<Settings>(context);
    final dbHelper = DBHelper(); // DBHelper örneğini oluştur

    return Scaffold(
      appBar: AppBar(
        title: const Text('Uygulama Ayarları',style: TextStyle(fontWeight: FontWeight.bold,)),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tema Seçimi', style: Theme.of(context).textTheme.titleLarge),
            SwitchListTile(
              title: const Text('Gece Modu'),
              value: settings.isDarkMode,
              onChanged: (value) {
                settings.toggleDarkMode();
              },
            ),
            const SizedBox(height: 20),
            Text('Yazı Tipi', style: Theme.of(context).textTheme.titleLarge),
            DropdownButton<String>(
              value: settings.fontFamily,
              items: <String>['Roboto', 'Arial', 'Courier'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                settings.setFontFamily(newValue!);
              },
            ),
            const SizedBox(height: 20),
            Text('Yazı Boyutu', style: Theme.of(context).textTheme.titleLarge),
            Slider(
              value: settings.fontSize,
              min: 10.0,
              max: 30.0,
              divisions: 10,
              label: settings.fontSize.toString(),
              onChanged: (newValue) {
                settings.setFontSize(newValue);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Onay mesajı gösterme
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Veritabanını Sıfırla'),
                      content: const Text('Bu işlem veritabanındaki tüm verileri silecektir. Devam etmek istediğinizden emin misiniz?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Hayır'),
                          onPressed: () {
                            Navigator.of(context).pop(); // Dialog'u kapat
                          },
                        ),
                        TextButton(
                          child: const Text('Evet'),
                          onPressed: () async {
                            Navigator.of(context).pop(); // Dialog'u kapat
                            try {
                              await dbHelper.resetDatabase();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Veritabanı sıfırlandı.')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Veritabanı sıfırlanırken bir hata oluştu: $e')),
                              );
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Veritabanını Sıfırla'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white38, // Butonun rengini kırmızı yap
              ),
            ),
          ],
        ),
      ),
    );
  }
}
