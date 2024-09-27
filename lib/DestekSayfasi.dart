import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class DestekSayfasi extends StatelessWidget {
  // URL açma işlevi
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Destek',style: TextStyle(fontWeight: FontWeight.bold,)),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SSS Bölümü
            Text(
              'Sıkça Sorulan Sorular (SSS)',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildFAQItem(
              question: 'Uygulama nasıl kullanılır?',
              answer: 'Uygulama, cihazlarınızın durumunu takip etmenizi sağlar. Başlangıçta cihazlarınızı ekleyin ve ardından detaylarını görüntüleyin veya güncelleyin.',
            ),
            _buildFAQItem(
              question: 'Sorun yaşarsam ne yapmalıyım?',
              answer: 'Sorun yaşarsanız, lütfen destek ekibimize ulaşın veya uygulamanın yardım belgelerini kontrol edin.',
            ),
            _buildFAQItem(
              question: 'Uygulama güncellemeleri nasıl yapılır?',
              answer: 'Uygulamanın en son sürümüne sahip olduğunuzdan emin olmak için Google Play Store veya App Store\'dan güncellemeleri kontrol edin.',
            ),
            const SizedBox(height: 20),
            // İletişim Bölümü
            Text(
              'İletişim Bilgileri',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Sorularınız ve destek talepleriniz için aşağıdaki iletişim bilgilerini kullanabilirsiniz:',
              style: GoogleFonts.roboto(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Telefon: (0212) 213 70 43',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _launchURL('mailto:teknik@vescom.com.tr'),
              child: Text(
                'E-posta: teknik@vescom.com.tr',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        title: Text(
          question,
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: GoogleFonts.roboto(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
