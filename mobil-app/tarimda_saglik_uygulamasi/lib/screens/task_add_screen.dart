import 'package:flutter/material.dart';
import '../db/dbHelper.dart';
import '../models/tarla.dart';
import '../models/islem.dart';
class TaskAddScreen extends StatefulWidget {
  const TaskAddScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return TaskAddScreenState();
  }
}


class TaskAddScreenState extends State<TaskAddScreen> {
  // Controller'lar
  var txtBaslik = TextEditingController();
  var txtAciklama = TextEditingController();


  List<Tarla> dbTarlalar = [];
  Tarla? secilenTarla;

  @override
  void initState() {
    super.initState();
    _tarlalariGetir(); // Sayfa açılırken tarlaları DB'den yükle
  }

  void _tarlalariGetir() async {
    final veriler = await DbHelper().getTarlalar();
    setState(() {
      dbTarlalar = veriler.map((e) => Tarla.fromMap(e)).toList();
    });
  }
  final List<String> isler = ['Toprak İşleme', 'Gübreleme','Sulama', 'İlaçlama','Budama','Ekim','Hasat', 'Toprak/Bitki Analiz', 'Diğer'];
  String? secilenIsBasligi;
  // Tarih Seçimi İçin
  DateTime secilenTarih = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Yeni İş Kaydı", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              buildTarlaField(),
              const SizedBox(height: 20),
              buildBaslikField(),
              const SizedBox(height: 20),
              buildAciklamaField(),
              const SizedBox(height: 20),
              buildTarihField(context),
              const SizedBox(height: 30),
              buildSaveButton(),
            ].map((widget) => SizedBox(
              width: 340,
              child: widget,
            )).toList(),
          ),
        ),
      ),
    );
  }

  // 1. TARLA SEÇİMİ
  Widget buildTarlaField() {
    return DropdownButtonFormField<Tarla>( // Türü Tarla olarak değiştirdik
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
      hint: const Text("Tarla Seçin"),
      value: secilenTarla,
      items: dbTarlalar.map((tarla) {
        return DropdownMenuItem<Tarla>(
          value: tarla,
          child: Text(tarla.tarlaAdi), // Ekranda tarlanın adını gösteriyoruz
        );
      }).toList(),
      onChanged: (yeniDeger) {
        setState(() {
          secilenTarla = yeniDeger;
        });
      },
    );
  }

  // 2. TARİH SEÇİMİ (Görseldeki gibi sağda ikonlu)
  Widget buildTarihField(BuildContext context) {
    return InkWell(
      onTap: () => _tarihSec(context), // Tıklayınca takvim açılır
      child: InputDecorator(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Tarih: ${secilenTarih.day}.${secilenTarih.month}.${secilenTarih.year}",
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(Icons.calendar_today_outlined),
          ],
        ),
      ),
    );
  }

  // Takvim Açma Fonksiyonu
  Future<void> _tarihSec(BuildContext context) async {
    final DateTime? secilen = await showDatePicker(
      context: context,
      initialDate: secilenTarih,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (secilen != null && secilen != secilenTarih) {
      setState(() {
        secilenTarih = secilen;
      });
    }
  }

  // 3. İŞ BAŞLIĞI
  Widget buildBaslikField() {
    return DropdownButtonFormField<String>(
      menuMaxHeight: 200,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
      hint: const Text("İş Başlığı Seçin"),
      value: secilenIsBasligi,
      items: isler.map((isbasligi) {
        return DropdownMenuItem<String>(
          value: isbasligi,
          child: Text(isbasligi),
        );
      }).toList(),
      onChanged: (yeniDeger) {
        setState(() {
          secilenIsBasligi = yeniDeger;
        });
      },
    );
  }

  // 4. AÇIKLAMA
  Widget buildAciklamaField() {
    return TextField(
      controller: txtAciklama,
      maxLines: 4,
      minLines: 4, // Görseldeki gibi geniş bir alan
      decoration: const InputDecoration(
        alignLabelWithHint: true,
        labelText: "Açıklama",
        border: OutlineInputBorder(),
      ),
    );
  }

  // 5. KAYDET BUTONU
  Widget buildSaveButton() {
    return SizedBox(
      height: 50, // Butonu biraz kalınlaştırdık
      child: ElevatedButton(
        onPressed: () {
          addKayit();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF3F0F5), // Görseldeki açık gri/mor tonu
          foregroundColor: Colors.deepPurple, // Görseldeki yazı rengi
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25), // Görseldeki gibi oval
          ),
        ),
        child: const Text("Kaydı Tamamla", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void addKayit() async{
    // 1. Boşluk Kontrolü
    if (secilenTarla == null || secilenIsBasligi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen Tarla ve İş Başlığı seçin!')),
      );
      return;
    }

    // 2. Tarih ve Hatırlatma Mantığı
    DateTime simdi = DateTime.now();
    // Saat/Dakika farklarını yoksaymak için sadece Gün/Ay/Yıl alıyoruz
    DateTime bugun = DateTime(simdi.year, simdi.month, simdi.day);
    DateTime secilen = DateTime(secilenTarih.year, secilenTarih.month, secilenTarih.day);

    DateTime islemTarihi;
    DateTime hatirlatmaTarihi;

    if (secilen.isAfter(bugun)) {
      // Girilen tarih bugünden İLERİDEYSE:
      // İşlemin kaydedildiği gün bugündür, hatırlatma ise seçilen o ileri tarihtir.
      islemTarihi = simdi;
      hatirlatmaTarihi = secilenTarih;
    } else {
      // Girilen tarih BUGÜN veya GEÇMİŞTEYSE:
      // İşlem o tarihte yapılmıştır, hatırlatmaya gerek yoktur (aynı tarih girilir).
      islemTarihi = secilenTarih;
      hatirlatmaTarihi = secilenTarih;
    }

    // 3. Veritabanına Uygun Modelin Oluşturulması
    Islem yeniIslem = Islem(
      islemAdi: secilenIsBasligi!, // Dropdown'dan gelen iş başlığı
      islemTuru: txtAciklama.text, // Şimdilik sabit bir tür veriyoruz
      tarih: islemTarihi,
      hatirlatma: hatirlatmaTarihi,
    );

    await DbHelper().insertIslem(yeniIslem, secilenTarla!.getID()!);

    // 5. Başarı mesajı
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('İşlem başarıyla kaydedildi!')),
    );

    // YENİ DÜZENLEME: Siyah ekran verdiren Navigator.pop YERİNE, formu sıfırlıyoruz:
    setState(() {
      secilenTarla = null; // Tarlayı boş yap
      secilenIsBasligi = null; // İş başlığını boş yap
      txtAciklama.clear(); // Açıklama kutusunu temizle
      secilenTarih = DateTime.now(); // Tarihi bugüne çek
    });
  }
}