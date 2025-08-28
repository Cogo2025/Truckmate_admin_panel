import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primaryColor,
                    theme.primaryColor.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              accountName: Text(
                authProvider.admin?.username ?? 'Admin',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: const Text('Administrator'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.admin_panel_settings,
                  size: 40,
                  color: theme.primaryColor,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard,
                    title: 'Dashboard',
                    route: '/dashboard',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.local_shipping_outlined,
                    activeIcon: Icons.local_shipping,
                    title: 'Drivers',
                    route: '/drivers',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.business_outlined,
                    activeIcon: Icons.business,
                    title: 'Owners',
                    route: '/owners',
                  ),
                  // ✅ NEW: Add verification menu item
                  _buildDrawerItem(
                    context,
                    icon: Icons.verified_user_outlined,
                    activeIcon: Icons.verified_user,
                    title: 'Verifications',
                    route: '/verification',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.history_outlined,
                    activeIcon: Icons.history,
                    title: 'History',
                    route: '/history',
                  ),
                  const Divider(height: 20, thickness: 1, color: Colors.white24),
                  _buildDrawerItem(
                    context,
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings,
                    title: 'Settings',
                    route: '/settings',
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  const Divider(height: 1, color: Colors.white24),
                  _buildDrawerItem(
                    context,
                    icon: Icons.logout_outlined,
                    activeIcon: Icons.logout,
                    title: 'Logout',
                    route: '/logout',
                    isLogout: true,
                    authProvider: authProvider,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required String route,
    bool isLogout = false,
    AuthProvider? authProvider,
  }) {
    final isActive = ModalRoute.of(context)?.settings.name == route;
    final color = isLogout ? Colors.red[400] : Theme.of(context).primaryColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isActive ? color!.withOpacity(0.2) : Colors.transparent,
          border: isActive
              ? Border.all(
                  color: color!.withOpacity(0.5),
                  width: 1,
                )
              : null,
        ),
        child: ListTile(
          leading: Icon(
            isActive ? activeIcon : icon,
            color: isActive ? color : Colors.white70,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? color : Colors.white70,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            if (isLogout) {
              authProvider?.logout(context);
            } else if (!isActive) {
              Navigator.pushNamed(context, route);
            }
          },
        ),
      ),
    );
  }
}
