import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/data/categories.dart';
import '../../../core/data/puzzle_catalog.dart';
import '../../profile/providers/profile_provider.dart';
import '../../profile/screens/profile_view.dart';
import '../../stats/providers/stats_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/mode_button.dart';
import '../widgets/stat_chip.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTab = 0;

  final List<_TabItem> _tabs = const [
    _TabItem(icon: Icons.home_rounded, label: 'Inicio'),
    _TabItem(icon: Icons.leaderboard_rounded, label: 'Ranking'),
    _TabItem(icon: Icons.person_rounded, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(child: _buildTabBody(context)),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildTabBody(BuildContext context) {
    switch (_selectedTab) {
      case 1:
        return const _RankingPlaceholder();
      case 2:
        return const ProfileView();
      default:
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildModeSection(context)),
            SliverToBoxAdapter(child: _buildStatsRow(context)),
            SliverToBoxAdapter(child: _buildCategoriesSection(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        );
    }
  }

  Widget _buildHeader(BuildContext context) {
    final name = ref.watch(profileNameProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                      '¡Hola, $name! 👋',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: -0.2, end: 0),
                const SizedBox(height: 2),
                Text(
                      'PuzzleRace',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            color: AppTheme.accent,
                            letterSpacing: -1.0,
                          ),
                    )
                    .animate()
                    .fadeIn(delay: 100.ms)
                    .slideX(begin: -0.2, end: 0, delay: 100.ms),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: AppTheme.textPrimary,
                  size: 22,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.accentOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildModeSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Elige tu modo',
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child:
                    ModeButton(
                          icon: Icons.timer_rounded,
                          label: 'Solitario',
                          subtitle: 'Contra el reloj',
                          color: AppTheme.accent,
                          onTap: () => context.push(
                            AppRoutes.category,
                            extra: {'mode': 'solo'},
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideY(begin: 0.2, end: 0, delay: 300.ms),
              ),
              const SizedBox(width: 12),
              Expanded(
                child:
                    ModeButton(
                          icon: Icons.sports_esports_rounded,
                          label: '1 vs 1',
                          subtitle: 'En línea',
                          color: AppTheme.accentBlue,
                          onTap: () => context.push(
                            AppRoutes.category,
                            extra: {'mode': 'versus'},
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideY(begin: 0.2, end: 0, delay: 400.ms),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final stats = ref.watch(statsProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: StatChip(
              icon: Icons.emoji_events_rounded,
              value: '${stats.wins}',
              label: 'Victorias',
              color: AppTheme.accent,
            ).animate().fadeIn(delay: 500.ms),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: StatChip(
              icon: Icons.videogame_asset_rounded,
              value: '${stats.gamesPlayed}',
              label: 'Partidas',
              color: AppTheme.accentBlue,
            ).animate().fadeIn(delay: 580.ms),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: StatChip(
              icon: Icons.speed_rounded,
              value: stats.formattedBestOverall,
              label: 'Mejor tiempo',
              color: AppTheme.accentOrange,
            ).animate().fadeIn(delay: 660.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    // Muestra las primeras 4 categorías del modelo compartido; la pantalla
    // de categorías las lista todas.
    final categories = AppCategories.all.take(4).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Categorías',
          ).animate().fadeIn(delay: 600.ms),
          const SizedBox(height: 14),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.55,
            ),
            itemCount: categories.length,
            itemBuilder: (context, i) {
              final cat = categories[i];
              return CategoryCard(
                    emoji: cat.emoji,
                    label: cat.label,
                    count:
                        '${PuzzleCatalog.forCategory(cat.id).length} puzzles',
                    color: cat.color,
                    onTap: () => context.push(
                      AppRoutes.images,
                      extra: {
                        'mode': 'solo',
                        'categoryId': cat.id,
                        'categoryLabel': cat.label,
                        'categoryEmoji': cat.emoji,
                        'categoryColor': cat.color,
                      },
                    ),
                  )
                  .animate()
                  .fadeIn(delay: (700 + i * 80).ms)
                  .slideY(begin: 0.15, end: 0, delay: (700 + i * 80).ms);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (i) {
              final isSelected = _selectedTab == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedTab = i),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 80,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _tabs[i].icon,
                        color: isSelected
                            ? AppTheme.accent
                            : AppTheme.textMuted,
                        size: 24,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _tabs[i].label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? AppTheme.accent
                              : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}

/// Placeholder del tab Ranking (ítem 14 pendiente: requiere backend).
class _RankingPlaceholder extends StatelessWidget {
  const _RankingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentBlue.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppTheme.accentBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.leaderboard_rounded,
                  color: AppTheme.accentBlue,
                  size: 34,
                ),
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
          const SizedBox(height: 18),
          Text(
            'Ranking global',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 6),
          Text(
            'Disponible cuando llegue el modo online',
            style: Theme.of(context).textTheme.bodyMedium,
          ).animate().fadeIn(delay: 180.ms),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
    );
  }
}
