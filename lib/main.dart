// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:ui'; // BackdropFilter üçün
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:surucu_check/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore-u əlavə etdik
import 'firebase_options.dart';
import 'register_page.dart';
import 'home_page.dart';
import 'forgot_password_page.dart';
import 'superadmin_page.dart'; // Superadmin səhifəsini əlavə etdik (fayl adı superadmin_page.dart olaraq fərz edilir)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final lastLogin = prefs.getInt('last_login') ?? 0;
  final now = DateTime.now().millisecondsSinceEpoch;
  final bool shouldAutoLogin = now - lastLogin <= 2 * 24 * 60 * 60 * 1000;

  runApp(SurucuCheckApp(autoLogin: shouldAutoLogin));
}

class SurucuCheckApp extends StatefulWidget {
  final bool autoLogin;
  const SurucuCheckApp({super.key, required this.autoLogin});

  static void setLocale(BuildContext context, Locale newLocale) {
    final _SurucuCheckAppState? state = context.findAncestorStateOfType<_SurucuCheckAppState>();
    state?.setLocale(newLocale);
  }

  static _SurucuCheckAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_SurucuCheckAppState>();
  }

  @override
  State<SurucuCheckApp> createState() => _SurucuCheckAppState();
}

class _SurucuCheckAppState extends State<SurucuCheckApp> {
  Locale _locale = const Locale('az');
  ThemeMode _themeMode = ThemeMode.light;

  void setLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  void toggleDarkMode() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      title: 'SürücüCheck',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: Colors.grey[100], // Əsas tətbiq fonu
        fontFamily: 'Inter', // Ümumi font
      ),
      darkTheme: ThemeData.dark().copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF1E2A2F),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF263238),
          foregroundColor: Colors.white,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Colors.blue,
          surface: Color(0xFF31434A),
          background: Color(0xFF1E2A2F),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C3A3F),
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white38),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white38),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.green),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
        dropdownMenuTheme: const DropdownMenuThemeData(
          textStyle: TextStyle(color: Colors.white),
          menuStyle: MenuStyle(
            backgroundColor: MaterialStatePropertyAll(Color(0xFF2C3A3F)),
          ),
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('az'),
        Locale('en'),
        Locale('ru'),
      ],
      home: widget.autoLogin && FirebaseAuth.instance.currentUser != null
          ? const HomePage() // Avtomatik girişdə hələlik HomePage-ə yönləndiririk. Firestore yoxlaması giriş səhifəsində olacaq.
          : SplashScreen(setLocale: setLocale),
    );
  }
}

