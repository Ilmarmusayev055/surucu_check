import 'package:flutter/material.dart';
import 'package:surucu_check/l10n/app_localizations.dart';

class ChangePhonePage extends StatefulWidget {
  const ChangePhonePage({super.key});

  @override
  State<ChangePhonePage> createState() => _ChangePhonePageState();
}

class _ChangePhonePageState extends State<ChangePhonePage> {
  final TextEditingController currentPhoneController =
  TextEditingController(text: '501234567');
  final TextEditingController newPhoneController = TextEditingController();
  final TextEditingController confirmPhoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.changePhone),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            buildPhoneField(currentPhoneController, loc.currentPhone),
            const SizedBox(height: 16),
            buildPhoneField(newPhoneController, loc.newPhone),
            const SizedBox(height: 16),
            buildPhoneField(confirmPhoneController, loc.confirmNewPhone),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (newPhoneController.text == confirmPhoneController.text &&
                    newPhoneController.text.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.phoneUpdated)),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.phoneMismatch)),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(loc.save),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPhoneField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: label,
        prefixText: '+994 ',
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
