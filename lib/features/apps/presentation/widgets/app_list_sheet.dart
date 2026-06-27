import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../bloc/app_cubit.dart';
import '../bloc/app_state.dart';
import '../../domain/entities/app_entity.dart';

enum AppListMode { allApps, selectFav, addToGrid }

class AppListSheet extends StatefulWidget {
  final AppListMode mode;
  const AppListSheet({super.key, required this.mode});

  @override
  State<AppListSheet> createState() => _AppListSheetState();
}

class _AppListSheetState extends State<AppListSheet> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  Timer? _debounce;
  
  List<AppEntity>? _cachedAppsReference;
  String _cachedSearchQuery = '';
  
  final double _appItemHeight = 56.0; 
  final double _headerItemHeight = 40.0;
  final List<String> _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ#'.split('');
  
  String? _draggingLetter;
  double _dragBubbleY = 0.0;

  Map<String, double> _letterOffsets = {};
  List<dynamic> _flattenedList = [];

  static const ColorFilter greyscaleFilter = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _buildListAndOffsets(List<AppEntity> apps) {
    _flattenedList.clear();
    _letterOffsets.clear();
    double currentOffset = 0.0;
    String? lastLetter;

    for (var app in apps) {
      String initial = app.name.isNotEmpty ? app.name[0].toUpperCase() : '#';
      if (!RegExp(r'[A-Z]').hasMatch(initial)) initial = '#';

      if (initial != lastLetter) {
        _flattenedList.add({'type': 'header', 'letter': initial});
        _letterOffsets[initial] = currentOffset; 
        currentOffset += _headerItemHeight;
        lastLetter = initial;
      }
      
      _flattenedList.add({'type': 'app', 'data': app});
      currentOffset += _appItemHeight;
    }
  }

  void _handleDrag(Offset localPosition, double maxHeight) {
    double letterBoxHeight = maxHeight / _alphabet.length;
    int index = (localPosition.dy / letterBoxHeight).floor();
    index = index.clamp(0, _alphabet.length - 1);
    
    String letter = _alphabet[index];

    if (_draggingLetter != letter) {
      HapticFeedback.selectionClick(); 
      setState(() {
        _draggingLetter = letter;
        _dragBubbleY = (index * letterBoxHeight) + (letterBoxHeight / 2); 
      });

      if (_letterOffsets.containsKey(letter)) {
        _scrollController.jumpTo(_letterOffsets[letter]!.clamp(0.0, _scrollController.position.maxScrollExtent));
      } else {
        for (int i = index - 1; i >= 0; i--) {
          if (_letterOffsets.containsKey(_alphabet[i])) {
            _scrollController.jumpTo(_letterOffsets[_alphabet[i]]!.clamp(0.0, _scrollController.position.maxScrollExtent));
            break;
          }
        }
      }
    }
  }

  void _endDrag() => setState(() => _draggingLetter = null);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(color: Color(0xFFF0F0F0), borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 24),
          
          if (widget.mode != AppListMode.allApps) ...[
            Center(child: Text(widget.mode == AppListMode.selectFav ? 'Select Fav App' : 'Select an App', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black))),
            const SizedBox(height: 24),
          ],
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFEBEBEB), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), offset: const Offset(2, 2), blurRadius: 4), BoxShadow(color: Colors.white.withValues(alpha: 0.8), offset: const Offset(-2, -2), blurRadius: 4)]),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.black.withValues(alpha: 0.4), size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce = Timer(const Duration(milliseconds: 150), () {
                          setState(() => _searchQuery = value.toLowerCase());
                        });
                      },
                      decoration: InputDecoration(hintText: 'Search apps...', hintStyle: GoogleFonts.dmSans(color: Colors.black.withValues(alpha: 0.4), fontSize: 13), border: InputBorder.none, isDense: true),
                      style: GoogleFonts.dmSans(color: Colors.black, fontSize: 13),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () { _searchController.clear(); setState(() => _searchQuery = ''); },
                      child: Icon(Icons.close, color: Colors.black.withValues(alpha: 0.4), size: 18),
                    )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box('settingsBox').listenable(keys: ['use_monochrome']),
              builder: (context, box, _) {
                // FIXED: Changed default to FALSE
                final rawMono = box.get('use_monochrome', defaultValue: false);
                final useMonochrome = rawMono is bool ? rawMono : rawMono.toString() == 'true';

                return BlocBuilder<AppCubit, AppState>(
                  builder: (context, state) {
                    if (state is AppLoading) return const Center(child: CircularProgressIndicator(color: Colors.black));
                    
                    if (state is AppLoaded) {
                      if (!state.isIconsLoaded) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(color: Colors.black),
                              const SizedBox(height: 16),
                              Text('Caching HD Icons...', style: GoogleFonts.dmSans(color: Colors.black.withValues(alpha: 0.5), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }

                      bool needsRecalculation = _cachedAppsReference != state.apps || _cachedSearchQuery != _searchQuery || _flattenedList.isEmpty;

                      if (needsRecalculation) {
                        final filteredApps = state.apps.where((app) => app.nameLower.contains(_searchQuery)).toList();
                        _buildListAndOffsets(filteredApps);
                        _cachedAppsReference = state.apps;
                        _cachedSearchQuery = _searchQuery;
                      }

                      return Stack(
                        children: [
                          ListView.builder(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 60), 
                            itemCount: _flattenedList.length,
                            itemBuilder: (context, index) {
                              final item = _flattenedList[index];

                              if (item['type'] == 'header') {
                                return SizedBox(
                                  height: _headerItemHeight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 32.0, top: 16.0),
                                    child: Text(item['letter'], style: GoogleFonts.dmMono(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black.withValues(alpha: 0.3))),
                                  ),
                                );
                              }

                              final AppEntity app = item['data'];
                              Widget iconWidget;
                              
                              if (app.icon != null) {
                                final img = Image.memory(app.icon!, width: 28, height: 28, cacheWidth: 84, cacheHeight: 84, gaplessPlayback: true);
                                iconWidget = useMonochrome ? ColorFiltered(colorFilter: greyscaleFilter, child: img) : img;
                              } else {
                                iconWidget = Text(app.name.isNotEmpty ? app.name[0].toUpperCase() : '?', style: GoogleFonts.dmMono(fontSize: 16, fontWeight: FontWeight.bold));
                              }

                              return SizedBox(
                                height: _appItemHeight,
                                child: InkWell(
                                  onTap: () {
                                    if (widget.mode == AppListMode.allApps) {
                                      context.read<AppCubit>().launchApp(app.packageName);
                                    } else if (widget.mode == AppListMode.selectFav) {
                                      Hive.box('settingsBox').put('fav_app', app.packageName);
                                    } else {
                                      final favBox = Hive.box<String>('favoriteAppsBox');
                                      if (favBox.length < 8) favBox.add(app.packageName);
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 8),
                                        iconWidget,
                                        const SizedBox(width: 16),
                                        Expanded(child: Text(app.name, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black.withValues(alpha: 0.85)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          if (_searchQuery.isEmpty)
                            Align(
                              alignment: Alignment.centerRight,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onVerticalDragStart: (details) => _handleDrag(details.localPosition, constraints.maxHeight),
                                    onVerticalDragUpdate: (details) => _handleDrag(details.localPosition, constraints.maxHeight),
                                    onVerticalDragEnd: (_) => _endDrag(),
                                    onVerticalDragCancel: _endDrag,
                                    child: SizedBox(
                                      width: 60,
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        alignment: Alignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: 12.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: _alphabet.map((letter) {
                                                bool isActive = _draggingLetter == letter;
                                                return Text(letter, style: GoogleFonts.dmMono(fontSize: isActive ? 14 : 10, fontWeight: FontWeight.bold, color: isActive ? Colors.black : Colors.black.withValues(alpha: 0.3)));
                                              }).toList(),
                                            ),
                                          ),
                                          if (_draggingLetter != null)
                                            Positioned(
                                              top: _dragBubbleY - 24, right: 50,
                                              child: RepaintBoundary(
                                                child: Container(
                                                  width: 48, height: 48,
                                                  decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(-2, 4))]),
                                                  child: Center(child: Text(_draggingLetter!, style: GoogleFonts.dmMono(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              ),
                            )
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}