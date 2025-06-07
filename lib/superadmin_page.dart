import 'package:flutter/material.dart'; // Flutter Material dizayn komponentləri üçün paket
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication xidməti üçün paket
import 'dart:ui'; // ImageFilter kimi UI effektləri üçün dart:ui kitabxanası
import 'main.dart'; // SurucuCheckApp üçün import

// SuperAdminPage dövlətsiz (stateless) widget-ıdır, çünki daxili vəziyyəti yoxdur.
class SuperAdminPage extends StatelessWidget {
  const SuperAdminPage({super.key}); // Konstanta konstruktor

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
                  "SuperAdmin Paneli",
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
                iconTheme: const IconThemeData(color: Colors.white), // İkonların rəngi ağ
                actions: [
                  IconButton( // Çıxış düyməsi
                    icon: const Icon(Icons.logout), // Çıxış ikonu
                    tooltip: 'Çıxış', // İpucu mətni
                    onPressed: () async { // Düyməyə basıldıqda
                      await FirebaseAuth.instance.signOut(); // Firebase-dən çıxış edir
                      // LoginPage səhifəsinə keçid edir və bütün əvvəlki səhifələri yığından silir
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const SurucuCheckApp(autoLogin: false)),
                            (route) => false,
                      );
                    },
                  ),
                ],
              ),
              Expanded( // Qalan sahəni doldurmaq üçün Expanded widget-i
                child: ListView( // Sürüşdürülə bilən siyahı
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16), // Siyahının boşluqları
                  children: [
                    const SectionHeader(title: "🧑💼 İstifadəçi İdarəetməsi"), // Başlıq
                    const SuperAdminTile(title: "🔍 Bütün istifadəçilər"), // Siyahı elementi
                    const SuperAdminTile(title: "✏️ İstifadəçi rolunu dəyiş"), // Siyahı elementi
                    const SuperAdminTile(title: "🔒 İstifadəçini blokla/deaktiv et"), // Siyahı elementi
                    const SuperAdminTile(title: "✅ Yeni admin/sahibkar yarat"), // Siyahı elementi
                    const SuperAdminTile(title: "🗑️ İstifadəçi hesabını sil"), // Siyahı elementi

                    const SectionHeader(title: "📋 Sürücü Məlumatları"), // Başlıq
                    const SuperAdminTile(title: "➕ Yeni sürücü əlavə et"), // Siyahı elementi
                    const SuperAdminTile(title: "🧾 Bütün sürücü məlumatları"), // Siyahı elementi
                    const SuperAdminTile(title: "📌 Problemli sürücüləri filtrlə"), // Siyahı elementi
                    const SuperAdminTile(title: "✏️ Sürücü məlumatlarını dəyiş"), // Siyahı elementi
                    const SuperAdminTile(title: "🗑️ Sahibkarın təhqiredici qeydlərini sil"), // Siyahı elementi

                    const SectionHeader(title: "🕵️ Aktivlik və Təhlükəsizlik"), // Başlıq
                    const SuperAdminTile(title: "🗂 Fəaliyyət tarixçəsi"), // Siyahı elementi
                    const SuperAdminTile(title: "⚠️ Qeyri-adi gecə aktivlikləri"), // Siyahı elementi
                    const SuperAdminTile(title: "🔑 Şifrələmə statuslarına nəzarət"), // Siyahı elementi

                    const SectionHeader(title: "🌐 Tətbiq Ayarları"), // Başlıq
                    const SuperAdminTile(title: "🌍 Dil seçimi və əlavə dil"), // Siyahı elementi
                    const SuperAdminTile(title: "🖼 Logo və vizual ayarlar"), // Siyahı elementi
                    const SuperAdminTile(title: "📢 Qlobal bildiriş göndər"), // Siyahı elementi
                    const SuperAdminTile(title: "🔄 Texniki baxım rejimi (Maintenance)"), // Siyahı elementi

                    const SectionHeader(title: "📊 Statistika və Hesabatlar"), // Başlıq
                    const SuperAdminTile(title: "📈 Aktivlik və istifadəçi artımı"), // Siyahı elementi
                    const SuperAdminTile(title: "🚖 Ən çox sürücü və parklar"), // Siyahı elementi
                    const SuperAdminTile(title: "⚠️ Problemli sürücülər statistikası"), // Siyahı elementi
                    const SuperAdminTile(title: "💰 Gəlir-çıxar statistikası"), // Siyahı elementi

                    const SectionHeader(title: "🧪 Test və Audit"), // Başlıq
                    const SuperAdminTile(title: "🧱 Test hesabı ilə yoxlama"), // Siyahı elementi
                    const SuperAdminTile(title: "🧾 Log sistemini izləmək"), // Siyahı elementi
                    const SuperAdminTile(title: "🔄 Firebase/Firestore backup/rollback"), // Siyahı elementi

                    const SectionHeader(title: "📢 Reklam Paneli"), // Başlıq
                    const SuperAdminTile(title: "➕ Yeni reklam əlavə et"), // Siyahı elementi
                    const SuperAdminTile(title: "📝 Reklam redaktə et"), // Siyahı elementi
                    const SuperAdminTile(title: "🗑️ Reklamı sil"), // Siyahı elementi

                    const SectionHeader(title: "🖼️ Reklam Növləri"), // Başlıq
                    const SuperAdminTile(title: "📌 Banner reklam (yuxarı/aşağı)"), // Siyahı elementi
                    const SuperAdminTile(title: "🎁 Popup reklam"), // Siyahı elementi
                    const SuperAdminTile(title: "🎯 Hədəflənmiş reklamlar"), // Siyahı elementi
                    const SuperAdminTile(title: "📺 Video reklam (bonus hüquq üçün)"), // Siyahı elementi

                    const SectionHeader(title: "⏰ Reklam Aktivliyi və Rotasiya"), // Başlıq
                    const SuperAdminTile(title: "🔛 Başlama/bitmə tarixi"), // Siyahı elementi
                    const SuperAdminTile(title: "✅ Aktiv/passiv status"), // Siyahı elementi
                    const SuperAdminTile(title: "🔄 Avtomatik reklam rotasiyası"), // Siyahı elementi

                    const SectionHeader(title: "📊 Reklam Statistikası"), // Başlıq
                    const SuperAdminTile(title: "👁️ Baxış/Klik sayı"), // Siyahı elementi
                    const SuperAdminTile(title: "💰 Sponsorlu reklam gəliri"), // Siyahı elementi

                    const SectionHeader(title: "🤝 Reklam Verənlər Paneli"), // Başlıq
                    const SuperAdminTile(title: "🧾 Reklam verənlər üçün hesab yarat"), // Siyahı elementi
                    const SuperAdminTile(title: "📥 Reklam yükləmə və izləmə paneli"), // Siyahı elementi

                    const SectionHeader(title: "🛡️ Təhlükəsizlik və Təsdiq"), // Başlıq
                    const SuperAdminTile(title: "🚫 Uyğunsuz reklamları deaktiv et"), // Siyahı elementi
                    const SuperAdminTile(title: "✅ Admin təsdiqindən sonra aktivləşmə"), // Siyahı elementi

                    const SectionHeader(title: "💼 Abunəlik və Ödəniş Sistemi"), // Başlıq
                    const SuperAdminTile(title: "📦 Mövcud paketlərə bax"), // Siyahı elementi
                    const SuperAdminTile(title: "➕ Yeni paket əlavə et"), // Siyahı elementi
                    const SuperAdminTile(title: "⚙️ Paketləri idarə et"), // Siyahı elementi
                    const SuperAdminTile(title: "🔍 Sınaq müddətini izləmək və bloklamaq"), // Siyahı elementi
                    const SuperAdminTile(title: "💳 Ödəniş sistemlərini seç və izləmək"), // Siyahı elementi
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// SectionHeader dövlətsiz widget-ıdır, hər hissənin başlığını təmsil edir.
class SectionHeader extends StatelessWidget {
  final String title; // Başlıq mətni
  const SectionHeader({super.key, required this.title}); // Konstanta konstruktor

  @override
  Widget build(BuildContext context) {
    return Padding( // Padding widget-i
      padding: const EdgeInsets.symmetric(vertical: 10.0), // Şaquli boşluqlar
      child: Text( // Başlıq mətni
        title,
        style: TextStyle( // Mətn stili
          fontSize: 18, // Şrift ölçüsü
          fontWeight: FontWeight.bold, // Qalın şrift
          color: Colors.white.withOpacity(0.9), // Yarı-şəffaf ağ rəng
          shadows: const [ // Mətn kölgəsi
            Shadow(blurRadius: 3.0, color: Colors.black54, offset: Offset(1.0, 1.0)),
          ],
        ),
      ),
    );
  }
}

// SuperAdminTile dövlətsiz widget-ıdır, hər admin paneli elementini təmsil edir.
class SuperAdminTile extends StatelessWidget {
  final String title; // Elementin başlığı
  const SuperAdminTile({super.key, required this.title}); // Konstanta konstruktor

  @override
  Widget build(BuildContext context) {
    return ClipRRect( // Kənar radiusu ilə kəsmək üçün ClipRRect
      borderRadius: BorderRadius.circular(15.0), // Kənar radiusu
      child: BackdropFilter( // Şüşə effekti
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0), // Bulanıqlıq
        child: Container( // Elementin konteyneri
          margin: const EdgeInsets.symmetric(vertical: 6), // Şaquli boşluq
          decoration: BoxDecoration( // Konteynerin bəzəyi
            color: Colors.white.withOpacity(0.15), // Yarı-şəffaf fon rəngi
            borderRadius: BorderRadius.circular(15.0), // Kənar radiusu
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.0), // Sərhəd
            boxShadow: [ // Kölgə
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // Kölgə rəngi
                blurRadius: 15, // Kölgənin bulanıqlığı
                spreadRadius: 5, // Kölgənin yayılması
                offset: const Offset(0, 8), // Kölgənin ofseti
              ),
            ],
          ),
          child: ListTile( // Siyahı elementi
            title: Text( // Başlıq mətni
              title,
              style: TextStyle( // Mətn stili
                fontWeight: FontWeight.w600, // Şrift qalınlığı
                color: Colors.white.withOpacity(0.9), // Yarı-şəffaf ağ rəng
                shadows: const [ // Mətn kölgəsi
                  Shadow(blurRadius: 2.0, color: Colors.black38, offset: Offset(0.5, 0.5)),
                ],
              ),
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white.withOpacity(0.7)), // Sağ tərəfdəki ikon
            onTap: () { // Toxunulduqda
              ScaffoldMessenger.of(context).showSnackBar( // SnackBar ilə mesaj göstərir
                SnackBar(content: Text('"$title" funksiyası hələ aktiv deyil')),
              );
            },
          ),
        ),
      ),
    );
  }
}
