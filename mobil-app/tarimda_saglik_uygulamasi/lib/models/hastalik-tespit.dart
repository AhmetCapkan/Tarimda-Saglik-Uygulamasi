import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> hastalikTespitEt(File resimDosyasi) async {

  var uri = Uri.parse("http://127.0.0.1:5000/predict");

  try {
    print("Resim modele gönderiliyor...");

    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', resimDosyasi.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonSonuc = json.decode(responseData);

      String tespitEdilen = jsonSonuc['hastalik'];
      double skor = jsonSonuc['guven_skoru'];

      print("Hastalık: $tespitEdilen");
      print("Güven Oranı: %$skor");

    } else {
      print("Sunucu Hatası. Model yanıt veremedi. Kod: ${response.statusCode}");
    }
  } catch (e) {
    print("API'ye ulaşılamadı. Flask sunucusunun açık olduğundan ve ADB bağlantısından emin olun. Hata: $e");
  }
}