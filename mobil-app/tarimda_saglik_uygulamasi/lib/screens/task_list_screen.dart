import 'package:flutter/material.dart';
import 'package:tarimda_saglik_uygulamasi/screens/task_list_details_screen.dart';
import '../db/dbHelper.dart';
import '../models/tarla.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Map<String, dynamic>> realData = [];

  final List<String> kapakResimleri = [
    "https://media.istockphoto.com/id/638155104/tr/foto%C4%9Fraf/water-sprinklers.jpg?s=612x612&w=0&k=20&c=59TqRIHU_Pv-274eTXL5dE2QrqUOnmqPYUTPnYTrHtc=",
    "https://isbh.tmgrup.com.tr/sbh/2021/03/15/650x344/diyarbakirin-silvan-ilcesinde-ciftciler-bugday-tar-1615797929688.jpg",
    "https://www.cropscience.bayer.com.tr/content/dam/bayer-crop-science/turkey/bcs/miscellaneous/article-images/bugdayin-tarladaki%CC%87-yolculugu-hasat-i%CC%87le-son-buluyor-2.jpg",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS0QkIGPwsrQegU-qDp3Tumv0IA8cAZHoY6LA&s"
  ];

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  String _getIslemResmi(String islemAdi) {
    // Dropdown'daki 'isler' listesine göre eşleştirme yapıyoruz
    switch (islemAdi) {
      case 'Toprak İşleme':
        return 'assets/toprak-isleme.png'; // Klasöre koyduğun resmin tam adı
      case 'Gübreleme':
        return 'assets/gübreleme.jpg';
      case 'Sulama':
        return 'assets/sulama.jpg';
      case 'İlaçlama':
        return 'assets/ilaclama.jpeg';
      case 'Budama':
        return 'assets/budama.jpg';
      case 'Ekim':
        return 'assets/ekim.jpg';
      case 'Hasat':
        return 'assets/hasat.jpg';
      case 'Toprak/Bitki Analiz':
        return 'assets/toprak-analizi.jpg';
      default:
      // 'Diğer' seçildiyse veya henüz hiç işlem yoksa standart bir tarla resmi göster
        return 'assets/diğer.jpeg';
    }
  }
  Future<void> _verileriYukle() async {
    final dbTarlalar = await DbHelper().getTarlalar();
    List<Map<String, dynamic>> geciciListe = [];

    DateTime simdi = DateTime.now();
    DateTime bugun = DateTime(simdi.year, simdi.month, simdi.day); // Sadece günü kıyaslamak için

    for (int i = 0; i < dbTarlalar.length; i++) {
      var tarla = dbTarlalar[i];
      int tarlaID = tarla['tarlaID'];
      String tarlaAdi = tarla['tarlaAdi'] ?? "İsimsiz Tarla";

      final islemler = await DbHelper().getIslemlerByTarla(tarlaID);

      String sonIslemBasligi = "Henüz işlem yok";
      String sonIslemTarihi = "";
      bool hasFutureTask = false; // YENİ: İleri tarihli iş var mı bayrağı

      if (islemler.isNotEmpty) {
        // 1. ADIM: İleri tarihli (yaklaşan) bir iş var mı diye tüm listeyi tarıyoruz
        for (var islem in islemler) {
          // Eski kayıtlarda hatirlatma boş olabilir diye güvenlik önlemi:
          String tarihMetni = islem['hatirlatma'] ?? islem['tarih'];
          DateTime islemZamani = DateTime.parse(tarihMetni);
          DateTime islemGunu = DateTime(islemZamani.year, islemZamani.month, islemZamani.day);

          if (islemGunu.isAfter(bugun)) {
            hasFutureTask = true; // Gelecekte bir iş bulduk!
            break; // Bir tane bulmak bildirimi yakmak için yeterli
          }
        }

        // 2. ADIM: Kartta göstermek için en son yapılan/eklenen işlemi buluyoruz
        var siraliIslemler = List<Map<String, dynamic>>.from(islemler);
        siraliIslemler.sort((a, b) => b['tarih'].compareTo(a['tarih']));

        var sonIslem = siraliIslemler.first;
        sonIslemBasligi = sonIslem['islemAdi'];

        // Akıllı Tarih: Hatırlatma tarihi varsa ve ilerideyse onu göster, yoksa işlem tarihini
        DateTime t = DateTime.parse(sonIslem['tarih']);
        DateTime h = DateTime.parse(sonIslem['hatirlatma'] ?? sonIslem['tarih']);
        DateTime gosterilecekDt = h.isAfter(t) ? h : t;

        sonIslemTarihi = "${gosterilecekDt.day}/${gosterilecekDt.month}/${gosterilecekDt.year}";
      }

      geciciListe.add({
        "tarlaID": tarlaID,
        "title": sonIslemBasligi,
        "location": tarlaAdi,
        "hasImage": true,
        "imageUrl": _getIslemResmi(sonIslemBasligi),
        "date": sonIslemTarihi,
        "hasFutureTask": hasFutureTask, // YENİ: Bildirim durumunu karta gönderiyoruz
      });
    }

    setState(() {
      realData = geciciListe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İş Kayıtları'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: () {
              _showAddTarlaDialog(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.teal,
        onRefresh: _verileriYukle,
        child: realData.isEmpty
            ? ListView( // Boş ekranda da aşağı kaydırıp yenilemek için ListView'a aldık
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.4),
            const Center(child: Text("Henüz kayıtlı tarla yok. + butonundan ekleyebilirsiniz.", style: TextStyle(color: Colors.grey))),
          ],
        )
            : Padding(
          padding: const EdgeInsets.all(10.0),
          child: GridView.builder(
            itemCount: realData.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final item = realData[index];

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskListDetailsScreen(
                          fieldName: item["location"] as String,
                          tarlaID: item["tarlaID"] as int,
                        ),
                      ),
                    ).then((_) {
                      _verileriYukle();
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            item["hasImage"] == true
                                ? Image.asset(
                              item["imageUrl"],
                              fit: BoxFit.cover,
                            )
                                : Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                            // --- YENİ BİLDİRİMLİ TARİH TASARIMI ---
                            if (item["date"].toString().isNotEmpty)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  // Row kullanarak hem ikonu hem yazıyı yan yana koyuyoruz
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Eğer ileri tarihli iş varsa turuncu zil ikonunu göster
                                      if (item["hasFutureTask"] == true) ...[
                                        const Icon(Icons.notifications_active, color: Colors.orangeAccent, size: 14),
                                        const SizedBox(width: 4),
                                      ],
                                      Text(
                                        item["date"],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: Colors.teal),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item["location"],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Text(
                                    "İş: ${item["title"]}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showAddTarlaDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameCont = TextEditingController();
    final dekarCont = TextEditingController();
    final mevkiCont = TextEditingController();
    final mahsulCont = TextEditingController();
    final verimCont = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Yeni Tarla Kaydı"),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCont,
                    decoration: const InputDecoration(labelText: "Tarla Adı (Örn: Kuzey Tarlası)"),
                    validator: (v) => v!.isEmpty ? "Boş bırakılamaz" : null,
                  ),
                  TextFormField(
                    controller: dekarCont,
                    decoration: const InputDecoration(labelText: "Dekar (Örn: 50.5)"),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: mevkiCont,
                    decoration: const InputDecoration(labelText: "Mevkii (Örn: Dere Boyu)"),
                  ),
                  TextFormField(
                    controller: mahsulCont,
                    decoration: const InputDecoration(labelText: "Ekilmiş Mahsül (Örn: Mısır)"),
                  ),
                  TextFormField(
                    controller: verimCont,
                    decoration: const InputDecoration(labelText: "Tahmini Toplam Verim"),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Tarla yeniTarla = Tarla(
                    tarlaAdi: nameCont.text,
                    dekar: double.tryParse(dekarCont.text) ?? 0,
                    mevki: mevkiCont.text,
                    mahsul: mahsulCont.text,
                    verim: double.tryParse(verimCont.text) ?? 0,
                  );

                  await DbHelper().insertTarla(yeniTarla);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tarla başarıyla eklendi!')),
                  );
                  Navigator.pop(context);
                  _verileriYukle();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text("Ekle", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}