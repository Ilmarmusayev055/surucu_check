import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surucu_check/l10n/app_localizations.dart';
import 'main.dart'; // LoginPage üçün import
import 'dart:ui'; // For ImageFilter

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final finController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final parkController = TextEditingController();
  final noteController = TextEditingController();

  String? selectedPosition;
  XFile? profileImage;
  XFile? idCardImage;
  bool isVerifying = false;
  bool isEmailVerified = false;
  bool showPassword = false;

  final List<String> positions = [
    'Park müdürü',
    'Sahibkar',
    'Müavin',
    'Qaraj müdürü',
    'Mühasib',
  ];

  Future<void> pickImage(bool isProfile) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent, // Şəffaf fon
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.5), // Yarı-şəffaf qara fon
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_library, color: Colors.white),
                    title: const Text('Qalereyadan seç', style: TextStyle(color: Colors.white)),
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt, color: Colors.white),
                    title: const Text('Kamera ilə çək', style: TextStyle(color: Colors.white)),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (source != null) {
      final image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          if (isProfile) {
            profileImage = image;
          } else {
            idCardImage = image;
          }
        });
      }
    }
  }

  Future<String?> uploadProfileImage(XFile image, String userId) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('profile_images/$userId.jpg');
      await storageRef.putFile(File(image.path));
      return await storageRef.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> registerUser() async {
    final loc = AppLocalizations.of(context)!;
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.fillRequiredFields)),
      );
      return;
    }

    setState(() {
      isVerifying = true; // Set to true to show loading indicator
    });

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? profileImageUrl;
      if (profileImage != null) {
        profileImageUrl = await uploadProfileImage(profileImage!, credential.user!.uid);
      }

      await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        'name': nameController.text.trim(),
        'surname': surnameController.text.trim(),
        'fin': finController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': email,
        'park': parkController.text.trim(),
        'position': selectedPosition ?? '',
        'note': noteController.text.trim(),
        'profileImage': profileImageUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await credential.user!.sendEmailVerification();
      // isVerifying state will be handled by checkEmailVerified dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.verificationEmailSent)),
      );

      await checkEmailVerified(credential.user!);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? loc.errorOccurred)),
      );
    } finally {
      setState(() {
        isVerifying = false; // Reset loading indicator
      });
    }
  }

  Future<void> checkEmailVerified(User user) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.8), // Şəffaf fon
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Email təsdiqləmə", style: TextStyle(color: Colors.black87)),
        content: const Text("Email ünvanınıza təsdiq mesajı göndərildi. Təsdiq etdikdən sonra 'Təsdiqlədim' düyməsinə klikləyin.", style: TextStyle(color: Colors.black54)),
        actions: [
          TextButton(
            onPressed: () async {
              await user.reload();
              final updatedUser = FirebaseAuth.instance.currentUser;
              if (updatedUser != null && updatedUser.emailVerified) {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Email hələ təsdiqlənməyib.")),
                );
              }
            },
            child: const Text("Təsdiqlədim", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  // Yenilənmiş _buildStyledTextField widget-i
  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
    int maxLines = 1,
    bool obscureText = false,
    String? hintText,
    Widget? suffixIcon,
    VoidCallback? onTap, // Yeni: onTap callback əlavə edildi
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15), // Yarı-şəffaf fon
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
        keyboardType: keyboardType,
        maxLines: obscureText ? 1 : maxLines,
        obscureText: obscureText,
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
          prefixText: prefixText, // Prefiks mətni
          suffixIcon: suffixIcon,
        ),
        onTap: onTap, // onTap callback TextField-ə ötürüldü
      ),
    );
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
                loc.register,
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
                children: [
                  _buildStyledTextField(
                    controller: nameController,
                    label: loc.firstName,
                    hintText: 'Adınızı daxil edin',
                  ),
                  const SizedBox(height: 16),
                  _buildStyledTextField(
                    controller: surnameController,
                    label: loc.lastName,
                    hintText: 'Soyadınızı daxil edin',
                  ),
                  const SizedBox(height: 16),
                  _buildStyledTextField(
                    controller: finController,
                    label: loc.fin,
                    hintText: 'FIN kodunuzu daxil edin',
                  ),
                  const SizedBox(height: 16),
                  _buildStyledTextField(
                    controller: phoneController,
                    label: loc.phone,
                    // prefixText: '+994 ', // Bu xanadan götürüldü
                    keyboardType: TextInputType.phone,
                    hintText: 'Telefon nömrənizi daxil edin',
                    onTap: () { // Yeni: onTap əlavə edildi
                      if (phoneController.text.isEmpty) {
                        phoneController.text = '+994 ';
                        // Kursuru Prefiksdən sonra yerləşdirmək üçün
                        phoneController.selection = TextSelection.fromPosition(
                          TextPosition(offset: phoneController.text.length),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildStyledTextField(
                    controller: emailController,
                    label: loc.email,
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'E-poçt ünvanınızı daxil edin',
                  ),
                  const SizedBox(height: 16),
                  _buildStyledTextField(
                    controller: passwordController,
                    label: loc.password,
                    obscureText: !showPassword,
                    hintText: 'Şifrənizi daxil edin',
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => pickImage(true),
                          child: Container(
                            height: 160,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15), // Yarı-şəffaf fon
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.2),
                                  blurRadius: 15,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: profileImage != null
                                  ? Image.file(
                                File(profileImage!.path),
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                                  : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.account_circle, color: Colors.white.withOpacity(0.7), size: 40),
                                  const SizedBox(height: 8),
                                  Text(
                                    loc.uploadProfilePhoto,
                                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => pickImage(false),
                          child: Container(
                            height: 160,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15), // Yarı-şəffaf fon
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.2),
                                  blurRadius: 15,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: idCardImage != null
                                  ? Image.file(
                                File(idCardImage!.path),
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                                  : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.upload_file, color: Colors.white.withOpacity(0.7), size: 40),
                                  const SizedBox(height: 8),
                                  Text(
                                    loc.uploadIdCard,
                                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStyledTextField(
                    controller: parkController,
                    label: loc.parkName,
                    hintText: 'Parkın adını daxil edin',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15), // Yarı-şəffaf fon
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedPosition,
                      decoration: InputDecoration(
                        labelText: loc.position,
                        labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.8), width: 2),
                        ),
                      ),
                      dropdownColor: Colors.black.withOpacity(0.7), // Dropdown menyunun fon rəngi
                      style: const TextStyle(color: Colors.white, fontSize: 16), // Seçilmiş elementin mətni
                      icon: Icon(Icons.arrow_drop_down, color: Colors.white.withOpacity(0.7)), // İkon rəngi
                      items: positions.map((pos) => DropdownMenuItem(
                        value: pos,
                        child: Text(pos, style: const TextStyle(color: Colors.white)), // Menyu elementlərinin mətni
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPosition = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStyledTextField(
                    controller: noteController,
                    label: loc.note,
                    maxLines: 3,
                    hintText: 'Əlavə qeydlər (isteğe bağlı)',
                  ),
                  const SizedBox(height: 24),
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
                      onPressed: isVerifying ? null : registerUser,
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
                      child: isVerifying
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        loc.registerButton,
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
        ],
      ),
    );
  }
}
