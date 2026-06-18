import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http; // API istekleri için

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _secilenResim;
  bool _yukleniyor = false;
  String? _tespitEdilenHastalik;
  double? _guvenSkoru;
  String? _hataMesaji;

  // Görüntü seçme fonksiyonu
  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        setState(() {
          _secilenResim = File(image.path);
          _yukleniyor = true; // Yükleme animasyonunu başlat
          _hataMesaji = null;
        });

        // Resmi API'ye gönder
        await _hastalikTespitEt(_secilenResim!);
      }
    } catch (e) {
      print("Kamera/Galeri Hatası: $e");
    }
  }

  // Python API'sine bağlanma fonksiyonu
  Future<void> _hastalikTespitEt(File resimDosyasi) async {
    // ADB Reverse kullandığımız için localhost (127.0.0.1) adresi çalışır
    var uri = Uri.parse("http://127.0.0.1:5000/predict");

    try {
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', resimDosyasi.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonSonuc = json.decode(responseData);

        setState(() {
          _tespitEdilenHastalik = jsonSonuc['hastalik'];
          _guvenSkoru = jsonSonuc['guven_skoru'];
          _yukleniyor = false; // Yükleme bitti
        });
      } else {
        setState(() {
          _hataMesaji = "Sunucu Hatası (Kod: ${response.statusCode}). Flask açık mı?";
          _yukleniyor = false;
        });
      }
    } catch (e) {
      setState(() {
        _hataMesaji = "Bağlantı kurulamadı. Lütfen terminalden 'adb reverse tcp:5000 tcp:5000' komutunu girdiğinizden ve Flask'ın çalıştığından emin olun.";
        _yukleniyor = false;
      });
    }
  }

  // Ekranı sıfırlama fonksiyonu (Yeni işlem için)
  void _temizle() {
    setState(() {
      _secilenResim = null;
      _tespitEdilenHastalik = null;
      _guvenSkoru = null;
      _hataMesaji = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hastalık Tespiti', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _buildBodyContent(), // Ekran durumuna göre içeriği çizen fonksiyon
      ),
    );
  }

  // Ekranın o anki durumuna göre hangi Widget'ı göstereceğine karar verir
  Widget _buildBodyContent() {
    // DURUM 1: Yükleme (İşlem yapılıyor) ekranı
    if (_yukleniyor) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.teal),
            SizedBox(height: 20),
            Text("Yapay Zeka Modeli İnceliyor...", style: TextStyle(fontSize: 18, color: Colors.teal)),
          ],
        ),
      );
    }

    // DURUM 2: Sonuç geldiğinde gösterilecek ekran
    if (_secilenResim != null && (_tespitEdilenHastalik != null || _hataMesaji != null)) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Seçilen Fotoğraf
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.file(_secilenResim!, height: 300, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),

            // Hata varsa hatayı, yoksa sonucu göster
            if (_hataMesaji != null)
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(10)),
                child: Text(_hataMesaji!, style: const TextStyle(color: Colors.red, fontSize: 16)),
              )
            else
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text("TEŞHİS SONUCU", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(
                        _tespitEdilenHastalik!,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text("Güven Oranı: %$_guvenSkoru", style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 30),

            // Yeniden dene butonu
            ElevatedButton.icon(
              onPressed: _temizle,
              icon: const Icon(Icons.refresh),
              label: const Text("Yeni Teşhis Yap", style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ],
        ),
      );
    }

    // DURUM 3: Başlangıç  Ekranı
    return Column(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.camera_alt,
            title: 'Kamerayı Aç',
            color: Colors.teal,
            onTap: () => _pickImage(ImageSource.camera),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _buildActionCard(
            icon: Icons.snippet_folder,
            title: 'Dosya Ekle',
            color: Colors.blueGrey,
            onTap: () => _pickImage(ImageSource.gallery),
          ),
        ),
      ],
    );
  }

  // Senin orijinal kart tasarımın (Dokunulmadı)
  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: color.withOpacity(0.05),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 90, color: color),
              const SizedBox(height: 15),
              Text(
                title,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color.withOpacity(0.8)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}