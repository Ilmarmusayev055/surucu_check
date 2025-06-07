import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore verilənlər bazası ilə əlaqə qurmaq üçün paket
import 'package:flutter/material.dart'; // Flutter Material dizayn komponentləri üçün paket
import 'package:surucu_check/l10n/app_localizations.dart'; // Lokalizasiya (dil dəstəyi) üçün paket
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication xidməti üçün paket
import 'dart:ui'; // ImageFilter kimi UI effektləri üçün dart:ui kitabxanası
import 'package:cached_network_image/cached_network_image.dart'; // Şəbəkədən şəkilləri keşləmək və göstərmək üçün paket

// SearchPage dövlətli (stateful) widget-ıdır.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key}); // Konstanta konstruktor

  @override
  State<SearchPage> createState() => _SearchPageState(); // Widget üçün State obyekti yaradır
}

// _SearchPageState State obyekti SearchPage-in vəziyyətini idarə edir.
class _SearchPageState extends State<SearchPage> {
  // Axtarış sahələri üçün TextEditingController-lər
  final TextEditingController searchController = TextEditingController(); // Ümumi axtarış sahəsi üçün
  final TextEditingController nameController = TextEditingController(); // Ad sahəsi üçün
  final TextEditingController surnameController = TextEditingController(); // Soyad sahəsi üçün
  final TextEditingController fatherNameController = TextEditingController(); // Ata adı sahəsi üçün

  String selectedSearchType = 'fin'; // Seçilmiş axtarış növünü saxlayan dəyişən (defolt olaraq 'fin')
  Map<String, dynamic>? driver; // Tapılan sürücü məlumatlarını saxlayan dəyişən
  List<Map<String, dynamic>> entries = []; // Sürücünün giriş qeydlərini saxlayan siyahı
  bool _hasSearched = false; // İstifadəçinin axtarış edib-etmədiyini göstərən flag

  // Axtarış növləri və onların istifadəçi üçün görünən adları
  final searchTypes = {
    'fin': 'FİN',
    'sv': 'SV nömrəsi',
    'phone': 'Telefon',
    'fullname': 'Ad Soyad Ata adı',
  };

  @override
  void initState() {
    super.initState();
    // ✅ DƏYİŞDİ: Axtarış xanaları üçün listener-lər əlavə edildi ki, 'x' düyməsi dinamik görünsün/gizlənsin.
    searchController.addListener(_onSearchChanged);
    nameController.addListener(_onSearchChanged);
    surnameController.addListener(_onSearchChanged);
    fatherNameController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    // ✅ DƏYİŞDİ: Listener-lər dispose metodunda silindi (memory leak qarşısını almaq üçün).
    searchController.removeListener(_onSearchChanged);
    nameController.removeListener(_onSearchChanged);
    surnameController.removeListener(_onSearchChanged);
    fatherNameController.removeListener(_onSearchChanged);
    searchController.dispose();
    nameController.dispose();
    surnameController.dispose();
    fatherNameController.dispose();
    super.dispose();
  }

  // Listener üçün callback funksiyası
  void _onSearchChanged() {
    setState(() {
      // Bu, sadəcə state-i yeniləyir ki, `_buildStyledTextField` içindəki `controller.text.isNotEmpty` yoxlaması yenidən işlənsin.
    });
  }

  // Seçilmiş axtarış növünə əsasən ipucu mətnini qaytaran funksiya
  String getHintText() {
    switch (selectedSearchType) {
      case 'fin':
        return 'FIN kodu daxil edin'; // FİN axtarışı üçün ipucu
      case 'sv':
        return 'SV nömrəsini daxil edin'; // SV nömrəsi axtarışı üçün ipucu
      case 'phone':
        return 'Mobil nömrəni daxil edin'; // Telefon nömrəsi axtarışı üçün ipucu
      default:
        return 'Dəyəri daxil edin'; // Digər hallar üçün ümumi ipucu
    }
  }

