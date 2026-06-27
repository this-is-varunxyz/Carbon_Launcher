import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../bloc/app_cubit.dart';
import '../bloc/app_state.dart';
import 'app_list_sheet.dart'; 
import 'carbon_settings_sheet.dart'; 
import '../../domain/entities/app_entity.dart';

class AppsDrawerSheet extends StatelessWidget {
  const AppsDrawerSheet({super.key});

  List<BoxShadow> get neuOut => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.10), offset: const Offset(6, 6), blurRadius: 14),
    BoxShadow(color: Colors.white.withValues(alpha: 0.85), offset: const Offset(-4, -4), blurRadius: 10),
  ];

  static const ColorFilter greyscaleFilter = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 24, top: 24, left: 24, right: 24),
      decoration: const BoxDecoration(
        color: Color(0xFFF0F0F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 32),
          
          ValueListenableBuilder(
            valueListenable: Hive.box<String>('favoriteAppsBox').listenable(),
            builder: (context, favBox, _) {
              return ValueListenableBuilder(
                valueListenable: Hive.box('settingsBox').listenable(keys: ['use_monochrome']),
                builder: (context, settingsBox, _) {
                  
                  // FIXED: Changed default to FALSE
                  final rawMono = settingsBox.get('use_monochrome', defaultValue: false);
                  final useMonochrome = rawMono is bool ? rawMono : rawMono.toString() == 'true';
                  
                  final savedPackages = favBox.values.toList();
                  
                  return BlocBuilder<AppCubit, AppState>(
                    builder: (context, state) {
                      if (state is! AppLoaded) return const CircularProgressIndicator(color: Colors.black);

                      // NEW: Show loading screen if icons are caching
                      if (!state.isIconsLoaded) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(color: Colors.black),
                                const SizedBox(height: 16),
                                Text('Caching HD Icons...', style: GoogleFonts.dmSans(color: Colors.black.withValues(alpha: 0.5), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      final myApps = savedPackages.map((pkg) {
                        return state.apps.firstWhere((app) => app.packageName == pkg, orElse: () => state.apps[0]);
                      }).toList();

                      final showPlusButton = myApps.length < 8;
                      final totalItems = 1 + myApps.length + (showPlusButton ? 1 : 0); 

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, crossAxisSpacing: 24, mainAxisSpacing: 24, childAspectRatio: 0.85,
                        ),
                        itemCount: totalItems,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _buildAppTile(
                              iconData: Icons.settings, label: 'Carbon', useMonochrome: useMonochrome,
                              onTap: () {
                                Navigator.pop(context);
                                showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const CarbonSettingsSheet());
                              },
                              onLongPress: () {},
                            );
                          }
                          
                          if (index == totalItems - 1 && showPlusButton) {
                            return _buildAppTile(
                              iconData: Icons.add, label: 'Add App', isDashed: true, useMonochrome: useMonochrome,
                              onTap: () {
                                Navigator.pop(context);
                                showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const AppListSheet(mode: AppListMode.addToGrid));
                              },
                              onLongPress: () {},
                            );
                          }
                          
                          final app = myApps[index - 1];
                          return _buildAppTile(
                            app: app, label: app.name, useMonochrome: useMonochrome, 
                            onTap: () => context.read<AppCubit>().launchApp(app.packageName),
                            onLongPress: () => favBox.deleteAt(index - 1),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppTile({
    AppEntity? app, 
    IconData? iconData, 
    required String label, 
    bool isDashed = false,
    required bool useMonochrome, 
    required VoidCallback onTap, 
    required VoidCallback onLongPress
  }) {
    Widget getIcon() {
      if (iconData != null) {
        return Icon(iconData, color: Colors.black.withValues(alpha: 0.6), size: 28);
      }
      if (app != null && app.icon != null) {
        final img = Image.memory(app.icon!, width: 32, height: 32, cacheWidth: 84, cacheHeight: 84, gaplessPlayback: true);
        return useMonochrome ? ColorFiltered(colorFilter: greyscaleFilter, child: img) : img;
      }
      return Text(app != null && app.name.isNotEmpty ? app.name[0].toUpperCase() : '?', style: GoogleFonts.dmMono(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black.withValues(alpha: 0.8)));
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 64, width: 64,
            decoration: BoxDecoration(
              color: isDashed ? Colors.transparent : const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(22),
              border: isDashed ? Border.all(color: Colors.black.withValues(alpha: 0.2), width: 1.5) : null,
              boxShadow: isDashed ? [] : neuOut,
            ),
            child: Center(child: getIcon()),
          ),
          const SizedBox(height: 12),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.dmSans(color: Colors.black.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.w600))
        ],
      ),
    );
  }
}