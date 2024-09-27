import 'package:flutter/services.dart'; // rootBundle için gerekli
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PdfService {
  Future<void> generateAndPrintDeviceReport(Map<String, dynamic> device) async {
    final pdf = pw.Document();

    // Fontları yükle
    final robotoRegular = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Roboto-Regular.ttf')
    );
    final robotoBold = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Roboto-Bold.ttf')
    );

    pdf.addPage(
        pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16), // Daha küçük kenar boşlukları
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
    fontSize: 24, // Yazı boyutunu küçült
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blue900,
    ),
    ),
    pw.TextSpan(
    text: 'COM',
    style: pw.TextStyle(
    font: robotoBold,
    fontSize: 24,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.green600,
    ),
    ),
    ],
    ),
    ),
    pw.SizedBox(height: 5),

    // Şirket bilgileri
    pw.Text(
    'MECİDİYEKÖY MAH. ATAKAN SK. ÖZÇELİK İŞ MERKEZİ D:1/A 34387 ŞİŞLİ/İSTANBUL',
    style: pw.TextStyle(
    font: robotoRegular,
    fontSize: 8, // Font boyutunu küçülttüm
    )),
    pw.Text('TEKNİK@VESCOM.COM.TR  TEL: 0 (212) 213 7043',
    style: pw.TextStyle(
    font: robotoRegular,
    fontSize: 8,
    )),
    pw.SizedBox(height: 10),

    // Başlık
    pw.Text('Servis Raporu',
    style: pw.TextStyle(
    font: robotoBold,
    fontSize: 16, // Başlık boyutunu küçülttüm
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
    )),
    pw.SizedBox(height: 10),

    // Müşteri Bilgileri
    pw.Text('Müşteri Bilgileri',
    style: pw.TextStyle(
    font: robotoBold,
    fontSize: 14, // Fontu küçülttüm
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
    )),
    pw.SizedBox(height: 5),

    // Müşteri Bilgileri Tablosu
    pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey),
    children: [
    _buildTableRow(['Bayi Adı', device['dealershipName']], robotoRegular),
    _buildTableRow(['Müşteri Adı', device['customerName']], robotoRegular),
    _buildTableRow(['Adres', device['address']], robotoRegular),
    _buildTableRow(['Telefon', device['phone']], robotoRegular),
    _buildTableRow(['E-posta', device['email']], robotoRegular),
    ],
    ),
    pw.SizedBox(height: 10),

    // Cihaz Bilgileri
    pw.Text('Cihaz Bilgileri',
    style: pw.TextStyle(
    font: robotoBold,
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
    )),
    pw.SizedBox(height: 5),

    // Cihaz Bilgileri Tablosu
    pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey),
    children: [
    _buildTableRow(['Cihaz Türü', device['deviceType']], robotoRegular),
    _buildTableRow(['Marka', device['brand']], robotoRegular),
    _buildTableRow(['Model', device['model']], robotoRegular),
    _buildTableRow(['Seri Numarası', device['serialNumber']], robotoRegular),
    _buildTableRow(['Fatura Tarihi', device['invoiceDate']], robotoRegular),
    _buildTableRow(['Garanti Bilgisi', device['warrantyInfo']], robotoRegular),
    _buildTableRow(['Genel Durum', device['overallCondition']], robotoRegular),
    _buildTableRow(['Servise Geliş Tarihi', device['serviceArrivalDate']], robotoRegular),
    _buildTableRow(['Toplam Ücret', '${device['totalFee']?.toStringAsFixed(2) ?? 'Bilgi mevcut değil'} TL'], robotoRegular),
    _buildTableRow(['Şikayet', device['explanation']], robotoRegular),
    _buildTableRow(['Cihazla Gelen Ürünler', device['accompanyingItems']], robotoRegular),
    _buildTableRow(['Cihazla İlgili Şikayetler', device['damageDescription']], robotoRegular),
    ],
    ),
    pw.SizedBox(height: 10),

    // Servis Sözleşmesi Maddeleri
    pw.Text('Servis Sözleşmesi',
    style: pw.TextStyle(
    font: robotoBold,
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.black,
    )),
    pw.SizedBox(height: 5),

    // Sözleşme maddelerini küçülterek yerleştiriyoruz
    _buildContractParagraph('1. Servisimize teslim tarihinden itibaren 1 ay içerisinde teslim alınmayan cihazlar için firmamız herhangi bir sorumluluk kabul etmez.', robotoRegular),
    _buildContractParagraph('2. Garanti harici durumlarda ve onarım kabul edilmediği durumlarda harcanan işçilik bedeli olarak standart servis ücreti alınır.', robotoRegular),
    _buildContractParagraph('3. 10 iş günü içerisinde geri alınmayan cihazlardan kur farkından doğan fiyat farkı talep edilir.', robotoRegular),
    _buildContractParagraph('4. Garanti harici cihazlar servis ücretinin ödenmesini takiben teslim edilecektir.', robotoRegular),
    _buildContractParagraph('5. Cihaz bu belge karşılığında geri verilecektir, üçüncü şahısların eline geçmesi sonucu oluşabilecek durumlardan firmamız sorumlu değildir.', robotoRegular),
    _buildContractParagraph('6. Müşterilerin servisimize getirdiği cihazlardaki kişisel ayar ve bilgileri yedeklemeleri gerekmektedir. Bu gibi durumlarda oluşabilecek kayıplardan firmamız sorumlu değildir.', robotoRegular),
    _buildContractParagraph('7. Kullanıcı hatalarından kaynaklanan arızalar garanti kapsamı dışıdır.', robotoRegular),
    _buildContractParagraph('8. Yetkisiz müdahale tespit edilirse cihaz garanti dışı kabul edilecektir.', robotoRegular),
    _buildContractParagraph('9. Sıvı teması olan cihazlarda onarım garantisi verilmez.', robotoRegular),
    _buildContractParagraph('10. Bu sözleşme kapsamadığı durumlarda yasa hükümleri uygulanır.', robotoRegular),
    _buildContractParagraph('11. Garanti dışı cihaz tamirlerinde onay alınmayan cihazlar tamir edilmez.', robotoRegular),
    _buildContractParagraph('12. Garanti dışı cihazlarda tüm kargo masrafları müşteriye aittir.', robotoRegular),
    pw.SizedBox(height: 10),

    // İmza alanları
    pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
    pw.Column(
    children: [
    pw.Text('Teslim Eden',
    style: pw.TextStyle(
    font: robotoBold,
    fontSize: 12,
    fontWeight: pw.FontWeight.bold,
    )),
    pw.SizedBox(height: 30), // Daha kısa boşluk
    pw.Container(width: 120, child: pw.Divider()),
    ],
    ),
    pw.Column(
    children: [
    pw.Text('Teslim Alan',
    style: pw.TextStyle(
    font: robotoBold,
    fontSize: 12,
    fontWeight: pw.FontWeight.bold,
    )),
    pw.SizedBox(height: 30),
      pw.Container(width: 120, child: pw.Divider()),
    ],
    ),
    ],
    ),
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
      children: cells
          .map((cell) => pw.Padding(
        padding: const pw.EdgeInsets.all(4), // Kenar boşluklarını küçülttüm
        child: pw.Text(cell,
            style: pw.TextStyle(font: font, fontSize: 10)), // Yazı boyutu küçültüldü
      ))
          .toList(),
    );
  }

  // Servis sözleşme maddelerini küçülterek yerleştirme metodu
  pw.Widget _buildContractParagraph(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 10), // Yazı boyutu küçültüldü
        textAlign: pw.TextAlign.justify,
      ),
    );
  }
}
