import 'package:flutter/material.dart';

class GmailBasicInfoScreen extends StatelessWidget {
  final List<String> days =
      List.generate(31, (index) => (index + 1).toString());
  final List<String> months = [
    'Tháng 1',
    'Tháng 2',
    'Tháng 3',
    'Tháng 4',
    'Tháng 5',
    'Tháng 6',
    'Tháng 7',
    'Tháng 8',
    'Tháng 9',
    'Tháng 10',
    'Tháng 11',
    'Tháng 12'
  ];
  final List<String> years =
      List.generate(100, (index) => (2024 - index).toString());
  final List<String> genders = ['Nam', 'Nữ', 'Khác'];

  String? selectedDay;
  String? selectedMonth;
  String? selectedYear;
  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin cơ bản'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nhập ngày sinh và giới tính của bạn',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  hint: Text('Ngày'),
                  value: selectedDay,
                  onChanged: (newValue) {
                    selectedDay = newValue;
                  },
                  items: days.map((day) {
                    return DropdownMenuItem(
                      child: Text(day),
                      value: day,
                    );
                  }).toList(),
                ),
                DropdownButton<String>(
                  hint: Text('Tháng'),
                  value: selectedMonth,
                  onChanged: (newValue) {
                    selectedMonth = newValue;
                  },
                  items: months.map((month) {
                    return DropdownMenuItem(
                      child: Text(month),
                      value: month,
                    );
                  }).toList(),
                ),
                DropdownButton<String>(
                  hint: Text('Năm'),
                  value: selectedYear,
                  onChanged: (newValue) {
                    selectedYear = newValue;
                  },
                  items: years.map((year) {
                    return DropdownMenuItem(
                      child: Text(year),
                      value: year,
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              hint: Text('Giới tính'),
              value: selectedGender,
              onChanged: (newValue) {
                selectedGender = newValue;
              },
              items: genders.map((gender) {
                return DropdownMenuItem(
                  child: Text(gender),
                  value: gender,
                );
              }).toList(),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/create-username');
              },
              child: Text('Tiếp theo'),
            ),
          ],
        ),
      ),
    );
  }
}
