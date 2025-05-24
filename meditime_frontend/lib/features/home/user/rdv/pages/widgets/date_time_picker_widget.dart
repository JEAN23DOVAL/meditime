import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meditime_frontend/features/home/user/rdv/pages/constants/app_constants.dart';

class DateTimePickerWidget extends StatefulWidget {
  final String label;
  final DateTime? initialDate;
  final Function(DateTime) onDateSelected;
  
  const DateTimePickerWidget({
    Key? key,
    required this.label,
    this.initialDate,
    required this.onDateSelected,
  }) : super(key: key);
  
  @override
  State<DateTimePickerWidget> createState() => _DateTimePickerWidgetState();
}

class _DateTimePickerWidgetState extends State<DateTimePickerWidget> {
  late DateTime selectedDay;
  late int selectedHour;
  late int selectedMinute;
  
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDay = widget.initialDate ?? now;
    selectedHour = selectedDay.hour;
    selectedMinute = selectedDay.minute - (selectedDay.minute % 5);
    if (selectedMinute < 0) selectedMinute = 0;
  }
  
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(AppConstants.maxDaysAhead, (i) => now.add(Duration(days: i)));
    final hours = List.generate(24, (i) => i);
    final minutes = List.generate(12, (i) => i * 5);
    
    int selectedDayIndex = _findDayIndex(days);
    int selectedHourIndex = hours.indexOf(selectedHour).clamp(0, hours.length - 1);
    int selectedMinuteIndex = minutes.indexOf(selectedMinute).clamp(0, minutes.length - 1);
    
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: SizedBox(
        height: AppConstants.itemExtent * 3 + 200,
        child: Column(
          children: [
            _buildHeader(),
            _buildYearDisplay(),
            _buildPickerSection(days, hours, minutes, selectedDayIndex, selectedHourIndex, selectedMinuteIndex),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        widget.label,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  Widget _buildYearDisplay() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        '${selectedDay.year}',
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  Widget _buildPickerSection(List<DateTime> days, List<int> hours, List<int> minutes, 
                           int selectedDayIndex, int selectedHourIndex, int selectedMinuteIndex) {
    return SizedBox(
      height: AppConstants.itemExtent * 3,
      child: Stack(
        children: [
          Row(
            children: [
              _buildDayPicker(days, selectedDayIndex),
              _buildHourPicker(hours, selectedHourIndex),
              _buildMinutePicker(minutes, selectedMinuteIndex),
            ],
          ),
          _buildSelectionIndicators(),
        ],
      ),
    );
  }
  
  Widget _buildDayPicker(List<DateTime> days, int selectedDayIndex) {
    return Expanded(
      flex: 2,
      child: ListWheelScrollView.useDelegate(
        itemExtent: AppConstants.itemExtent,
        perspective: 0.002,
        diameterRatio: 2.5,
        physics: const FixedExtentScrollPhysics(),
        controller: FixedExtentScrollController(initialItem: selectedDayIndex),
        onSelectedItemChanged: (index) => _onDayChanged(days[index]),
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) => _buildDayItem(days[index]),
          childCount: days.length,
        ),
      ),
    );
  }
  
  Widget _buildHourPicker(List<int> hours, int selectedHourIndex) {
    return Expanded(
      flex: 1,
      child: ListWheelScrollView.useDelegate(
        itemExtent: AppConstants.itemExtent,
        perspective: 0.002,
        diameterRatio: 2.5,
        physics: const FixedExtentScrollPhysics(),
        controller: FixedExtentScrollController(initialItem: selectedHourIndex),
        onSelectedItemChanged: (index) => _onHourChanged(hours[index]),
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) => _buildTimeItem(hours[index]),
          childCount: hours.length,
        ),
      ),
    );
  }
  
  Widget _buildMinutePicker(List<int> minutes, int selectedMinuteIndex) {
    return Expanded(
      flex: 1,
      child: ListWheelScrollView.useDelegate(
        itemExtent: AppConstants.itemExtent,
        perspective: 0.002,
        diameterRatio: 2.5,
        physics: const FixedExtentScrollPhysics(),
        controller: FixedExtentScrollController(initialItem: selectedMinuteIndex),
        onSelectedItemChanged: (index) => _onMinuteChanged(minutes[index % minutes.length]),
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) => _buildTimeItem(minutes[index % minutes.length]),
          childCount: AppConstants.maxMinuteItems,
        ),
      ),
    );
  }
  
  Widget _buildDayItem(DateTime day) {
    final now = DateTime.now();
    final isToday = day.day == now.day && day.month == now.month && day.year == now.year;
    
    return Center(
      child: Text(
        isToday ? "Aujourd'hui" : DateFormat('EEE d MMM', 'fr_FR').format(day),
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
  
  Widget _buildTimeItem(int value) {
    return Center(
      child: Text(
        value.toString().padLeft(2, '0'),
        style: const TextStyle(fontSize: 22),
      ),
    );
  }
  
  Widget _buildSelectionIndicators() {
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(height: 2, color: AppConstants.primaryColor),
          SizedBox(height: AppConstants.itemExtent),
          Container(height: 2, color: AppConstants.primaryColor),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: AppConstants.buttonHeight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: AppConstants.buttonHeight,
              child: ElevatedButton(
                onPressed: () => _onConfirm(context),
                child: const Text('Suivant', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper methods
  int _findDayIndex(List<DateTime> days) {
    return days.indexWhere((d) =>
      d.day == selectedDay.day && 
      d.month == selectedDay.month && 
      d.year == selectedDay.year
    ).clamp(0, days.length - 1);
  }
  
  void _onDayChanged(DateTime newDay) {
    setState(() {
      selectedDay = DateTime(
        newDay.year,
        newDay.month,
        newDay.day,
        selectedHour,
        selectedMinute,
      );
    });
  }
  
  void _onHourChanged(int hour) {
    setState(() {
      selectedHour = hour;
      selectedDay = DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
        selectedHour,
        selectedMinute,
      );
    });
  }
  
  void _onMinuteChanged(int minute) {
    setState(() {
      selectedMinute = minute;
      selectedDay = DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
        selectedHour,
        selectedMinute,
      );
    });
  }
  
  void _onConfirm(BuildContext context) {
    widget.onDateSelected(selectedDay);
    Navigator.of(context).pop();
  }
}