class SplashScreen extends StatefulWidget {
  final void Function(Locale)? setLocale;
  const SplashScreen({super.key, this.setLocale});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage(setLocale: widget.setLocale)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2A2F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 100, height: 100),
            const SizedBox(height: 20),
            const Text(
              'SürücüCheck',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
                fontFamily: 'GaboDrive',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  final void Function(Locale)? setLocale;
  const LoginPage({super.key, this.setLocale});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;
  bool obscureText = true;

  @override
  void initState() {
    super.initState();
    loadSavedCredentials();
  }

  Future<void> loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');
    final lastLogin = prefs.getInt('last_login') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (now - lastLogin <= 2 * 24 * 60 * 60 * 1000 && savedEmail != null && savedPassword != null) {
      setState(() {
        emailController.text = savedEmail;
        passwordController.text = savedPassword;
        rememberMe = true;
      });
    }
  }

  Future<void> loginUser() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email və şifrə boş ola bilməz.")),
      );
      return;
    }

    try {
      // Firebase Auth ilə giriş
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final prefs = await SharedPreferences.getInstance();
      if (rememberMe) {
        await prefs.setInt('last_login', DateTime.now().millisecondsSinceEpoch);
        await prefs.setString('saved_email', email);
        await prefs.setString('saved_password', password);
      } else {
        await prefs.remove('saved_email');
        await prefs.remove('saved_password');
      }

      // Firestore-dan istifadəçi rolunu yoxla
      if (userCredential.user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users') // İstifadəçi məlumatlarının saxlandığı kolleksiyanın adı
            .doc(userCredential.user!.uid) // İstifadəçinin UID-si ilə sənədi tapırıq
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          // 'role' yerinə 'isSuperAdmin' sahəsini yoxlayırıq
          if (userData['isSuperAdmin'] == true) {
            // Əgər istifadəçi superadmin-dirsə, SuperAdminDashboardPage-ə keçid et
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SuperAdminPage()),
            );
          } else {
            // Digər istifadəçilər üçün HomePage-ə keçid et
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          }
        } else {
          // İstifadəçi sənədi Firestore-da tapılmasa, normal HomePage-ə yönləndir
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      } else {
        // İstifadəçi obyekti boş olarsa (bu nadir hallarda olar), HomePage-ə yönləndir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = "Belə bir istifadəçi tapılmadı.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Yanlış şifrə.";
      } else {
        errorMessage = e.message ?? "Giriş zamanı xəta baş verdi.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gözlənilməz xəta baş verdi: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      // Arxa fon üçün gradient və şüşə effekti
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                // Logo
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3), // Yarı-şəffaf ağ fon
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Image.asset('assets/logo.png', width: 90, height: 90),
                ),
                const SizedBox(height: 16),
                // Tətbiq Başlığı
                Text(
                  loc.appTitle,
                  style: const TextStyle(
                    fontSize: 32, // Daha böyük font ölçüsü
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GaboDrive', // GaboDrive fontunu saxlayırıq
                    color: Colors.white, // Ağ rəng
                    letterSpacing: 2, // Hərf aralığı
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black45,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48), // Daha çox boşluq
                // Login Kartı
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Kart üçün şüşə effekti
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15), // Yarı-şəffaf ağ fon
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5), // Zərif kənar
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2), // Canlı kölgə
                            blurRadius: 20,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // E-poçt / İstifadəçi adı girişi
                          _buildTextField(emailController, loc.email, false, 'E-poçtunuzu və ya istifadəçi adınızı daxil edin'),
                          const SizedBox(height: 20), // Daha çox boşluq
                          // Şifrə girişi
                          _buildTextField(passwordController, loc.password, true, 'Şifrənizi daxil edin'),
                          const SizedBox(height: 16),
                          // Yadda saxla və Şifrəni unutmusunuz?
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        rememberMe = value ?? false;
                                      });
                                    },
                                    activeColor: Colors.white.withOpacity(0.8), // Aktiv rəngi
                                    checkColor: Colors.purple.shade700, // İşarə rəngi
                                  ),
                                  Text(
                                    loc.rememberMe,
                                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white70, // Mətn rəngi
                                ),
                                child: Text(
                                  loc.forgotPassword,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32), // Daha çox boşluq
                          // Daxil ol düyməsi
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
                              onPressed: loginUser,
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
                              child: Text(
                                loc.login,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Qeydiyyatdan keçin linki
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                loc.noAccount,
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                              const SizedBox(width: 4),
                              TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white, // Mətn rəngi
                                ),
                                child: Text(
                                  loc.register,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Dil seçimi və "Powered by Green"
          Positioned(
            bottom: 32, // Dəyişiklik burada edildi: 16-dan 32-yə qaldırıldı
            left: 0, // Ekranın sol kənarından başlasın
            right: 0, // Ekranın sağ kənarına qədər uzansın
            child: Stack( // Mətn və düyməni üst-üstə yerləşdirmək üçün Stack istifadə edirik
              alignment: Alignment.center, // Stack-dəki elementləri mərkəzə gətirir
              children: [
                // "Powered by Green" mətni mərkəzdə
                const Text(
                  'Powered by Green',
                  style: TextStyle(fontSize: 12, color: Colors.white54),
                ),
                // Dil seçimi düyməsi solda
                Positioned(
                  left: 16, // Sol tərəfdən padding
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.language, color: Colors.white70),
                    onSelected: (String value) {
                      widget.setLocale?.call(Locale(value));
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
          )
        ],
      ),
    );
  }

  // Yenilənmiş _buildTextField widget-i
  Widget _buildTextField(TextEditingController controller, String label, bool isPassword, String hintText) {
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
        obscureText: isPassword ? obscureText : false,
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
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              obscureText ? Icons.visibility : Icons.visibility_off,
              color: Colors.white.withOpacity(0.7), // İkon rəngi
            ),
            onPressed: () => setState(() => obscureText = !obscureText),
          )
              : null,
        ),
      ),
    );
  }
}
