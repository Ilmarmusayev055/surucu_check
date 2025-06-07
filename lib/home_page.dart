import 'package:flutter/material.dart';
import 'package:surucu_check/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui'; // For ImageFilter

import 'main.dart'; // LoginPage üçün
import 'search_page.dart';
import 'add_driver_page.dart';
import 'driver_list_page.dart';
import 'profile_settings_page.dart';
import 'chat_page.dart'; // ChatPage-i import etdik

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = '';
  String profileImage = '';
  String fleetName = '';
  String position = '';

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          userName = data['name'] ?? '';
          profileImage = data['profileImage'] ?? '';
          fleetName = data['park'] ?? '';
          position = data['position'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: false, // klaviatura açıldığında layoutu dəyişməmək üçün
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
          Column(
            children: [
              // Custom AppBar
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: const SizedBox(), // Sol tərəfi boş saxlayırıq
                // Başlıq AppBar-dan kənara çıxarıldığı üçün buranı boş saxlayırıq
                title: const Text(''),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white), // Çıxış düyməsinin rəngi ağ
                    tooltip: locale.logout,
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                  )
                ],
              ),
              // Username salamlamasını aşağı salmaq üçün əlavə boşluq
              Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0), // Yuxarıdan 16.0 boşluq əlavə edildi
                child: Align(
                  alignment: Alignment.centerLeft, // Mətni sola hizala
                  child: Text(
                    '${locale.homeWelcome}, $userName',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Mətn rəngi ağ
                      shadows: [
                        Shadow(
                          blurRadius: 5.0,
                          color: Colors.black38,
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24.0), // Salamlama mətni ilə növbəti hissə arasındakı boşluq

              // Qalan məzmun SingleChildScrollView içində
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0), // Üfüqi boşluğu saxlayırıq
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // İstifadəçi Məlumatları hissəsi
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15), // Yarı-şəffaf ağ fon
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
                            child: Row(
                              children: [
                                Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 2), // Çərçivə
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.2),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                    image: profileImage.isNotEmpty
                                        ? DecorationImage(
                                      image: CachedNetworkImageProvider(profileImage),
                                      fit: BoxFit.cover,
                                    )
                                        : const DecorationImage(
                                      image: AssetImage('assets/logo.png'), // Default şəkil
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fleetName.isNotEmpty ? fleetName : '—',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white, // Mətn rəngi ağ
                                        shadows: [
                                          Shadow(
                                            blurRadius: 5.0,
                                            color: Colors.black38,
                                            offset: Offset(1.0, 1.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      position.isNotEmpty ? position : locale.taxiCompany,
                                      style: TextStyle(color: Colors.white.withOpacity(0.7)), // Mətn rəngi
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32), // Boşluq
                      // Menu GridView
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.2, // Kart nisbətini tənzimləyir
                        children: [
                          _buildMenuCard(
                            context,
                            icon: Icons.search,
                            label: locale.searchDriver,
                            page: const SearchPage(),
                            cardColor: Colors.blue.shade300,
                          ),
                          _buildMenuCard(
                            context,
                            icon: Icons.person_add,
                            label: locale.addDriver,
                            page: const AddDriverPage(),
                            cardColor: Colors.green.shade300,
                          ),
                          _buildMenuCard(
                            context,
                            icon: Icons.list,
                            label: locale.driverList,
                            page: const DriverListPage(),
                            cardColor: Colors.orange.shade300,
                          ),
                          _buildMenuCard(
                            context,
                            icon: Icons.settings,
                            label: locale.profileSettings,
                            page: const ProfileSettingsPage(),
                            cardColor: Colors.purple.shade300,
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
      // Çat ikonu FloatingActionButton olaraq əlavə edildi
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatPage()),
          );
        },
        backgroundColor: Colors.green.shade600, // Yaşıl rəngdə ikon
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Kvadrat formalı
        child: const Icon(Icons.chat, color: Colors.white, size: 30), // Ağ rəngdə çat ikonu
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Sağ aşağıda yerləşdirdik
    );
  }

  // Yenilənmiş _buildMenuCard widget-i
  Widget _buildMenuCard(BuildContext context, {
    required IconData icon,
    required String label,
    required Widget page,
    required Color cardColor, // Kart rəngi əlavə edildi
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0), // Şüşə effekti
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15), // Yarı-şəffaf ağ fon
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.0), // Zərif kənar
              boxShadow: [
                BoxShadow(
                  color: cardColor.withOpacity(0.4), // Kart rənginə uyğun canlı kölgə
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.1), // Parıltı effekti
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: cardColor.withOpacity(0.9), // İkon rəngi
                ),
                const SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white, // Mətn rəngi ağ
                      shadows: [
                        Shadow(
                          blurRadius: 5.0,
                          color: Colors.black38,
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> deleteLatestDriver() async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('drivers')
        .orderBy('entries.0.date', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final latestDoc = snapshot.docs.first;
      final docId = latestDoc.id;
      final name = latestDoc['name'];
      final surname = latestDoc['surname'];

      await FirebaseFirestore.instance.collection('drivers').doc(docId).delete();

      print("✅ Silindi: $name $surname (ID: $docId)");
    } else {
      print("❌ Heç bir sürücü tapılmadı.");
    }
  } catch (e) {
    print("⚠️ Xəta baş verdi: $e");
  }
}
