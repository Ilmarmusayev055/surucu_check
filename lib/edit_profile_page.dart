import 'dart:io'; // Fayl əməliyyatları üçün (şəkil seçimi)
import 'package:flutter/material.dart'; // Flutter Material dizayn komponentləri üçün paket
import 'package:image_picker/image_picker.dart'; // Şəkil seçmək üçün paket
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication xidməti üçün paket
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore verilənlər bazası ilə əlaqə üçün paket
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage (fayl saxlama) xidməti üçün paket
import 'package:surucu_check/l10n/app_localizations.dart'; // Lokalizasiya (dil dəstəyi) üçün paket
import 'package:cached_network_image/cached_network_image.dart'; // Şəbəkədən şəkilləri keşləmək və göstərmək üçün paket
import 'dart:ui'; // ImageFilter kimi UI effektləri üçün dart:ui kitabxanası

// EditProfilePage dövlətli (stateful) widget-ıdır.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key}); // Konstanta konstruktor

  @override
  State<EditProfilePage> createState() => _EditProfilePageState(); // Widget üçün State obyekti yaradır
}

// _EditProfilePageState State obyekti EditProfilePage-in vəziyyətini idarə edir.
class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController(); // Ad sahəsi üçün TextEditingController
  final TextEditingController surnameController = TextEditingController(); // Soyad sahəsi üçün TextEditingController
  final TextEditingController parkController = TextEditingController(); // Park adı sahəsi üçün TextEditingController

  String? selectedPosition; // Seçilmiş vəzifə
  File? profileImage; // Yeni seçilmiş profil şəkli faylı
  String? imageUrl; // Cari profil şəklinin URL-i

  final List<String> positions = [ // Vəzifə seçimləri siyahısı
    'Park müdürü',
    'Sahibkar',
    'Müavin',
    'Qaraj müdürü',
    'Mühasib',
  ];

  @override
  void initState() {
    super.initState(); // Üst sinifin initState metodunu çağırır
    loadUserData(); // İstifadəçi məlumatlarını yükləyir
  }

  // İstifadəçi məlumatlarını Firestore-dan yükləyən asinxron funksiya
  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser; // Cari istifadəçini alır
    if (user != null) { // Əgər istifadəçi daxil olubsa
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get(); // İstifadəçi sənədini alır
      if (doc.exists) { // Əgər sənəd mövcuddursa
        final data = doc.data()!; // Sənədin məlumatlarını alır
        nameController.text = data['name'] ?? ''; // Adı ilkinləşdirir
        surnameController.text = data['surname'] ?? ''; // Soyadı ilkinləşdirir
        parkController.text = data['park'] ?? ''; // Park adını ilkinləşdirir
        selectedPosition = data['position']; // Vəzifəni ilkinləşdirir
        imageUrl = data['profileImage']; // Şəkil URL-ni ilkinləşdirir
        setState(() {}); // UI-ı yeniləyir
      }
    }
  }

  // Şəkil seçmək üçün funksiya (kamera və ya qalereya)
  Future<void> pickImage({required bool fromCamera}) async {
    final picker = ImagePicker(); // ImagePicker obyekti yaradır
    final XFile? picked = await picker.pickImage( // Şəkil seçir
      source: fromCamera ? ImageSource.camera : ImageSource.gallery, // Mənbəni təyin edir
    );

    if (picked != null) { // Əgər şəkil seçilibsə
      setState(() {
        profileImage = File(picked.path); // Seçilmiş şəkli saxlayır
      });
    }
  }

  // Şəkil mənbəyi seçimi dialoqunu göstərən funksiya
  void showImageSourceDialog() {
    final loc = AppLocalizations.of(context)!; // Lokalizasiya obyektini alır
    showModalBottomSheet( // Aşağıdan açılan modal göstərir
      backgroundColor: Colors.transparent, // Şəffaf fon
      context: context, // Cari kontekst
      builder: (_) => SafeArea( // Təhlükəsiz sahəni təmin edir
        child: ClipRRect( // Kənar radiusu ilə kəsmək üçün
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)), // Üst küncləri yuvarlaq
          child: BackdropFilter( // Şüşə effekti
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Bulanıqlıq
            child: Container(
              decoration: BoxDecoration( // Konteynerin bəzəyi
                color: Colors.black.withOpacity(0.3), // Yarı-şəffaf qara fon
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)), // Üst küncləri yuvarlaq
              ),
              child: Wrap( // Məzmunu sətirə uyğunlaşdırır
                children: [
                  ListTile( // Kamera ilə çəkmək üçün seçim
                    leading: const Icon(Icons.photo_camera, color: Colors.greenAccent), // İkon
                    title: Text(loc.takePhoto, style: const TextStyle(color: Colors.white, fontSize: 18)), // Başlıq
                    onTap: () { // Toxunulduqda
                      Navigator.pop(context); // Modalı bağlayır
                      pickImage(fromCamera: true); // Kameradan şəkil seçir
                    },
                  ),
                  ListTile( // Qalereyadan seçmək üçün seçim
                    leading: const Icon(Icons.photo_library, color: Colors.blueAccent), // İkon
                    title: Text(loc.chooseFromGallery, style: const TextStyle(color: Colors.white, fontSize: 18)), // Başlıq
                    onTap: () { // Toxunulduqda
                      Navigator.pop(context); // Modalı bağlayır
                      pickImage(fromCamera: false); // Qalereyadan şəkil seçir
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Profil məlumatlarını yadda saxlamaq üçün asinxron funksiya
  Future<void> saveProfile() async {
    final user = FirebaseAuth.instance.currentUser; // Cari istifadəçini alır
    if (user == null) return; // İstifadəçi yoxdursa çıxır

    String? uploadedUrl = imageUrl; // Yüklənəcək şəkil URL-i (əvvəlki URL)

    if (profileImage != null) { // Əgər yeni profil şəkli seçilibsə
      final ref = FirebaseStorage.instance.ref().child('profile_images/${user.uid}.jpg'); // Faylın yolu
      await ref.putFile(profileImage!); // Şəkli Firebase Storage-a yükləyir
      uploadedUrl = await ref.getDownloadURL(); // Yüklənmiş şəklin URL-ni alır
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({ // Firestore sənədini yeniləyir
      'name': nameController.text.trim(), // Adı yeniləyir
      'surname': surnameController.text.trim(), // Soyadı yeniləyir
      'park': parkController.text.trim(), // Park adını yeniləyir
      'position': selectedPosition, // Vəzifəni yeniləyir
      'profileImage': uploadedUrl, // Profil şəkli URL-ni yeniləyir
    });

    if (context.mounted) { // Kontekst hələ də mounted-dirsə
      ScaffoldMessenger.of(context).showSnackBar( // SnackBar ilə uğurlu mesaj göstərir
        SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdated)),
      );
      Navigator.pop(context); // Səhifədən çıxır
    }
  }

  // Özelleşdirilmiş mətn sahəsi (TextField) widget-i
  Widget _buildStyledTextField(TextEditingController controller, String labelText) {
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
        style: const TextStyle(color: Colors.white, fontSize: 16), // Mətn stili (rəngi ağ)
        decoration: InputDecoration( // Mətn sahəsinin bəzəyi
          labelText: labelText, // Etiket mətni
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)), // Etiket mətni stili
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)), // İpucu mətni stili
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // İçəridən boşluq
          border: InputBorder.none, // Sərhədi ləğv edir
          enabledBorder: InputBorder.none, // Aktiv sərhədi ləğv edir
          focusedBorder: OutlineInputBorder( // Fokuslanmış sərhəd
            borderRadius: BorderRadius.circular(12), // Kənar radiusu
            borderSide: BorderSide(color: Colors.white.withOpacity(0.8), width: 2), // Fokuslanmış zaman ağ sərhəd
          ),
        ),
      ),
    );
  }

  // Özelleşdirilmiş DropdownButtonFormField widget-i
  Widget _buildStyledDropdownButtonFormField<T>({
    T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required String labelText,
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
      child: DropdownButtonFormField<T>( // Açılan menyu
        value: value, // Seçilmiş dəyər
        items: items, // Menyudakı elementlər
        onChanged: onChanged, // Dəyər dəyişdikdə
        dropdownColor: Colors.black.withOpacity(0.7), // Açılan menyunun fon rəngi
        style: const TextStyle(color: Colors.white, fontSize: 16), // Menyudakı mətn stili
        icon: Icon(Icons.arrow_drop_down, color: Colors.white.withOpacity(0.7)), // Açılan menyu ikonu
        decoration: InputDecoration( // Bəzək
          labelText: labelText, // Etiket mətni
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)), // Etiket mətni stili
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)), // İpucu mətni stili
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // İçəridən boşluq
          border: InputBorder.none, // Sərhədi ləğv edir
          enabledBorder: InputBorder.none, // Aktiv sərhədi ləğv edir
          focusedBorder: OutlineInputBorder( // Fokuslanmış sərhəd
            borderRadius: BorderRadius.circular(12), // Kənar radiusu
            borderSide: BorderSide(color: Colors.white.withOpacity(0.8), width: 2), // Fokuslanmış zaman ağ sərhəd
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // Lokalizasiya obyektini alır

    return Scaffold( // Scaffold widget-i, əsas vizual quruluşu təmin edir
      resizeToAvoidBottomInset: false, // Klaviatura açıldığında layoutu dəyişməmək üçün
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
          Column( // Səhifənin əsas məzmunu üçün Sütun
            children: [
              AppBar( // Tətbiq çubuğu (AppBar)
                backgroundColor: Colors.transparent, // Şəffaf fon
                elevation: 0, // Kölgəni ləğv edir
                title: Text( // Başlıq mətni
                  loc.editProfile, // Lokalizasiyadan alınan redaktə profili başlığı
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
                      GestureDetector( // Şəkil seçmək üçün toxunma sahəsi
                        onTap: showImageSourceDialog, // Toxunulduqda şəkil mənbəyi dialoqunu göstərir
                        child: Stack( // Şəkil və redaktə ikonu üçün Stack
                          alignment: Alignment.bottomRight, // İkonu aşağı sağ küncə yerləşdirir
                          children: [
                            Container( // Profil şəkli üçün konteyner
                              height: 120, // Hündürlük
                              width: 120, // En
                              decoration: BoxDecoration( // Bəzək
                                shape: BoxShape.circle, // Dairəvi forma
                                border: Border.all(color: Colors.white.withOpacity(0.7), width: 3), // Kənar
                                boxShadow: [ // Kölgə
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 15,
                                    spreadRadius: 5,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                                image: profileImage != null // Əgər yeni profil şəkli seçilibsə
                                    ? DecorationImage(image: FileImage(profileImage!), fit: BoxFit.cover) // Fayldan şəkil göstər
                                    : (imageUrl != null && imageUrl!.isNotEmpty // Əgər şəkil URL-i varsa və boş deyilsə
                                    ? DecorationImage(image: CachedNetworkImageProvider(imageUrl!), fit: BoxFit.cover) // Şəbəkədən şəkil göstər
                                    : const DecorationImage(image: AssetImage('assets/profile.png'), fit: BoxFit.cover)), // Default şəkil göstər
                              ),
                            ),
                            Container( // Redaktə ikonu üçün konteyner
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.8), // Ağ fon
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 5,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(8), // İçəridən boşluq
                              child: const Icon(Icons.edit, size: 20, color: Color(0xFF8A2BE2)), // İkon (rəngi mavi-bənövşəyi)
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32), // Boşluq
                      _buildStyledTextField(nameController, loc.name), // Ad sahəsi
                      const SizedBox(height: 16), // Boşluq
                      _buildStyledTextField(surnameController, loc.surname), // Soyad sahəsi
                      const SizedBox(height: 16), // Boşluq
                      _buildStyledTextField(parkController, loc.parkName), // Park adı sahəsi
                      const SizedBox(height: 16), // Boşluq
                      _buildStyledDropdownButtonFormField<String>( // Vəzifə seçimi
                        value: selectedPosition,
                        labelText: loc.position,
                        items: positions
                            .map((role) => DropdownMenuItem(value: role, child: Text(role, style: const TextStyle(color: Colors.white))))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedPosition = val; // Vəzifəni yeniləyir
                          });
                        },
                      ),
                      const SizedBox(height: 32), // Boşluq
                      Container( // Dəyişiklikləri yadda saxla düyməsi üçün Konteyner
                        width: double.infinity, // Genişliyi tam edir
                        decoration: BoxDecoration( // Bəzək
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)], // Canlı yaşıl gradient
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(30), // Kənar radiusu
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.4), // Yaşıl kölgə
                              blurRadius: 15,
                              spreadRadius: 5,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton( // Yüksəldilmiş düymə
                          onPressed: saveProfile, // Düyməyə basıldıqda saveProfile funksiyasını çağırır
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
                            loc.saveChanges, // Lokalizasiyadan alınan 'dəyişiklikləri yadda saxla' mətni
                            style: const TextStyle( // Mətn stili
                              fontSize: 18, // Şrift ölçüsü
                              fontWeight: FontWeight.bold, // Qalın şrift
                              letterSpacing: 1, // Hərf aralığı
                            ),
                          ),
                        ),
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
}
