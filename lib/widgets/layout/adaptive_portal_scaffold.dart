import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/institution_provider.dart';
import '../../services/navigation_preferences_service.dart';

class PortalSubItem {
  final String id;
  final String label;
  final IconData icon;
  final Widget body;
  final String? badge;

  const PortalSubItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.body,
    this.badge,
  });
}

class PortalTabItem {
  final String id;
  final String label;
  final IconData icon;
  final Widget? body;
  final String? badge;
  final List<PortalSubItem> subItems;

  const PortalTabItem({
    required this.id,
    required this.label,
    required this.icon,
    this.body,
    this.badge,
    this.subItems = const [],
  });

  bool get hasSubItems => subItems.isNotEmpty;
}

class PortalLeafItem {
  final String id;
  final String label;
  final String parentLabel;
  final IconData icon;
  final int tabIndex;
  final int subIndex;
  final Widget body;

  const PortalLeafItem({
    required this.id,
    required this.label,
    required this.parentLabel,
    required this.icon,
    required this.tabIndex,
    required this.subIndex,
    required this.body,
  });
}

class AdaptivePortalScaffold extends StatefulWidget {
  final String portalId;
  final String portalTitle;
  final String? portalSubtitle;
  final List<PortalTabItem> tabs;
  final int initialIndex;
  final int? initialSubIndex;
  final List<String>? defaultPinnedTabIds;
  final ValueChanged<int>? onTabChanged;
  final void Function(int tabIndex, int subIndex)? onSubTabChanged;
  final List<Widget>? headerActions;
  final VoidCallback? onBack;

  const AdaptivePortalScaffold({
    super.key,
    this.portalId = 'portal',
    required this.portalTitle,
    this.portalSubtitle,
    required this.tabs,
    this.initialIndex = 0,
    this.initialSubIndex,
    this.defaultPinnedTabIds,
    this.onTabChanged,
    this.onSubTabChanged,
    this.headerActions,
    this.onBack,
  });

  @override
  State<AdaptivePortalScaffold> createState() => _AdaptivePortalScaffoldState();
}

class _AdaptivePortalScaffoldState extends State<AdaptivePortalScaffold> {
  late int _currentTabIndex;
  late int _currentSubIndex;
  bool _isSidebarExpanded = true;
  List<String> _pinnedTabIds = [];
  bool _pinnedLoaded = false;

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.initialIndex.clamp(0, widget.tabs.isEmpty ? 0 : widget.tabs.length - 1);
    final activeTab = widget.tabs.isNotEmpty ? widget.tabs[_currentTabIndex] : null;
    final maxSub = (activeTab != null && activeTab.hasSubItems) ? activeTab.subItems.length - 1 : 0;
    _currentSubIndex = (widget.initialSubIndex ?? 0).clamp(0, maxSub < 0 ? 0 : maxSub);

