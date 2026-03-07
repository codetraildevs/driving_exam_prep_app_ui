import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../data/models/sign_model.dart';
import '../../data/repositories/signs_repository.dart';

class SignsPage extends StatefulWidget {
  const SignsPage({Key? key}) : super(key: key);

  @override
  State<SignsPage> createState() => _SignsPageState();
}

class _SignsPageState extends State<SignsPage> {
  final signsRepo = SignsRepository();
  late TextEditingController _searchController;
  String _selectedCategory = '';
  List<String> _categories = [];
  late Future<List<TrafficSignModel>> _signsFuture;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadCategories();
    _loadSigns();
  }

  void _loadCategories() async {
    try {
      final categories = await signsRepo.getCategories();
      setState(() {
        _categories = ['All', ...categories];
        _selectedCategory = 'All';
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  void _loadSigns() {
    setState(() {
      _signsFuture = signsRepo.getTrafficSigns(
        category: _selectedCategory.isEmpty || _selectedCategory == 'All'
            ? null
            : _selectedCategory,
        searchQuery: _searchController.text,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).signsTitle),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildCategoryFilter(),
            Expanded(child: _buildSignsGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => _loadSigns(),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).signsSearchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _loadSigns();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                  _loadSigns();
                });
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.textInverse : AppColors.textPrimary,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.neutral300,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSignsGrid() {
    return FutureBuilder<List<TrafficSignModel>>(
      future: _signsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.traffic_outlined,
                  size: 64,
                  color: AppColors.neutral300,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).signsNotFound,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        final signs = snapshot.data!;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: signs.length,
          itemBuilder: (context, index) => _buildSignCard(signs[index]),
        );
      },
    );
  }

  Widget _buildSignCard(TrafficSignModel sign) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const SizedBox();
        }

        return FutureBuilder<bool>(
          future: signsRepo.isSignLearned(state.user.id, sign.id),
          builder: (context, snapshot) {
            final isLearned = snapshot.data ?? false;

            return GestureDetector(
              onTap: () => context.push('/signs/${sign.id}'),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.1),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '🛑',
                            style: TextStyle(fontSize: 48),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sign.title,
                            style: AppTextStyles.labelLarge,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          if (isLearned)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color: AppColors.success,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    AppLocalizations.of(context).signsLearned,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
