import 'hastalik.dart';
import 'islem.dart';

class Tarla {
  int? _tarlaID;
  String _mahsul;

  String tarlaAdi;
  double dekar;
  String mevki;
  double verim;
  List<Islem>? isler;
  List<Hastalik>? hastaliklar;

  Tarla({
    int? tarlaID,
    required this.tarlaAdi,
    required this.dekar,
    required this.mevki,
    required String mahsul,
    required this.verim,
    this.isler,
    this.hastaliklar,
  })  : _tarlaID = tarlaID,
        _mahsul = mahsul;

  int? getID() => _tarlaID;

  double getDekaraVerim() {
    // Dekara verim hesabı: Toplam Verim / Dekar
    if (dekar <= 0) return 0;
    return verim / dekar;
  }

  String getMahsul() => _mahsul;
  void setMahsul(String mahsul) => _mahsul = mahsul;

  Map<String, dynamic> toMap() {
    return {
      'tarlaID': _tarlaID,
      'tarlaAdi': tarlaAdi,
      'dekar': dekar,
      'mevki': mevki,
      'mahsul': _mahsul, // Private alana sınıf içinden erişebiliriz
      'verim': verim,
    };
  }
  factory Tarla.fromMap(Map<String, dynamic> map) {
    return Tarla(
      tarlaID: map['tarlaID'],
      tarlaAdi: map['tarlaAdi'],
      dekar: map['dekar'],
      mevki: map['mevki'],
      mahsul: map['mahsul'],
      verim: map['verim'],
    );
  }
}