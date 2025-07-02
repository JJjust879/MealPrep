import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'MealSelectionPage.dart';

class SchedulingScreen extends StatefulWidget {
  final String? editDocId;
  final String? initialMealId;
  final String? initialMealName;
  final String? initialType;
  final DateTime? initialDateTime;

  const SchedulingScreen({
    super.key,
    this.editDocId,
    this.initialMealId,
    this.initialMealName,
    this.initialType,
    this.initialDateTime,
  });

  @override
  State<SchedulingScreen> createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends State<SchedulingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? selectedMealId;
  String? selectedMealName;
  String? selectedType;
  DateTime? selectedDateTime;

  bool _loading = false;

  final List<String> mealTypes = ['Breakfast', 'Lunch', 'Dinner'];

  @override
  void initState() {
    super.initState();
    selectedMealId = widget.initialMealId;
    selectedMealName = widget.initialMealName;
    selectedType = widget.initialType;
    selectedDateTime = widget.initialDateTime;
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: selectedDateTime != null
          ? TimeOfDay.fromDateTime(selectedDateTime!)
          : const TimeOfDay(hour: 8, minute: 0),
    );

    if (time == null) return;

    setState(() {
      selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _selectMeal() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (_) => const MealSelectionPage()),
    );

    if (result != null) {
      setState(() {
        selectedMealId = result['id'];
        selectedMealName = result['name'];
      });
    }
  }

  Future<void> _saveMeal() async {
    if (selectedMealId == null || selectedType == null || selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      if (widget.editDocId != null) {
        // Update existing doc
        await _firestore.collection('Scheduling').doc(widget.editDocId).update({
          'Meal': selectedMealName,
          'MealId': selectedMealId,
          'Type': selectedType,
          'DateTime': Timestamp.fromDate(selectedDateTime!),
        });
      } else {
        // Add new doc
        final authState = ClerkAuth.of(context);
        final userId = authState.user?.id;

        if (userId == null) throw Exception('User not signed in');

        await _firestore.collection('Scheduling').add({
          'Meal': selectedMealName,
          'MealId': selectedMealId,
          'Type': selectedType,
          'DateTime': Timestamp.fromDate(selectedDateTime!),
          'User': _firestore.doc('/user/$userId'),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.editDocId != null
                ? 'Meal updated successfully!'
                : 'Meal scheduled successfully!',
          ),
        ),
      );

      Navigator.pop(context); // return to previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editDocId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Meal Schedule' : 'Add Meal Schedule'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Meal'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _selectMeal,
              child: Text(selectedMealName ?? 'Choose Meal'),
            ),
            const SizedBox(height: 16),
            const Text('Select Meal Type'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedType,
              items: mealTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedType = value),
              hint: const Text('Choose type'),
            ),
            const SizedBox(height: 16),
            const Text('Select Date & Time'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _pickDateTime,
              child: Text(
                selectedDateTime != null
                    ? selectedDateTime.toString()
                    : 'Pick Date & Time',
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: _loading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.save),
              label: Text(_loading
                  ? (isEdit ? 'Updating...' : 'Saving...')
                  : (isEdit ? 'Update Meal' : 'Save Meal')),
              onPressed: _loading ? null : _saveMeal,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
          ],
        ),
      ),
    );
  }
}
