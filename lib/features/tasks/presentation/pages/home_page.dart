import 'dart:async';
import 'dart:typed_data';
import 'package:carbon_launcher/features/apps/presentation/bloc/app_cubit.dart';
import 'package:carbon_launcher/features/apps/presentation/bloc/app_state.dart';
import 'package:carbon_launcher/features/apps/presentation/widgets/all_apps_drawer_sheet.dart';
import 'package:carbon_launcher/features/apps/presentation/widgets/app_selection_sheet.dart';
import 'package:carbon_launcher/features/apps/presentation/widgets/apps_drawer_sheet.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart'; 


import '../widgets/flag_calendar_widget.dart';
import '../widgets/add_task_sheet.dart';


import '../bloc/task_cubit.dart';
import '../bloc/task_state.dart';
import '../../domain/entities/task_entity.dart';



final Color bgColor = const Color(0xFFF0F0F0);
final Color inputColor = const Color(0xFFEBEBEB);
final Color textColor = const Color(0xFF0A0A0A);

List<BoxShadow> get neuOut => [
  BoxShadow(color: Colors.black.withValues(alpha: 0.10), offset: const Offset(6, 6), blurRadius: 14),
  BoxShadow(color: Colors.white.withValues(alpha: 0.85), offset: const Offset(-4, -4), blurRadius: 10),
];

List<BoxShadow> get neuCard => [
  BoxShadow(color: Colors.black.withValues(alpha: 0.08), offset: const Offset(4, 4), blurRadius: 10),
  BoxShadow(color: Colors.white.withValues(alpha: 0.90), offset: const Offset(-3, -3), blurRadius: 8),
];

const ColorFilter greyscaleFilter = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
]);

Color getPriorityColor(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.high: return const Color(0xFFEF4444);
    case TaskPriority.medium: return const Color(0xFFEAB308);
    case TaskPriority.low: return const Color(0xFF3B82F6);
    default: return Colors.transparent;
  }
}

String formatDisplayDate(DateTime? date) {
  if (date == null) return '';
  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final minute = date.minute.toString().padLeft(2, '0');
  return '${months[date.month - 1]} ${date.day} ${date.hour}:$minute';
}

