import 'dart:io'; // Fayl əməliyyatları üçün (şəkil seçimi)

import 'package:flutter/material.dart'; // Flutter Material dizayn komponentləri üçün paket
import 'package:flutter/services.dart'; // TextInputFormatter üçün
import 'package:image_picker/image_picker.dart'; // Şəkil seçmək üçün paket
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore verilənlər bazası ilə əlaqə üçün paket
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication xidməti üçün paket (Düzəliş edildi)
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage (fayl saxlama) xidməti üçün paket
import 'package:surucu_check/l10n/app_localizations.dart'; // Lokalizasiya (dil dəstəyi) üçün paket
import 'package:cached_network_image/cached_network_image.dart'; // Şəbəkədən şəkilləri keşləmək və göstərmək üçün paket
import 'dart:ui'; // ImageFilter kimi UI effektləri üçün dart:ui kitabxanası

// EditDriverEntryPage dövlətli (stateful) widget-ıdır.
class EditDriverEntryPage extends StatefulWidget {
  final String driverId; // Redaktə ediləcək sürücünün ID-si
  final Map<String, dynamic> entry; // Redaktə ediləcək sürücü qeydi

  const EditDriverEntryPage({super.key, required this.driverId, required this.entry}); // Konstruktor

  @override
  State<EditDriverEntryPage> createState() => _EditDriverEntryPageState(); // Widget üçün State obyekti yaradır
}

// _EditDriverEntryPageState State obyekti EditDriverEntryPage-in vəziyyətini idarə edir.
class _EditDriverEntryPageState extends State<EditDriverEntryPage> {
  late TextEditingController noteController; // Qeyd sahəsi üçün TextEditingController
  late TextEditingController svController; // SV nömrəsi sahəsi üçün TextEditingController
  late TextEditingController phoneController; // Telefon nömrəsi sahəsi üçün TextEditingController
  String status = 'Problemsiz'; // Sürücü statusu (defolt olaraq 'Problemsiz')
  String? reason; // Problemli statusunun səbəbi
  File? _newImageFile; // Yeni seçilmiş şəkil faylı
  String? imageUrl; // Cari sürücü şəklinin URL-i
  final List<String> statusOptions = ['Problemsiz', 'Problemli']; // Status seçimləri siyahısı
  final List<String> reasonOptions = ['Borcu var', 'Maşını vurub', 'Cərimə saxlayıb', 'Digər']; // Səbəb seçimləri siyahısı

