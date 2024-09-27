import 'dart:math';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }


  Future<void> backupDatabase() async {
    try {
      final dbPath = join(await getDatabasesPath(), 'devices.db');
      final backupPath = join(await getDatabasesPath(), 'devices_backup.db');
      await File(dbPath).copy(backupPath);
      print('Backup successful to $backupPath');
    } catch (e) {
      print('Error backing up database: $e');
    }
  }

  Future<void> resetDatabase() async {
    try {
      await backupDatabase();
      final path = join(await getDatabasesPath(), 'devices.db');
      print('Database path: $path');
      await deleteDatabase(path);
      _database = await _initDatabase();
      print('Database reset successful');
    } catch (e) {
      print('Error resetting database: $e');
    }
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'devices.db');
    return openDatabase(
      path,
      version: 7,
      onCreate: (Database db, int version) async {
        await db.execute('''        
        CREATE TABLE devices (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          dealershipName TEXT,
          customerName TEXT,
          address TEXT,
          phone TEXT,
          email TEXT,
          deviceType TEXT,
          brand TEXT,
          model TEXT,
          serialNumber TEXT,
          invoiceDate TEXT,
          warrantyInfo TEXT,
          overallCondition TEXT,
          serviceArrivalDate TEXT,
          totalFee REAL,
          explanation TEXT,
          accompanyingItems TEXT,
          damageDescription TEXT,
          imagePath TEXT,
          isExternalService INTEGER DEFAULT 0,
          isCompleted INTEGER DEFAULT 0,
          servis_numarasi TEXT UNIQUE,
          technician TEXT,
          technicianContact TEXT 
        )
        ''' );
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE devices ADD COLUMN overallCondition TEXT');
          await db.execute('ALTER TABLE devices ADD COLUMN serviceArrivalDate TEXT');
          await db.execute('ALTER TABLE devices ADD COLUMN damageDescription TEXT');
          await db.execute('ALTER TABLE devices ADD COLUMN imagePath TEXT');
          await db.execute('ALTER TABLE devices ADD COLUMN explanation TEXT');
        }
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE devices ADD COLUMN isCompleted INTEGER DEFAULT 0');
        }
        if (oldVersion < 5) {
          await db.execute('ALTER TABLE devices ADD COLUMN servis_numarasi TEXT UNIQUE');
        }
        if (oldVersion < 6) {
          await db.execute('ALTER TABLE devices ADD COLUMN technician TEXT');
        }
        if (oldVersion < 7) {
          await db.execute('ALTER TABLE devices ADD COLUMN technicianContact TEXT');
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> getDevices({bool onlyCompleted = false}) async {
    try {
      final db = await database;
      return await db.query(
        'devices',
        where: onlyCompleted ? 'isCompleted = ?' : null,
        whereArgs: onlyCompleted ? [1] : null,
      );
    } catch (e) {
      print('Error retrieving devices: $e');
      return [];
    }
  }

  Future<String> generateUniqueServiceNumber() async {
    final db = await database;
    String serviceNumber;
    bool isUnique;

    do {
      serviceNumber = 'SN-${Random().nextInt(1000000).toString().padLeft(6, '0')}';
      final result = await db.query(
        'devices',
        where: 'servis_numarasi = ?',
        whereArgs: [serviceNumber],
      );
      isUnique = result.isEmpty;
    } while (!isUnique);

    return serviceNumber;
  }

  Future<void> insertDevice(Map<String, dynamic> device) async {
    try {

      if (device['customerName'] == null || device['customerName'].isEmpty) {
        print('Customer name is required.');
        return;
      }
      if (device['deviceType'] == null || device['deviceType'].isEmpty) {
        print('Device type is required.');
        return;
      }
      if (device['servis_numarasi'] == null || device['servis_numarasi'].isEmpty) {
        print('Service number is required.');
        return;
      }


      final db = await database;
      final existingDevice = await db.query(
        'devices',
        where: 'servis_numarasi = ?',
        whereArgs: [device['servis_numarasi']],
      );

      if (existingDevice.isNotEmpty) {
        print('Service number must be unique. This number already exists.');
        return;
      }


      device['isExternalService'] = device['isExternalService'] is bool
          ? (device['isExternalService'] as bool ? 1 : 0)
          : device['isExternalService'] ?? 0;
      device['isCompleted'] = device['isCompleted'] ?? 0;
      device['technician'] = device['technician'] ?? '';
      device['technicianContact'] = device['technicianContact'] ?? '';


      await db.insert(
        'devices',
        device,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      print('Device inserted successfully.');
    } catch (e) {
      print('Error inserting device: $e');
    }
  }

  Future<void> updateDevice(int id, Map<String, dynamic> device) async {
    try {
      final db = await database;
      device['isExternalService'] = device['isExternalService'] is bool
          ? (device['isExternalService'] as bool ? 1 : 0)
          : device['isExternalService'] ?? 0;
      device['technician'] = device['technician'] ?? '';
      device['technicianContact'] = device['technicianContact'] ?? '';

      await db.update(
        'devices',
        device,
        where: 'id = ?',
        whereArgs: [id],
      );
      print('Device updated successfully.');
    } catch (e) {
      print('Error updating device: $e');
    }
  }

  Future<void> markDeviceAsCompleted(int id) async {
    try {
      final db = await database;
      await db.update(
        'devices',
        {'isCompleted': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
      print('Device marked as completed.');
    } catch (e) {
      print('Error marking device as completed: $e');
    }
  }

  Future<void> deleteDevice(int id) async {
    try {
      final db = await database;
      await db.delete(
        'devices',
        where: 'id = ?',
        whereArgs: [id],
      );
      print('Device deleted successfully.');
    } catch (e) {
      print('Error deleting device: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCompletedDevices() async {
    return await getDevices(onlyCompleted: true);
  }

  Future<int> getDeviceCount({bool onlyCompleted = false}) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) FROM devices WHERE isCompleted = ?',
        [onlyCompleted ? 1 : 0],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('Error getting device count: $e');
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> searchCompletedDevices(String query) async {
    try {
      final db = await database;
      return await db.query(
        'devices',
        where: 'isCompleted = 1 AND (customerName LIKE ? OR deviceType LIKE ?)',
        whereArgs: ['%$query%', '%$query%'],
      );
    } catch (e) {
      print('Error searching completed devices: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchDevices(String query) async {
    try {
      final db = await database;
      return await db.query(
        'devices',
        where: 'customerName LIKE ? OR deviceType LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
      );
    } catch (e) {
      print('Error searching devices: $e');
      return [];
    }
  }

  Future<void> exportToExcel() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheet = excel['Devices'];


      List<String> headers = [
        'ID',
        'Customer Name',
        'Device Type',
        'Service Number',
        'Is Completed',
        'Technician',
        'Technician Contact',
      ];

      sheet.appendRow(headers);


      final devices = await getDevices();
      for (var device in devices) {
        sheet.appendRow([
          device['id'],
          device['customerName'],
          device['deviceType'],
          device['servis_numarasi'],
          device['isCompleted'],
          device['technician'],
          device['technicianContact'],
        ]);
      }

      
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/devices.xlsx';
      final bytes = excel.save() ?? [];
      File(filePath).writeAsBytesSync(bytes);
      print('Devices exported to $filePath');
    } catch (e) {
      print('Error exporting to Excel: $e');
    }
  }
}