void confirmDelete(BuildContext context, String taskId) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: const Color(0xFFF0F0F0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Task?', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.black)),
        content: Text('Are you sure you want to permanently delete this task?', style: GoogleFonts.dmSans(color: Colors.black.withValues(alpha: 0.8))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: GoogleFonts.dmSans(color: Colors.black.withValues(alpha: 0.6), fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              context.read<TaskCubit>().deleteTask(taskId);
              Navigator.pop(dialogContext);
            },
            child: Text('Delete', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      );
    },
  );
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  static const platform = MethodChannel('carbon.launcher/channel');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkIfDefaultLauncher());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkIfDefaultLauncher();
  }

  Future<void> _checkIfDefaultLauncher() async {
    try {
      final bool isDefault = await platform.invokeMethod('isDefaultLauncher');
      if (!isDefault && mounted) _promptDefaultLauncher();
    } on PlatformException catch (e) {
      debugPrint("Failed to check default launcher status: '${e.message}'.");
    }
  }

  void _promptDefaultLauncher() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF0F0F0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Default Launcher', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.black)),
          content: Text('To use Carbon as your primary home screen, please set it as your default launcher in the system settings.', style: GoogleFonts.dmSans(color: Colors.black.withOpacity(0.8))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: GoogleFonts.dmSans(color: Colors.black.withOpacity(0.6), fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                Navigator.pop(dialogContext);
                const intent = AndroidIntent(action: 'android.settings.HOME_SETTINGS');
                await intent.launch();
              },
              child: Text('Open Settings', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // TOP HEADER (Clock is now isolated to prevent full page rebuilds)
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LiveClockWidget(),
                  FlagCalendarWidget(),
                ],
              ),
              const SizedBox(height: 24),

              // SEARCH BAR
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: inputColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), offset: const Offset(2, 2), blurRadius: 4),
                    BoxShadow(color: Colors.white.withValues(alpha: 0.8), offset: const Offset(-2, -2), blurRadius: 4),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.black.withValues(alpha: 0.4), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (query) async {
                          if (query.trim().isNotEmpty) {
                            final intent = AndroidIntent(action: 'android.intent.action.WEB_SEARCH', arguments: <String, dynamic>{'query': query});
                            await intent.launch();
                            _searchController.clear();
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Google Search',
                          hintStyle: GoogleFonts.dmSans(color: textColor.withValues(alpha: 0.4), fontSize: 14, fontWeight: FontWeight.w400),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: GoogleFonts.dmSans(color: textColor, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: BlocBuilder<TaskCubit, TaskState>(
                  builder: (context, state) {
                    if (state is TaskLoading) return const Center(child: CircularProgressIndicator(color: Colors.black));

                    if (state is TaskLoaded) {
                      final tasks = state.tasks;
                      final deadlines = tasks.where((t) => t.type == TaskType.deadline && !t.isCompleted).toList();
                      final normalTasks = tasks.where((t) => t.type == TaskType.normal && !t.isCompleted).toList();
                      final doneTasks = tasks.where((t) => t.isCompleted).toList();

                      return CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          if (deadlines.isNotEmpty) ...[
                            SliverToBoxAdapter(child: SectionHeader(icon: Icons.access_time, label: 'DEADLINES · ${deadlines.length}')),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => DeadlineTaskCard(task: deadlines[index]),
                                childCount: deadlines.length,
                              ),
                            ),
                            const SliverToBoxAdapter(child: SizedBox(height: 20)),
                          ],

                          if (normalTasks.isNotEmpty || (deadlines.isEmpty && doneTasks.isEmpty)) ...[
                            SliverToBoxAdapter(child: SectionHeader(icon: Icons.check, label: 'TASKS · ${normalTasks.length}')),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => NormalTaskCard(task: normalTasks[index]),
                                childCount: normalTasks.length,
                              ),
                            ),
                            const SliverToBoxAdapter(child: SizedBox(height: 20)),
                          ],

                          if (doneTasks.isNotEmpty) ...[
                            SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  Divider(color: Colors.black.withValues(alpha: 0.06), height: 1),
                                  const SizedBox(height: 12),
                                  SectionHeader(icon: Icons.check, label: 'DONE · ${doneTasks.length}', faded: true),
                                ],
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => DoneTaskCard(task: doneTasks[index]),
                                childCount: doneTasks.length,
                              ),
                            ),
                          ],
                          const SliverToBoxAdapter(child: SizedBox(height: 40)), // Bottom padding
                        ],
                      );
                    }
                    return const SliverToBoxAdapter(child: SizedBox());
                  },
                ),
              ),

              GestureDetector(
                onVerticalDragEnd: (details) {
                  final enableSwipe = Hive.box<String>('settingsBox').get('enable_swipe_drawer', defaultValue: 'true') == 'true';
                  if (enableSwipe && details.primaryVelocity != null && details.primaryVelocity! < -300) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      transitionAnimationController: AnimationController(
                        vsync: Navigator.of(context),
                        duration: const Duration(milliseconds: 350),
                      )..drive(CurveTween(curve: Curves.easeOutQuart)),
                      builder: (_) => const AllAppsDrawerSheet(),
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 24, left: 10, right: 10),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(24), boxShadow: neuOut),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: Hive.box<String>('settingsBox').listenable(),
                        builder: (context, box, _) {
                          final favPackage = box.get('fav_app');
                          final useMonochrome = box.get('use_monochrome', defaultValue: 'true') == 'true';

                          return BlocBuilder<AppCubit, AppState>(
                            builder: (context, state) {
                              if (state is AppLoaded && favPackage != null) {
                                final favApp = state.apps.firstWhere((a) => a.packageName == favPackage, orElse: () => state.apps[0]);
                                return DockButton(
                                  iconBytes: favApp.icon,
                                  letterFallback: favApp.name.isNotEmpty ? favApp.name[0].toUpperCase() : '?',
                                  label: favApp.name,
                                  isPrimary: false,
                                  useMonochrome: useMonochrome,
                                  onTap: () => context.read<AppCubit>().launchApp(favApp.packageName),
                                  onLongPress: () => box.delete('fav_app'),
                                );
                              }
                              return DockButton(
                                iconData: Icons.favorite_border,
                                label: 'Fav',
                                isPrimary: false,
                                onTap: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const AppSelectionSheet(isSelectingFav: true)),
                              );
                            },
                          );
                        },
                      ),

                      DockButton(
                        iconData: Icons.add,
                        label: 'Add',
                        isPrimary: true,
                        onTap: () => showModalBottomSheet(
                          context: context, isScrollControlled: true, backgroundColor: Colors.transparent, 
                          builder: (_) => BlocProvider.value(value: context.read<TaskCubit>(), child: const AddTaskSheet()),
                        ),
                      ),

                      DockButton(
                        iconData: Icons.grid_view_rounded,
                        label: 'Apps',
                        isPrimary: false,
                        onTap: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const AppsDrawerSheet()),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class LiveClockWidget extends StatelessWidget {
  const LiveClockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        final now = DateTime.now();
        int hour = now.hour % 12;
        if (hour == 0) hour = 12;
        final String hourStr = hour.toString().padLeft(2, '0');
        final String minStr = now.minute.toString().padLeft(2, '0');

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              hourStr,
              style: GoogleFonts.dmMono(
                fontSize: 64, height: 1, letterSpacing: -1.5,
                foreground: Paint()..style = PaintingStyle.stroke..strokeWidth = 1.4..color = Colors.black.withValues(alpha: 0.82),
              ),
            ),
            Text(minStr, style: GoogleFonts.dmSans(fontSize: 42, fontWeight: FontWeight.w700, color: textColor, height: 1, letterSpacing: -1.2)),
          ],
        );
      },
    );
  }
}