  // Axtarış əməliyyatını yerinə yetirən asinxron funksiya
  Future<void> performSearch() async {
    final value = searchController.text.trim().toUpperCase(); // Axtarış dəyərini böyük hərflərlə alır və boşluqları təmizləyir
    final name = nameController.text.trim().toLowerCase(); // Adı kiçik hərflərlə alır və boşluqları təmizləyir
    final surname = surnameController.text.trim().toLowerCase(); // Soyadı kiçik hərflərlə alır və boşluqları təmizləyir
    final fatherName = fatherNameController.text.trim().toLowerCase(); // Ata adını kiçik hərflərlə alır və boşluqları təmizləyir

    // Axtarış növü 'fullname' deyilsə və axtarış sahəsi boşdursa, xəta mesajı göstərir
    if (selectedSearchType != 'fullname' && value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Axtarış üçün dəyər daxil edin.")), // SnackBar ilə mesaj göstərir
      );
      return; // Funksiyadan çıxır
    }
    // Axtarış növü 'fullname' olarsa və ad və soyad boşdursa, xəta mesajı göstərir
    // ✅ DƏYİŞDİ: "Ad Soyad Ata adı" axtarışı üçün validasiya dəyişdirildi.
    // Artıq ata adı boş olsa belə (ad və soyad dolu olarsa) axtarışa icazə verilir.
    if (selectedSearchType == 'fullname' && (name.isEmpty || surname.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ad və Soyad boş ola bilməz.")), // SnackBar ilə mesaj göstərir
      );
      return; // Funksiyadan çıxır
    }

    // Axtarış prosesi başlayanda UI-da dəyişikliklər edir
    setState(() {
      driver = null; // Əvvəlki sürücü məlumatlarını təmizləyir
      entries = []; // Əvvəlki qeydləri təmizləyir
      _hasSearched = true; // Axtarış edildiyini qeyd edir
      // Yüklənmə indikatoru əlavə etmək istəsəniz, burada `isLoading = true;` kimi bir state dəyişəni təyin edə bilərsiniz
    });

    // Firestore-dan 'drivers' kolleksiyasının bütün sənədlərini alır
    final querySnapshot = await FirebaseFirestore.instance.collection('drivers').get();

    bool found = false; // Sürücünün tapılıb-tapılmadığını izləyən flag
    for (final doc in querySnapshot.docs) { // Hər sənəd üzərində dövr edir
      final data = doc.data(); // Sənədin məlumatlarını alır
      final entryList = List<Map<String, dynamic>>.from(data['entries'] ?? []); // Sürücünün giriş qeydlərini alır

      bool match = false; // Uyğunluq flagı
      switch (selectedSearchType) { // Seçilmiş axtarış növünə əsasən yoxlama edir
        case 'fin':
          match = data['fin']?.toString().toUpperCase() == value; // FİN kodu uyğunluğunu yoxlayır
          break;
        case 'sv':
          match = data['sv']?.toString().toUpperCase() == value; // SV nömrəsi uyğunluğunu yoxlayır
          break;
        case 'phone':
          match = data['phone']?.toString().toUpperCase() == value; // Telefon nömrəsi uyğunluğunu yoxlayır
          break;
        case 'fullname':
        // ✅ DƏYİŞDİ: "Ad Soyad Ata adı" axtarışı üçün uyğunluq məntiqi dəyişdirildi.
        // Ad və Soyad uyğunluğu məcburi, Ata adı isə əlavə (isteğe bağlı) olaraq yoxlanılır.
          final driverName = data['name']?.toString().toLowerCase();
          final driverSurname = (data['surname'] ?? '').toString().trim().toLowerCase(); // ✅ DƏYİŞDİ: `surnameController` istifadə edildi
          final driverFatherName = data['fatherName']?.toString().toLowerCase();

          // Ad və Soyad uyğunluğu əsas şərtdir.
          bool nameSurnameMatch = (driverName == name) && (driverSurname == surname);

          if (nameSurnameMatch) {
            if (fatherName.isNotEmpty) {
              // Əgər ata adı daxil edilibsə, hər üçü uyğun olmalıdır.
              match = (driverFatherName == fatherName);
            } else {
              // Ata adı daxil edilməyibsə, yalnız ad və soyadın uyğunluğu kifayətdir.
              match = true;
            }
          }
          break;
      }

      if (match) { // Əgər uyğunluq tapılarsa
        setState(() {
          driver = data; // Tapılan sürücü məlumatlarını saxlayır
          entries = entryList; // Sürücünün qeydlərini saxlayır
          found = true; // Tapıldı flagını true edir
        });
        break; // Nəticə tapıldıqda dövrü dayandırır
      }
    }

