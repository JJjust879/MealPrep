import 'package:flutter/material.dart';

/// Landing page that introduces the app and guides users to sign up/sign in.
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  size: 60,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to\nMeal Planner',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Plan your meals, organize your schedule,\nand eat healthier every day.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    FeatureItem(
                      icon: Icons.calendar_today,
                      title: 'Weekly Planning',
                      description: 'Plan your meals for the entire week',
                    ),
                    SizedBox(height: 16),
                    FeatureItem(
                      icon: Icons.list_alt,
                      title: 'Smart Lists',
                      description: 'Generate shopping lists automatically',
                    ),
                    SizedBox(height: 16),
                    FeatureItem(
                      icon: Icons.favorite,
                      title: 'Healthy Choices',
                      description: 'Track nutrition and stay healthy',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/auth');
                  },
                  child: Text(
                    'Get Started',
                    style: TextStyle(fontSize: 16, color: Colors.green[700]),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget that displays a feature with an icon, title, and description.
class FeatureItem extends StatelessWidget {
  const FeatureItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.green[700],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