class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool faded;

  const SectionHeader({super.key, required this.icon, required this.label, this.faded = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.black.withValues(alpha: faded ? 0.15 : 0.32)),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.dmMono(color: Colors.black.withValues(alpha: faded ? 0.15 : 0.36), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class TaskCheckbox extends StatelessWidget {
  final bool isCompleted;
  const TaskCheckbox({super.key, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18, height: 18,
      decoration: BoxDecoration(color: isCompleted ? const Color(0xFFE8E8E8) : bgColor, shape: BoxShape.circle, boxShadow: isCompleted ? [] : neuOut),
      child: isCompleted ? Icon(Icons.check, size: 10, color: Colors.black.withValues(alpha: 0.4)) : null,
    );
  }
}

class PriorityDot extends StatelessWidget {
  final Color color;
  const PriorityDot({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    if (color == Colors.transparent) return const SizedBox();
    return Container(
      width: 6, height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 4)]),
    );
  }
}


class NormalTaskCard extends StatelessWidget {
  final TaskEntity task;
  const NormalTaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => confirmDelete(context, task.id),
      onTap: () => context.read<TaskCubit>().toggleTaskCompletion(task),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), boxShadow: neuCard),
        child: Row(
          children: [
            TaskCheckbox(isCompleted: task.isCompleted),
            const SizedBox(width: 12),
            Expanded(child: Text(task.title, style: GoogleFonts.dmSans(color: textColor.withValues(alpha: 0.82), fontSize: 13, fontWeight: FontWeight.w400))),
            PriorityDot(color: getPriorityColor(task.priority)),
          ],
        ),
      ),
    );
  }
}

class DoneTaskCard extends StatelessWidget {
  final TaskEntity task;
  const DoneTaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => confirmDelete(context, task.id),
      onTap: () => context.read<TaskCubit>().toggleTaskCompletion(task),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: inputColor, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            TaskCheckbox(isCompleted: task.isCompleted),
            const SizedBox(width: 12),
            Expanded(child: Text(task.title, style: GoogleFonts.dmSans(color: Colors.black.withValues(alpha: 0.28), fontSize: 13, fontWeight: FontWeight.w300, decoration: TextDecoration.lineThrough))),
          ],
        ),
      ),
    );
  }
}

class DeadlineTaskCard extends StatefulWidget {
  final TaskEntity task;
  const DeadlineTaskCard({super.key, required this.task});

  @override
  State<DeadlineTaskCard> createState() => _DeadlineTaskCardState();
}

