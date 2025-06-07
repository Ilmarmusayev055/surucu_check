import 'package:flutter/material.dart';
import 'package:surucu_check/l10n/app_localizations.dart';

class DriverDetailPage extends StatefulWidget {
  final Map<String, String> driver;

  const DriverDetailPage({super.key, required this.driver});

  @override
  State<DriverDetailPage> createState() => _DriverDetailPageState();
}

class _DriverDetailPageState extends State<DriverDetailPage> {
  late String status;
  late TextEditingController noteController;

  final List<String> statusOptions = ['Problemli', 'Problemsiz'];
  final List<String> problemReasons = ['Borcu var', 'Maşını vurub', 'Cərimə saxlayıb', 'Digər'];
  String? selectedReason;

  @override
  void initState() {
    super.initState();
    status = widget.driver['status'] ?? 'Problemsiz';
    noteController = TextEditingController(text: widget.driver['note'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.driverDetailTitle),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sürücü Məlumatları
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    buildDetailRow(loc.nameSurname, widget.driver['name']),
                    buildDetailRow(loc.phone, widget.driver['phone']),
                    buildDetailRow(loc.license, widget.driver['sv']),
                    buildDetailRow(loc.fin, widget.driver['fin']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Status və Qeyd
            Text(loc.status, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: status,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: statusOptions
                  .map((val) => DropdownMenuItem(value: val, child: Text(val == 'Problemli' ? loc.problematic : loc.notProblematic)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  status = val!;
                });
              },
            ),
            if (status == 'Problemli') ...[
              const SizedBox(height: 16),
              Text(loc.reason, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedReason,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: problemReasons
                    .map((r) => DropdownMenuItem(value: r, child: Text(getLocalizedReason(context, r))))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedReason = val;
                  });
                },
              ),
            ],
            const SizedBox(height: 24),
            Text(loc.note),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.addDriverSuccess)),
                );
              },
              child: Text(loc.save),
            )
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('$title:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 5, child: Text(value ?? '-')),
        ],
      ),
    );
  }

  String getLocalizedReason(BuildContext context, String reasonKey) {
    final loc = AppLocalizations.of(context)!;
    switch (reasonKey) {
      case 'Borcu var':
        return loc.reasonDebt;
      case 'Maşını vurub':
        return loc.reasonAccident;
      case 'Cərimə saxlayıb':
        return loc.reasonPenalty;
      case 'Digər':
        return loc.reasonOther;
      default:
        return reasonKey;
    }
  }
}