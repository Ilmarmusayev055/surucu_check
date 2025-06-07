// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:surucu_check/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui'; // For ImageFilter

import 'driver_edit_page.dart'; // Driver edit page importu
import 'main.dart'; // LoginPage üçün import (əgər istifadə olunursa)


class DriverListPage extends StatefulWidget {
  const DriverListPage({super.key});

  @override
  State<DriverListPage> createState() => _DriverListPageState();
}

class _DriverListPageState extends State<DriverListPage> {
  List<Map<String, dynamic>> myDrivers = [];
  String currentUserName = ''; // Cari istifadəçinin adını saxlamaq üçün
  bool isLoading = true; // Yüklənmə vəziyyətini izləmək üçün

  @override
  void initState() {
    super.initState();
    fetchDrivers();
  }

  Future<void> fetchDrivers() async {
    setState(() {
      isLoading = true; // Yüklənməyə başla
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final userData = userDoc.data();
    if (userData == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final ownerName = '${userData['name']} ${userData['surname']}';
    currentUserName = ownerName; // Cari istifadəçinin adını dəyişkənə mənimsədirik

    final snapshot = await FirebaseFirestore.instance.collection('drivers').get();
    final List<Map<String, dynamic>> drivers = [];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final entries = List<Map<String, dynamic>>.from(data['entries'] ?? []);
      // Yalnız cari sahibkara aid qeydləri filtrləyirik
      final ownEntries = entries.where((e) => e['owner'] == ownerName).toList();

      if (ownEntries.isNotEmpty) {
        drivers.add({
          'id': doc.id,
          'name': data['name'],
          'surname': data['surname'],
          'fatherName': data['fatherName'],
          'fin': data['fin'],
          'sv': data['sv'],
          'photoUrl': data['photoUrl'],
          'phone': data['phone'], // sürücü üçün qeyd olunmuş əsas telefon nömrəsi
          'entries': ownEntries, // Yalnız cari sahibkarın qeydlərini əlavə edirik
        });
      }
    }

    setState(() {
      myDrivers = drivers;
      isLoading = false; // Yüklənmə bitdi
    });
  }

  // Yalnız profil sahibinin əlavə etdiyi xüsusi bir qeydi silən funksiya
  Future<void> _deleteSpecificEntry(String driverId, Map<String, dynamic> entryToDelete) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Səlahiyyətiniz yoxdur. Zəhmət olmasa, yenidən daxil olun.')),
          );
        }
        return;
      }

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userData = userDoc.data();
      if (userData == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('İstifadəçi məlumatları tapılmadı.')),
          );
        }
        return;
      }

      final ownerName = '${userData['name']} ${userData['surname']}';

      // Təsdiq dialoqu göstər
      final bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Text('Qeydi Sil', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            content: const Text('Bu qeydi silmək istədiyinizə əminsinizmi? Bu əməliyyat geri qaytarıla bilməz.', style: TextStyle(color: Colors.black87)),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false); // Ləğv et
                },
                child: const Text('Ləğv et', style: TextStyle(color: Colors.blueAccent)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true); // Sil
                },
                child: const Text('Sil', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ) ?? false;

      if (confirmDelete) {
        final driverRef = FirebaseFirestore.instance.collection('drivers').doc(driverId);
        final driverDoc = await driverRef.get();
        final driverData = driverDoc.data();

        if (driverData != null && driverData.containsKey('entries')) {
          List<Map<String, dynamic>> entries = List<Map<String, dynamic>>.from(driverData['entries']);

          // Yalnız cari sahibkarın əlavə etdiyi və tarixi uyğun gələn qeydi silirik
          final initialLength = entries.length;
          entries.removeWhere((e) =>
          e['owner'] == ownerName &&
              (e['date'] is Timestamp && entryToDelete['date'] is Timestamp
                  ? e['date'] == entryToDelete['date']
                  : e['date'] == entryToDelete['date'])); // Timestamp-ları və ya String-ləri müqayisə et

          if (entries.length < initialLength) { // Əgər qeyd siliniblərsə
            await driverRef.update({'entries': entries});

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sürücü uğurla silindi.')),
              );
              // Detallar pəncərəsini bağlayır və siyahını yeniləyir
              Navigator.pop(context); // Detallar pəncərəsini bağlayır
              fetchDrivers(); // Siyahını yeniləyir
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Silmək üçün uyğun qeyd tapılmadı və ya siz bu qeydin sahibi deyilsiniz.')),
              );
            }
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sürücü məlumatları və ya qeydlər tapılmadı.')),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Qeydi silərkən xəta baş verdi: $e')),
        );
      }
    }
  }

  void showDriverDetails(BuildContext context, Map<String, dynamic> driver) {
    final loc = AppLocalizations.of(context)!;
    final isProblematic = driver['entries'].any((e) => e['status'] == 'Problemli');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.transparent, // Şəffaf fon
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero, // Kontent paddingini sıfırlayırıq ki, ClipRRect işləsin
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // İçindəki kontentin ölçüsünə uyğunlaşsın
                  children: [
                    Center(
                      child: Text(
                        '${driver['name']} ${driver['surname']} ${driver['fatherName'] ?? ''}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(blurRadius: 5.0, color: Colors.black38, offset: Offset(1.0, 1.0)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (driver['photoUrl'] != null && driver['photoUrl'] != '')
                      Center(
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(driver['photoUrl']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                    else
                      Center(
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                            color: Colors.grey.withOpacity(0.3), // Default ikon üçün fon
                          ),
                          child: Icon(Icons.person, size: 40, color: Colors.white.withOpacity(0.7)),
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildDetailText('Telefon nömrəsi: +994${driver['phone'] ?? "-"}', Colors.white.withOpacity(0.8)),
                    const SizedBox(height: 8),
                    Text(
                      'Status: ${isProblematic ? loc.problematic : loc.notProblematic}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isProblematic ? Colors.redAccent : Colors.greenAccent,
                        shadows: const [
                          Shadow(blurRadius: 5.0, color: Colors.black38, offset: Offset(1.0, 1.0)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc.activityPlaces,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                        shadows: [
                          Shadow(blurRadius: 5.0, color: Colors.black38, offset: Offset(1.0, 1.0)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Burada yalnız cari istifadəçinin qeydləri göstərilir, çünki fetchDrivers metodu bunu filtrləyir.
                    // Hər bir qeyd üçün "Sil" düyməsi əlavə etmək istəyirsinizsə, burada dəyişikliklər etmək lazımdır.
                    // Lakin hazırda istifadəçinin sorğusu açılan pəncərədəki _bir_ sil düyməsi üçündür.
                    ...driver['entries'].map<Widget>((entry) {
                      final reason = entry['status'] == 'Problemli' ? ' (${entry['reason']})' : '';
                      final dynamic dateData = entry['date'];
                      final String formattedDate;

                      if (dateData is Timestamp) {
                        final date = dateData.toDate();
                        formattedDate = '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
                      } else if (dateData is String) {
                        formattedDate = dateData;
                      } else {
                        formattedDate = '-';
                      }

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailText('Park: ${entry['park']}', Colors.white.withOpacity(0.8)),
                                _buildDetailText('Status: ${entry['status']}$reason', Colors.white.withOpacity(0.8)),
                                _buildDetailText('Sahibkar: ${entry['owner']}', Colors.white.withOpacity(0.8)),
                                _buildDetailText('Əlaqə: +994${entry['ownerPhone'] ?? "-"}', Colors.white.withOpacity(0.8)),
                                _buildDetailText('Əlavə etdiyi tarix: $formattedDate', Colors.white.withOpacity(0.8)),
                                _buildDetailText('Qeyd: ${entry['note'] ?? "-"}', Colors.white.withOpacity(0.8)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ),
        actions: [
          // Sil düyməsi
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFDC143C), Color(0xFFE57373)], // Crimson to light red gradient
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 5,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextButton(
              // Burada şikayətin silinməsi üçün yalnız cari istifadəçinin qeydlərindən ilkini hədəfləyirik.
              // Əgər sürücünün bir neçə qeydi varsa və hər birini ayrı-ayrı silmək lazımdırsa,
              // UI-da hər qeydin yanında sil düyməsi olmalıdır.
              onPressed: () {
                if (driver['entries'].isNotEmpty) {
                  _deleteSpecificEntry(driver['id'], driver['entries'][0]);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Silinəcək qeyd tapılmadı.')),
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Sil', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          Container(
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
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                minimumSize: Size.zero, // Minimal ölçünü sıfırlayır
                tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Toxunma sahəsini kiçildir
              ),
              child: Text(loc.close, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
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
                  color: Colors.green.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 5,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditDriverEntryPage(
                      driverId: driver['id'],
                      // Sadəcə ilk entry-ni düzəliş üçün göndəririk, çünki fetchDrivers
                      // metodu driver['entries'] yalnız cari istifadəçinin qeydlərini ehtiva edir.
                      entry: driver['entries'][0],
                    ),
                  ),
                );
                if (result == true) {
                  fetchDrivers(); // düzəlişdən sonra yenilə
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                minimumSize: Size.zero, // Minimal ölçünü sıfırlayır
                tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Toxunma sahəsini kiçildir
              ),
              child: Text(loc.edit, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // Məlumat mətnləri üçün köməkçi widget
  Widget _buildDetailText(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 14,
        shadows: const [
          Shadow(blurRadius: 2.0, color: Colors.black38, offset: Offset(0.5, 0.5)),
        ],
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
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  loc.driverListTitle,
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
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: isLoading
                      ? const Center(
                    child: CircularProgressIndicator(color: Colors.white), // Yüklənmə indikatoru
                  )
                      : myDrivers.isEmpty
                      ? Center(
                    child: Text(
                      loc.noDriversFound, // Sürücü tapılmadı mesajı
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        shadows: const [
                          Shadow(blurRadius: 2.0, color: Colors.black38, offset: Offset(0.5, 0.5)),
                        ],
                      ),
                    ),
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: BackdropFilter(
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
                        child: ListView.builder(
                          itemCount: myDrivers.length + 1, // Header row + drivers
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              // Header row
                              return _buildHeaderRow(loc);
                            }
                            final driver = myDrivers[index - 1];
                            final entry = driver['entries'][0];
                            final isProblematic = entry['status'] == 'Problemli';

                            return Column(
                              children: [
                                _buildDriverRow(context, driver, entry, isProblematic, loc),
                                if (index < myDrivers.length)
                                  Divider(color: Colors.white.withOpacity(0.3), height: 1),
                              ],
                            );
                          },
                        ),
                      ),
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

  // Custom Table Header Row
  Widget _buildHeaderRow(AppLocalizations loc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2), // Başlıq sətiri üçün bir az daha tünd fon
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)), // Üst küncləri yuvarlaq
      ),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(loc.nameSurname, style: _headerTextStyle()),
          ),
          Expanded(
            flex: 3,
            child: Text(loc.phoneNumber, style: _headerTextStyle()),
          ),
          Expanded(
            flex: 3,
            child: Text(loc.license, style: _headerTextStyle()),
          ),
          Expanded(
            flex: 2,
            child: Text(loc.status, style: _headerTextStyle()),
          ),
        ],
      ),
    );
  }

  // Custom Driver Data Row
  Widget _buildDriverRow(BuildContext context, Map<String, dynamic> driver, Map<String, dynamic> entry, bool isProblematic, AppLocalizations loc) {
    return GestureDetector(
      onTap: () => showDriverDetails(context, driver),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        color: Colors.transparent, // Arxa fon yoxdur, əsas konteyner tərəfindən idarə olunur
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                '${driver['name']} ${driver['surname']}',
                style: _dataTextStyle(),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                '+994${driver['phone'] ?? "-"}',
                style: _dataTextStyle(),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                driver['sv'] ?? '',
                style: _dataTextStyle(),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                entry['status'] ?? '',
                style: _dataTextStyle(
                  color: isProblematic ? Colors.redAccent : Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _headerTextStyle() {
    return const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontSize: 14,
      shadows: [
        Shadow(blurRadius: 2.0, color: Colors.black38, offset: Offset(0.5, 0.5)),
      ],
    );
  }

  TextStyle _dataTextStyle({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      color: color ?? Colors.white.withOpacity(0.8),
      fontSize: 13,
      fontWeight: fontWeight,
      shadows: const [
        Shadow(blurRadius: 1.0, color: Colors.black26, offset: Offset(0.3, 0.3)),
      ],
    );
  }

  String _formatDate(dynamic date) {
    try {
      if (date is Timestamp) {
        final d = date.toDate();
        return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
      } else if (date is String) {
        // Əgər date String kimi gəlirsə, onu olduğu kimi qaytar
        return date;
      }
      return date.toString();
    } catch (_) {
      return "-";
    }
  }
}
