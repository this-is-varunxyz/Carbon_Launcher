import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_cubit.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final TextEditingController _titleController = TextEditingController();
  bool _isDeadline = false;
  DateTime? _selectedDeadline;
  TaskPriority _priority = TaskPriority.none;

  final Map<TaskPriority, Color> priorityColors = {
    TaskPriority.none: Colors.grey.shade400,
    TaskPriority.low: const Color(0xFF3B82F6), 
    TaskPriority.medium: const Color(0xFFEAB308), 
    TaskPriority.high: const Color(0xFFEF4444), 
  };

  Future<void> _pickDateTime() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.black),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(primary: Colors.black),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _isDeadline = true;
          _selectedDeadline = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    } else {
      setState(() => _isDeadline = false);
    }
  }

  String _getFormattedDate() {
    if (_selectedDeadline == null) return 'Deadline';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final minute = _selectedDeadline!.minute.toString().padLeft(2, '0');
    return '${months[_selectedDeadline!.month - 1]} ${_selectedDeadline!.day}, ${_selectedDeadline!.hour}:$minute';
  }

  void _submitTask() {
    if (_titleController.text.trim().isEmpty) return;

    final newTask = TaskEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      type: _isDeadline ? TaskType.deadline : TaskType.normal,
      priority: _priority,
      deadline: _isDeadline ? _selectedDeadline : null, 
    );

    context.read<TaskCubit>().addTask(newTask);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24, 
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF0F0F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            autofocus: true,
            style: GoogleFonts.dmSans(fontSize: 18, color: const Color(0xFF0A0A0A)),
            decoration: InputDecoration(
              hintText: 'What needs to be done?',
              hintStyle: GoogleFonts.dmSans(color: Colors.black.withOpacity(0.3)),
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _pickDateTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isDeadline ? const Color(0xFF0A0A0A) : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getFormattedDate(),
                    style: GoogleFonts.dmMono(
                      color: _isDeadline ? Colors.white : Colors.black.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              
              Row(
                children: TaskPriority.values.map((p) {
                  final isSelected = _priority == p;
                  return GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: Container(
                      margin: const EdgeInsets.only(left: 12),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.white : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? priorityColors[p]! : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: CircleAvatar(
                          radius: 6,
                          backgroundColor: priorityColors[p],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A0A0A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: _submitTask,
              child: Text(
                'Save Task',
                style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}