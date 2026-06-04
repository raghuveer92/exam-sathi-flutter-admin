import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';

class AdminShell extends StatefulWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  static const _mobileRoutes = ['/dashboard', '/exams', '/students'];

  int _selectedIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/students')) return 2;
    if (loc.startsWith('/exam')) return 1;
    if (loc.startsWith('/featured')) return 1;
    return 0;
  }

  int _sidebarIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/featured-exams')) return 3;
    if (loc.startsWith('/exam-roadmaps')) return 4;
    if (loc.startsWith('/exam-categories')) return 1;
    if (loc.startsWith('/exams')) return 2;
    if (loc.startsWith('/students')) return 5;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 720;

    return Scaffold(
      body: isWide
          ? Row(children: [
              _AdminSidebar(
                  selectedIndex: _sidebarIndex(context),
                  onTap: (route) => context.go(route)),
              Expanded(child: widget.child),
            ])
          : widget.child,
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex(context),
              onDestinationSelected: (i) => context.go(_mobileRoutes[i]),
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: 'Dashboard'),
                NavigationDestination(
                    icon: Icon(Icons.menu_book_outlined),
                    selectedIcon: Icon(Icons.menu_book),
                    label: 'Exams'),
                NavigationDestination(
                    icon: Icon(Icons.people_outline),
                    selectedIcon: Icon(Icons.people),
                    label: 'Students'),
              ],
            ),
    );
  }
}

class _AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final void Function(String route) onTap;

  const _AdminSidebar(
      {required this.selectedIndex, required this.onTap});

  static const _items = [
    _SidebarItem(route: '/dashboard', icon: Icons.dashboard_outlined, label: 'Dashboard'),
    _SidebarItem(route: '/exam-categories', icon: Icons.category_outlined, label: 'Categories'),
    _SidebarItem(route: '/exams', icon: Icons.menu_book_outlined, label: 'Exams'),
    _SidebarItem(route: '/featured-exams', icon: Icons.star_outline, label: 'Featured'),
    _SidebarItem(route: '/exam-roadmaps', icon: Icons.map_outlined, label: 'Roadmaps'),
    _SidebarItem(route: '/students', icon: Icons.people_outline, label: 'Students'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: AdminColors.sidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  gradient: AdminColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'ExamSaathi',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'ADMIN PANEL',
              style: TextStyle(
                color: AdminColors.sidebarText,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'EXAM MANAGEMENT',
              style: TextStyle(
                color: AdminColors.sidebarText,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ...List.generate(_items.length, (i) {
            final item = _items[i];
            final isActive = selectedIndex == i;
            if (i == 0) {
              // Dashboard before exam management header spacing handled above
            }
            return GestureDetector(
              onTap: () => onTap(item.route),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: isActive
                      ? AdminColors.sidebarActive.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  Icon(item.icon,
                      size: 20,
                      color: isActive
                          ? AdminColors.sidebarActive
                          : AdminColors.sidebarText),
                  const SizedBox(width: 10),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: isActive
                          ? Colors.white
                          : AdminColors.sidebarText,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ]),
              ),
            );
          }),
          const Spacer(),
          // Logout
          GestureDetector(
            onTap: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: const Row(children: [
                Icon(Icons.logout_rounded,
                    size: 20, color: AdminColors.sidebarText),
                SizedBox(width: 10),
                Text('Logout',
                    style: TextStyle(
                        color: AdminColors.sidebarText, fontSize: 14)),
              ]),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SidebarItem {
  final String route;
  final IconData icon;
  final String label;
  const _SidebarItem({
    required this.route,
    required this.icon,
    required this.label,
  });
}
