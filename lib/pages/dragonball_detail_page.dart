import 'package:flutter/material.dart';

import '../models/dragonball.dart';
import '../theme/app_theme.dart';

class DragonballDetailPage extends StatelessWidget {
  const DragonballDetailPage({super.key, required this.character});

  final Item character;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Detail Karakter'),
        actions: const [ThemeModeToggleButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CoverImage(url: character.image),
            const SizedBox(height: 20),
            Text(
              character.name,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Character ID #${character.id}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            _PowerCard(character: character),
            const SizedBox(height: 24),
            _SectionTitle(icon: Icons.menu_book_outlined, title: 'Sinopsis'),
            const SizedBox(height: 10),
            Text(
              character.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle(
              icon: Icons.info_outline,
              title: 'Informasi Karakter',
            ),
            const SizedBox(height: 10),
            Card(
              color: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.07),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.category_outlined,
                      label: 'Race',
                      value: _raceLabel(character.race),
                    ),
                    _InfoRow(
                      icon: Icons.wc_outlined,
                      label: 'Gender',
                      value: _genderLabel(character.gender),
                    ),
                    _InfoRow(
                      icon: Icons.groups_outlined,
                      label: 'Affiliation',
                      value: _affiliationLabel(character.affiliation),
                    ),
                    _InfoRow(
                      icon: Icons.verified_outlined,
                      label: 'Status data',
                      value: character.deletedAt == null
                          ? 'Aktif'
                          : 'Dihapus pada ${character.deletedAt}',
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 0.82,
        child: url.isEmpty
            ? ColoredBox(
                color: theme.colorScheme.surface,
                child: Icon(
                  Icons.person_outline,
                  color: theme.colorScheme.primary,
                  size: 80,
                ),
              )
            : Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => ColoredBox(
                  color: theme.colorScheme.surface,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: theme.colorScheme.primary,
                    size: 64,
                  ),
                ),
              ),
      ),
    );
  }
}

class _PowerCard extends StatelessWidget {
  const _PowerCard({required this.character});

  final Item character;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _PowerValue(
                label: 'Ki',
                value: character.ki,
                icon: Icons.bolt,
              ),
            ),
            Container(
              width: 1,
              height: 56,
              color: theme.colorScheme.primary.withValues(alpha: 0.25),
            ),
            Expanded(
              child: _PowerValue(
                label: 'Max Ki',
                value: character.maxKi,
                icon: Icons.auto_awesome,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PowerValue extends StatelessWidget {
  const _PowerValue({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color)),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 21),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

String _raceLabel(Race value) => switch (value) {
  Race.ANDROID => 'Android',
  Race.FRIEZA_RACE => 'Frieza Race',
  Race.HUMAN => 'Human',
  Race.NAMEKIAN => 'Namekian',
  Race.SAIYAN => 'Saiyan',
  Race.UNKNOWN => 'Unknown',
};

String _genderLabel(Gender value) => switch (value) {
  Gender.FEMALE => 'Female',
  Gender.MALE => 'Male',
  Gender.UNKNOWN => 'Unknown',
};

String _affiliationLabel(Affiliation value) => switch (value) {
  Affiliation.ARMY_OF_FRIEZA => 'Army of Frieza',
  Affiliation.FREELANCER => 'Freelancer',
  Affiliation.OTHER => 'Other',
  Affiliation.VILLAIN => 'Villain',
  Affiliation.Z_FIGHTER => 'Z Fighter',
  Affiliation.UNKNOWN => 'Unknown',
};
