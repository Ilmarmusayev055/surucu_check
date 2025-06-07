import 'dart:io'; // Fayl əməliyyatları üçün (şəkil seçimi)
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore verilənlər bazası ilə əlaqə üçün paket
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication xidməti üçün paket
import 'package:flutter/material.dart'; // Flutter Material dizayn komponentləri üçün paket
import 'package:image_picker/image_picker.dart'; // Şəkil seçmək üçün paket
import 'package:surucu_check/l10n/app_localizations.dart'; // Lokalizasiya (dil dəstəyi) üçün paket
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage (fayl saxlama) xidməti üçün paket
import 'dart:ui'; // ImageFilter kimi UI effektləri üçün dart:ui kitabxanası

// AddDriverPage dövlətli (stateful) widget-ıdır.
class AddDriverPage extends StatefulWidget {
  const AddDriverPage({super.key}); // Konstanta konstruktor

  @override
  State<AddDriverPage> createState() => _AddDriverPageState(); // Widget üçün State obyekti yaradır
}

// _AddDriverPageState State obyekti AddDriverPage-in vəziyyətini idarə edir.
class _AddDriverPageState extends State<AddDriverPage> {
  final nameController = TextEditingController(); // Ad sahəsi üçün TextEditingController
  final surnameController = TextEditingController(); // Soyad sahəsi üçün TextEditingController
  final fatherNameController = TextEditingController(); // Ata adı sahəsi üçün TextEditingController
  final finController = TextEditingController(); // FİN sahəsi üçün TextEditingController
  final svController = TextEditingController(); // SV nömrəsi sahəsi üçün TextEditingController
  final phoneController = TextEditingController(); // Telefon nömrəsi sahəsi üçün TextEditingController
  final noteController = TextEditingController(); // Qeyd sahəsi üçün TextEditingController

  String? selectedStatus; // Seçilmiş status
  String? selectedReason; // Seçilmiş səbəb (əgər status problemlidirsə)
  XFile? driverImage; // Seçilmiş sürücü şəkli faylı (XFile ImagePicker-dən gəlir)

  final _formKey = GlobalKey<FormState>(); // Form vəziyyətini idarə etmək üçün GlobalKey

  // FİN və SV sahələri üçün FocusNode-ları birbaşa ilkinləşdirin.
  final FocusNode _finFocusNode = FocusNode();
  final FocusNode _svFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Hər bir TextEditingController üçün listener əlavə edildi.
    // Bu, hər xanadakı mətn dəyişdikdə "x" düyməsinin görünürlüğünü yeniləməyə kömək edir.
    nameController.addListener(_onFieldChanged);
    surnameController.addListener(_onFieldChanged);
    fatherNameController.addListener(_onFieldChanged);
    finController.addListener(_onFieldChanged);
    svController.addListener(_onFieldChanged);
    phoneController.addListener(_onFieldChanged);
    noteController.addListener(_onFieldChanged);

    // selectedStatus üçün ilkin dəyər təyin edin
    selectedStatus = 'Problemsiz'; // Default dəyər

