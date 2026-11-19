import 'package:flutter/material.dart';
import 'package:ujian_projek/navigation/about_page.dart';
import 'package:ujian_projek/pages/dragonball_page.dart';
import 'package:ujian_projek/theme/app_theme.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  static const Color background = Color(0xFF101419);
  static const Color surface = Color(0xFF191F26);
  static const Color accent = Color(0xFF8AB4F8);
  static const Color secondaryText = Color(0xFF929DAA);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),

              const SizedBox(height: 38),

              Text(
                'Widget Laboratory',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),

              const SizedBox(height: 24),

              _buildSectionLabel(context, 'MATERI PEMBELAJARAN'),

              const SizedBox(height: 14),

              _buildNavCard(
                context: context,
                number: '01',
                title: 'Dragon Ball',
                subtitle: 'Daftar karakter Dragon Ball dari API.',
                icon: Icons.auto_awesome,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DragonballLoadingPage(),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Center(
                child: Text(
                  'FLUTTER LEARNING PROJECT  •  2026',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;
    final accentColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.07),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                'A',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Muhammad Luthfi Ardhiansyah',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'XII RPL  •  17 Tahun',
                  style: TextStyle(color: secondaryColor, fontSize: 12),
                ),
              ],
            ),
          ),

          ValueListenableBuilder<ThemeMode>(
            valueListenable: appThemeMode,
            builder: (context, mode, _) {
              final isDark = mode == ThemeMode.dark;
              return IconButton(
                tooltip: isDark ? 'Gunakan light mode' : 'Gunakan dark mode',
                onPressed: () {
                  appThemeMode.value = isDark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                },
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.onSurface.withValues(
                    alpha: 0.06,
                  ),
                  foregroundColor: accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    key: ValueKey(isDark),
                    size: 19,
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 6),

          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutPage(
                    nama: 'Muhammad Luthfi Ardhiansyah',
                    kelas: 'XII RPL 3',
                    umur: 17,
                  ),
                ),
              );
            },
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.onSurface.withValues(
                alpha: 0.06,
              ),
              foregroundColor: accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.arrow_forward_rounded, size: 19),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildNavCard({
    required BuildContext context,
    required String number,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;
    final accentColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Material(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          splashColor: accentColor.withValues(alpha: 0.08),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              children: [
                Text(
                  number,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(width: 15),

                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accentColor, size: 22),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        subtitle,
                        style: TextStyle(color: secondaryColor, fontSize: 11),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 21,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
