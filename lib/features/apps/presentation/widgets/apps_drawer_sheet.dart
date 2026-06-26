import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../bloc/app_cubit.dart';
import '../bloc/app_state.dart';
import 'app_selection_sheet.dart';

class AppsDrawerSheet extends StatelessWidget {
  const AppsDrawerSheet({super.key});

  List<BoxShadow> get neuOut => [
    BoxShadow(color: Colors.black.withOpacity(0.10), offset: const Offset(6, 6), blurRadius: 14),
    BoxShadow(color: Colors.white.withOpacity(0.85), offset: const Offset(-4, -4), blurRadius: 10),
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
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 32),
          
          ValueListenableBuilder(
            valueListenable: Hive.box<String>('favoriteAppsBox').listenable(),
            builder: (context, box, _) {
              final savedPackages = box.values.toList();
              
              return BlocBuilder<AppCubit, AppState>(
                builder: (context, state) {
                  if (state is! AppLoaded) return const CircularProgressIndicator(color: Colors.black);
                  
                  final myApps = savedPackages.map((pkg) {
                    return state.apps.firstWhere((app) => app.packageName == pkg, orElse: () => state.apps[0]);
                  }).toList();

                  final showPlusButton = myApps.length < 8;
                  final totalItems = 1 + myApps.length + (showPlusButton ? 1 : 0); 

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: totalItems,
                    itemBuilder: (context, index) {
                      
                      
                      if (index == 0) {
                        return _buildAppTile(
                          iconData: Icons.settings,
                          label: 'Carbon',
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Carbon Settings coming soon!'))),
                          onLongPress: () {},
                        );
                      }
                      
                      
                      if (index == totalItems - 1 && showPlusButton) {
                        return _buildAppTile(
                          iconData: Icons.add,
                          label: 'Add App',
                          isDashed: true,
                          onTap: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const AppSelectionSheet(isSelectingFav: false),
                          ),
                          onLongPress: () {},
                        );
                      }
                      
                      
                      final app = myApps[index - 1];
                      
                      return _buildAppTile(
                        iconBytes: app.icon, 
                        letterFallback: app.name.isNotEmpty ? app.name[0].toUpperCase() : '?',
                        label: app.name,
                        onTap: () => context.read<AppCubit>().launchApp(app.packageName),
                        onLongPress: () => box.deleteAt(index - 1),
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
    String? letterFallback, 
    IconData? iconData, 
    Uint8List? iconBytes,
    required String label, 
    bool isDashed = false, 
    required VoidCallback onTap, 
    required VoidCallback onLongPress
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: isDashed ? Colors.transparent : const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(22),
              border: isDashed ? Border.all(color: Colors.black.withOpacity(0.2), width: 1.5) : null,
              boxShadow: isDashed ? [] : neuOut,
            ),
            child: Center(
              child: _buildIconContent(iconData, iconBytes, letterFallback),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(color: Colors.black.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }

  Widget _buildIconContent(IconData? iconData, Uint8List? iconBytes, String? letter) {
    if (iconData != null) {
      return Icon(iconData, color: Colors.black.withOpacity(0.6), size: 28);
    } else if (iconBytes != null) {
      
      return ColorFiltered(
        colorFilter: greyscaleFilter,
        child: Image.memory(iconBytes, width: 32, height: 32),
      );
    } else {
      return Text(letter ?? '?', style: GoogleFonts.dmMono(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.8)));
    }
  }
}