import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/institution_provider.dart';

class PortalTabItem {
  final String id;
  final String label;
  final IconData icon;
  final Widget body;
  final String? badge;

  const PortalTabItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.body,
    this.badge,
  });
}

class AdaptivePortalScaffold extends StatefulWidget {
  final String portalTitle;
  final String? portalSubtitle;
  final List<PortalTabItem> tabs;
  final int initialIndex;
  final ValueChanged<int>? onTabChanged;
  final List<Widget>? headerActions;
  final VoidCallback? onBack;

  const AdaptivePortalScaffold({
    super.key,
    required this.portalTitle,
    this.portalSubtitle,
    required this.tabs,
    this.initialIndex = 0,
    this.onTabChanged,
    this.headerActions,
    this.onBack,
  });

  @override
  State<AdaptivePortalScaffold> createState() => _AdaptivePortalScaffoldState();
}

class _AdaptivePortalScaffoldState extends State<AdaptivePortalScaffold> {
  late int _currentIndex;
  bool _isSidebarExpanded = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _switchTab(int index) {
    if (index < 0 || index >= widget.tabs.length) return;
    setState(() {
      _currentIndex = index;
    });
    widget.onTabChanged?.call(index);
  }

  void _showMoreTabsSheet(BuildContext context) {
    final remainingTabs = widget.tabs.sublist(4);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.grid_view_rounded, size: 20, color: Color(0xFF2563EB)),
                    const SizedBox(width: 8),
                    Text(
                      'More Modules (${widget.portalTitle})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                ...List.generate(remainingTabs.length, (i) {
                  final actualIndex = 4 + i;
                  final tab = remainingTabs[i];
                  final isSelected = _currentIndex == actualIndex;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    tileColor: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        tab.icon,
                        size: 20,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                    title: Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF0F172A),
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB), size: 18)
                        : const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                    onTap: () {
                      Navigator.pop(ctx);
                      _switchTab(actualIndex);
                    },
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 850;
    final provider = context.watch<InstitutionProvider>();
    final setting = provider.setting;

    if (isDesktop) {
      return _buildDesktopLayout(context, setting);
    } else {
      return _buildMobileLayout(context, setting);
    }
  }

  // ==================== DESKTOP / LAPTOP LAYOUT ====================
  Widget _buildDesktopLayout(BuildContext context, dynamic setting) {
    final currentTab = widget.tabs[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // 1. Top Universal Desktop Header
          Container(
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                // Institution Logo & Name
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.school, color: Color(0xFF2563EB)),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      setting.institutionName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      widget.portalTitle,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
                    ),
                  ],
                ),
                const SizedBox(width: 24),

                // Sidebar Collapse / Expand Toggle Button
                IconButton(
                  tooltip: _isSidebarExpanded ? 'Collapse Sidebar' : 'Expand Sidebar',
                  icon: Icon(
                    _isSidebarExpanded ? Icons.menu_open_rounded : Icons.menu_rounded,
                    color: const Color(0xFF475569),
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSidebarExpanded = !_isSidebarExpanded;
                    });
                  },
                ),

                const Spacer(),

                // Custom Header Actions
                if (widget.headerActions != null) ...widget.headerActions!,

                const SizedBox(width: 8),

                // Back / Exit Button
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
          ),

          // 2. Body Area (Sidebar on Left + Content Canvas on Right)
          Expanded(
            child: Row(
              children: [
                // Collapsible / Expandable Sidebar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  width: _isSidebarExpanded ? 240 : 72,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: widget.tabs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 4),
                          itemBuilder: (ctx, index) {
                            final tab = widget.tabs[index];
                            final isSelected = index == _currentIndex;

                            if (_isSidebarExpanded) {
                              // Expanded Item (Icon + Label)
                              return InkWell(
                                onTap: () => _switchTab(index),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: isSelected
                                        ? Border.all(color: const Color(0xFFBFDBFE))
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        tab.icon,
                                        size: 20,
                                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          tab.label,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF334155),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (tab.badge != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEF4444),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            tab.badge!,
                                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              // Collapsed Item (Centered Icon + Tooltip)
                              return Tooltip(
                                message: tab.label,
                                preferBelow: false,
                                child: InkWell(
                                  onTap: () => _switchTab(index),
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
                              );
                            }
                          },
                        ),
                      ),

                      // Sidebar Bottom Footer Toggle
                      const Divider(height: 1),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isSidebarExpanded = !_isSidebarExpanded;
                          });
                        },
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            mainAxisAlignment: _isSidebarExpanded
                                ? MainAxisAlignment.spaceBetween
                                : MainAxisAlignment.center,
                            children: [
                              if (_isSidebarExpanded)
                                const Text(
                                  'Collapse Menu',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                                ),
                              Icon(
                                _isSidebarExpanded
                                    ? Icons.keyboard_double_arrow_left_rounded
                                    : Icons.keyboard_double_arrow_right_rounded,
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

                // Main Content Canvas
                Expanded(
                  child: currentTab.body,
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
    final currentTab = widget.tabs[_currentIndex];
    final hasMore = widget.tabs.length > 5;

    // Bottom navigation items (maximum 5)
    final bottomNavCount = hasMore ? 5 : widget.tabs.length;

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
              currentTab.label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF2563EB)),
            ),
          ],
        ),
        actions: [
          if (widget.headerActions != null) ...widget.headerActions!,
        ],
      ),
      body: currentTab.body,

      // Mobile Bottom Navigation Bar (Maximum 5 items)
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: List.generate(bottomNavCount, (index) {
                final isMoreItem = hasMore && index == 4;

                if (isMoreItem) {
                  // Special 5th item: "More"
                  final isMoreActive = _currentIndex >= 4;
                  final activeLabel = isMoreActive ? widget.tabs[_currentIndex].label : 'More';

                  return Expanded(
                    child: InkWell(
                      onTap: () => _showMoreTabsSheet(context),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isMoreActive ? Icons.grid_view_rounded : Icons.more_horiz_rounded,
                            size: 22,
                            color: isMoreActive ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            activeLabel,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: isMoreActive ? FontWeight.bold : FontWeight.w500,
                              color: isMoreActive ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final tab = widget.tabs[index];
                final isSelected = _currentIndex == index;

                return Expanded(
                  child: InkWell(
                    onTap: () => _switchTab(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tab.icon,
                          size: 22,
                          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 10.5,
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
            ),
          ),
        ),
      ),
    );
  }
}
