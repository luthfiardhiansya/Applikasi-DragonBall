import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({
    super.key,
    required this.nama,
    required this.kelas,
    required this.umur,
  });

  final String nama;
  final String kelas;
  final int umur;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Saya')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(radius: 32, child: Icon(Icons.person)),
                const SizedBox(height: 16),
                Text(nama, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('$kelas â€¢ $umur tahun'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
