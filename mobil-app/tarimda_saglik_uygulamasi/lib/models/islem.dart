class Islem {
  // Private Alanlar (-)
  int? _islemID;
  String _islemAdi;
  String _islemTuru;
  DateTime _tarih;
  DateTime _hatirlatma;

  Islem({
    int? islemID,
    required String islemAdi,
    required String islemTuru,
    required DateTime tarih,
    required DateTime hatirlatma,
  })  : _islemID = islemID,
        _islemAdi = islemAdi,
        _islemTuru = islemTuru,
        _tarih = tarih,
        _hatirlatma = hatirlatma;

  int? getID() => _islemID;

  String getIslemAdi() => _islemAdi;
  void setIslemAdi(String ad) => _islemAdi = ad;

  String getIslemTuru() => _islemTuru;
  void setIslemTuru(String tur) => _islemTuru = tur;

  DateTime getTarih() => _tarih;
  void setTarih(DateTime tarih) => _tarih = tarih;

  DateTime getHatirlatma() => _hatirlatma;
  void setHatirlatma(DateTime hatirlatma) => _hatirlatma = hatirlatma;

  Map<String, dynamic> toMap() {
    return {
      'islemID': _islemID,
      'islemAdi': _islemAdi,
      'islemTuru': _islemTuru,
      'tarih': _tarih.toIso8601String(),
      'hatirlatma': _hatirlatma.toIso8601String(),
    };
  }
}