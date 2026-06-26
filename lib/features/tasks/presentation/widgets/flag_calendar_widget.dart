import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FlagCalendarWidget extends StatelessWidget {
  const FlagCalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final int totalDays = DateUtils.getDaysInMonth(now.year, now.month);
    final int currentDay = now.day;

    final months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    final String currentMonth = months[now.month - 1];

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              currentMonth,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 1.2,
                color: const Color(0xFF0A0A0A),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.circle, size: 4, color: Color(0xFF0A0A0A)),
                const SizedBox(width: 4),
                Text(
                  '$currentDay / $totalDays',
                  style: GoogleFonts.dmMono(
                    color: Colors.black.withOpacity(0.36),
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(width: 10),
        Container(height: 38, width: 1, color: Colors.black.withOpacity(0.1)),
        const SizedBox(width: 10),

        SizedBox(
          width: 96,
          child: Wrap(
            spacing: 4,
            runSpacing: 5,
            children: List.generate(totalDays, (index) {
              final int dayNumber = index + 1;
              final bool isCurrent = dayNumber == currentDay;
              final bool isPast = dayNumber < currentDay;

              return Icon(
                Icons.circle,
                size: 8,
                color: isCurrent
                    ? const Color(0xFF0A0A0A)
                    : isPast
                    ? Colors.black.withOpacity(0.2)
                    : Colors.black.withOpacity(0.08),
              );
            }),
          ),
        ),
      ],
    );
  }
}
