import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:surucu_check/l10n/app_localizations.dart';
import 'dart:ui'; // For ImageFilter

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Future<void> resetPassword() async {
    final String email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Zəhmət olmasa email daxil edin.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Şifrə yeniləmə linki email ünvanınıza göndərildi.")),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Xəta baş verdi.")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Canlı rəngli gradient fon
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF8A2BE2), // Blue Violet
                  Color(0xFFDA70D6), // Orchid
                  Color(0xFFFF69B4), // Hot Pink
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Şüşə effekti
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Daha güclü blur
            child: Container(
              color: Colors.black.withOpacity(0.2), // Yarı-şəffaf qara overlay
            ),
          ),
          // AppBar-ı Stack içərisində yerləşdiririk ki, fonun üzərində görünsün
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent, // Şəffaf fon
              elevation: 0,
              title: Text(
                loc.forgotPassword,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  shadows: [
                    Shadow(
                      blurRadius: 5.0,
                      color: Colors.black38,
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                ),
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.white), // Geri düyməsinin rəngi
            ),
          ),
          // Scrollable content
          Padding(
            padding: EdgeInsets.only(top: AppBar().preferredSize.height + MediaQuery.of(context).padding.top),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  // Məlumatlandırma mətni
                  Text(
                    "Email ünvanınızı daxil edin, sizə şifrəni yeniləmək üçün link göndəriləcək.",
                    style: const TextStyle(
                      color: Colors.white70, // Ağ rəng
                      fontSize: 16,
                      shadows: [
                        Shadow(
                          blurRadius: 5.0,
                          color: Colors.black38,
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48), // Daha çox boşluq
                  // Email girişi
                  _buildTextField(emailController, loc.email, 'E-poçtunuzu daxil edin'),
                  const SizedBox(height: 32), // Daha çox boşluq
                  // Şifrəni yenilə düyməsi
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)], // Canlı yaşıl gradient
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.4), // Yaşıl kölgə
                          blurRadius: 15,
                          spreadRadius: 5,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent, // Gradient üçün şəffaf
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55), // Daha böyük düymə
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0, // Kölgəni Container verir
                        padding: EdgeInsets.zero, // Padding Container-də idarə olunur
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        loc.resetPassword, // Lokalizasiya açarından istifadə
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // "Powered by Green" mətni
          Positioned(
            bottom: 32, // Alt hissədən yuxarıya qaldırıldı
            left: 0,
            right: 0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  'Powered by Green',
                  style: TextStyle(fontSize: 12, color: Colors.white54),
                ),
                // Dil seçimi düyməsi, ForgotPasswordPage-də görünməyəcək, lakin eyni layout tətbiq olunur
                Positioned(
                  left: 16,
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.language, color: Colors.transparent), // Şəffaf ikon
                    onSelected: (String value) {
                      // Do nothing, as language selection is not intended here
                    },
                    itemBuilder: (BuildContext context) => const [
                      PopupMenuItem(value: 'az', child: Text('Azərbaycan dili')),
                      PopupMenuItem(value: 'en', child: Text('English')),
                      PopupMenuItem(value: 'ru', child: Text('Русский')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // _buildTextField widget-i
  Widget _buildTextField(TextEditingController controller, String label, String hintText) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1), // Yarı-şəffaf fon
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: Colors.white, fontSize: 16), // Mətn rəngi ağ
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)), // Label rəngi
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)), // Hint rəngi
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: InputBorder.none, // Sərhədi ləğv edir
          enabledBorder: InputBorder.none, // Sərhədi ləğv edir
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.8), width: 2), // Fokuslanmış zaman ağ sərhəd
          ),
        ),
      ),
    );
  }
}