    // Səhifə yüklənən kimi xəbərdarlıq pəncərəsini göstərin
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFinSvWarningDialog();
    });
  }

  @override
  void dispose() {
    // Controller-lər dispose metodunda listener-lərlə birlikdə azad edilir.
    // Bu, yaddaş sızmasının qarşısını almaq üçün vacibdir.
    nameController.removeListener(_onFieldChanged);
    surnameController.removeListener(_onFieldChanged);
    fatherNameController.removeListener(_onFieldChanged);
    finController.removeListener(_onFieldChanged);
    svController.removeListener(_onFieldChanged);
    phoneController.removeListener(_onFieldChanged);
    noteController.removeListener(_onFieldChanged);

    // FocusNode-ları dispose edin
    _finFocusNode.dispose();
    _svFocusNode.dispose();

    nameController.dispose();
    surnameController.dispose();
    fatherNameController.dispose();
    finController.dispose();
    svController.dispose();
    phoneController.dispose();
    noteController.dispose();
    super.dispose();
  }

  // Sahələrdə dəyişiklik olduqda UI-ı yeniləmək üçün callback funksiyası.
  void _onFieldChanged() {
    setState(() {
      // Bu metod, TextField-lərin `suffixIcon` vəziyyətini yeniləmək üçün
      // `setState` funksiyasını çağırır.
    });
  }

  // Səhifəyə daxil olan kimi FİN/SV xanaları üçün xəbərdarlıq pəncərəsini göstərir.
  void _showFinSvWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Dialogu kənara toxunaraq bağlamağı qadağan edin
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Xəbərdarlıq!", style: TextStyle(color: Colors.black87)),
          content: RichText( // RichText istifadə edərək mətnin bir hissəsini qalın edirik
            text: TextSpan(
              style: const TextStyle(color: Colors.black54),
              children: [
                const TextSpan(text: "FİN və SV nömrəsi xanaları boş buraxıla bilməz. Əgər bu məlumatlar yoxdursa "),
                TextSpan(
                  text: "\"Məlumat yoxdur\"",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: " yazın!"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Anladım", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  // Şəkil seçmək üçün funksiya (kamera və ya qalereya).
  Future<void> pickImage({bool fromCamera = false}) async {
    final picker = ImagePicker(); // ImagePicker obyekti yaradır
    final image = await picker.pickImage( // Şəkil seçir
        source: fromCamera ? ImageSource.camera : ImageSource.gallery); // Mənbəni təyin edir
    if (image != null) { // Əgər şəkil seçilibsə
      setState(() {
        driverImage = image; // Seçilmiş şəkli saxlayır
      });
    }
  }

  // Formu göndərmək üçün funksiya.
  Future<void> handleSubmit() async {
    if (!_formKey.currentState!.validate()) return; // Form validasiyasını yoxlayır, keçmirsə çıxır

    final user = FirebaseAuth.instance.currentUser; // Cari istifadəçini alır
    if (user == null) return; // İstifadəçi yoxdursa çıxır

    final doc =
    await FirebaseFirestore.instance.collection('users').doc(user.uid).get(); // İstifadəçi sənədini alır
    final ownerName = '${doc['name']} ${doc['surname']}'; // Sahibkarın adını və soyadını alır
    final ownerPark = doc['park']; // Sahibkarın parkını alır
    final ownerPhone = doc['phone']; // Sahibkarın telefon nömrəsini alır

    final entry = { // Yeni qeyd obyekti yaradır
      'owner': ownerName, // Sahibkarın adı
      'ownerUid': user.uid, // Cari istifadəçinin UID-si
      'park': ownerPark, // Park
      'ownerPhone': ownerPhone, // Sahibkarın telefon nömrəsi
      'status': selectedStatus ?? 'Problemsiz', // Status (Əgər null olarsa 'Problemsiz' qəbul edir)
      'note': noteController.text.trim(), // Qeyd mətni
      'date': Timestamp.now(), // Cari tarix və zaman (Timestamp olaraq)
      'reason': (selectedStatus == 'Problemli' && selectedReason != null) ? selectedReason : null, // Əgər status problemlidirsə səbəbi saxlayır
    };

    // FİN və SV nömrələrini normallaşdırın (Firestore-a göndərmədən əvvəl "Məlumat yoxdur"u boş sətirə çevirin)
    String finToStore = finController.text.trim().toUpperCase();
    String svToStore = svController.text.trim().toUpperCase();

    if (finToStore == 'MƏLUMAT YOXDUR') {
      finToStore = '';
    }
    if (svToStore == 'MƏLUMAT YOXDUR') {
      svToStore = '';
    }

    final driverData = { // Yeni sürücü məlumatı obyekti yaradır
      'name': nameController.text.trim(), // Ad
      'surname': surnameController.text.trim(), // Soyad
      'fatherName': fatherNameController.text.trim(), // Ata adı
      'fin': finToStore, // FİN
      'sv': svToStore, // SV nömrəsi
      'phone': phoneController.text.trim().replaceFirst('+994', ''), // Telefon nömrəsi (prefiks təmizlənir)
      'photoUrl': '', // Şəkil URL-i (əvvəlcə boş, sonra yüklənəcək)
      'entries': [entry] // Giriş qeydləri
    };

    DocumentSnapshot? matchingDriverDoc; // Match olan sürücü sənədini saxlamaq üçün

    // 1. FIN nömrəsinə görə axtarış aparın
    if (finToStore.isNotEmpty) {
      final finQuerySnapshot = await FirebaseFirestore.instance
          .collection('drivers')
          .where('fin', isEqualTo: finToStore)
          .limit(1)
          .get();
      if (finQuerySnapshot.docs.isNotEmpty) {
        matchingDriverDoc = finQuerySnapshot.docs.first;
      }
    }

    // 2. Əgər FIN-ə görə tapılmayıbsa və SV nömrəsi boş deyilsə, SV nömrəsinə görə axtarış aparın
    if (matchingDriverDoc == null && svToStore.isNotEmpty) {
      final svQuerySnapshot = await FirebaseFirestore.instance
          .collection('drivers')
          .where('sv', isEqualTo: svToStore)
          .limit(1)
          .get();
      if (svQuerySnapshot.docs.isNotEmpty) {
        matchingDriverDoc = svQuerySnapshot.docs.first;
      }
    }

    // 3. Əgər yuxarıdakı heç birinə görə tapılmayıbsa VƏ Ad, Soyad və Ata adı doldurulubsa, Ad, Soyad və Ata adına görə axtarış aparın
    final nameTrimmed = nameController.text.trim();
    final surnameTrimmed = surnameController.text.trim();
    final fatherNameTrimmed = fatherNameController.text.trim();

    if (matchingDriverDoc == null &&
        nameTrimmed.isNotEmpty &&
        surnameTrimmed.isNotEmpty &&
        fatherNameTrimmed.isNotEmpty) {
      final nameSurnameFatherQuerySnapshot = await FirebaseFirestore.instance
          .collection('drivers')
          .where('name', isEqualTo: nameTrimmed)
          .where('surname', isEqualTo: surnameTrimmed)
          .where('fatherName', isEqualTo: fatherNameTrimmed)
          .limit(1)
          .get();
      if (nameSurnameFatherQuerySnapshot.docs.isNotEmpty) {
        matchingDriverDoc = nameSurnameFatherQuerySnapshot.docs.first;
      }
    }

    if (matchingDriverDoc != null) { // Əgər mövcud sürücü tapılarsa
      final docId = matchingDriverDoc.id; // Mövcud sürücünün sənəd ID-sini alır
      await FirebaseFirestore.instance.collection('drivers').doc(docId).update({
        'entries': FieldValue.arrayUnion([entry]), // Yeni qeydi mövcud qeydlər siyahısına əlavə edir
      });
    } else { // Mövcud sürücü tapılmazsa
      final newDriverDoc = await FirebaseFirestore.instance.collection('drivers').add(driverData); // Yeni sürücü sənədi əlavə edir
      // Əgər şəkil seçilibsə, onu Firebase Storage-a yükləyir
      if (driverImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('driver_images/${newDriverDoc.id}_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(File(driverImage!.path));
        final downloadUrl = await ref.getDownloadURL();
        await newDriverDoc.update({'photoUrl': downloadUrl}); // Yüklənmiş şəklin URL-ni sürücü sənədinə yazır
      }
    }

    if (context.mounted) { // Kontekst hələ də mounted-dirsə
      ScaffoldMessenger.of(context).showSnackBar( // SnackBar ilə uğurlu mesaj göstərir
        SnackBar(content: Text(AppLocalizations.of(context)!.addDriverSuccess)),
      );
      Navigator.pop(context); // Səhifədən çıxır
    }
  }

  // Özelleşdirilmiş mətn sahəsi (TextFormField) widget-i.
  // İndi bu metod mətn sahəsinin sağında "x" düyməsi əlavə edəcək.
  Widget _buildStyledTextFormField(TextEditingController controller, String labelText,
      {int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
        VoidCallback? onTap,
        TextCapitalization textCapitalization = TextCapitalization.none,
        String? hintText,
        String? prefixText, // Prefiks mətni, məsələn, "+994"
        bool isOptional = false, // Yeni parametr: sahə məcburi deyil
        FocusNode? focusNode, // Yeni parametr: FocusNode
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
      child: TextFormField( // Mətn sahəsi widget-i
        controller: controller, // Kontroler
        maxLines: maxLines, // Maksimum sətir sayı
        keyboardType: keyboardType, // Klaviatura növü
        textCapitalization: textCapitalization, // Mətnin avtomatik böyük hərflə başlaması
        focusNode: focusNode, // FocusNode-u əlavə edin
        onTap: () {
          // Telefon nömrəsi sahəsi üçün xüsusi işləmə:
          // Əgər sahə boşdursa və klaviatura telefon nömrəsi üçündürsə, "+994" prefiksini əlavə edir.
          if (keyboardType == TextInputType.phone && controller.text.isEmpty) {
            controller.text = '+994'; // Prefiksi əlavə edin

            // Kursoru prefiksdən sonra yerləşdirmək.
            controller.selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length),
            );
          }
          onTap?.call(); // Əgər əlavə onTap callback varsa, onu çağırır.
        },
        validator: (value) {
          if (isOptional) { // Əgər sahə məcburi deyilsə
            return null; // Validasiya yoxdur
          }
          // Validasiya məntiqi: dəyər boşdursa və ya null-dırsa xəta mesajı qaytarır.
          if (value == null || value.isEmpty || (prefixText != null && value == prefixText)) { // "Məlumat yoxdur" dəyərini artıq yoxlamırıq
            // Telefon nömrəsi üçün: əgər yalnız '+994' varsa, onu da boş sayır.
            if (keyboardType == TextInputType.phone && value == '+994') {
              return 'Məcburi sahədir';
            }
            return 'Məcburi sahədir';
          }
          return null;
        },
        style: const TextStyle(color: Colors.white, fontSize: 16), // Mətn stili (rəngi ağ)
        decoration: InputDecoration( // Mətn sahəsinin bəzəyi
          labelText: labelText, // Etiket mətni
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
          prefixText: prefixText, // Prefiks mətni (məsələn, telefon üçün "+994")
          // "x" düyməsi: yalnız mətn sahəsi boş olmadıqda və ya yalnız prefiks olmadıqda görünür.
          suffixIcon: controller.text.isNotEmpty && (prefixText == null || controller.text != prefixText)
              ? IconButton( // "Məlumat yoxdur" sözünü artıq yoxlamırıq
            icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.7)),
            onPressed: () {
              controller.clear(); // Mətn sahəsini təmizləyir.
              if (prefixText != null && prefixText.isNotEmpty) {
                controller.text = prefixText; // Əgər prefiks varsa, təmizlədikdən sonra onu bərpa edir.
              }
              setState(() {
                // UI-ı yeniləmək üçün (əsasən "x" düyməsinin görünürlüğünü tənzimləmək üçün).
              });
            },
          )
              : null, // Əks halda null (düymə görünmür).
        ),
      ),
    );
  }

  // Özelleşdirilmiş DropdownButtonFormField widget-i.
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
      resizeToAvoidBottomInset: true, // Klaviatura açıldığında layoutu avtomatik tənzimləsin
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
                  loc.addDriverTitle, // Lokalizasiyadan alınan başlıq
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
                  child: Form( // Form widget-i (validasiya üçün)
                    key: _formKey, // Formun GlobalKey-i
                    child: Column( // Formun elementləri üçün Sütun
                      children: [
                        // Ad sahəsi
                        _buildStyledTextFormField(nameController, loc.name, hintText: loc.name, textCapitalization: TextCapitalization.words),
                        const SizedBox(height: 16), // Boşluq
                        // Soyad sahəsi
                        _buildStyledTextFormField(surnameController, loc.surname, hintText: loc.surname, textCapitalization: TextCapitalization.words),
                        const SizedBox(height: 16), // Boşluq
                        // Ata adı sahəsi
                        _buildStyledTextFormField(fatherNameController, loc.fatherName ?? 'Ata adı', hintText: loc.fatherName ?? 'Ata adı', textCapitalization: TextCapitalization.words),
                        const SizedBox(height: 16), // Boşluq
                        // FİN sahəsi
                        _buildStyledTextFormField(finController, loc.fin, textCapitalization: TextCapitalization.characters, hintText: loc.fin, focusNode: _finFocusNode),
                        const SizedBox(height: 16), // Boşluq
                        // SV nömrəsi sahəsi
                        _buildStyledTextFormField(svController, loc.license, textCapitalization: TextCapitalization.characters, hintText: loc.license, focusNode: _svFocusNode),
                        const SizedBox(height: 16), // Boşluq
                        // Telefon nömrəsi sahəsi
                        _buildStyledTextFormField(
                          phoneController,
                          loc.phone,
                          keyboardType: TextInputType.phone,
                          hintText: loc.phone,
                          prefixText: '+994', // Prefiks avtomatik əlavə edilir.
                          isOptional: true, // Telefon nömrəsi sahəsi məcburi deyil
                        ),
                        const SizedBox(height: 16), // Boşluq
                        // Status seçimi üçün DropdownButtonFormField
                        _buildStyledDropdownButtonFormField<String>(
                          value: selectedStatus,
                          items: [
                            DropdownMenuItem(value: 'Problemli', child: Text(loc.problematic, style: const TextStyle(color: Colors.white))),
                            DropdownMenuItem(value: 'Problemsiz', child: Text(loc.notProblematic, style: const TextStyle(color: Colors.white))),
                          ],
                          onChanged: (value) => setState(() {
                            selectedStatus = value;
                            if (selectedStatus == 'Problemsiz') selectedReason = null; // Status problemsizsə səbəbi sıfırla
                          }),
                          labelText: loc.status,
                        ),
                        const SizedBox(height: 16), // Boşluq
                        // Əgər status problemlidirsə, səbəb seçimi göstərilir.
                        if (selectedStatus == 'Problemli')
                          _buildStyledDropdownButtonFormField<String>( // Səbəb seçimi
                            value: selectedReason,
                            items: [
                              DropdownMenuItem(value: 'Borcu var', child: Text(loc.reasonDebt, style: const TextStyle(color: Colors.white))),
                              DropdownMenuItem(value: 'Maşını vurub', child: Text(loc.reasonAccident, style: const TextStyle(color: Colors.white))),
                              DropdownMenuItem(value: 'Cərimə saxlayıb', child: Text(loc.reasonPenalty, style: const TextStyle(color: Colors.white))),
                              DropdownMenuItem(value: 'Digər', child: Text(loc.reasonOther, style: const TextStyle(color: Colors.white))),
                            ],
                            onChanged: (value) => setState(() => selectedReason = value),
                            labelText: loc.reason,
                          ),
                        const SizedBox(height: 16), // Boşluq
                        // Qeyd sahəsi
                        _buildStyledTextFormField(noteController, loc.note, maxLines: 3, hintText: loc.note),
                        const SizedBox(height: 16), // Boşluq
                        // Əgər sürücü şəkli seçilibsə, onu göstər.
                        if (driverImage != null)
                          ClipRRect( // Kənar radiusu ilə kəsmək üçün
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file( // Şəkli fayldan göstər
                              File(driverImage!.path),
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(height: 16), // Boşluq
                        // Şəkil yükləmə düyməsi üçün Konteyner.
                        Container(
                          decoration: BoxDecoration( // Bəzək
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)], // Bənövşəyi gradient
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.4),
                                blurRadius: 15,
                                spreadRadius: 5,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: TextButton.icon( // Şəkil yükləmə düyməsi
                            onPressed: () => showDialog( // Düyməyə basıldıqda dialoq göstər
                              context: context,
                              builder: (_) => AlertDialog( // Şəkil yükləmə dialoqu
                                backgroundColor: Colors.white.withOpacity(0.2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                content: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                    child: Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
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
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(loc.uploadPhoto, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, shadows: [
                                            Shadow(blurRadius: 5.0, color: Colors.black38, offset: Offset(1.0, 1.0)),
                                          ])),
                                          const SizedBox(height: 20),
                                          Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)], // Mavi gradient
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                              borderRadius: BorderRadius.circular(30),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.blue.withOpacity(0.4),
                                                  blurRadius: 15,
                                                  spreadRadius: 5,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                            ),
                                            child: TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                pickImage(fromCamera: false);
                                              },
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                minimumSize: const Size(double.infinity, 48),
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                              child: Text(loc.fromGallery, style: const TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)], // Yaşıl gradient
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
                                            child: TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                pickImage(fromCamera: true);
                                              },
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                minimumSize: const Size(double.infinity, 48),
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                              child: Text(loc.fromCamera, style: const TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                actionsPadding: const EdgeInsets.all(20),
                              ),
                            ),
                            icon: const Icon(Icons.photo_camera, color: Colors.white), // İkon
                            label: Text(loc.uploadPhoto, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), // Mətn
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              foregroundColor: Colors.white, // Mətn rəngi
                            ),
                          ),
                        ),
                        const SizedBox(height: 24), // Boşluq
                        // Sürücünü əlavə et düyməsi üçün Konteyner
                        Container(
                          decoration: BoxDecoration( // Bəzək
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
                          child: ElevatedButton( // Yüksəldilmiş düymə
                            onPressed: handleSubmit, // Düyməyə basıldıqda handleSubmit funksiyasını çağırır
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
                              loc.addDriver, // Lokalizasiyadan alınan 'sürücünü əlavə et' mətni
                              style: const TextStyle( // Mətn stili
                                fontSize: 18, // Şrift ölçüsü
                                fontWeight: FontWeight.bold, // Qalın şrift
                                letterSpacing: 1, // Hərf aralığı
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
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
