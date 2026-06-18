class Hastalik {
  int? _hastalikID;
  String _hastalikAdi;
  DateTime _tarih;

  Hastalik({
    int? hastalikID,
    required String hastalikAdi,
    required DateTime tarih,
  })  : _hastalikID = hastalikID,
        _hastalikAdi = hastalikAdi,
        _tarih = tarih;

  // Public Metotlar (+)
  int? getID() => _hastalikID;

  String getHastalikAdi() => _hastalikAdi;
  void setHastalikAdi(String ad) => _hastalikAdi = ad;

  DateTime getTarih() => _tarih;
  void setTarih(DateTime tarih) => _tarih = tarih;

  // Veritabanı işlemleri için yardımcı metot
  Map<String, dynamic> toMap() {
    return {
      'hastalikID': _hastalikID,
      'hastalikAdi': _hastalikAdi,
      'tarih': _tarih.toIso8601String(),
    };
  }
}