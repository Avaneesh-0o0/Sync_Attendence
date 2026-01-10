import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_bar.dart';

class StudentAttendanceHistory extends StatelessWidget {
  const StudentAttendanceHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance History')),
      body: const Center(child: Text('Student Attendance History')),
      bottomNavigationBar: CustomBottomBar.student(
        currentIndex: 1,
        onTap: (index) {
          // Navigation handled by bottom bar
        },
      ),
    );
  }
}

