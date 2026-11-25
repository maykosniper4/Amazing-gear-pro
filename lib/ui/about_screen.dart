import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_theme.dart';

class AboutScreen extends StatelessWidget {
  final GameTheme gameTheme;

  const AboutScreen({super.key, required this.gameTheme});

  @override
  Widget build(BuildContext context) {
    final color = gameTheme.hudColor;
    return Scaffold(
      backgroundColor: gameTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: gameTheme.backgroundColor,
        foregroundColor: color,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/images/app_icon.png',
                        width: 112,
                        height: 112,
                        semanticLabel: 'Amazing gear 2 icon',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Amazing gear 2',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: color,
                          fontSize: 30,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 24),
                  Text('Developed by',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: color.withValues(alpha: 0.7))),
                  const SizedBox(height: 8),
                  Text('Bereketab Mihiretab',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: color,
                          fontSize: 22,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 32),
                  _contact(context, Icons.email_outlined, 'Email',
                      'bereketab00@gmail.com'),
                  _contact(context, Icons.send_outlined, 'Telegram',
                      '@BereketabMihiretab'),
                  _contact(
                      context, Icons.public, 'Facebook', '@bereketabmihiretab'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _contact(
      BuildContext context, IconData icon, String label, String value) {
    final color = gameTheme.hudColor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            color: color, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    SelectableText(value, style: TextStyle(color: color)),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Copy $label',
                color: color,
                icon: const Icon(Icons.copy_outlined, size: 20),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: value));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$label copied')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
