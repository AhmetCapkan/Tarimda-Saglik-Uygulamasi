import 'package:flutter/material.dart';
import '../db/dbHelper.dart';

// 1. DEĞİŞİKLİK: Anlık yenileme için sayfayı StatefulWidget yaptık
class TaskListDetailsScreen extends StatefulWidget {
  final String fieldName;
  final int tarlaID;

  const TaskListDetailsScreen({
    super.key,
    required this.fieldName,
    required this.tarlaID,
  });

  @override
  State<TaskListDetailsScreen> createState() => _TaskListDetailsScreenState();
}

class _TaskListDetailsScreenState extends State<TaskListDetailsScreen> {
  // Sayfa her yenilendiğinde verileri tekrar çekmesi için bir değişken oluşturduk
  late Future<List<Map<String, dynamic>>> islemVerileri;

  @override
  void initState() {
    super.initState();
    _listeyiYenile();
  }

  // Listeyi DB'den tekrar çeken fonksiyon
  void _listeyiYenile() {
    setState(() {
      islemVerileri = DbHelper().getIslemlerByTarla(widget.tarlaID);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.fieldName} İşlemleri'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: islemVerileri, // Değişkenimizi buraya bağladık
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Bir hata oluştu!"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Bu tarlaya ait henüz bir işlem bulunmuyor.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          final isler = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: isler.length,
            itemBuilder: (context, index) {
              final islem = isler[index];

              DateTime islemTarihi = DateTime.parse(islem['tarih']);
              DateTime hatirlatmaTarihi = DateTime.parse(islem['hatirlatma']);

              String gosterilecekTarih;

              if (hatirlatmaTarihi.isAfter(islemTarihi)) {
                // Bu bir gelecek zamanlı görev (hatırlatma)
                gosterilecekTarih = "${hatirlatmaTarihi.day}/${hatirlatmaTarihi.month}/${hatirlatmaTarihi.year}";
              } else {
                // Bu geçmişte yapılmış bir işlem
                gosterilecekTarih = "${islemTarihi.day}/${islemTarihi.month}/${islemTarihi.year}";
              }

              String aciklamaMetni = islem["aciklama"] ?? islem["islemTuru"] ?? "Açıklama girilmemiş.";
              String baslikMetni = islem["islemAdi"] ?? "Bilinmeyen İşlem";

              // Veritabanındaki ID'yi alıyoruz ki hangisini sileceğimizi bilelim
              int islemID = islem["islemID"];

              // 2. DEĞİŞİKLİK: Kartın etrafını Dismissible (Kaydırılabilir) ile sardık
              return Dismissible(
                key: Key(islemID.toString()), // Her karta özel bir anahtar verdik (Zorunlu)
                direction: DismissDirection.endToStart, // Sadece sağdan sola kaydırma

                // Kart kaydırılırken alttan çıkacak olan kırmızı tasarım ve çöp kutusu/eksi ikonu
                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
                ),

                // Kaydırma işlemi bitince (kart ekrandan çıkınca) çalışacak kod
                onDismissed: (direction) async {
                  // 1. Veritabanından sil
                  await DbHelper().deleteIslem(islemID);

                  // 2. Kullanıcıya bilgi ver
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$baslikMetni silindi!')),
                  );

                  // 3. (Gerekirse) Listeyi yenile
                  _listeyiYenile();
                },

                // SENİN KART TASARIMIN (Hiç dokunulmadı)
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      _showDetayPopup(context, baslikMetni, aciklamaMetni, gosterilecekTarih);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  baslikMetni,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  aciklamaMetni,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            gosterilecekTarih,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDetayPopup(BuildContext context, String baslik, String aciklama, String tarih) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  baslik,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                tarih,
                style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              aciklama,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Kapat", style: TextStyle(color: Colors.teal, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }
}