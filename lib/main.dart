import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Anasayfa.dart';
import 'Ayarlar.dart'; // Settings sağlayıcısını ekleyin
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // sqflite_common_ffi import edin
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'; // Web için sqflite_common_ffi_web import edin
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:window_manager/window_manager.dart'; // window_manager import edin

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Veritabanı ve pencere yönetimi için asenkron başlatma
  await _initializeDependencies();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Settings()), // Settings sağlayıcısını buraya ekleyin
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _initializeDependencies() async {
  await _initializeDatabase();

  if (!kIsWeb) {
    await _initializeWindow();
  }
}

Future<void> _initializeDatabase() async {
  try {
    sqfliteFfiInit();
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      debugPrint('Web platformu için veritabanı başlatıldı.');
    } else {
      databaseFactory = databaseFactoryFfi;
      debugPrint('Desktop platformu için veritabanı başlatıldı.');
    }
  } catch (e) {
    debugPrint('Veritabanı başlatma hatası: $e');
  }
}

Future<void> _initializeWindow() async {
  try {
    await windowManager.ensureInitialized();
    await windowManager.waitUntilReadyToShow();
    await windowManager.setSize(const Size(1260, 950));
    await windowManager.setResizable(false); // Pencerenin yeniden boyutlandırılmasını devre dışı bırakın
    await windowManager.center();
    await windowManager.show();
    debugPrint('Pencere başarıyla başlatıldı.');
  } catch (e) {
    debugPrint('Pencere yönetimi hatası: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<Settings>(context);
    return MaterialApp(
      title: 'Gelişmiş Servis Takip Uygulaması',
      theme: settings.getThemeData(),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
