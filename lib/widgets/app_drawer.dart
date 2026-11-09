// widgets/app_drawer.dart
import 'package:flutter/material.dart';

import '../services/session_service.dart';
import '../screens/login_screen.dart';
import '../screens/lead/lead_list_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          SizedBox(
            height: 220,
            width: double.infinity,
            child: DrawerHeader(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(color: Color(0xFF2E7D32)),
              child: FutureBuilder<String?>(
                future: SessionService().getUserName(),
                builder: (context, snapshot) {
                  final user = snapshot.data ?? 'User';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 32,
                          color: Color(0xFF2E7D32),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Prevent long email addresses from overflowing.
                      Text(
                        user,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        'Madathil Solar ERP',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Dashboard
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          // Leads
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Leads'),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeadListScreen()),
              );
            },
          ),

          // Customers
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Customers'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          // Quotations
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Quotations'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          // Sales Orders
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Sales Orders'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          // Profile
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          // Settings
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          const Spacer(),

          const Divider(height: 1),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              await SessionService().logout();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),

          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