    if (!found) { // Əgər axtarışdan sonra sürücü tapılmasa
      setState(() {
        driver = null; // driver dəyişənini null edir
      });
    }

    // Axtarış prosesi bitəndə (əgər `isLoading` istifadə olunursa, burada `isLoading = false;` olmalıdır)
  }

  // Sürücünün problemli olub-olmadığını yoxlayan getter
  bool get isProblematic =>
      entries.any((entry) => entry['status'] == 'Problemli'); // Hər hansı bir girişdə status 'Problemli' olarsa true qaytarır

  // Özelleşdirilmiş mətn sahəsi (TextField) widget-i
  Widget _buildStyledTextField({
    required TextEditingController controller, // Mətn sahəsinin kontroleri
    required String label, // Mətn sahəsinin etiketi
    TextInputType keyboardType = TextInputType.text, // Klaviatura növü (defolt olaraq mətn)
    String? prefixText, // Prefiks mətni
    int maxLines = 1, // Maksimum sətir sayı
    bool obscureText = false, // Mətnin gizlədilməsi (şifrə sahəsi üçün)
    String? hintText, // İpucu mətni
    VoidCallback? onTap, // Mətn sahəsinə toxunulduqda işə düşəcək funksiya
    TextCapitalization textCapitalization = TextCapitalization.none, // Mətnin avtomatik böyük hərflə başlaması
  }) {
    return Container( // Konteyner widget-i
      decoration: BoxDecoration( // Konteynerin bəzəyi
        color: Colors.white.withOpacity(0.15), // Yarı-şəffaf fon rəngi
        borderRadius: BorderRadius.circular(12), // Kənar radiusu
        boxShadow: [ // Kölgə effekti
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Kölgə rəngi
            blurRadius: 10, // Kölgənin bulanıqlığı
            offset: const Offset(0, 5), // Kölgənin ofseti
          ),
        ],
      ),
      child: TextField( // Mətn sahəsi widget-i
        controller: controller, // Kontroler
        keyboardType: keyboardType, // Klaviatura növü
        maxLines: obscureText ? 1 : maxLines, // Maksimum sətir sayı (şifrədirsə 1, əks halda verilən dəyər)
        obscureText: obscureText, // Mətnin gizlədilməsi
        style: const TextStyle(color: Colors.white, fontSize: 16), // Mətn stili (rəngi ağ)
        textCapitalization: textCapitalization, // Mətnin avtomatik böyük hərflə başlaması
        decoration: InputDecoration( // Mətn sahəsinin bəzəyi
          labelText: label, // Etiket mətni
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)), // Etiket mətni stili
          hintText: hintText, // İpucu mətni
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)), // İpucu mətni stili
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // İçəridən boşluq
          border: InputBorder.none, // Sərhədi ləğv edir
          enabledBorder: InputBorder.none, // Aktiv sərhədi ləğv edir
          focusedBorder: OutlineInputBorder( // Fokuslanmış sərhəd
            borderRadius: BorderRadius.circular(12), // Kənar radiusu
            borderSide: BorderSide(color: Colors.white.withOpacity(0.8), width: 2), // Fokuslanmış zaman ağ sərhəd
          ),
          prefixText: prefixText, // Prefiks mətni
          // ✅ DƏYİŞDİ: TextField üçün "x" təmizləmə düyməsi əlavə edildi
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.7)),
            onPressed: () {
              controller.clear();
              // Həm də axtarış nəticələrini təmizləyə bilərik, əgər istifadəçi axtarış xanasını təmizləyirsə
              setState(() {
                driver = null;
                entries = [];
                _hasSearched = false;
              });
            },
          )
              : null,
        ),
        onTap: onTap, // Mətn sahəsinə toxunulduqda işə düşəcək funksiya
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // Lokalizasiya obyektini alır
    final user = FirebaseAuth.instance.currentUser; // Cari istifadəçi məlumatlarını alır

    return Scaffold( // Scaffold widget-i, əsas vizual quruluşu təmin edir
      resizeToAvoidBottomInset: true, // ✅ DƏYİŞDİ: Klaviatura açıldığında layoutu avtomatik tənzimləsin
      body: Stack( // Uşaq widget-ları üst-üstə yerləşdirmək üçün Stack widget-i
        fit: StackFit.expand, // Stack-i bütün mövcud sahəyə yayır
        children: [
          // Canlı rəngli gradient fon
          Container( // Fon üçün Konteyner
            decoration: const BoxDecoration( // Konteynerin bəzəyi
              gradient: LinearGradient( // Xətti gradient
                colors: [
                  Color(0xFF8A2BE2), // Mavi Bənövşəyi
                  Color(0xFFDA70D6), // Orchid
                  Color(0xFFFF69B4), // Hot Pink
                ],
                begin: Alignment.topLeft, // Gradientin başlanğıc nöqtəsi
                end: Alignment.bottomRight, // Gradientin son nöqtəsi
              ),
            ),
          ),
          // Şüşə effekti
          BackdropFilter( // Arxa fonu bulanıqlaşdırmaq üçün BackdropFilter
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Daha güclü bulanıqlıq (blur)
            child: Container( // Bulanık fonun üzərindəki overlay Konteyner
              color: Colors.black.withOpacity(0.2), // Yarı-şəffaf qara overlay
            ),
          ),
          // Scrollable content
          Column( // Şaquli istiqamətdə uşaq widget-ları yerləşdirmək üçün Sütun
            children: [
              AppBar( // Tətbiq çubuğu (AppBar)
                backgroundColor: Colors.transparent, // Şəffaf fon
                elevation: 0, // Kölgəni ləğv edir
                title: Text( // Başlıq mətni
                  loc.searchTitle, // Lokalizasiyadan alınan axtarış başlığı
                  style: const TextStyle( // Mətn stili
                    color: Colors.white, // Mətn rəngi ağ
                    fontWeight: FontWeight.bold, // Qalın şrift
                    fontSize: 22, // Şrift ölçüsü
                    shadows: [ // Mətn kölgəsi
                      Shadow(
                        blurRadius: 5.0, // Kölgənin bulanıqlığı
                        color: Colors.black38, // Kölgə rəngi
                        offset: Offset(1.0, 1.0), // Kölgənin ofseti
                      ),
                    ],
                  ),
                ),
                centerTitle: true, // Başlığı mərkəzə yerləşdirir
                iconTheme: const IconThemeData(color: Colors.white), // Geri düyməsinin rəngi ağ
              ),
              Expanded( // Qalan sahəni doldurmaq üçün Expanded widget-i
                child: SingleChildScrollView( // Məzmunun sürüşdürülə bilən olması üçün
                  padding: const EdgeInsets.all(24), // İçəridən bütün tərəflərdən boşluq
                  child: Column( // Sürüşdürülə bilən məzmun üçün Sütun
                    children: [
                      Container( // Axtarış növü seçimi üçün Konteyner
                        decoration: BoxDecoration( // Konteynerin bəzəyi
                          color: Colors.white.withOpacity(0.15), // Yarı-şəffaf fon
                          borderRadius: BorderRadius.circular(12), // Kənar radiusu
                          boxShadow: [ // Kölgə
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: DropdownButtonFormField<String>( // Açılan menyu
                          value: selectedSearchType, // Seçilmiş dəyər
                          decoration: InputDecoration( // Bəzək
                            labelText: loc.searchType, // Etiket mətni
                            labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)), // Etiket stili
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)), // İpucu stili
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // İçəridən boşluq
                            border: InputBorder.none, // Sərhədi ləğv edir
                            enabledBorder: InputBorder.none, // Aktiv sərhədi ləğv edir
                            focusedBorder: OutlineInputBorder( // Fokuslanmış sərhəd
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.8), width: 2),
                            ),
                          ),
                          dropdownColor: Colors.black.withOpacity(0.7), // Açılan menyunun fon rəngi
                          style: const TextStyle(color: Colors.white, fontSize: 16), // Menyudakı mətn stili
                          icon: Icon(Icons.arrow_drop_down, color: Colors.white.withOpacity(0.7)), // Açılan menyu ikonu
                          items: searchTypes.entries // Menyudakı elementlər
                              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(color: Colors.white))))
                              .toList(),
                          onChanged: (val) { // Dəyər dəyişdikdə
                            if (val != null) {
                              setState(() { // Vəziyyəti yeniləyir
                                selectedSearchType = val; // Seçilmiş axtarış növünü yeniləyir
                                searchController.clear(); // Axtarış sahəsini təmizləyir
                                nameController.clear(); // Ad sahəsini təmizləyir
                                surnameController.clear(); // Soyad sahəsini təmizləyir
                                fatherNameController.clear(); // Ata adı sahəsini təmizləyir
                                _hasSearched = false; // Axtarış nəticəsini sıfırlayır
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 16), // Boşluq
                      if (selectedSearchType != 'fullname') // Axtarış növü 'fullname' deyilsə
                        _buildStyledTextField( // Tek mətn sahəsi
                          controller: searchController, // Kontroler
                          label: getHintText(), // Etiket
                          hintText: getHintText(), // İpucu
                          textCapitalization: TextCapitalization.characters, // Mətnin böyük hərflərlə yazılması
                        ),
                      if (selectedSearchType == 'fullname') ...[ // Axtarış növü 'fullname' olarsa
                        _buildStyledTextField( // Ad sahəsi
                          controller: nameController, // Kontroler
                          label: 'Ad', // Etiket
                          hintText: 'Ad daxil edin', // İpucu
                          textCapitalization: TextCapitalization.words, // ✅ DƏYİŞDİ: Hər sözün birinci hərfi böyük olacaq
                        ),
                        const SizedBox(height: 12), // Boşluq
                        _buildStyledTextField( // Soyad sahəsi
                          controller: surnameController, // Kontroler
                          label: 'Soyad', // Etiket
                          hintText: 'Soyad daxil edin', // İpucu
                          textCapitalization: TextCapitalization.words, // ✅ DƏYİŞDİ: Hər sözün birinci hərfi böyük olacaq
                        ),
                        const SizedBox(height: 12), // Boşluq
                        _buildStyledTextField( // Ata adı sahəsi
                          controller: fatherNameController, // Kontroler
                          label: 'Ata adı', // Etiket
                          hintText: 'Ata adı daxil edin', // İpucu
                          textCapitalization: TextCapitalization.words, // ✅ DƏYİŞDİ: Hər sözün birinci hərfi böyük olacaq
                        ),
                      ],
                      const SizedBox(height: 16), // Boşluq
                      Container( // Axtarış düyməsi üçün Konteyner
                        decoration: BoxDecoration( // Konteynerin bəzəyi
                          gradient: const LinearGradient( // Xətti gradient
                            colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)], // Canlı yaşıl gradient rəngləri
                            begin: Alignment.centerLeft, // Gradientin başlanğıc nöqtəsi
                            end: Alignment.centerRight, // Gradientin son nöqtəsi
                          ),
                          borderRadius: BorderRadius.circular(30), // Kənar radiusu
                          boxShadow: [ // Kölgə
                            BoxShadow(
                              color: Colors.green.withOpacity(0.4), // Yaşıl kölgə rəngi
                              blurRadius: 15, // Kölgənin bulanıqlığı
                              spreadRadius: 5, // Kölgənin yayılması
                              offset: const Offset(0, 8), // Kölgənin ofseti
                            ),
                          ],
                        ),
                        child: ElevatedButton( // Yüksəldilmiş düymə
                          onPressed: performSearch, // Düyməyə basıldıqda performSearch funksiyasını çağırır
                          style: ElevatedButton.styleFrom( // Düymənin stili
                            backgroundColor: Colors.transparent, // Gradient üçün şəffaf fon
                            foregroundColor: Colors.white, // Mətn rəngi ağ
                            minimumSize: const Size(double.infinity, 55), // Daha böyük düymə ölçüsü
                            shape: RoundedRectangleBorder( // Düymənin forması
                              borderRadius: BorderRadius.circular(30), // Kənar radiusu
                            ),
                            elevation: 0, // Kölgəni Container verir
                            padding: EdgeInsets.zero, // Padding Container-də idarə olunur
                          ),
                          child: Text( // Düymənin mətni
                            loc.search, // Lokalizasiyadan alınan 'axtarış' mətni
                            style: const TextStyle( // Mətn stili
                              fontSize: 18, // Şrift ölçüsü
                              fontWeight: FontWeight.bold, // Qalın şrift
                              letterSpacing: 1, // Hərf aralığı
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24), // Boşluq

                      // İlk dəfə yüklənəndə və axtarış edilməyibsə göstərilən mətn
                      if (!_hasSearched) // Əgər axtarış edilməyibsə
                        FutureBuilder<DocumentSnapshot>( // Asinxron məlumatları göstərmək üçün FutureBuilder
                          future: FirebaseFirestore.instance // Firestore instance
                              .collection('users') // 'users' kolleksiyası
                              .doc(user?.uid) // Cari istifadəçinin UID-si ilə sənəd
                              .get(), // Sənədi alır
                          builder: (context, snapshot) { // Builder funksiyası
                            if (snapshot.connectionState == ConnectionState.waiting) { // Əgər məlumat gözlənilirsə
                              return const CircularProgressIndicator(color: Colors.white); // Yüklənmə indikatoru göstərir
                            }
                            final userName = snapshot.data?.get('name') ?? ''; // İstifadəçi adını alır
                            return ClipRRect( // Kənar radiusu ilə kəsmək üçün ClipRRect
                              borderRadius: BorderRadius.circular(15.0), // Kənar radiusu
                              child: BackdropFilter( // Şüşə effekti
                                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0), // Bulanıqlıq
                                child: Container( // Məlumat mətni üçün Konteyner
                                  padding: const EdgeInsets.all(16), // İçəridən boşluq
                                  margin: const EdgeInsets.only(bottom: 16), // Aşağıdan boşluq
                                  decoration: BoxDecoration( // Konteynerin bəzəyi
                                    color: Colors.white.withOpacity(0.15), // Yarı-şəffaf fon
                                    borderRadius: BorderRadius.circular(15.0), // Kənar radiusu
                                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.0), // Sərhəd
                                    boxShadow: [ // Kölgə
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 15,
                                        spreadRadius: 5,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: RichText( // Zəngin mətn
                                    textAlign: TextAlign.center, // Mətni mərkəzə yerləşdirir
                                    text: TextSpan( // Mətn hissələri
                                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, height: 1.4, shadows: const [
                                        Shadow(blurRadius: 2.0, color: Colors.black38, offset: Offset(0.5, 0.5)),
                                      ]),
                                      children: [
                                        const TextSpan(text: "Qeyd:", style: TextStyle(fontWeight: FontWeight.bold)), // Qeyd mətni
                                        const TextSpan(text: " Salam "), // Salam mətni
                                        TextSpan(text: userName, style: const TextStyle(fontWeight: FontWeight.bold)), // İstifadəçi adı
                                        const TextSpan(text: ", axtarış zamanı sürücülər barəsində bazada məlumatlar tam olmadığı üçün məsləhət görülür ki, axtarış verərkən hər zaman ilk öncə "),
                                        const TextSpan(text: "FİN", style: TextStyle(fontWeight: FontWeight.bold)),
                                        const TextSpan(text: " nömrəsi, sonra "),
                                        const TextSpan(text: "SV", style: TextStyle(fontWeight: FontWeight.bold)),
                                        const TextSpan(text: " nömrəsi, sonra "),
                                        const TextSpan(text: "Ad Soyad Ata adı", style: TextStyle(fontWeight: FontWeight.bold)),
                                        const TextSpan(text: ", daha sonra mobil nömrə ilə axtarasınız. Axtar düyməsini sıxdıqdan sonra nəticə ekranda görünənə qədər gözləyin. "),
                                        const TextSpan(text: "FİN", style: TextStyle(fontWeight: FontWeight.bold)),
                                        const TextSpan(text: ", xanasına "),
                                        const TextSpan(text: "Seriya nömrəsidə", style: TextStyle(fontWeight: FontWeight.bold)),
                                        const TextSpan(text: ", əlavə etsəniz NƏTİCƏ verəcək."),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                      if (_hasSearched && driver == null) // Əgər axtarış edilibsə və sürücü tapılmayıbsa
                        Column( // Nəticə yoxdur mesajı üçün Sütun
                          children: [
                            const SizedBox(height: 40), // Boşluq
                            Text("Nəticə yoxdur", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, shadows: [
                              Shadow(blurRadius: 5.0, color: Colors.black38, offset: Offset(1.0, 1.0)),
                            ])), // Başlıq
                            const SizedBox(height: 10), // Boşluq
                            Text( // Məlumat mətni
                              "Qeyd: Bazada bu sürücü barəsində məlumatlar əlavə edilməyib. Zəhmət olmasa Siz əlavə edərdiniz. Təşəkkürlər 🙂",
                              style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.7), shadows: [
                                Shadow(blurRadius: 2.0, color: Colors.black38, offset: Offset(0.5, 0.5)),
                              ]),
                              textAlign: TextAlign.center, // Mətni mərkəzə yerləşdirir
                            ),
                          ],
                        ),

                      if (driver != null) // Əgər sürücü tapılarsa
                        Column( // Sürücü məlumatları üçün Sütun
                          crossAxisAlignment: CrossAxisAlignment.start, // Məzmunu sola hizalayır
                          children: [
                            ClipRRect( // Kənar radiusu ilə kəsmək üçün ClipRRect
                              borderRadius: BorderRadius.circular(15.0), // Kənar radiusu
                              child: BackdropFilter( // Şüşə effekti
                                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0), // Bulanıqlıq
                                child: Container( // Sürücü məlumatları kartı üçün Konteyner
                                  padding: const EdgeInsets.all(16), // İçəridən boşluq
                                  decoration: BoxDecoration( // Konteynerin bəzəyi
                                    color: Colors.white.withOpacity(0.15), // Yarı-şəffaf fon
                                    borderRadius: BorderRadius.circular(15.0), // Kənar radiusu
                                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.0), // Sərhəd
                                    boxShadow: [ // Kölgə
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 15,
                                        spreadRadius: 5,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column( // Məlumatları şaquli yerləşdirmək üçün Sütun
                                    crossAxisAlignment: CrossAxisAlignment.start, // Məzmunu sola hizalayır
                                    children: [
                                      Center( // Avatarı mərkəzə yerləşdirir
                                        child: Container( // Avatar üçün Konteyner
                                          height: 80, // Hündürlük
                                          width: 80, // En
                                          decoration: BoxDecoration( // Bəzək
                                            shape: BoxShape.circle, // Dairəvi forma
                                            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2), // Sərhəd
                                            boxShadow: [ // Kölgə
                                              BoxShadow(
                                                color: Colors.white.withOpacity(0.2),
                                                blurRadius: 10,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                            image: driver!['photoUrl'] != null && driver!['photoUrl'] != "" // Əgər foto URL-i varsa
                                                ? DecorationImage( // Şəkil göstərir
                                              image: CachedNetworkImageProvider(driver!['photoUrl']), // Keşlənmiş şəbəkə şəkli
                                              fit: BoxFit.cover, // Şəkli konteynerə uyğunlaşdırır
                                            )
                                                : null, // Yoxsa null
                                          ),
                                          child: driver!['photoUrl'] == null || driver!['photoUrl'] == "" // Əgər foto URL-i yoxsa
                                              ? Icon(Icons.person, size: 40, color: Colors.white.withOpacity(0.7)) // Default ikon göstərir
                                              : null, // Yoxsa null
                                        ),
                                      ),
                                      const SizedBox(height: 12), // Boşluq
                                      Text( // Sürücünün tam adı
                                        '${driver!['name']} ${driver!['surname']} ${driver!['fatherName'] ?? ''} oğlu',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, shadows: [
                                          Shadow(blurRadius: 5.0, color: Colors.black38, offset: Offset(1.0, 1.0)),
                                        ]),
                                      ),
                                      const SizedBox(height: 4), // Boşluq
                                      // ✅ DƏYİŞDİ: FİN və SV nömrələri gizlədildi.
                                      // Text('FİN: ${driver!['fin']}', style: TextStyle(color: Colors.white.withOpacity(0.8))), // FİN məlumatı
                                      // Text('SV nömrəsi: ${driver!['sv'] ?? "-"}', style: TextStyle(color: Colors.white.withOpacity(0.8))), // SV nömrəsi məlumatı
                                      Text('Telefon nömrəsi: +994${driver!['phone'] ?? "-"}', style: TextStyle(color: Colors.white.withOpacity(0.8))), // Telefon nömrəsi məlumatı
                                      const SizedBox(height: 8), // Boşluq
                                      Text( // Status məlumatı
                                        isProblematic ? 'Status: Problemli' : 'Status: Problemsiz', // Statusa görə mətn
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold, // Qalın şrift
                                          color: isProblematic ? Colors.redAccent : Colors.greenAccent, // Statusa görə rəng
                                          shadows: const [
                                            Shadow(blurRadius: 5.0, color: Colors.black38, offset: Offset(1.0, 1.0)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16), // Boşluq
                                      const Text( // Fəaliyyət yerləri başlığı
                                        'Fəaliyyət yerləri',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, shadows: [
                                          Shadow(blurRadius: 5.0, color: Colors.black38, offset: Offset(1.0, 1.0)),
                                        ]),
                                      ),
                                      const SizedBox(height: 8), // Boşluq
                                      ...entries.map((entry) { // Giriş qeydləri üzərində dövr edir
                                        final entryStatus = entry['status'] ?? ''; // Giriş statusu
                                        final reason = entryStatus == 'Problemli' ? ' (${entry['reason']})' : ''; // Problemli səbəbi
                                        return ClipRRect( // Kənar radiusu ilə kəsmək üçün ClipRRect
                                          borderRadius: BorderRadius.circular(12), // Kənar radiusu
                                          child: BackdropFilter( // Şüşə effekti
                                            filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0), // Bulanıqlıq
                                            child: Container( // Hər bir giriş qeydi üçün Konteyner
                                              margin: const EdgeInsets.only(bottom: 12), // Aşağıdan boşluq
                                              padding: const EdgeInsets.all(12), // İçəridən boşluq
                                              decoration: BoxDecoration( // Bəzək
                                                color: Colors.white.withOpacity(0.1), // Daha şəffaf fon
                                                borderRadius: BorderRadius.circular(12), // Kənar radiusu
                                                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0), // Sərhəd
                                                boxShadow: [ // Kölgə
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.1),
                                                    blurRadius: 10,
                                                    spreadRadius: 2,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Column( // Məlumatları şaquli yerləşdirmək üçün Sütun
                                                crossAxisAlignment: CrossAxisAlignment.start, // Məzmunu sola hizalayır
                                                children: [
                                                  Text('Park: ${entry['park']}', style: TextStyle(color: Colors.white.withOpacity(0.8))), // Park adı
                                                  Text('Status: ${entry['status']}$reason', style: TextStyle(color: Colors.white.withOpacity(0.8))), // Status və səbəb
                                                  Text('Sahibkar: ${entry['owner']}', style: TextStyle(color: Colors.white.withOpacity(0.8))), // Sahibkar
                                                  Text('Əlaqə: +994${entry['ownerPhone'] ?? "-"}', style: TextStyle(color: Colors.white.withOpacity(0.8))), // Sahibkar əlaqə
                                                  Text('Əlavə etdiyi tarix: ${_formatDate(entry['date'])}', style: TextStyle(color: Colors.white.withOpacity(0.8))), // Əlavə edilmə tarixi
                                                  Text('Qeyd: ${entry['note'] ?? "-"}', style: TextStyle(color: Colors.white.withOpacity(0.8))), // Qeyd
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Tarix formatını düzəldən funksiya
  String _formatDate(dynamic date) {
    try {
      if (date is Timestamp) { // Əgər dəyər Timestamp tipindədirsə
        final d = date.toDate(); // Tarixi Date obyektinə çevirir
        return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}'; // Formatlaşdırılmış tarixi qaytarır
      }
      return date.toString(); // Başqa halda dəyəri string olaraq qaytarır
    } catch (_) { // Xəta baş verərsə
      return "-"; // "-" qaytarır
    }
  }
}
