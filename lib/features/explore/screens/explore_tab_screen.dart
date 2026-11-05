import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:impact_loop/config/routes/app_routes.dart';
import 'package:impact_loop/core/models/mission_models.dart';
import 'package:impact_loop/core/utils/app_colors.dart';
import 'package:impact_loop/core/widgets/mission_card.dart';
import 'package:impact_loop/core/widgets/ui_kit.dart';
import 'package:impact_loop/features/auth/data/missions_repository.dart';
import 'package:impact_loop/injector.dart';

class ExploreTabScreen extends StatefulWidget {
  const ExploreTabScreen({super.key});

  @override
  State<ExploreTabScreen> createState() => _ExploreTabScreenState();
}

class _ExploreTabScreenState extends State<ExploreTabScreen> {
  final _searchController = TextEditingController();
  bool _loading = true;
  String? _error;
  List<MissionSummary> _allMissions = [];
  List<MissionSummary> _filteredMissions = [];
  String _selectedCategory = 'ALL';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String? query}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await serviceLocator<MissionsRepository>().listMissions(
      query: query,
    );
    result.fold(
      (l) => setState(() {
        _loading = false;
        _error = l.message;
      }),
      (r) => setState(() {
        _loading = false;
        _allMissions = r;
        _applyFilter();
      }),
    );
  }

  void _applyFilter() {
    if (_selectedCategory == 'ALL') {
      _filteredMissions = List.of(_allMissions);
    } else {
      _filteredMissions = _allMissions.where((m) {
        return m.taskTypes.contains(_selectedCategory);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'key': 'ALL', 'label': 'all'.tr()},
      {'key': 'DUMPING_REPORT', 'label': 'type_dumping'.tr()},
      {'key': 'RECYCLING_DROPOFF', 'label': 'type_recycling'.tr()},
      {'key': 'PUBLIC_TRANSPORT', 'label': 'type_transport'.tr()},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('explore_title'.tr()),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, Routes.notificationsRoute),
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'search_missions'.tr(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _load();
                        },
                      )
                    : null,
              ),
              onSubmitted: (val) => _load(query: val),
            ),
          ),
          // Filter Chips
          SizedBox(
            height: 48.h,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => Gap(8.w),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = _selectedCategory == cat['key'];
                return ChoiceChip(
                  label: Text(cat['label']!),
                  selected: isSelected,
                  selectedColor: AppColors.secondPrimary,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = cat['key']!;
                        _applyFilter();
                      });
                    }
                  },
                );
              },
            ),
          ),
          Gap(8.h),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? ErrorState(message: _error!, onRetry: _load)
                    : _filteredMissions.isEmpty
                        ? EmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'no_data'.tr(),
                            message: 'search_empty_hint'.tr(),
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.separated(
                              padding: EdgeInsets.all(16.w),
                              itemCount: _filteredMissions.length,
                              separatorBuilder: (_, __) => Gap(12.h),
                              itemBuilder: (context, index) {
                                final mission = _filteredMissions[index];
                                return MissionCard(
                                  mission: mission,
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    Routes.missionDetailRoute,
                                    arguments: mission.id,
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
