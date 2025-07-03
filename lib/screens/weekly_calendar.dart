import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyCalendar extends StatelessWidget {
  final String? userId;
  const WeeklyCalendar({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Weekly Summary",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<QuerySnapshot>(
              future:
                  userId == null
                      ? null
                      : FirebaseFirestore.instance
                          .collection('Scheduling')
                          .where(
                            'User',
                            isEqualTo: FirebaseFirestore.instance.doc(
                              '/user/$userId',
                            ),
                          )
                          .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Text(
                    'No data for this week.',
                    style: TextStyle(color: Colors.green),
                  );
                }
                final docs = snapshot.data?.docs ?? [];
                // Group meals by day
                Map<DateTime, List<Map<String, dynamic>>> mealsByDay = {};
                for (var d in days) {
                  mealsByDay[DateTime(d.year, d.month, d.day)] = [];
                }
                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final dt = (data['DateTime'] as Timestamp).toDate();
                  final dayKey = DateTime(dt.year, dt.month, dt.day);
                  if (mealsByDay.containsKey(dayKey)) {
                    mealsByDay[dayKey]!.add(data);
                  }
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        days.map((d) {
                          final isToday =
                              d.year == today.year &&
                              d.month == today.month &&
                              d.day == today.day;
                          final meals =
                              mealsByDay[DateTime(d.year, d.month, d.day)] ??
                              [];
                          return Container(
                            width: 120,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: isToday ? Colors.green[100] : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isToday
                                        ? Colors.green
                                        : Colors.grey.shade200,
                              ),
                              boxShadow:
                                  isToday
                                      ? [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.1),
                                          blurRadius: 8,
                                        ),
                                      ]
                                      : [],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        isToday
                                            ? Colors.green[700]
                                            : Colors.green[100],
                                    child: Text(
                                      [
                                        'M',
                                        'T',
                                        'W',
                                        'T',
                                        'F',
                                        'S',
                                        'S',
                                      ][d.weekday - 1],
                                      style: TextStyle(
                                        color:
                                            isToday
                                                ? Colors.white
                                                : Colors.green[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${d.day}/${d.month}',
                                    style: TextStyle(
                                      color:
                                          isToday
                                              ? Colors.green[700]
                                              : Colors.grey[700],
                                      fontWeight:
                                          isToday
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  meals.isEmpty
                                      ? Text(
                                        'No meals',
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontSize: 12,
                                        ),
                                      )
                                      : Column(
                                        children:
                                            meals
                                                .map(
                                                  (meal) => Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 2,
                                                        ),
                                                    child: Chip(
                                                      label: Text(
                                                        meal['Meal'] ?? '',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.green[700],
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      backgroundColor:
                                                          Colors.green[50],
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                      ),
                                  if (isToday)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Icon(
                                        Icons.today,
                                        color: Colors.green[700],
                                        size: 18,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
