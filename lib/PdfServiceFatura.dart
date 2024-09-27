import 'package:flutter/services.dart'; // rootBundle için gerekli
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PdfServiceFatura {
  Future<void> generateAndPrintInvoice(Map<String, dynamic> invoiceData) async {
    final pdf = pw.Document();

    // Fontları yükle
    final robotoRegular = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Roboto-Regular.ttf')
    );
    final robotoBold = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Roboto-Bold.ttf')
    );

    // Müşteri bilgileri
    final String serviceNumber = invoiceData['serviceNumber'] ?? 'N/A';
    final String customerName = invoiceData['customerName'] ?? 'N/A';
    final String serialNumber = invoiceData['serialNumber'] ?? 'N/A';

    // Parçalar ve fiyatlar listesi
    final List<Map<String, dynamic>> parts = invoiceData['parts'] ?? [];

    // Parçaların toplam fiyatını hesapla
    double partsTotal = 0.0;
    for (var part in parts) {
      partsTotal += part['price'] as double;
    }

    // Toplam ücreti (parçalar + diğer ücretler) hesapla
    final baseFee = invoiceData['totalFee'] as double; // Ana ücret
    final totalFee = baseFee + partsTotal; // Ana ücret + parça fiyatları

    final bool applyVat = invoiceData['includeVat'] ?? false; // KDV Uygula switch'inin durumu
    final double vatRate = invoiceData['vatRate'] as double? ?? 0.0; // KDV oranı, varsayılan 0.0

    double vatAmount = 0.0;
    double totalWithVat = totalFee;

    if (applyVat) {
      vatAmount = totalFee * (vatRate / 100); // KDV tutarı
      totalWithVat = totalFee + vatAmount; // KDV dahil toplam
    }

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // VESCOM yazısı
              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: 'VES',
                      style: pw.TextStyle(
                        font: robotoBold,
                        fontSize: 36,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.TextSpan(
                      text: 'COM',
                      style: pw.TextStyle(
                        font: robotoBold,
                        fontSize: 36,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green600,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Şirket Bilgileri
              pw.Text(
                'MECİDİYEKÖY MAH. ATAKAN SK. ÖZÇELİK İŞ MERKEZİ D:1/A 34387 ŞİŞLİ/İSTANBUL\n'
                    'TEKNİK@VESCOM.COM.TR TEL: 0 (212) 213 7043',
                style: pw.TextStyle(
                  font: robotoRegular,
                  fontSize: 12,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 20),

              pw.Text('Fatura', style: pw.TextStyle(
                font: robotoBold,
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              )),
              pw.SizedBox(height: 20),

              // Servis Numarası, Müşteri Adı, Seri Numarası
              pw.Text('Servis Numarası: $serviceNumber', style: pw.TextStyle(
                font: robotoRegular,
                fontSize: 14,
              )),
              pw.SizedBox(height: 10),
              pw.Text('Müşteri Adı: $customerName', style: pw.TextStyle(
                font: robotoRegular,
                fontSize: 14,
              )),
              pw.SizedBox(height: 10),
              pw.Text('Seri Numarası: $serialNumber', style: pw.TextStyle(
                font: robotoRegular,
                fontSize: 14,
              )),
              pw.SizedBox(height: 20),

              // Parça Bilgileri Tablosu
              if (parts.isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Parçalar:', style: pw.TextStyle(
                      font: robotoBold,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    )),
                    pw.SizedBox(height: 10),
                    pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey),
                      children: [
                        _buildTableRow(['Parça Adı', 'Fiyat'], robotoBold), // Başlıklar
                        ...parts.map((part) {
                          return _buildTableRow([part['name'] ?? 'N/A', '${part['price'].toStringAsFixed(2)} TL'], robotoRegular);
                        }).toList(),
                      ],
                    ),
                    pw.SizedBox(height: 20),
                  ],
                ),

              // Fatura Bilgileri Tablosu
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey),
                children: [
                  _buildTableRow(['Toplam Ücret (Parçalar dahil)', '${totalFee.toStringAsFixed(2)} TL'], robotoRegular),
                  if (applyVat) ...[
                    _buildTableRow(['KDV Oranı', '${vatRate.toStringAsFixed(2)} %'], robotoRegular),
                    _buildTableRow(['KDV Tutarı', '${vatAmount.toStringAsFixed(2)} TL'], robotoRegular),
                  ],
                  _buildTableRow(['KDV Dahil Toplam', '${totalWithVat.toStringAsFixed(2)} TL'], robotoRegular),
                ],
              ),

              pw.SizedBox(height: 20),

              // İmza ve Divider
              pw.Text('İmza:', style: pw.TextStyle(
                font: robotoBold,
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              )),
              pw.SizedBox(height: 30),
              pw.Text('Ad Soyad:', style: pw.TextStyle(
                font: robotoRegular,
                fontSize: 14,
              )),
              pw.SizedBox(height: 20),
              pw.Text('İmza / Kaşe:', style: pw.TextStyle(
                font: robotoRegular,
                fontSize: 14,
              )),
              pw.SizedBox(height: 50),
              pw.Container(width: double.infinity, child: pw.Divider()),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  // Tablo satırı oluşturma metodu
  pw.TableRow _buildTableRow(List<String> cells, pw.Font font) {
    return pw.TableRow(
      children: cells.map((cell) => pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(cell, style: pw.TextStyle(font: font, fontSize: 12)),
      )).toList(),
    );
  }
}
