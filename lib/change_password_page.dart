import 'package:flutter/material.dart'; // Flutter Material dizayn komponentləri üçün paket
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication xidməti üçün paket
import 'dart:ui'; // ImageFilter kimi UI effektləri üçün dart:ui kitabxanası

// ChangePasswordPage dövlətli (stateful) widget-ıdır.
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key}); // Konstanta konstruktor

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState(); // Widget üçün State obyekti yaradır
}

// _ChangePasswordPageState State obyekti ChangePasswordPage-in vəziyyətini idarə edir.
class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final currentPasswordController = TextEditingController(); // Cari şifrə sahəsi üçün TextEditingController
  final newPasswordController = TextEditingController(); // Yeni şifrə sahəsi üçün TextEditingController
  final confirmPasswordController = TextEditingController(); // Yeni şifrəni təsdiqləmə sahəsi üçün TextEditingController

  bool isLoading = false; // Yüklənmə vəziyyətini izləyən dəyişən

  @override
  Widget build(BuildContext context) {
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
                title: const Text( // Başlıq mətni
                  'Şifrəni dəyiş',
                  style: TextStyle( // Mətn stili
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
                      _buildStyledPasswordField(currentPasswordController, 'Cari şifrə'), // Cari şifrə sahəsi
                      const SizedBox(height: 16), // Boşluq
                      _buildStyledPasswordField(newPasswordController, 'Yeni şifrə'), // Yeni şifrə sahəsi
                      const SizedBox(height: 16), // Boşluq
                      _buildStyledPasswordField(confirmPasswordController, 'Yeni şifrəni təsdiqlə'), // Yeni şifrəni təsdiqlə sahəsi
                      const SizedBox(height: 32), // Boşluq
                      isLoading // Yüklənmə vəziyyətindədirsə
                          ? const CircularProgressIndicator(color: Colors.white) // Yüklənmə indikatoru göstər
                          : Container( // Təsdiqlə düyməsi üçün Konteyner
                        width: double.infinity, // Genişliyi tam edir
                        decoration: BoxDecoration( // Bəzək
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
                          onPressed: _changePassword, // Düyməyə basıldıqda şifrəni dəyişdirmə funksiyasını çağırır
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
                          child: const Text( // Düymənin mətni
                            'Təsdiqlə',
                            style: TextStyle( // Mətn stili
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

  // Özelleşdirilmiş şifrə sahəsi (TextField) widget-i
  Widget _buildStyledPasswordField(TextEditingController controller, String label) {
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
        obscureText: true, // Mətni gizlədir (şifrə üçün)
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
      ),
    );
  }

  // ✅ Əsas dəyişiklik: Firebase ilə köhnə şifrə yoxlanır, sonra yeni şifrə tətbiq olunur
  // Şifrə dəyişdirmə əməliyyatını yerinə yetirən asinxron funksiya
  Future<void> _changePassword() async {
    final current = currentPasswordController.text.trim(); // Cari şifrəni alır
    final newPass = newPasswordController.text.trim(); // Yeni şifrəni alır
    final confirm = confirmPasswordController.text.trim(); // Təsdiq şifrəsini alır
    final user = FirebaseAuth.instance.currentUser; // Cari istifadəçini alır

    if (newPass != confirm) { // Yeni şifrə və təsdiqi eyni deyilsə
      _showMessage('Yeni şifrə və təsdiqi eyni olmalıdır.'); // Xəta mesajı göstər
      return; // Funksiyadan çıxır
    }
    if (newPass.length < 6) { // Yeni şifrənin uzunluğu 6-dan azdırsa
      _showMessage('Şifrə ən azı 6 simvol olmalıdır.'); // Xəta mesajı göstər
      return; // Funksiyadan çıxır
    }
    if (user == null || user.email == null) { // İstifadəçi məlumatı tapılmazsa
      _showMessage('İstifadəçi məlumatı tapılmadı.'); // Xəta mesajı göstər
      return; // Funksiyadan çıxır
    }

    setState(() => isLoading = true); // Yüklənmə vəziyyətinə keçir

    try {
      final credential = EmailAuthProvider.credential( // Email və şifrə ilə təsdiq credential yaradır
        email: user.email!, // İstifadəçinin email-i
        password: current, // Cari şifrə
      );

      await user.reauthenticateWithCredential(credential); // İstifadəçini cari şifrə ilə yenidən təsdiqləyir
      await user.updatePassword(newPass); // Firebase-də şifrəni yeniləyir

      if (mounted) { // Kontekst hələ də mounted-dirsə
        _showMessage('Şifrə uğurla dəyişdirildi.'); // Uğurlu mesaj göstər
        Navigator.pop(context); // Səhifədən çıxır
      }
    } on FirebaseAuthException catch (e) { // Firebase Authentication xətalarını tutur
      if (e.code == 'wrong-password') { // Şifrə yanlışdırsa
        _showMessage('Cari şifrə yanlışdır.');
      } else if (e.code == 'weak-password') { // Yeni şifrə zəifdirsə
        _showMessage('Yeni şifrə çox zəifdir.');
      } else { // Digər Firebase xətaları
        _showMessage('Xəta baş verdi: ${e.message}');
      }
    } catch (e) { // Digər naməlum xətaları tutur
      _showMessage('Naməlum xəta: $e');
    } finally { // Hər hansı halda, əməliyyat bitdikdə
      if (mounted) setState(() => isLoading = false); // Yüklənmə vəziyyətini sıfırla
    }
  }

  // SnackBar vasitəsilə mesaj göstərən köməkçi funksiya
  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg))); // SnackBar ilə mesaj göstərir
  }
}
