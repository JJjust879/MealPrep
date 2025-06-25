import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MealScheduleScreen extends StatefulWidget {
  @override
  _MealScheduleScreenState createState() => _MealScheduleScreenState();
}

class _MealScheduleScreenState extends State<MealScheduleScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sample data structure for meals
  Map<String, Map<String, String?>> weeklyMeals = {
    'Monday': {'Breakfast': null, 'Lunch': null, 'Dinner': null},
    'Tuesday': {'Breakfast': null, 'Lunch': null, 'Dinner': null},
    'Wednesday': {'Breakfast': null, 'Lunch': null, 'Dinner': null},
    'Thursday': {'Breakfast': null, 'Lunch': null, 'Dinner': null},
    'Friday': {'Breakfast': null, 'Lunch': null, 'Dinner': null},
    'Saturday': {'Breakfast': null, 'Lunch': null, 'Dinner': null},
    'Sunday': {'Breakfast': null, 'Lunch': null, 'Dinner': null},
  };

  // Store meal IDs for saving to Firebase later
  Map<String, Map<String, String?>> weeklyMealIds = {
    'Monday': {'Breakfast': null, 'Lunch': null, 'Dinner': null},
    'Tuesday': {'Breakfast': null, 'Lunch': null, 'Dinner': null},
    'Wednesday': {'Breakfast': null, 'Lunch': null, 'Dinner': null},
    'Thursday': {'Breakfast': null, 'Lunch': null, 'Dinner': null},
    'Friday': {'Breakfast': null, 'Lunch': null, 'Dinner': null},
    'Saturday': {'Breakfast': null, 'Lunch': null, 'Dinner': null},
    'Sunday': {'Breakfast': null, 'Lunch': null, 'Dinner': null},
  };

  @override
  void initState() {
    super.initState();
    _loadScheduledMeals();
  }

  // Load existing scheduled meals from Firebase
  Future<void> _loadScheduledMeals() async {
    try {
      QuerySnapshot schedulingSnapshot = await _firestore
          .collection('Scheduling')
          .get();

      for (var doc in schedulingSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data['DateTime'] != null && data['Meal'] != null && data['Type'] != null) {
          DateTime dateTime = (data['DateTime'] as Timestamp).toDate();
          String dayOfWeek = _getDayOfWeek(dateTime.weekday);
          String mealType = data['Type'];
          String mealRef = data['Meal'];

          // Extract meal ID from reference path
          String mealId = mealRef.split('/').last;

          // Get meal name from Meals collection
          DocumentSnapshot mealDoc = await _firestore
              .collection('Meals')
              .doc(mealId)
              .get();

          if (mealDoc.exists) {
            Map<String, dynamic> mealData = mealDoc.data() as Map<String, dynamic>;
            String mealName = mealData['Name'] ?? 'Unknown Meal';

            setState(() {
              weeklyMeals[dayOfWeek]![mealType] = mealName;
              weeklyMealIds[dayOfWeek]![mealType] = mealId;
            });
          }
        }
      }
    } catch (e) {
      print('Error loading scheduled meals: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading scheduled meals')),
      );
    }
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Monday';
    }
  }

  // Fetch meals from Firebase and show picker
  Future<void> _showMealPicker(String day, String mealType) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      QuerySnapshot mealsSnapshot = await _firestore
          .collection('Meals')
          .get();

      // Close loading dialog
      Navigator.of(context).pop();

      if (mealsSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No meals found in database')),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select $mealType for $day'),
            content: Container(
              width: double.maxFinite,
              height: 300,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: mealsSnapshot.docs.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                      leading: Icon(Icons.clear),
                      title: Text('Clear selection'),
                      onTap: () {
                        _clearMealSelection(day, mealType);
                        Navigator.of(context).pop();
                      },
                    );
                  }

                  DocumentSnapshot mealDoc = mealsSnapshot.docs[index - 1];
                  Map<String, dynamic> mealData = mealDoc.data() as Map<String, dynamic>;
                  String mealName = mealData['Name'] ?? 'Unknown Meal';

                  return ListTile(
                    leading: Icon(Icons.restaurant),
                    title: Text(mealName),
                    onTap: () {
                      _selectMeal(day, mealType, mealName, mealDoc.id);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Close loading dialog if still open
      Navigator.of(context).pop();

      print('Error fetching meals: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching meals from database')),
      );
    }
  }

  // Select a meal and save to Firebase
  Future<void> _selectMeal(String day, String mealType, String mealName, String mealId) async {
    setState(() {
      weeklyMeals[day]![mealType] = mealName;
      weeklyMealIds[day]![mealType] = mealId;
    });

    // Save to Firebase Scheduling collection
    try {
      // Calculate the date for the selected day
      DateTime now = DateTime.now();
      int currentWeekday = now.weekday;
      int targetWeekday = _getWeekdayNumber(day);
      int daysToAdd = (targetWeekday - currentWeekday) % 7;
      DateTime targetDate = now.add(Duration(days: daysToAdd));

      // Set time based on meal type
      DateTime scheduledDateTime;
      switch (mealType) {
        case 'Breakfast':
          scheduledDateTime = DateTime(targetDate.year, targetDate.month, targetDate.day, 8, 0);
          break;
        case 'Lunch':
          scheduledDateTime = DateTime(targetDate.year, targetDate.month, targetDate.day, 12, 0);
          break;
        case 'Dinner':
          scheduledDateTime = DateTime(targetDate.year, targetDate.month, targetDate.day, 18, 0);
          break;
        default:
          scheduledDateTime = targetDate;
      }

      await _firestore.collection('Scheduling').add({
        'DateTime': Timestamp.fromDate(scheduledDateTime),
        'Meal': '/MealPrep/Meals/$mealId',
        'Type': mealType,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$mealType scheduled for $day')),
      );
    } catch (e) {
      print('Error saving to Firebase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving meal schedule')),
      );
    }
  }

  // Clear meal selection and remove from Firebase
  Future<void> _clearMealSelection(String day, String mealType) async {
    setState(() {
      weeklyMeals[day]![mealType] = null;
      weeklyMealIds[day]![mealType] = null;
    });

    // Remove from Firebase (find and delete the document)
    try {
      QuerySnapshot existingSchedules = await _firestore
          .collection('Scheduling')
          .where('Type', isEqualTo: mealType)
          .get();

      for (var doc in existingSchedules.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        DateTime dateTime = (data['DateTime'] as Timestamp).toDate();
        String scheduledDay = _getDayOfWeek(dateTime.weekday);

        if (scheduledDay == day) {
          await doc.reference.delete();
          break;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$mealType cleared for $day')),
      );
    } catch (e) {
      print('Error clearing from Firebase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error clearing meal schedule')),
      );
    }
  }

  int _getWeekdayNumber(String day) {
    switch (day) {
      case 'Monday': return 1;
      case 'Tuesday': return 2;
      case 'Wednesday': return 3;
      case 'Thursday': return 4;
      case 'Friday': return 5;
      case 'Saturday': return 6;
      case 'Sunday': return 7;
      default: return 1;
    }
  }

  Widget _buildMealCard(String day, String mealType, String? meal) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getMealColor(mealType),
          child: Icon(
            _getMealIcon(mealType),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          mealType,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          meal ?? 'Not planned',
          style: TextStyle(
            color: meal != null ? Colors.black87 : Colors.grey,
            fontStyle: meal != null ? FontStyle.normal : FontStyle.italic,
          ),
        ),
        trailing: Icon(Icons.edit),
        onTap: () => _showMealPicker(day, mealType),
      ),
    );
  }

  Color _getMealColor(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return Colors.orange;
      case 'Lunch':
        return Colors.green;
      case 'Dinner':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return Icons.wb_sunny;
      case 'Lunch':
        return Icons.wb_cloudy;
      case 'Dinner':
        return Icons.nights_stay;
      default:
        return Icons.restaurant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Schedule'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _loadScheduledMeals();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Schedule refreshed')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: weeklyMeals.keys.length,
        itemBuilder: (context, index) {
          String day = weeklyMeals.keys.elementAt(index);
          Map<String, String?> dayMeals = weeklyMeals[day]!;

          return Card(
            margin: EdgeInsets.only(bottom: 16),
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.blue,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        day,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ...dayMeals.entries.map((entry) {
                    return _buildMealCard(day, entry.key, entry.value);
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Show summary of planned meals
          int plannedMeals = 0;
          weeklyMeals.forEach((day, meals) {
            meals.forEach((mealType, meal) {
              if (meal != null) plannedMeals++;
            });
          });

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Meal Plan Summary'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total meals planned: $plannedMeals out of 21'),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: plannedMeals / 21,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Completion: ${(plannedMeals / 21 * 100).toStringAsFixed(1)}%',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        },
        icon: Icon(Icons.summarize),
        label: Text('Summary'),
        backgroundColor: Colors.green,
      ),
    );
  }
}