  @override
  void initState() {
    super.initState(); // Üst sinifin initState metodunu çağırır
    // Kontrolerləri widget-in giriş məlumatları ilə ilkinləşdirir
    noteController = TextEditingController(text: widget.entry['note'] ?? ''); // Qeyd mətnini ilkinləşdirir
    svController = TextEditingController(text: widget.entry['sv'] ?? ''); // SV nömrəsi mətnini ilkinləşdirir

    // ✅ DƏYİŞDİ: Telefon nömrəsi prefiksini ilkinləşdirmə zamanı təmizləyin.
    String initialPhone = widget.entry['phone'] ?? '';
    if (initialPhone.isNotEmpty && initialPhone.startsWith('+994')) {
      initialPhone = initialPhone.substring(4); // +994-ü silir, çünki bu, TextField-in prefixText-i olaraq əlavə olunacaq
    }
    phoneController = TextEditingController(text: initialPhone); // Telefon nömrəsi mətnini ilkinləşdirir

    status = widget.entry['status'] ?? 'Problemsiz'; // Statusu ilkinləşdirir
    // Səbəbi ilkinləşdirir, əgər mövcud səbəb siyahıda yoxdursa, ilk səbəbi seçir
    reason = reasonOptions.contains(widget.entry['reason']) ? widget.entry['reason'] : reasonOptions.first;

    imageUrl = widget.entry['photoUrl']; // Şəkil URL-ni ilkinləşdirir

    // ✅ DƏYİŞDİ: SV və Telefon sahələri üçün listenerlər əlavə edildi
    svController.addListener(_onFieldChanged);
    phoneController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    // ✅ DƏYİŞDİ: Listenerlər dispose metodunda silindi (memory leak qarşısını almaq üçün).
    svController.removeListener(_onFieldChanged);
    phoneController.removeListener(_onFieldChanged);
    noteController.dispose();
    svController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // Sahələrdə dəyişiklik olduqda UI-ı yeniləmək üçün callback
  void _onFieldChanged() {
    setState(() {
      // Bu metod sahə dəyəri dəyişdikdə suffixIcon görünürlüğünü yeniləmək üçün setState-i çağırır.
    });
  }

  // Şəkil seçmək üçün funksiya (qalereya və ya kamera)
  Future<void> pickImage() async {
    final picker = ImagePicker(); // ImagePicker obyekti yaradır
    final source = await showModalBottomSheet<ImageSource>( // Aşağıdan açılan modal göstərir
      context: context, // Cari kontekst
      builder: (context) => SafeArea( // Təhlükəsiz sahəni təmin edir
        child: Wrap( // Məzmunu sətirə uyğunlaşdırır
          children: [
            ListTile( // Qalereyadan seçmək üçün seçim
              leading: const Icon(Icons.photo_library, color: Colors.blueAccent), // İkon
              title: const Text('Qalereyadan seç', style: TextStyle(color: Colors.black)), // Başlıq
              onTap: () => Navigator.pop(context, ImageSource.gallery), // Toxunulduqda qalereya seçimi ilə çıxır
            ),
            ListTile( // Kamera ilə çəkmək üçün seçim
              leading: const Icon(Icons.camera_alt, color: Colors.greenAccent), // İkon
              title: const Text('Kamera ilə çək', style: TextStyle(color: Colors.black)), // Başlıq
              onTap: () => Navigator.pop(context, ImageSource.camera), // Toxunulduqda kamera seçimi ilə çıxır
            ),
          ],
        ),
      ),
    );

    if (source != null) { // Əgər mənbə seçilibsə
      final picked = await picker.pickImage(source: source); // Şəkil seçir
      if (picked != null) { // Əgər şəkil seçilibsə
        setState(() {
          _newImageFile = File(picked.path); // Yeni şəkli saxlayır
        });
      }
    }
  }

  // Dəyişiklikləri yadda saxlamaq üçün asinxron funksiya
  Future<void> saveChanges() async {
    final uid = FirebaseAuth.instance.currentUser?.uid; // Cari istifadəçinin UID-ni alır
    if (uid == null) return; // UID yoxdursa funksiyadan çıxır

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get(); // İstifadəçi sənədini alır
    final userData = userDoc.data(); // İstifadəçi məlumatlarını alır
    if (userData == null) return; // Məlumat yoxdursa funksiyadan çıxır

    final ownerName = '${userData['name']} ${userData['surname']}'; // Sahibkarın adını və soyadını birləşdirir

    final driverRef = FirebaseFirestore.instance.collection('drivers').doc(widget.driverId); // Sürücünün sənədinə istinad alır
    final driverDoc = await driverRef.get(); // Sürücü sənədini alır
    final driverData = driverDoc.data(); // Sürücü məlumatlarını alır
    if (driverData == null) return; // Məlumat yoxdursa funksiyadan çıxır

    List<Map<String, dynamic>> entries = List<Map<String, dynamic>>.from(driverData['entries'] ?? []); // Sürücünün giriş qeydlərini alır

    String? uploadedImageUrl = imageUrl; // Yüklənəcək şəkil URL-i (əvvəlki URL)
    if (_newImageFile != null) { // Əgər yeni şəkil seçilibsə
      final ref = FirebaseStorage.instance // Firebase Storage istinadını alır
          .ref() // Kök referans
          .child('driver_images/${widget.driverId}_${DateTime.now().millisecondsSinceEpoch}.jpg'); // Faylın yolunu təyin edir
      await ref.putFile(_newImageFile!); // Yeni şəkli yükləyir
      uploadedImageUrl = await ref.getDownloadURL(); // Yüklənmiş şəklin URL-ni alır
    }

    // Giriş qeydlərini yeniləyir
    final updatedEntries = entries.map((e) {
      if (e['owner'] == ownerName && e['date'] == widget.entry['date']) { // Sahibkar və tarix uyğundursa
        String newPhone = phoneController.text;
        // ✅ DƏYİŞDİ: Telefon nömrəsini firestore-a yazarkən prefiksdən sonrakı hissəni saxlayır.
        if (newPhone.isNotEmpty && newPhone.startsWith('+994')) {
          newPhone = newPhone.substring(4); // +994-ü silir
        }

        return { // Qeydi yeniləyir
          ...e, // Mövcud qeyd məlumatları
          'status': status, // Yeni status
          'note': noteController.text.isNotEmpty ? noteController.text : e['note'], // Boş deyilsə yenilə
          'sv': svController.text.isNotEmpty ? svController.text.toUpperCase() : e['sv'], // Boş deyilsə yenilə, böyük hərfə çevir
          'phone': newPhone.isNotEmpty ? newPhone : e['phone'], // Təmizlənmiş telefon nömrəsini və ya əvvəlki dəyəri saxla
          'reason': status == 'Problemli' ? reason : null, // Status 'Problemli'dirsə səbəbi qeyd edir
          'photoUrl': uploadedImageUrl, // Yeni şəkil URL-i
        };
      }
      return e; // Başqa qeydləri dəyişmədən qaytarır
    }).toList(); // Listə çevirir

    // Sürücü sənədini yeniləyir (SV nömrəsini ümumi sənəddə dəyişir, telefon nömrəsi ümumi sənəddə yoxdur)
    String newPhone = phoneController.text.trim();
    if (newPhone.startsWith('+994')) {
      newPhone = newPhone.substring(4); // +994 varsa, çıxar
    }

// Firestore-a yazılacaq tam telefon nömrəsi prefiks ilə birlikdə
    String fullPhone = '+994$newPhone';

    await driverRef.update({
      'sv': svController.text.isNotEmpty ? svController.text.toUpperCase() : driverData['sv'], // SV nömrəsini dəyiş
      'phone': newPhone.isNotEmpty ? newPhone : driverData['phone'], // ✅ Telefon nömrəsini sənədin özündə dəyiş
      'entries': updatedEntries, // entries dəyişməzsə belə onu saxlayırsan
    });


    if (context.mounted) { // Kontekst hələ də mounted-dirsə
      Navigator.pop(context, true); // Səhifədən çıxır və true qaytarır
    }
  }

  // Özelleşdirilmiş mətn sahəsi (TextField) widget-i
  Widget _buildStyledInputField({
    required TextEditingController controller, // Mətn sahəsinin kontroleri
    required String label, // Mətn sahəsinin etiketi
    TextInputType keyboardType = TextInputType.text, // Klaviatura növü (defolt olaraq mətn)
    String? hintText, // İpucu mətni
    int maxLines = 1, // Maksimum sətir sayı
    TextCapitalization textCapitalization = TextCapitalization.none, // Mətnin avtomatik böyük hərflə başlaması
    String? prefixText, // Prefiks mətni
    List<TextInputFormatter>? inputFormatters, // Input formatlayıcılar
    VoidCallback? onTap, // TextField'ə toxunulduqda işə düşəcək callback
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
        maxLines: maxLines, // Maksimum sətir sayı
        style: const TextStyle(color: Colors.white, fontSize: 16), // Mətn stili (rəngi ağ)
        textCapitalization: textCapitalization, // Mətnin avtomatik böyük hərflə başlaması
        inputFormatters: inputFormatters, // Input formatlayıcılar
        onTap: () { // ✅ DƏYİŞDİ: Telefon nömrəsi üçün onTap funksionallığı
          // Əgər telefon nömrəsi sahəsinə toxunulubsa və sahə boşdursa, +994 əlavə et
          if (keyboardType == TextInputType.phone && controller.text.isEmpty) {
             // Prefiksi əlavə edir
            controller.selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length), // Kursoru axıra gətirir
            );
          }
          onTap?.call(); // Əgər əlavə onTap funksionallığı varsa onu da çağır
        },
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
          prefixText: prefixText, // Prefiks mətni (telefon üçün +994)
          // ✅ DƏYİŞDİ: TextField üçün "x" təmizləmə düyməsi əlavə edildi
          suffixIcon: controller.text.isNotEmpty && (prefixText == null || controller.text != prefixText)
              ? IconButton(
            icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.7)),
            onPressed: () {
              controller.clear();
              if (prefixText != null) { // Əgər prefiks varsa, təmizlədikdən sonra prefiksi bərpa et.
                controller.text = prefixText;
              }
              setState(() {
                // UI-ı yeniləmək üçün
              });
            },
          )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // Lokalizasiya obyektini alır

    return Scaffold( // Scaffold widget-i, əsas vizual quruluşu təmin edir
      resizeToAvoidBottomInset: true, // Klaviatura açıldığında layoutu avtomatik tənzimləsin
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
                  loc.editDriver, // Lokalizasiyadan alınan redaktə başlığı
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
                      Stack( // Şəkil və redaktə ikonu üçün Stack
                        alignment: Alignment.bottomRight, // İkonu aşağı sağ küncə yerləşdirir
                        children: [
                          Container( // Şəkil üçün konteyner
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
                              image: _newImageFile != null // Əgər yeni şəkil seçilibsə
                                  ? DecorationImage(image: FileImage(_newImageFile!), fit: BoxFit.cover) // Fayldan şəkil göstər
                                  : (imageUrl != null && imageUrl!.isNotEmpty // Əgər şəkil URL-i varsa və boş deyilsə
                                  ? DecorationImage(image: CachedNetworkImageProvider(imageUrl!), fit: BoxFit.cover) // Şəbəkədən şəkil göstər
                                  : const DecorationImage(image: AssetImage('assets/default_driver.png'), fit: BoxFit.cover)), // Default şəkil göstər
                            ),
                          ),
                          IconButton( // Redaktə ikonu düyməsi
                            icon: const Icon(Icons.edit, color: Colors.white, size: 24), // İkon (rəngi ağ)
                            onPressed: pickImage, // Düyməyə basıldıqda şəkil seçmə funksiyasını çağırır
                            style: IconButton.styleFrom( // İkon düyməsinin stili
                              backgroundColor: Colors.black.withOpacity(0.6), // Yarı-şəffaf qara fon
                              shape: const CircleBorder(), // Dairəvi forma
                              padding: const EdgeInsets.all(8), // İçəridən boşluq
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32), // Boşluq
                      // Status seçimi üçün DropdownButtonFormField
                      _buildLabeledField(
                        loc.status, // Etiket
                        Container( // DropdownButtonFormField-i konteynerə bükürük
                          decoration: BoxDecoration( // Konteynerin bəzəyi
                            color: Colors.white.withOpacity(0.15), // Yarı-şəffaf fon
                            borderRadius: BorderRadius.circular(12), // Kənar radiusu
                            boxShadow: [ // Kölgə effekti
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: DropdownButtonFormField<String>(
                            value: status, // Seçilmiş dəyər
                            items: statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(color: Colors.white)))).toList(), // Seçimlər
                            onChanged: (val) => setState(() { // Dəyər dəyişdikdə
                              if (val != null) status = val; // Statusu yeniləyir
                              if (status == 'Problemsiz') reason = null; // Əgər status 'Problemsiz' olarsa, səbəbi sıfırlayır
                            }),
                            dropdownColor: Colors.black.withOpacity(0.7), // Açılan menyunun fon rəngi
                            style: const TextStyle(color: Colors.white, fontSize: 16), // Menyudakı mətn stili
                            icon: Icon(Icons.arrow_drop_down, color: Colors.white.withOpacity(0.7)), // Açılan menyu ikonu
                            decoration: InputDecoration( // Bəzək
                              labelText: loc.status, // Etiket
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
                          ),
                        ),
                      ),
                      if (status == 'Problemli') ...[ // Əgər status 'Problemli'dirsə
                        const SizedBox(height: 16), // Boşluq
                        _buildLabeledField( // Səbəb seçimi üçün DropdownButtonFormField
                          "Səbəb", // Etiket
                          Container( // DropdownButtonFormField-i konteynerə bükürük
                            decoration: BoxDecoration( // Konteynerin bəzəyi
                              color: Colors.white.withOpacity(0.15), // Yarı-şəffaf fon
                              borderRadius: BorderRadius.circular(12), // Kənar radiusu
                              boxShadow: [ // Kölgə effekti
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: DropdownButtonFormField<String>(
                              value: reason, // Seçilmiş dəyər
                              items: reasonOptions.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(color: Colors.white)))).toList(), // Seçimlər
                              onChanged: (val) => setState(() => reason = val), // Dəyər dəyişdikdə səbəbi yeniləyir
                              dropdownColor: Colors.black.withOpacity(0.7), // Açılan menyunun fon rəngi
                              style: const TextStyle(color: Colors.white, fontSize: 16), // Menyudakı mətn stili
                              icon: Icon(Icons.arrow_drop_down, color: Colors.white.withOpacity(0.7)), // Açılan menyu ikonu
                              decoration: InputDecoration( // Bəzək
                                labelText: "Səbəb", // Etiket
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
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16), // Boşluq
                      _buildLabeledField( // SV nömrəsi sahəsi
                        "SV nömrəsi", // Etiket
                        _buildStyledInputField( // Özelleşdirilmiş mətn sahəsi
                          controller: svController, // Kontroler
                          label: "SV nömrəsi", // Etiket
                          hintText: "Sürücülük vəsiqəsinin nömrəsi", // İpucu
                          textCapitalization: TextCapitalization.characters, // Həmişə böyük hərflə yazılsın
                        ),
                      ),
                      const SizedBox(height: 16), // Boşluq
                      _buildLabeledField( // Telefon nömrəsi sahəsi
                        "Telefon nömrəsi", // Etiket
                        _buildStyledInputField( // Özelleşdirilmiş mətn sahəsi
                          controller: phoneController, // Kontroler
                          label: "Telefon nömrəsi", // Etiket
                          hintText: "Mobil nömrə", // İpucu
                          keyboardType: TextInputType.phone, // Klaviatura növü telefon nömrəsi üçün
                          prefixText: '+994', // Avtomatik prefiks əlavə edildi
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Yalnız rəqəmlərə icazə ver
                        ),
                      ),
                      const SizedBox(height: 16), // Boşluq
                      _buildLabeledField( // Qeyd sahəsi
                        loc.note, // Etiket
                        _buildStyledInputField( // Özelleşdirilmiş mətn sahəsi
                          controller: noteController, // Kontroler
                          label: loc.note, // Etiket
                          hintText: "Əlavə qeydlərinizi daxil edin", // İpucu
                          maxLines: 3, // Maksimum 3 sətir
                        ),
                      ),
                      const SizedBox(height: 24), // Boşluq
                      Container( // Yadda saxla düyməsi üçün Konteyner
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
                          onPressed: saveChanges, // Düyməyə basıldıqda saveChanges funksiyasını çağırır
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
                            loc.save, // Lokalizasiyadan alınan 'yadda saxla' mətni
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

  // Etiketli sahə (TextField və ya DropdownButtonFormField) üçün köməkçi widget
  Widget _buildLabeledField(String label, Widget child) {
    return Column( // Şaquli istiqamətdə uşaq widget-ları yerləşdirmək üçün Sütun
      crossAxisAlignment: CrossAxisAlignment.start, // Məzmunu sola hizalayır
      children: [
        Text( // Etiket mətni
          label,
          style: TextStyle( // Mətn stili
            fontWeight: FontWeight.bold, // Qalın şrift
            color: Colors.white.withOpacity(0.9), // Yarı-şəffaf ağ rəng
            shadows: const [ // Kölgə
              Shadow(blurRadius: 2.0, color: Colors.black38, offset: Offset(0.5, 0.5)),
            ],
          ),
        ),
        const SizedBox(height: 8), // Boşluq
        child, // Uşaq widget-i (mətn sahəsi və ya açılan menyu)
      ],
    );
  }
}
