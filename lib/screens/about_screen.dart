import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            Image.asset('lib/assets/logo3.png',
                height: 250,
                width: double.infinity,
                fit: BoxFit.fitWidth,
                ),
            //image
            ElevatedButton.icon(
              onPressed: () async {
                if (await url_launcher
                    .canLaunchUrl(Uri.parse('https://t.me/xanon'))) {
                  await url_launcher.launchUrl(Uri.parse('https://t.me/xanon'));
                }
              },
              icon: const Icon(Icons.telegram),
              label: const Text('Contact the developer'),
            ),
          ],
        ),
      ),
    );
  }
}
