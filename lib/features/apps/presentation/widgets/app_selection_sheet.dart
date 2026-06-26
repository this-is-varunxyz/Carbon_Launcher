import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../bloc/app_cubit.dart';
import '../bloc/app_state.dart';

class AppSelectionSheet extends StatelessWidget {
  final bool isSelectingFav;

  const AppSelectionSheet({super.key, this.isSelectingFav = false});

  
  static const ColorFilter greyscaleFilter = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFFF0F0F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isSelectingFav ? 'Select Fav App' : 'Select an App',
            style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: BlocBuilder<AppCubit, AppState>(
              builder: (context, state) {
                if (state is AppLoading) {
                  return const Center(child: CircularProgressIndicator(color: Colors.black));
                }
                if (state is AppLoaded) {
                  final apps = state.apps;
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: apps.length,
                    itemBuilder: (context, index) {
                      final app = apps[index];

                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            
                            child: app.icon != null
                                ? ColorFiltered(
                                    colorFilter: greyscaleFilter,
                                    child: Image.memory(app.icon!, width: 24, height: 24),
                                  )
                                : Text(
                                    app.name.isNotEmpty ? app.name[0].toUpperCase() : '?',
                                    style: GoogleFonts.dmMono(fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        title: Text(app.name, style: GoogleFonts.dmSans(fontSize: 14)),
                        onTap: () {
                          if (isSelectingFav) {
                            Hive.box<String>('settingsBox').put('fav_app', app.packageName);
                          } else {
                            final box = Hive.box<String>('favoriteAppsBox');
                            if (box.length < 8) { 
                              box.add(app.packageName);
                            }
                          }
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}