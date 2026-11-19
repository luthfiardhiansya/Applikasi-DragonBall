import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

import '../models/dragonball.dart';
import '../theme/app_theme.dart';
import 'dragonball_detail_page.dart';

class DragonballLoadingPage extends StatefulWidget {
  const DragonballLoadingPage({super.key});

  @override
  State<DragonballLoadingPage> createState() => _DragonballLoadingPageState();
}

class _DragonballLoadingPageState extends State<DragonballLoadingPage> {
  Timer? _navigationTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    // Durasi GIF mengikuti durasi video referensi sekitar 1,5 detik.
    _navigationTimer = Timer(
      const Duration(milliseconds: 1650),
      _openDragonballPage,
    );
  }

  void _openDragonballPage() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _navigationTimer?.cancel();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DragonballPage()),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Image.asset(
          'assets/loadingscreen.gif',
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class DragonballPage extends StatefulWidget {
  const DragonballPage({super.key});

  @override
  State<DragonballPage> createState() => _DragonballPageState();
}

class _DragonballPageState extends State<DragonballPage> {
  static const String _lottieAnimationUrl =
      'https://raw.githubusercontent.com/xvrh/lottie-flutter/master/example/assets/Mobilo/A.json';

  static final Uri _charactersUri = Uri.parse(
    'https://dragonball-api.com/api/characters?limit=100',
  );

  final TextEditingController _searchController = TextEditingController();
  late Future<Dragonball> _charactersFuture;
  Gender? _selectedGender;
  Race? _selectedRace;
  Affiliation? _selectedAffiliation;
  double? _minimumKi;
  double? _maximumKi;
  Timer? _filterLoadingTimer;
  bool _isFilterLoading = false;

  @override
  void initState() {
    super.initState();
    _charactersFuture = _fetchCharacters();
  }

  @override
  void dispose() {
    _filterLoadingTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterLoading() {
    _filterLoadingTimer?.cancel();
    setState(() => _isFilterLoading = true);
    _filterLoadingTimer = Timer(const Duration(milliseconds: 420), () {
      if (mounted) setState(() => _isFilterLoading = false);
    });
  }

  void _onSearchChanged(String _) {
    setState(() {});
  }

  void _onGenderChanged(Gender? gender) {
    setState(() => _selectedGender = gender);
    _showFilterLoading();
  }

  void _onRaceChanged(Race? race) {
    setState(() => _selectedRace = race);
    _showFilterLoading();
  }

  void _onAffiliationChanged(Affiliation? affiliation) {
    setState(() => _selectedAffiliation = affiliation);
    _showFilterLoading();
  }

  Future<Dragonball> _fetchCharacters() async {
    final response = await http.get(_charactersUri);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data karakter (${response.statusCode})');
    }

    return dragonballFromJson(response.body);
  }

  Future<void> _refresh() async {
    setState(() {
      _charactersFuture = _fetchCharacters();
    });
    await _charactersFuture;
  }

  List<Item> _filterCharacters(List<Item> characters) {
    final query = _searchController.text.trim().toLowerCase();

    return characters.where((character) {
      final matchesName = character.name.toLowerCase().contains(query);
      final matchesGender =
          _selectedGender == null || character.gender == _selectedGender;
      final matchesRace =
          _selectedRace == null || character.race == _selectedRace;
      final matchesAffiliation =
          _selectedAffiliation == null ||
          character.affiliation == _selectedAffiliation;
      final characterKi = kiToNumber(character.ki);
      final matchesMinimumKi =
          _minimumKi == null ||
          (characterKi != null && characterKi >= _minimumKi!);
      final matchesMaximumKi =
          _maximumKi == null ||
          (characterKi != null && characterKi <= _maximumKi!);

      return matchesName &&
          matchesGender &&
          matchesRace &&
          matchesAffiliation &&
          matchesMinimumKi &&
          matchesMaximumKi;
    }).toList();
  }

  bool get _hasActiveFilters =>
      _searchController.text.isNotEmpty ||
      _selectedGender != null ||
      _selectedRace != null ||
      _selectedAffiliation != null ||
      _minimumKi != null ||
      _maximumKi != null;

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedGender = null;
      _selectedRace = null;
      _selectedAffiliation = null;
      _minimumKi = null;
      _maximumKi = null;
    });
    _showFilterLoading();
  }

  Future<void> _showKiFilterDialog() async {
    final minimumController = TextEditingController(
      text: _minimumKi == null ? '' : _formatNumber(_minimumKi!),
    );
    final maximumController = TextEditingController(
      text: _maximumKi == null ? '' : _formatNumber(_maximumKi!),
    );

    final result = await showDialog<_KiRange>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Filter jumlah Ki'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: minimumController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Ki minimum',
                  hintText: 'Contoh: 1000',
                  prefixIcon: Icon(Icons.south_west),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: maximumController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Ki maksimum',
                  hintText: 'Contoh: 1000000',
                  prefixIcon: Icon(Icons.north_east),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, const _KiRange()),
              child: const Text('Hapus'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  _KiRange(
                    minimum: _parseInputNumber(minimumController.text),
                    maximum: _parseInputNumber(maximumController.text),
                  ),
                );
              },
              child: const Text('Terapkan'),
            ),
          ],
        );
      },
    );

    minimumController.dispose();
    maximumController.dispose();

    if (result != null && mounted) {
      setState(() {
        _minimumKi = result.minimum;
        _maximumKi = result.maximum;
      });
      _showFilterLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Dragon Ball Characters'),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: ThemeModeToggleButton(),
          ),
        ],
      ),
      body: FutureBuilder<Dragonball>(
        future: _charactersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingView();
          }

          if (snapshot.hasError) {
            return _ErrorView(
              message: snapshot.error.toString().replaceFirst(
                'Exception: ',
                '',
              ),
              onRetry: _refresh,
            );
          }

          final data = snapshot.data;
          if (data == null || data.items.isEmpty) {
            return Center(
              child: Text(
                'Data karakter tidak ditemukan.',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            );
          }

          final filteredCharacters = _filterCharacters(data.items);

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: _refresh,
                color: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.surface,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      sliver: SliverToBoxAdapter(
                        child: _FilterPanel(
                          controller: _searchController,
                          selectedGender: _selectedGender,
                          selectedRace: _selectedRace,
                          selectedAffiliation: _selectedAffiliation,
                          minimumKi: _minimumKi,
                          maximumKi: _maximumKi,
                          hasActiveFilters: _hasActiveFilters,
                          onSearchChanged: _onSearchChanged,
                          onGenderChanged: _onGenderChanged,
                          onRaceChanged: _onRaceChanged,
                          onAffiliationChanged: _onAffiliationChanged,
                          onKiFilterTap: _showKiFilterDialog,
                          onReset: _resetFilters,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      sliver: SliverToBoxAdapter(
                        child: _ResultSummary(
                          total: data.items.length,
                          shown: filteredCharacters.length,
                        ),
                      ),
                    ),
                    if (filteredCharacters.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptySearchResult(),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                        sliver: SliverLayoutBuilder(
                          builder: (context, constraints) {
                            final columns = constraints.crossAxisExtent >= 1100
                                ? 5
                                : constraints.crossAxisExtent >= 800
                                ? 4
                                : constraints.crossAxisExtent >= 560
                                ? 3
                                : 2;

                            return SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    mainAxisExtent: 294,
                                  ),
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final character = filteredCharacters[index];
                                return _CharacterCard(
                                  character: character,
                                  onTap: () => _showCharacterDetails(character),
                                );
                              }, childCount: filteredCharacters.length),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              if (_isFilterLoading) const _FilterLoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  void _showCharacterDetails(Item character) {
    _filterLoadingTimer?.cancel();
    setState(() => _isFilterLoading = true);
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => _isFilterLoading = false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DragonballDetailPage(character: character),
        ),
      );
    });
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.controller,
    required this.selectedGender,
    required this.selectedRace,
    required this.selectedAffiliation,
    required this.minimumKi,
    required this.maximumKi,
    required this.hasActiveFilters,
    required this.onSearchChanged,
    required this.onGenderChanged,
    required this.onRaceChanged,
    required this.onAffiliationChanged,
    required this.onKiFilterTap,
    required this.onReset,
  });

  final TextEditingController controller;
  final Gender? selectedGender;
  final Race? selectedRace;
  final Affiliation? selectedAffiliation;
  final double? minimumKi;
  final double? maximumKi;
  final bool hasActiveFilters;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<Gender?> onGenderChanged;
  final ValueChanged<Race?> onRaceChanged;
  final ValueChanged<Affiliation?> onAffiliationChanged;
  final VoidCallback onKiFilterTap;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onSearchChanged,
                textInputAction: TextInputAction.search,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Cari nama karakter...',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.colorScheme.primary,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.08,
                      ),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.08,
                      ),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _ResetButton(enabled: hasActiveFilters, onPressed: onReset),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                icon: Icons.people_alt_outlined,
                label: selectedGender == null
                    ? 'Gender'
                    : genderLabel(selectedGender!),
                selected: selectedGender == null,
                onPressed: () => _showGenderMenu(context),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                icon: Icons.category_outlined,
                label: selectedRace == null ? 'Ras' : raceLabel(selectedRace!),
                selected: selectedRace != null,
                onPressed: () => _showRaceMenu(context),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                icon: Icons.bolt,
                label: _kiLabel,
                selected: minimumKi != null || maximumKi != null,
                onPressed: onKiFilterTap,
              ),
              const SizedBox(width: 8),
              _FilterChip(
                icon: Icons.groups_outlined,
                label: selectedAffiliation == null
                    ? 'Affiliation'
                    : affiliationLabel(selectedAffiliation!),
                selected: selectedAffiliation != null,
                onPressed: () => _showAffiliationMenu(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String get _kiLabel {
    if (minimumKi == null && maximumKi == null) return 'Ki';
    final minimum = minimumKi == null ? '0' : _formatNumber(minimumKi!);
    final maximum = maximumKi == null ? '∞' : _formatNumber(maximumKi!);
    return 'Ki $minimum–$maximum';
  }

  Future<void> _showGenderMenu(BuildContext context) async {
    final selected = await showModalBottomSheet<_GenderChoice>(
      context: context,
      builder: (context) => _ChoiceSheet<_GenderChoice>(
        title: 'Filter gender',
        icon: Icons.people_alt_outlined,
        options: const [
          _ChoiceOption(value: _GenderChoice.all, label: 'Semua gender'),
          _ChoiceOption(value: _GenderChoice(Gender.MALE), label: 'Male'),
          _ChoiceOption(value: _GenderChoice(Gender.FEMALE), label: 'Female'),
        ],
        selected: _GenderChoice(selectedGender),
      ),
    );
    if (selected != null) {
      onGenderChanged(selected.gender);
    }
  }

  Future<void> _showRaceMenu(BuildContext context) async {
    final selected = await showModalBottomSheet<_RaceChoice>(
      context: context,
      builder: (context) => _ChoiceSheet<_RaceChoice>(
        title: 'Filter ras',
        icon: Icons.category_outlined,
        options: [
          const _ChoiceOption(value: _RaceChoice.all, label: 'Semua ras'),
          ...Race.values
              .where((race) => race != Race.UNKNOWN)
              .map(
                (race) => _ChoiceOption(
                  value: _RaceChoice(race),
                  label: raceLabel(race),
                ),
              ),
        ],
        selected: selectedRace == null
            ? _RaceChoice.all
            : _RaceChoice(selectedRace),
      ),
    );
    if (selected != null) {
      onRaceChanged(selected.race);
    }
  }

  Future<void> _showAffiliationMenu(BuildContext context) async {
    final selected = await showModalBottomSheet<_AffiliationChoice>(
      context: context,
      builder: (context) => _ChoiceSheet<_AffiliationChoice>(
        title: 'Filter affiliation',
        icon: Icons.groups_outlined,
        options: [
          const _ChoiceOption(
            value: _AffiliationChoice.all,
            label: 'Semua affiliation',
          ),
          ...Affiliation.values
              .where((affiliation) => affiliation != Affiliation.UNKNOWN)
              .map(
                (affiliation) => _ChoiceOption(
                  value: _AffiliationChoice(affiliation),
                  label: affiliationLabel(affiliation),
                ),
              ),
        ],
        selected: selectedAffiliation == null
            ? _AffiliationChoice.all
            : _AffiliationChoice(selectedAffiliation),
      ),
    );
    if (selected != null) {
      onAffiliationChanged(selected.affiliation);
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FilterChip(
      avatar: Icon(
        icon,
        size: 17,
        color: selected ? colors.onPrimary : colors.onSurfaceVariant,
      ),
      label: Text(label, overflow: TextOverflow.ellipsis),
      selected: selected,
      selectedColor: colors.primary,
      backgroundColor: colors.surface,
      checkmarkColor: colors.onPrimary,
      labelStyle: TextStyle(
        color: selected ? colors.onPrimary : colors.onSurfaceVariant,
      ),
      side: BorderSide(color: colors.onSurface.withValues(alpha: 0.08)),
      onSelected: (_) => onPressed(),
    );
  }
}

class _ResetButton extends StatelessWidget {
  const _ResetButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: enabled ? onPressed : null,
      tooltip: 'Reset filter',
      style: IconButton.styleFrom(
        minimumSize: const Size(52, 52),
        backgroundColor: colors.surface,
        foregroundColor: colors.primary,
        disabledForegroundColor: colors.onSurfaceVariant.withValues(
          alpha: 0.35,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.onSurface.withValues(alpha: 0.08)),
        ),
      ),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.restart_alt_rounded),
          if (enabled)
            Positioned(
              right: -4,
              top: -4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.error,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox(width: 7, height: 7),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChoiceOption<T> {
  const _ChoiceOption({required this.value, required this.label});

  final T value;
  final String label;
}

class _GenderChoice {
  const _GenderChoice(this.gender);

  static const all = _GenderChoice(null);

  final Gender? gender;

  @override
  bool operator ==(Object other) =>
      other is _GenderChoice && other.gender == gender;

  @override
  int get hashCode => gender.hashCode;
}

class _RaceChoice {
  const _RaceChoice(this.race);

  static const all = _RaceChoice(null);

  final Race? race;

  @override
  bool operator ==(Object other) => other is _RaceChoice && other.race == race;

  @override
  int get hashCode => race.hashCode;
}

class _AffiliationChoice {
  const _AffiliationChoice(this.affiliation);

  static const all = _AffiliationChoice(null);

  final Affiliation? affiliation;

  @override
  bool operator ==(Object other) =>
      other is _AffiliationChoice && other.affiliation == affiliation;

  @override
  int get hashCode => affiliation.hashCode;
}

class _ChoiceSheet<T> extends StatelessWidget {
  const _ChoiceSheet({
    required this.title,
    required this.icon,
    required this.options,
    required this.selected,
  });

  final String title;
  final IconData icon;
  final List<_ChoiceOption<T>> options;
  final T selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colors.primary),
                const SizedBox(width: 10),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 10),
            ...options.map(
              (option) => RadioListTile<T>(
                value: option.value,
                groupValue: selected,
                title: Text(option.label),
                onChanged: (value) => Navigator.pop(context, value),
                contentPadding: EdgeInsets.zero,
                activeColor: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultSummary extends StatelessWidget {
  const _ResultSummary({required this.total, required this.shown});

  final int total;
  final int shown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          '$shown karakter ditampilkan',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          'dari $total',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({required this.character, required this.onTap});

  final Item character;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      color: theme.colorScheme.surface,
      shadowColor: Colors.black.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.07),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CharacterImage(url: character.image),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          character.gender == Gender.FEMALE
                              ? Icons.female
                              : Icons.male,
                          size: 15,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${genderLabel(character.gender)} • ${raceLabel(character.race)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      'Ki: ${character.ki}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      affiliationLabel(character.affiliation),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
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

class _CharacterImage extends StatelessWidget {
  const _CharacterImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = url.isEmpty ? null : NetworkImage(url);

    return Ink(
      width: double.infinity,
      height: 172,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        image: image == null
            ? null
            : DecorationImage(image: image, fit: BoxFit.contain),
      ),
      child: image == null
          ? Center(
              child: Icon(
                Icons.person,
                color: theme.colorScheme.primary,
                size: 58,
              ),
            )
          : null,
    );
  }
}

class _FilterLoadingOverlay extends StatelessWidget {
  const _FilterLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Positioned.fill(
      child: ColoredBox(
        color: colors.scrim.withValues(alpha: 0.48),
        child: Center(
          child: Card(
            color: colors.surface,
            margin: const EdgeInsets.all(32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.network(
                    _DragonballPageState._lottieAnimationUrl,
                    height: 90,
                    repeat: true,
                  ),
                  Text(
                    'Memuat...',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptySearchResult extends StatelessWidget {
  const _EmptySearchResult();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.network(
              _DragonballPageState._lottieAnimationUrl,
              height: 150,
              repeat: true,
            ),
            const SizedBox(height: 12),
            Text(
              'Karakter tidak ditemukan',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Coba ubah kata kunci atau filter gender.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.network(
              _DragonballPageState._lottieAnimationUrl,
              height: 150,
              repeat: true,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.network(
        _DragonballPageState._lottieAnimationUrl,
        height: 180,
        repeat: true,
      ),
    );
  }
}

class _KiRange {
  const _KiRange({this.minimum, this.maximum});

  final double? minimum;
  final double? maximum;
}

double? _parseInputNumber(String value) {
  final normalized = value.trim().replaceAll(',', '.');
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}

String _formatNumber(double value) {
  if (value.isInfinite) return '∞';
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2);
}

double? kiToNumber(String value) {
  final normalized = value.trim().toLowerCase().replaceAll(',', '');
  final numberMatch = RegExp(r'\d+(?:\.\d+)?').firstMatch(normalized);
  if (numberMatch == null) return null;

  final number = double.tryParse(numberMatch.group(0)!);
  if (number == null) return null;
  if (normalized.contains('infinite')) return double.infinity;

  const multipliers = <String, double>{
    'thousand': 1e3,
    'million': 1e6,
    'billion': 1e9,
    'trillion': 1e12,
    'quadrillion': 1e15,
    'quintillion': 1e18,
    'sextillion': 1e21,
    'septillion': 1e24,
    'octillion': 1e27,
    'nonillion': 1e30,
    'decillion': 1e33,
  };

  for (final entry in multipliers.entries) {
    if (normalized.contains(entry.key)) return number * entry.value;
  }
  return number;
}

String raceLabel(Race value) => switch (value) {
  Race.ANDROID => 'Android',
  Race.FRIEZA_RACE => 'Frieza Race',
  Race.HUMAN => 'Human',
  Race.NAMEKIAN => 'Namekian',
  Race.SAIYAN => 'Saiyan',
  Race.UNKNOWN => 'Unknown',
};

String genderLabel(Gender value) => switch (value) {
  Gender.FEMALE => 'Female',
  Gender.MALE => 'Male',
  Gender.UNKNOWN => 'Unknown',
};

String affiliationLabel(Affiliation value) => switch (value) {
  Affiliation.ARMY_OF_FRIEZA => 'Army of Frieza',
  Affiliation.FREELANCER => 'Freelancer',
  Affiliation.OTHER => 'Other',
  Affiliation.VILLAIN => 'Villain',
  Affiliation.Z_FIGHTER => 'Z Fighter',
  Affiliation.UNKNOWN => 'Unknown',
};
