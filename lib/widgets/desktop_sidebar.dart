import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_export.dart';
import '../services/auth_service.dart';

class DesktopSidebar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onIndexChanged;
  final String role;
  
  const DesktopSidebar({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.role,
  });

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      await AuthService().signOut();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final menuItems = role == 'teacher' ? [
      {'icon': Icons.dashboard_outlined, 'label': 'DASHBOARD'},
      {'icon': Icons.qr_code_scanner_outlined, 'label': 'RUNTIMES'},
      {'icon': Icons.people_outline, 'label': 'STUDENTS'},
      {'icon': Icons.person_outline, 'label': 'PROFILE'},
    ] : [
      {'icon': Icons.dashboard_outlined, 'label': 'DASHBOARD'},
      {'icon': Icons.qr_code_scanner_outlined, 'label': 'SCANNER'},
      {'icon': Icons.history_outlined, 'label': 'HISTORY'},
      {'icon': Icons.person_outline, 'label': 'PROFILE'},
    ];

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.5),
        border: Border(
          right: BorderSide(
            color: colorScheme.primary.withOpacity(0.2),
            width: 1.5,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Branding
          const CustomLogoWidget(size: 80),
          const SizedBox(height: 16),
          Text(
            'AttendEase',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              
            ),
          ).animate().fadeIn().shimmer(duration: 1500.ms, color: colorScheme.secondary),
          const SizedBox(height: 40),
          
          // Navigation Links
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final isSelected = currentIndex == index;
                final item = menuItems[index];
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      if (index == 1 && role == 'teacher') {
                        Navigator.pushNamed(context, '/start-attendance-screen');
                      } else {
                        onIndexChanged(index);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? colorScheme.primary.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                              ? colorScheme.primary.withOpacity(0.5)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          )
                        ] : [],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            color: isSelected 
                                ? colorScheme.primary 
                                : colorScheme.onSurface.withOpacity(0.6),
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            item['label'] as String,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: isSelected 
                                  ? colorScheme.primary 
                                  : colorScheme.onSurface.withOpacity(0.6),
                              
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Footer
          Divider(color: colorScheme.primary.withOpacity(0.2)),
          Padding(
            padding: const EdgeInsets.all(24),
            child: InkWell(
              onTap: () => _handleSignOut(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.error.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_outlined, color: colorScheme.error, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'TERMINATE SESSION',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.error,
                        
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