    _loadPinnedTabs();
  }

  @override
  void didUpdateWidget(covariant AdaptivePortalScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex || widget.initialSubIndex != oldWidget.initialSubIndex) {
      _currentTabIndex = widget.initialIndex.clamp(0, widget.tabs.isEmpty ? 0 : widget.tabs.length - 1);
      final activeTab = widget.tabs.isNotEmpty ? widget.tabs[_currentTabIndex] : null;
      final maxSub = (activeTab != null && activeTab.hasSubItems) ? activeTab.subItems.length - 1 : 0;
      _currentSubIndex = (widget.initialSubIndex ?? 0).clamp(0, maxSub < 0 ? 0 : maxSub);
    }
  }

  List<PortalLeafItem> _getAllLeafItems() {
    final List<PortalLeafItem> leaves = [];
    for (int t = 0; t < widget.tabs.length; t++) {
      final tab = widget.tabs[t];
      if (tab.hasSubItems) {
        for (int s = 0; s < tab.subItems.length; s++) {
          final sub = tab.subItems[s];
          leaves.add(PortalLeafItem(
            id: sub.id,
            label: sub.label,
            parentLabel: tab.label,
            icon: sub.icon,
            tabIndex: t,
            subIndex: s,
            body: sub.body,
          ));
        }
      } else if (tab.body != null) {
        leaves.add(PortalLeafItem(
          id: tab.id,
          label: tab.label,
          parentLabel: tab.label,
          icon: tab.icon,
          tabIndex: t,
          subIndex: 0,
          body: tab.body!,
        ));
      }
    }
    return leaves;
  }

  Future<void> _loadPinnedTabs() async {
    final allLeaves = _getAllLeafItems();
    final defaultIds = widget.defaultPinnedTabIds != null && widget.defaultPinnedTabIds!.isNotEmpty
        ? widget.defaultPinnedTabIds!
        : allLeaves.take(4).map((l) => l.id).toList();

    final saved = await NavigationPreferencesService.getPinnedTabs(widget.portalId, defaultIds);
    if (mounted) {
      setState(() {
        _pinnedTabIds = saved;
        _pinnedLoaded = true;
      });
    }
  }

  void _selectSubItem(int tabIndex, int subIndex) {
    if (tabIndex < 0 || tabIndex >= widget.tabs.length) return;
    final tab = widget.tabs[tabIndex];
    final validSub = tab.hasSubItems
        ? subIndex.clamp(0, tab.subItems.isEmpty ? 0 : tab.subItems.length - 1)
        : 0;

    setState(() {
      _currentTabIndex = tabIndex;
      _currentSubIndex = validSub;
    });

    widget.onTabChanged?.call(tabIndex);
    widget.onSubTabChanged?.call(tabIndex, validSub);
  }

  PortalLeafItem? _getActiveLeaf() {
    final leaves = _getAllLeafItems();
    try {
      return leaves.firstWhere(
        (l) => l.tabIndex == _currentTabIndex && l.subIndex == _currentSubIndex,
      );
    } catch (_) {
      return leaves.isNotEmpty ? leaves.first : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 850;
    final provider = context.watch<InstitutionProvider>();
    final setting = provider.setting;

    if (widget.tabs.isEmpty) {
      return const Scaffold(body: Center(child: Text('No tabs configured.')));
    }

    if (isDesktop) {
      return _buildDesktopLayout(context, setting);
    } else {
      return _buildMobileLayout(context, setting);
    }
  }

  // ==================== DESKTOP / LAPTOP LAYOUT ====================
  Widget _buildDesktopLayout(BuildContext context, dynamic setting) {
    final currentTab = widget.tabs[_currentTabIndex];
    final activeLeaf = _getActiveLeaf();
    final activeBody = activeLeaf != null
        ? activeLeaf.body
        : (currentTab.body ?? const SizedBox.shrink());

    final breadcrumb = currentTab.hasSubItems
        ? '${currentTab.label} • ${activeLeaf?.label ?? ""}'
        : currentTab.label;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // 1. Top Desktop Header (STRICTLY CENTER-ALIGNED BRANDING)
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                // Left: Sidebar Toggle + Portal Tag
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: _isSidebarExpanded ? 'Collapse Sidebar' : 'Expand Sidebar',
                      icon: Icon(
                        _isSidebarExpanded ? Icons.menu_open_rounded : Icons.menu_rounded,
                        color: const Color(0xFF1E293B),
                        size: 24,
                      ),
                      onPressed: () {
                        setState(() {
                          _isSidebarExpanded = !_isSidebarExpanded;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Text(
                        widget.portalTitle,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D4ED8),
                        ),
                      ),
                    ),
                  ],
                ),

                // Center: Strictly Center-Aligned Logo + School Name + Active Breadcrumb
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                            color: Colors.white,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.school, size: 20, color: Color(0xFF2563EB)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              setting.institutionName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              breadcrumb,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2563EB),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Right: Actions & Back
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.headerActions != null) ...widget.headerActions!,
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: widget.onBack ?? () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: const Text('Back', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF475569),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Body Area (Sidebar on Left + Content Canvas on Right)
          Expanded(
            child: Row(
              children: [
                // Hierarchical Sidebar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  width: _isSidebarExpanded ? 260 : 72,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: widget.tabs.length,
                          itemBuilder: (ctx, tIdx) {
                            final tab = widget.tabs[tIdx];

                            if (_isSidebarExpanded) {
                              // EXPANDED HIERARCHICAL MODE
                              if (tab.hasSubItems) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Category Header
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        child: Row(
                                          children: [
                                            Icon(tab.icon, size: 16, color: const Color(0xFF64748B)),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                tab.label.toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF64748B),
                                                  letterSpacing: 0.6,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (tab.badge != null)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF1F5F9),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                                ),
                                                child: Text(
                                                  tab.badge!,
                                                  style: const TextStyle(color: Color(0xFF475569), fontSize: 9.5, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),

                                      // Nested Sub-Items
                                      ...List.generate(tab.subItems.length, (sIdx) {
                                        final sub = tab.subItems[sIdx];
                                        final isSelected = _currentTabIndex == tIdx && _currentSubIndex == sIdx;

                                        return Container(
                                          margin: const EdgeInsets.only(top: 2, left: 6),
                                          child: InkWell(
                                            onTap: () => _selectSubItem(tIdx, sIdx),
                                            borderRadius: BorderRadius.circular(8),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
                                                borderRadius: BorderRadius.circular(8),
                                                border: isSelected ? Border.all(color: const Color(0xFFBFDBFE)) : null,
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    sub.icon,
                                                    size: 17,
                                                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      sub.label,
                                                      style: TextStyle(
                                                        fontSize: 12.5,
                                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                                        color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF334155),
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  if (sub.badge != null)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                      decoration: BoxDecoration(
                                                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        sub.badge!,
                                                        style: TextStyle(
                                                          color: isSelected ? Colors.white : const Color(0xFF475569),
                                                          fontSize: 9.5,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                );
                              } else {
                                // Flat Tab Item
                                final isSelected = _currentTabIndex == tIdx;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: InkWell(
                                    onTap: () => _selectSubItem(tIdx, 0),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                        border: isSelected ? Border.all(color: const Color(0xFFBFDBFE)) : null,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(tab.icon, size: 20, color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              tab.label,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF334155),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            } else {
                              // COLLAPSED COMPACT MODE
                              final isSelected = _currentTabIndex == tIdx;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Tooltip(
                                  message: tab.label,
                                  preferBelow: false,
                                  child: InkWell(
                                    onTap: () {
                                      _selectSubItem(tIdx, 0);
                                      setState(() => _isSidebarExpanded = true);
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      width: 48,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                        border: isSelected ? Border.all(color: const Color(0xFFBFDBFE)) : null,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          tab.icon,
                                          size: 22,
                                          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),

                      // Sidebar Bottom Toggle
                      const Divider(height: 1),
                      InkWell(
                        onTap: () => setState(() => _isSidebarExpanded = !_isSidebarExpanded),
                        child: Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            mainAxisAlignment: _isSidebarExpanded ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                            children: [
                              if (_isSidebarExpanded)
                                const Text('Collapse Menu', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                              Icon(
                                _isSidebarExpanded ? Icons.keyboard_double_arrow_left_rounded : Icons.keyboard_double_arrow_right_rounded,
                                size: 18,
                                color: const Color(0xFF64748B),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content Canvas (Takes full width, NO top subtab bar!)
                Expanded(
                  child: activeBody,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== MOBILE PHONE LAYOUT ====================
  Widget _buildMobileLayout(BuildContext context, dynamic setting) {
    final activeLeaf = _getActiveLeaf();
    final activeBody = activeLeaf != null
        ? activeLeaf.body
        : (widget.tabs[_currentTabIndex].body ?? const SizedBox.shrink());

    final allLeaves = _getAllLeafItems();

    // Determine the 4 pinned leaves
    final List<PortalLeafItem> pinnedLeaves = [];
    for (final pid in _pinnedTabIds) {
      try {
        final match = allLeaves.firstWhere((l) => l.id == pid);
        if (!pinnedLeaves.contains(match)) pinnedLeaves.add(match);
      } catch (_) {}
    }
    // Fill up to 4 if missing
    for (final l in allLeaves) {
      if (pinnedLeaves.length >= 4) break;
      if (!pinnedLeaves.contains(l)) pinnedLeaves.add(l);
    }

    final hasMore = allLeaves.length > 4;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.portalTitle,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            Text(
              activeLeaf != null ? '${activeLeaf.parentLabel} • ${activeLeaf.label}' : '',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF2563EB)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          if (widget.headerActions != null) ...widget.headerActions!,
        ],
      ),
      body: activeBody,

      // Mobile Bottom Navigation Bar (Maximum 4 Custom Tabs + 1 More/Settings Tab = 5 slots)
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                // Render the up-to 4 pinned tabs
                ...List.generate(pinnedLeaves.length, (idx) {
                  final leaf = pinnedLeaves[idx];
                  final isSelected = _currentTabIndex == leaf.tabIndex && _currentSubIndex == leaf.subIndex;

                  return Expanded(
                    child: InkWell(
                      onTap: () => _selectSubItem(leaf.tabIndex, leaf.subIndex),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            leaf.icon,
                            size: 21,
                            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            leaf.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // Slot 5: "More / Customize"
                if (hasMore)
                  Expanded(
                    child: InkWell(
                      onTap: () => _showMobileMenuSheet(context, allLeaves),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            size: 21,
                            color: (!pinnedLeaves.any((l) => l.tabIndex == _currentTabIndex && l.subIndex == _currentSubIndex))
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF64748B),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'More / കസ്റ്റം',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: (!pinnedLeaves.any((l) => l.tabIndex == _currentTabIndex && l.subIndex == _currentSubIndex))
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: (!pinnedLeaves.any((l) => l.tabIndex == _currentTabIndex && l.subIndex == _currentSubIndex))
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== MOBILE MENU & CUSTOMIZE SHEET ====================
  void _showMobileMenuSheet(BuildContext context, List<PortalLeafItem> allLeaves) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return DefaultTabController(
              length: 2,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.85,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Sheet Header with Tabs
                    TabBar(
                      labelColor: const Color(0xFF2563EB),
                      unselectedLabelColor: const Color(0xFF64748B),
                      indicatorColor: const Color(0xFF2563EB),
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      tabs: const [
                        Tab(icon: Icon(Icons.grid_view_rounded, size: 18), text: 'All Modules'),
                        Tab(icon: Icon(Icons.tune_rounded, size: 18), text: 'Customize Bar (4 Tabs)'),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Expanded(
                      child: TabBarView(
                        children: [
                          // TAB 1: ALL MODULES LIST
                          ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 20),
                            itemCount: widget.tabs.length,
                            itemBuilder: (ctx, tIdx) {
                              final tab = widget.tabs[tIdx];
                              return Card(
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(tab.icon, size: 18, color: const Color(0xFF2563EB)),
                                          const SizedBox(width: 8),
                                          Text(
                                            tab.label,
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 16),
                                      if (tab.hasSubItems)
                                        ...List.generate(tab.subItems.length, (sIdx) {
                                          final sub = tab.subItems[sIdx];
                                          final isSelected = _currentTabIndex == tIdx && _currentSubIndex == sIdx;
                                          return ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            visualDensity: VisualDensity.compact,
                                            leading: Icon(sub.icon, size: 18, color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
                                            title: Text(
                                              sub.label,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF334155),
                                              ),
                                            ),
                                            trailing: isSelected
                                                ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB), size: 18)
                                                : const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
                                            onTap: () {
                                              Navigator.pop(ctx);
                                              _selectSubItem(tIdx, sIdx);
                                            },
                                          );
                                        })
                                      else
                                        ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          visualDensity: VisualDensity.compact,
                                          leading: Icon(tab.icon, size: 18, color: const Color(0xFF2563EB)),
                                          title: Text(tab.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                          trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
                                          onTap: () {
                                            Navigator.pop(ctx);
                                            _selectSubItem(tIdx, 0);
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // TAB 2: CUSTOMIZE QUICK BAR (PICK UP TO 4 TABS)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFBFDBFE)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'ബോട്ടം നാവിഗേഷനായി കൃത്യമായി 4 ടാബുകൾ വരെ സെലക്ട് ചെയ്യാം (${_pinnedTabIds.length} / 4 തിരഞ്ഞെടുത്തു).',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E40AF)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: allLeaves.length,
                                  itemBuilder: (ctx, idx) {
                                    final leaf = allLeaves[idx];
                                    final isPinned = _pinnedTabIds.contains(leaf.id);

                                    return CheckboxListTile(
                                      value: isPinned,
                                      dense: true,
                                      secondary: Icon(leaf.icon, size: 20, color: isPinned ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
                                      title: Text(leaf.label, style: TextStyle(fontSize: 13, fontWeight: isPinned ? FontWeight.bold : FontWeight.w500)),
                                      subtitle: Text(leaf.parentLabel, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                      onChanged: (val) {
                                        setSheetState(() {
                                          if (val == true) {
                                            if (_pinnedTabIds.length >= 4) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('മാക്സിമം 4 ടാബുകൾ മാത്രമേ തിരഞ്ഞെടുക്കാൻ സാധിക്കൂ!')),
                                              );
                                            } else {
                                              _pinnedTabIds.add(leaf.id);
                                            }
                                          } else {
                                            if (_pinnedTabIds.length <= 1) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('കുറഞ്ഞത് ഒരു ടാബ് എങ്കിലും വേണം!')),
                                              );
                                            } else {
                                              _pinnedTabIds.remove(leaf.id);
                                            }
                                          }
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    await NavigationPreferencesService.setPinnedTabs(widget.portalId, _pinnedTabIds);
                                    if (mounted) setState(() {});
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('ബോട്ടം നാവിഗേഷൻ ഈ ഡിവൈസിനായി ക്രമീകരിച്ചു!')),
                                    );
                                  },
                                  icon: const Icon(Icons.save_rounded, size: 18),
                                  label: const Text('സേവ് ചെയ്ത് അപ്ലൈ ചെയ്യുക (Save Preferences)'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 13),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                            ],
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
