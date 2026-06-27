import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CarbonSettingsSheet extends StatelessWidget {
  const CarbonSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 24, top: 24, left: 24, right: 24),
      decoration: const BoxDecoration(color: Color(0xFFF0F0F0), borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 32),
          Text('Carbon Settings', style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 24),
          
          ValueListenableBuilder(
            valueListenable: Hive.box('settingsBox').listenable(keys: ['use_monochrome', 'enable_swipe_drawer']),
            builder: (context, box, _) {
              
              final rawMono = box.get('use_monochrome', defaultValue: true);
              final useMonochrome = rawMono is bool ? rawMono : rawMono.toString() == 'true';
              
              final rawSwipe = box.get('enable_swipe_drawer', defaultValue: true);
              final enableSwipeDrawer = rawSwipe is bool ? rawSwipe : rawSwipe.toString() == 'true';
              
              return Column(
                children: [
                  SwitchListTile(
                    activeThumbColor: Colors.black, contentPadding: EdgeInsets.zero,
                    title: Text('Monochrome Icons', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, color: Colors.black)),
                    subtitle: Text('Apply grayscale filter to all app icons', style: GoogleFonts.dmSans(fontSize: 12, color: Colors.black.withValues(alpha: 0.6))),
                    value: useMonochrome, onChanged: (value) => box.put('use_monochrome', value),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    activeThumbColor: Colors.black, contentPadding: EdgeInsets.zero,
                    title: Text('Swipe-Up App Drawer', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, color: Colors.black)),
                    subtitle: Text('Swipe up on the bottom dock to open all apps', style: GoogleFonts.dmSans(fontSize: 12, color: Colors.black.withValues(alpha: 0.6))),
                    value: enableSwipeDrawer, onChanged: (value) => box.put('enable_swipe_drawer', value),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}