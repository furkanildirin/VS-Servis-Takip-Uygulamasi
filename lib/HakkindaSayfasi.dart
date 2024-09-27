import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HakkindaSayfasi extends StatelessWidget {
  // URL açma işlevi
  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://vescom.com.tr/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'URL açılamadı: $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor = brightness == Brightness.dark ? Colors.white : Colors.black;
    final vescomTextColor1 = brightness == Brightness.dark ? Colors.white : Colors.blue[800];
    final vescomTextColor2 = brightness == Brightness.dark ? Colors.white : Colors.green[800];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hakkında',style: TextStyle(fontWeight: FontWeight.bold,)),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Geliştirici: Furkan İldirin',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: textColor, // Yazı rengini dinamik olarak ayarladık
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Bu uygulama, cihazların takip edilmesi ve yönetilmesi amacıyla geliştirilmiştir. '
                        'Kullanıcı dostu arayüzü ve kapsamlı özellikleri ile cihazlarınızın durumu hakkında hızlı ve etkili bir şekilde bilgi almanızı sağlar.',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: textColor, // Yazı rengini dinamik olarak ayarladık
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _launchURL,
                    child: Text(
                      'Vescom, teknoloji alanında yenilikçi çözümler sunan bir şirkettir. Şirket, çeşitli teknolojik ürünler ve hizmetler ile '
                          'müşterilerine modern ve etkili çözümler sunmayı hedefler. Daha fazla bilgi için web sitesini ziyaret edebilirsiniz.',
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
          ),
          // VESCOM logo text at the bottom with a black background
          Container(
            color: Colors.black, // VESCOM yazısının arka planını siyah yapıyoruz
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'VES',
                      style: GoogleFonts.roboto(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: vescomTextColor1, // Dinamik renk kullanımı
                      ),
                    ),
                    TextSpan(
                      text: 'COM',
                      style: GoogleFonts.roboto(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: vescomTextColor2, // Dinamik renk kullanımı
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
