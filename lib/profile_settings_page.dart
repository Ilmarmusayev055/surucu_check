import 'package:flutter/material.dart'; // Flutter Material dizayn komponentləri üçün paket
import 'package:flutter_localizations/flutter_localizations.dart'; // Lokalizasiya üçün (əgər istifadə olunursa)
import 'package:surucu_check/l10n/app_localizations.dart'; // Lokalizasiya (dil dəstəyi) üçün paket
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication xidməti üçün paket
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore verilənlər bazası ilə əlaqə üçün paket
import 'dart:ui'; // ImageFilter kimi UI effektləri üçün dart:ui kitabxanası

import 'main.dart'; // LoginPage və SurucuCheckApp üçün import
import 'edit_profile_page.dart'; // Profil redaktə səhifəsi üçün import
import 'change_password_page.dart'; // Şifrə dəyişdirmə səhifəsi üçün import
import 'utils.dart'; // utils.dart faylının daxil edilməsi (əgər mövcuddursa və metodları istifadə olunursa)


// ProfileSettingsPage dövlətli (stateful) widget-ıdır.
class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key}); // Konstanta konstruktor

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState(); // Widget üçün State obyekti yaradır
}

// _ProfileSettingsPageState State obyekti ProfileSettingsPage-in vəziyyətini idarə edir.
class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  String selectedLang = 'az'; // Seçilmiş dil (defolt olaraq 'az')

  String name = ''; // İstifadəçinin adı
  String surname = ''; // İstifadəçinin soyadı
  String park = ''; // İstifadəçinin parkı
  String position = ''; // İstifadəçinin mövqeyi

  @override
  void initState() {
    super.initState(); // Üst sinifin initState metodunu çağırır
    fetchUserData(); // İstifadəçi məlumatlarını yükləyir
  }

  // İstifadəçi məlumatlarını Firestore-dan yükləyən asinxron funksiya
  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser; // Cari istifadəçini alır
    if (user != null) { // Əgər istifadəçi daxil olubsa
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get(); // İstifadəçi sənədini alır
      if (doc.exists) { // Əgər sənəd mövcuddursa
        setState(() { // Vəziyyəti yeniləyir
          name = doc['name'] ?? ''; // Adı alır
          surname = doc['surname'] ?? ''; // Soyadı alır
          park = doc['park'] ?? ''; // Parkı alır
          position = doc['position'] ?? ''; // Mövqeyi alır
        });
      }
    }
  }

  // Dil dəyişdirmək üçün funksiya
  void _changeLanguage(String langCode) {
    setState(() { // Vəziyyəti yeniləyir
      selectedLang = langCode; // Seçilmiş dili saxlayır
      SurucuCheckApp.setLocale(context, Locale(langCode)); // Tətbiqin dilini dəyişir
      _showMessage('Dil dəyişdirildi: $langCode'); // Mesaj göstərir
    });
  }

  // İstifadəçiyə SnackBar vasitəsilə mesaj göstərən funksiya
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)), // SnackBar ilə mesaj göstərir
    );
  }

  // Çıxış (logout) funksiyası
  void _logout() {
    FirebaseAuth.instance.signOut(); // Firebase-dən çıxış edir
    Navigator.pushReplacement( // Cari səhifəni LoginPage ilə əvəz edir
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
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
                  Color(0xFF8A2BE2), // Blue Violet
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
                  loc.profileSettings, // Lokalizasiyadan alınan profil ayarları başlığı
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
                  padding: const EdgeInsets.all(16), // İçəridən bütün tərəflərdən boşluq
                  child: Column( // Sürüşdürülə bilən məzmun üçün Sütun
                    children: [
                      const SizedBox(height: 16), // Boşluq
                      name.isEmpty // Ad boşdursa (yüklənməyibsə)
                          ? const CircularProgressIndicator(color: Colors.white) // Yüklənmə indikatoru göstər
                          : Column( // Məlumatlar yüklənibsə
                        children: [
                          Text( // Ad və soyad
                            '$name $surname',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, shadows: [
                              Shadow(blurRadius: 5.0, color: Colors.black38, offset: Offset(1.0, 1.0)),
                            ]),
                          ),
                          Text( // Park və mövqe
                            '$park — $position',
                            style: TextStyle(color: Colors.white.withOpacity(0.7), shadows: const [
                              Shadow(blurRadius: 2.0, color: Colors.black38, offset: Offset(0.5, 0.5)),
                            ]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24), // Boşluq
                      _buildGlassmorphicListTile( // Profil redaktə etmə seçimi
                        leadingIcon: Icons.edit,
                        title: loc.editProfile,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EditProfilePage()),
                        ),
                      ),
                      const SizedBox(height: 10), // Boşluq
                      _buildGlassmorphicListTile( // Şifrə dəyişdirmə seçimi
                        leadingIcon: Icons.lock,
                        title: loc.changePassword,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                        ),
                      ),
                      const SizedBox(height: 10), // Boşluq
                      _buildGlassmorphicListTile( // Telefon nömrəsini dəyişmə seçimi
                        leadingIcon: Icons.phone,
                        title: loc.changePhone,
                        onTap: () => _showChangeFieldDialog(
                          context,
                          field: 'phone',
                          title: 'Telefon nömrəsini dəyiş',
                          oldLabel: 'Köhnə telefon nömrəsi',
                          newLabel: 'Yeni telefon nömrəsi',
                        ),
                      ),
                      const SizedBox(height: 10), // Boşluq
                      _buildGlassmorphicListTile( // Emaili dəyişmə seçimi
                        leadingIcon: Icons.email,
                        title: loc.changeEmail, // ✅ DƏYİŞDİ: Lokalizasiya üçün `loc.changeEmail` istifadə edildi
                        onTap: () => _showChangeFieldDialog(
                          context,
                          field: 'email',
                          title: 'Emaili dəyiş',
                          oldLabel: 'Köhnə email',
                          newLabel: 'Yeni email',
                        ),
                      ),
                      const SizedBox(height: 10), // Boşluq

                      const SizedBox(height: 10), // Boşluq
                      _buildGlassmorphicListTile( // Dil seçimi
                        leadingIcon: Icons.language,
                        title: loc.language, // Lokalizasiyadan dil başlığını alır
                        trailingWidget: DropdownButton<String>( // Dil seçimi üçün açılan menyu
                          value: selectedLang, // Seçilmiş dil
                          dropdownColor: Colors.black.withOpacity(0.7), // Açılan menyunun fon rəngi
                          style: const TextStyle(color: Colors.white, fontSize: 16), // Menyudakı mətn stili
                          icon: Icon(Icons.arrow_drop_down, color: Colors.white.withOpacity(0.7)), // Açılan menyu ikonu
                          onChanged: (String? newLang) { // Dəyər dəyişdikdə
                            if (newLang != null) {
                              _changeLanguage(newLang); // Dili dəyişir
                            }
                          },
                          items: const [ // Dil seçimləri
                            DropdownMenuItem(value: 'az', child: Text('Azərbaycan', style: TextStyle(color: Colors.white))),
                            DropdownMenuItem(value: 'en', child: Text('English', style: TextStyle(color: Colors.white))),
                            DropdownMenuItem(value: 'ru', child: Text('Русский', style: TextStyle(color: Colors.white))),
                          ],
                        ),
                        onTap: () { // Dil seçimi ListTile üçün onTap, funksionallığa təsir etmir.
                          // Bu ListTile-a toxunulduqda əlavə bir iş görmək lazım deyilsə, boş saxlamaq olar.
                          // DropdownButton-un öz onTap callback-i artıq dəyişikliyi idarə edir.
                        },
                      ),
                      const SizedBox(height: 24), // Boşluq
                      Container( // Çıxış düyməsi üçün Konteyner
                        width: double.infinity, // Genişliyi tam edir
                        decoration: BoxDecoration( // Bəzək
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE53935), Color(0xFFD32F2F)], // Qırmızı gradient
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(30), // Kənar radiusu
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.4), // Qırmızı kölgə
                              blurRadius: 15,
                              spreadRadius: 5,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon( // Yüksəldilmiş düymə (ikonlu)
                          onPressed: _logout, // Düyməyə basıldıqda çıxış funksiyasını çağırır
                          icon: const Icon(Icons.logout, color: Colors.white), // İkon
                          label: Text(loc.logout, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)), // Mətn
                          style: ElevatedButton.styleFrom( // Düymənin stili
                            backgroundColor: Colors.transparent, // Gradient üçün şəffaf fon
                            foregroundColor: Colors.white, // Mətn rəngi ağ
                            minimumSize: const Size(double.infinity, 55), // Daha böyük düymə ölçüsü
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0, // Kölgəni Container verir
                            padding: EdgeInsets.zero, // Padding Container-də idarə olunur
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

  // Şüşə effekti ilə ListTile yaradan köməkçi widget
  Widget _buildGlassmorphicListTile({
    required IconData leadingIcon,
    required String title,
    Widget? trailingWidget,
    required VoidCallback onTap,
  }) {
    return ClipRRect( // Kənar radiusu ilə kəsmək üçün
      borderRadius: BorderRadius.circular(15.0),
      child: BackdropFilter( // Şüşə effekti
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15), // Yarı-şəffaf fon
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 5,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ListTile( // Əsas siyahı elementi
            leading: Icon(leadingIcon, color: Colors.white.withOpacity(0.8), size: 28), // Sol tərəfdəki ikon
            title: Text(
              title,
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 17, shadows: const [
                Shadow(blurRadius: 2.0, color: Colors.black38, offset: Offset(0.5, 0.5)),
              ]),
            ), // Başlıq mətni
            trailing: trailingWidget, // Sağ tərəfdəki widget (məsələn, DropdownButton)
            onTap: onTap, // Toxunulduqda işə düşəcək funksiya
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), // İçəridən boşluq
          ),
        ),
      ),
    );
  }

  // Şüşə effekti ilə SwitchListTile yaradan köməkçi widget
  Widget _buildGlassmorphicSwitchListTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ClipRRect( // Kənar radiusu ilə kəsmək üçün
      borderRadius: BorderRadius.circular(15.0),
      child: BackdropFilter( // Şüşə effekti
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15), // Yarı-şəffaf fon
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 5,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SwitchListTile( // Əsas keçid siyahısı elementi
            title: Text(
              title,
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 17, shadows: const [
                Shadow(blurRadius: 2.0, color: Colors.black38, offset: Offset(0.5, 0.5)),
              ]),
            ), // Başlıq mətni
            value: value, // Keçidin cari dəyəri
            onChanged: onChanged, // Dəyər dəyişdikdə işə düşəcək funksiya
            activeColor: Colors.greenAccent, // Aktiv vəziyyətdəki rəng
            inactiveThumbColor: Colors.grey.withOpacity(0.7), // Qeyri-aktiv vəziyyətdəki baş barmaq rəngi
            inactiveTrackColor: Colors.white.withOpacity(0.3), // Qeyri-aktiv vəziyyətdəki iz rəngi
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), // İçəridən boşluq
          ),
        ),
      ),
    );
  }


  // ✅ DƏYİŞDİ: Telefon nömrəsini dəyişərkən köhnə dəyər yoxlanılır və yeni dizayna uyğunlaşdırıldı
  void _showChangeFieldDialog(
      BuildContext context, {
        required String field,
        required String title,
        required String oldLabel,
        required String newLabel,
      }) {
    final TextEditingController oldController = TextEditingController(); // Köhnə dəyər üçün kontroler
    final TextEditingController newController = TextEditingController(); // Yeni dəyər üçün kontroler
    final TextEditingController passwordController = TextEditingController(); // Şifrə üçün kontroler
    final user = FirebaseAuth.instance.currentUser; // Cari istifadəçi

    showDialog( // Dialoq göstərir
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent, // Şəffaf fon
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Şüşə effekti
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15), // Yarı-şəffaf ağ fon
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Məzmun ölçüsünə uyğunlaşır
                children: [
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, shadows: [
                    Shadow(blurRadius: 5.0, color: Colors.black38, offset: Offset(1.0, 1.0)),
                  ])), // Dialoq başlığı
                  const SizedBox(height: 20), // Boşluq
                  _buildStyledInputField( // Köhnə dəyər sahəsi
                    controller: oldController,
                    label: oldLabel,
                    keyboardType: field == 'phone' ? TextInputType.phone : TextInputType.emailAddress,
                    onTap: () {
                      if (field == 'phone' && oldController.text.isEmpty) {
                        oldController.text = '+994'; // Telefon üçün prefiks əlavə edir
                      }
                    },
                  ),
                  const SizedBox(height: 10), // Boşluq
                  _buildStyledInputField( // Yeni dəyər sahəsi
                    controller: newController,
                    label: newLabel,
                    keyboardType: field == 'phone' ? TextInputType.phone : TextInputType.emailAddress,
                    onTap: () {
                      if (field == 'phone' && newController.text.isEmpty) {
                        newController.text = '+994'; // Telefon üçün prefiks əlavə edir
                      }
                    },
                  ),
                  if (field == 'email') ...[ // Əgər email dəyişdirilirsə, şifrə sahəsi göstər
                    const SizedBox(height: 10), // Boşluq
                    _buildStyledInputField( // Şifrə sahəsi
                      controller: passwordController,
                      label: 'Şifrə',
                      obscureText: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        actions: [
          Container( // Ləğv et düyməsi üçün konteyner
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFDA70D6), Color(0xFFFF69B4)], // Qırmızı-çəhrayı gradient
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 5,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextButton( // Ləğv et düyməsi
              child: const Text("Ləğv et", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              onPressed: () => Navigator.pop(context), // Dialoqu bağlayır
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          Container( // Yadda saxla düyməsi üçün konteyner
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)], // Canlı yaşıl gradient
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 5,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton( // Yadda saxla düyməsi
              child: const Text("Yadda saxla", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              onPressed: () async { // Düyməyə basıldıqda
                final oldValRaw = oldController.text.trim(); // Köhnə dəyəri alır
                final newValRaw = newController.text.trim(); // Yeni dəyəri alır
                final password = passwordController.text.trim(); // Şifrəni alır

                if (user == null) return; // İstifadəçi yoxdursa çıxır

                final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid); // İstifadəçi sənədinin referansını alır
                final doc = await docRef.get(); // Sənədi alır

                if (!doc.exists) { // Əgər sənəd mövcud deyilsə
                  Navigator.pop(context); // Dialoqu bağlayır
                  _showMessage("İstifadəçi tapılmadı."); // Mesaj göstərir
                  return;
                }

                String cleanedOldVal = oldValRaw.replaceAll(' ', ''); // Köhnə dəyərdən boşluqları təmizləyir
                String cleanedNewVal = newValRaw.trim(); // Yeni dəyəri təmizləyir
                String currentVal = (doc[field] ?? '').toString().replaceAll(' ', ''); // Cari dəyəri alır

                if (field == 'phone') { // Əgər sahə 'phone'dirsə
                  if (cleanedOldVal.startsWith('+994')) { // Prefiks varsa təmizləyir
                    cleanedOldVal = cleanedOldVal.replaceFirst('+994', '');
                  }
                  if (currentVal.startsWith('+994')) { // Prefiks varsa təmizləyir
                    currentVal = currentVal.replaceFirst('+994', '');
                  }
                  if (cleanedOldVal != currentVal) { // Köhnə dəyər düzgün deyilsə
                    _showMessage("Köhnə telefon nömrəsi düzgün deyil."); // Mesaj göstərir
                    return;
                  }
                  cleanedNewVal = '+994' + cleanedNewVal.replaceAll('+994', ''); // Yeni dəyərə prefiks əlavə edir
                }

                if (field == 'email') { // Əgər sahə 'email'dirsə
                  String currentEmail = user.email?.replaceAll(' ', '') ?? ''; // Cari email-i alır
                  if (cleanedOldVal.toLowerCase() != currentEmail.toLowerCase()) { // Köhnə email düzgün deyilsə
                    _showMessage("Köhnə email düzgün deyil."); // Mesaj göstərir
                    return;
                  }

                  try {
                    final credential = EmailAuthProvider.credential( // Təsdiq credential yaradır
                      email: user.email!,
                      password: password,
                    );
                    await user.reauthenticateWithCredential(credential); // İstifadəçini yenidən təsdiqləyir
                    await user.verifyBeforeUpdateEmail(cleanedNewVal); // Email dəyişikliyini təsdiqləmə linki göndərir

                    if (context.mounted) Navigator.pop(context); // Input dialoqunu bağlayır

                    showDialog( // Təsdiqləmə dialoqu göstərir
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text("Təsdiqləmə tələb olunur", style: TextStyle(color: Colors.white)),
                          content: const Text(
                            "E-poçtunuza təsdiq linki göndərildi. Təsdiq etdikdən sonra profilinizə yenidən daxil olun!", style: TextStyle(color: Colors.white70),
                          ),
                          backgroundColor: Colors.white.withOpacity(0.2), // Şəffaf fon
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          actions: [
                            TextButton(
                              child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              onPressed: () {
                                Navigator.of(dialogContext).pop(); // Təsdiqləmə dialoqunu bağlayır
                              },
                            ),
                          ],
                        );
                      },
                    );

                    return;
                  } catch (e) { // Xəta tutulduqda
                    if (context.mounted) Navigator.pop(context); // Dialoqu bağlayır
                    if (e.toString().contains('wrong-password')) { // Şifrə yanlışdırsa
                      _showMessage("Şifrə yanlışdır.");
                    } else if (e.toString().contains('requires-recent-login')) { // Yenidən daxil olmaq lazımdırsa
                      _showMessage("Email dəyişmək üçün yenidən daxil olun.");
                    } else { // Digər xətalar
                      _showMessage("Xəta baş verdi: $e");
                    }
                    return;
                  }
                }

                try {
                  await docRef.update({field: cleanedNewVal}); // Firestore sənədini yeniləyir
                  Navigator.pop(context); // Dialoqu bağlayır
                  _showMessage("$field uğurla dəyişdirildi."); // Uğurlu mesaj göstərir
                } catch (e) { // Xəta tutulduqda
                  if (context.mounted) Navigator.pop(context); // Dialoqu bağlayır
                  _showMessage("Xəta baş verdi: $e"); // Xəta mesajı göstərir
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Özelleşdirilmiş mətn sahəsi (TextField) widget-i - Dialoqlar üçün
  Widget _buildStyledInputField({
    required TextEditingController controller, // Mətn sahəsinin kontroleri
    required String label, // Mətn sahəsinin etiketi
    TextInputType keyboardType = TextInputType.text, // Klaviatura növü
    bool obscureText = false, // Mətnin gizlədilməsi
    VoidCallback? onTap, // Toxunulduqda işə düşəcək funksiya
  }) {
    return Container( // Konteyner widget-i
      decoration: BoxDecoration( // Konteynerin bəzəyi
        color: Colors.white.withOpacity(0.1), // Yarı-şəffaf fon rəngi
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
        obscureText: obscureText, // Mətnin gizlədilməsi
        style: const TextStyle(color: Colors.white, fontSize: 16), // Mətn stili (rəngi ağ)
        decoration: InputDecoration( // Mətn sahəsinin bəzəyi
          labelText: label, // Etiket mətni
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)), // Etiket mətni stili
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // İçəridən boşluq
          border: InputBorder.none, // Sərhədi ləğv edir
          enabledBorder: InputBorder.none, // Aktiv sərhədi ləğv edir
          focusedBorder: OutlineInputBorder( // Fokuslanmış sərhəd
            borderRadius: BorderRadius.circular(12), // Kənar radiusu
            borderSide: BorderSide(color: Colors.white.withOpacity(0.8), width: 2), // Fokuslanmış zaman ağ sərhəd
          ),
        ),
        onTap: onTap, // Toxunulduqda işə düşəcək funksiya
      ),
    );
  }
}