class _DeadlineTaskCardState extends State<DeadlineTaskCard> {
  Timer? _timer;
  static final Set<String> _alertedTasks = {}; 
  static final AudioPlayer _audioPlayer = AudioPlayer(); 

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    super.dispose();
  }

  void _showUrgentAlarm(String taskTitle) async {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 300), () => HapticFeedback.heavyImpact());
    Future.delayed(const Duration(milliseconds: 600), () => HapticFeedback.heavyImpact());

    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
    } catch (e) {
      debugPrint("Audio issue: $e"); 
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Material(
          color: const Color(0xFFEF4444), 
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 100),
                  const SizedBox(height: 32),
                  Text('"$taskTitle"\ndeadline is so close!', textAlign: TextAlign.center, style: GoogleFonts.dmSans(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
                  const SizedBox(height: 64),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFEF4444), minimumSize: const Size(double.infinity, 64), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
                    onPressed: () {
                      _audioPlayer.stop(); 
                      Navigator.pop(dialogContext);
                    },
                    child: Text('Okay', style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = getPriorityColor(widget.task.priority);
    final createdAt = DateTime.fromMillisecondsSinceEpoch(int.parse(widget.task.id));
    final now = DateTime.now();

    double progress = 0.0;
    bool isUrgent = false;
    String subtitle = '';

    if (widget.task.deadline != null) {
      final totalMinutes = widget.task.deadline!.difference(createdAt).inMinutes;
      final elapsedMinutes = now.difference(createdAt).inMinutes;

      if (now.isAfter(widget.task.deadline!)) {
        progress = 1.0;
        isUrgent = true;
        subtitle = 'Overdue · ${formatDisplayDate(widget.task.deadline)}';
      } else {
        progress = totalMinutes > 0 ? (elapsedMinutes / totalMinutes).clamp(0.0, 1.0) : 1.0;
        final diff = widget.task.deadline!.difference(now);
        isUrgent = diff.inHours <= 24;

        String remaining = diff.inDays > 0 ? '${diff.inDays}d' : diff.inHours > 0 ? '${diff.inHours}h' : '${diff.inMinutes}m';
        subtitle = '$remaining · ${formatDisplayDate(widget.task.deadline)}';

        if (progress >= 0.90 && !_alertedTasks.contains(widget.task.id)) {
          _alertedTasks.add(widget.task.id);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showUrgentAlarm(widget.task.title);
          });
        }
      }
    }

    return GestureDetector(
      onTap: () => context.read<TaskCubit>().toggleTaskCompletion(widget.task),
      onLongPress: () => confirmDelete(context, widget.task.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), boxShadow: neuCard),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TaskCheckbox(isCompleted: widget.task.isCompleted),
                const SizedBox(width: 12),
                Expanded(child: Text(widget.task.title, style: GoogleFonts.dmSans(color: textColor.withValues(alpha: 0.82), fontSize: 13, fontWeight: FontWeight.w400))),
                PriorityDot(color: color),
                const SizedBox(width: 12),
                CustomPaint(size: const Size(20, 20), painter: DeadlineRingPainter(progress: progress, color: color, urgent: isUrgent)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 34, top: 4),
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 10, color: isUrgent ? const Color(0xFFEF4444) : Colors.black.withValues(alpha: 0.3)),
                  const SizedBox(width: 6),
                  Text(subtitle, style: GoogleFonts.dmMono(fontSize: 9, letterSpacing: 0.5, color: isUrgent ? const Color(0xFFEF4444) : Colors.black.withValues(alpha: 0.36))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class DockButton extends StatelessWidget {
  final String? letterFallback;
  final IconData? iconData;
  final Uint8List? iconBytes;
  final String label;
  final bool isPrimary;
  final bool useMonochrome;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const DockButton({
    super.key, this.letterFallback, this.iconData, this.iconBytes, required this.label, required this.isPrimary, this.useMonochrome = false, this.onTap, this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 56, width: 56,
              decoration: BoxDecoration(
                color: isPrimary ? textColor : bgColor, borderRadius: BorderRadius.circular(20),
                boxShadow: isPrimary ? [BoxShadow(color: Colors.black.withValues(alpha: 0.28), blurRadius: 10, offset: const Offset(3, 3))] : neuOut,
              ),
              child: Center(
                child: iconData != null
                    ? Icon(iconData, color: isPrimary ? const Color(0xFFF5F5F5) : Colors.black.withValues(alpha: 0.52), size: 24)
                    : iconBytes != null
                        ? (useMonochrome 
                            ? ColorFiltered(colorFilter: greyscaleFilter, child: Image.memory(iconBytes!, width: 28, height: 28, cacheWidth: 84, cacheHeight: 84, gaplessPlayback: true)) // OPTIMIZED
                            : Image.memory(iconBytes!, width: 28, height: 28, cacheWidth: 84, cacheHeight: 84, gaplessPlayback: true)) // OPTIMIZED
                        : Text(letterFallback ?? '?', style: GoogleFonts.dmMono(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black.withValues(alpha: 0.7))),
              ),
            ),
            const SizedBox(height: 8),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.dmMono(color: isPrimary ? Colors.black.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.3), fontSize: 9, letterSpacing: 1.0, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class DeadlineRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool urgent;

  DeadlineRingPainter({required this.progress, required this.color, required this.urgent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final trackPaint = Paint()..color = Colors.black.withValues(alpha: 0.08)..style = PaintingStyle.stroke..strokeWidth = 2.5;
    canvas.drawCircle(center, radius, trackPaint);

    final fillPaint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -1.5708, progress * 6.2832, false, fillPaint);

    final dotPaint = Paint()..color = urgent ? color : Colors.black.withValues(alpha: 0.18)..style = PaintingStyle.fill;
    canvas.drawCircle(center, 2.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true; // Re-paints cleanly per minute now
}