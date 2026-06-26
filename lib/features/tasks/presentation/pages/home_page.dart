import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/flag_calendar_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  List<BoxShadow> get neuOut => [
    BoxShadow(color: Colors.black.withOpacity(0.10), offset: const Offset(6, 6), blurRadius: 14),
    BoxShadow(color: Colors.white.withOpacity(0.85), offset: const Offset(-4, -4), blurRadius: 10),
  ];

  List<BoxShadow> get neuCard => [
    BoxShadow(color: Colors.black.withOpacity(0.08), offset: const Offset(4, 4), blurRadius: 10),
    BoxShadow(color: Colors.white.withOpacity(0.90), offset: const Offset(-3, -3), blurRadius: 8),
  ];

  final Color bgColor = const Color(0xFFF0F0F0);
  final Color inputColor = const Color(0xFFEBEBEB);
  final Color textColor = const Color(0xFF0A0A0A);

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
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '19',
                        style: GoogleFonts.dmMono(
                          fontSize: 64, 
                          height: 1,
                          letterSpacing: -1.5,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 1.4
                            ..color = Colors.black.withOpacity(0.82),
                        ),
                      ),
                      Text(
                        '23',
                        style: GoogleFonts.dmSans(
                          fontSize: 42,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          height: 1,
                          letterSpacing: -1.2,
                        ),
                      ),
                    ],
                  ),
                  const FlagCalendarWidget(),
                ],
              ),
              
              const SizedBox(height: 24),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                decoration: BoxDecoration(
                  color: inputColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border(
                    top: BorderSide(color: Colors.black.withOpacity(0.05), width: 1.5),
                    left: BorderSide(color: Colors.black.withOpacity(0.05), width: 1.5),
                    bottom: BorderSide(color: Colors.white.withOpacity(0.6), width: 1.5),
                    right: BorderSide(color: Colors.white.withOpacity(0.6), width: 1.5),
                  )
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.black.withOpacity(0.35), size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search apps, notes, web...',
                          hintStyle: GoogleFonts.dmSans(
                            color: textColor.withOpacity(0.5), 
                            fontSize: 14, 
                            fontWeight: FontWeight.w300
                          ),
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(Icons.access_time, 'DEADLINES · 3'),
                      _buildDeadlineTask('Submit design review deck', '22h · Jun 27 17:00', const Color(0xFFEF4444), 0.85, true),
                      _buildDeadlineTask('Buy groceries', 'Overdue · Jun 26 19:00', const Color(0xFFEAB308), 1.0, true),
                      _buildDeadlineTask('Push hotfix to production', '2d · Jun 28 09:00', const Color(0xFF22C55E), 0.3, false),
                      
                      const SizedBox(height: 20),
                      _buildSectionHeader(Icons.check, 'TASKS · 2'),
                      _buildNormalTask('Read 20 pages — Thinking Fast', const Color(0xFF3B82F6)),
                      _buildNormalTask('Call dentist to reschedule', null),

                      const SizedBox(height: 20),
                      Divider(color: Colors.black.withOpacity(0.06), height: 1),
                      const SizedBox(height: 12),
                      _buildSectionHeader(Icons.check, 'DONE · 1', faded: true),
                      _buildDoneTask('Reply to Priya\'s message'),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              
              Container(
                margin: const EdgeInsets.only(bottom: 24, left: 10, right: 10),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: neuOut,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDockButton(icon: Icons.auto_awesome, label: 'AI', isPrimary: false),
                    _buildDockButton(icon: Icons.add, label: 'Add', isPrimary: true),
                    _buildDockButton(icon: Icons.grid_view_rounded, label: 'Apps', isPrimary: false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String label, {bool faded = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.black.withOpacity(faded ? 0.15 : 0.32)),
          const SizedBox(width: 6),
          Text(
            label, 
            style: GoogleFonts.dmMono(
              color: Colors.black.withOpacity(faded ? 0.15 : 0.36), 
              fontSize: 10, 
              letterSpacing: 1.5, 
              fontWeight: FontWeight.w500
            )
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineTask(String title, String subtitle, Color color, double progress, bool urgent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10), // Shrunk margin
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), // Shrunk padding
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: neuCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildCheckbox(false),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: GoogleFonts.dmSans(color: textColor.withOpacity(0.82), fontSize: 13, fontWeight: FontWeight.w400)), // Slightly smaller text
              ),
              _buildPriorityDot(color),
              const SizedBox(width: 12),
              CustomPaint(
                size: const Size(20, 20),
                painter: DeadlineRingPainter(progress: progress, color: color, urgent: urgent),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 34, top: 4),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 10, color: urgent ? const Color(0xFFEF4444) : Colors.black.withOpacity(0.3)),
                const SizedBox(width: 6),
                Text(
                  subtitle,
                  style: GoogleFonts.dmMono(fontSize: 9, letterSpacing: 0.5, color: urgent ? const Color(0xFFEF4444) : Colors.black.withOpacity(0.36)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNormalTask(String title, Color? priorityColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), // Shrunk padding
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: neuCard,
      ),
      child: Row(
        children: [
          _buildCheckbox(false),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: GoogleFonts.dmSans(color: textColor.withOpacity(0.82), fontSize: 13, fontWeight: FontWeight.w400)),
          ),
          if (priorityColor != null) _buildPriorityDot(priorityColor),
        ],
      ),
    );
  }

  Widget _buildDoneTask(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: inputColor, 
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildCheckbox(true),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title, 
              style: GoogleFonts.dmSans(
                color: Colors.black.withOpacity(0.28), 
                fontSize: 13, 
                fontWeight: FontWeight.w300,
                decoration: TextDecoration.lineThrough,
              )
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(bool isDone) {
    return Container(
      width: 18, 
      height: 18,
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFFE8E8E8) : bgColor,
        shape: BoxShape.circle,
        boxShadow: isDone ? [] : neuOut,
      ),
      child: isDone ? Icon(Icons.check, size: 10, color: Colors.black.withOpacity(0.4)) : null,
    );
  }

  Widget _buildPriorityDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 4)],
      ),
    );
  }

  Widget _buildDockButton({required IconData icon, required String label, required bool isPrimary}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: isPrimary ? textColor : bgColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isPrimary 
              ? [BoxShadow(color: Colors.black.withOpacity(0.28), blurRadius: 10, offset: const Offset(3, 3))] 
              : neuOut,
          ),
          child: Icon(icon, color: isPrimary ? const Color(0xFFF5F5F5) : Colors.black.withOpacity(0.52), size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.dmMono(
            color: isPrimary ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.3), 
            fontSize: 9, 
            letterSpacing: 1.0,
            fontWeight: FontWeight.w500
          ),
        )
      ],
    );
  }
}

// Custom Painter (Remains Unchanged)
class DeadlineRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool urgent;

  DeadlineRingPainter({required this.progress, required this.color, required this.urgent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final trackPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius, trackPaint);

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, 
      progress * 6.2832, 
      false,
      fillPaint,
    );

    final dotPaint = Paint()
      ..color = urgent ? color : Colors.black.withOpacity(0.18)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 2.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}