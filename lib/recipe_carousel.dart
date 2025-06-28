import 'package:flutter/material.dart';
import 'recipemodel.dart';

class RecipeCarousel extends StatelessWidget {
  final List<RecipeModel> recipes;
  final String title;
  final TextStyle? titleStyle;
  const RecipeCarousel({
    super.key,
    required this.recipes,
    required this.title,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            title,
            style: titleStyle ?? Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recipes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return SizedBox(
                width: 250, // Increased width for future image and details
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Placeholder for image
                            Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.image,
                                size: 32,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Removed description, only show name, time, and calories
                            Text(
                              recipe.name,
                              style: Theme.of(
                                context,
                              ).textTheme.titleSmall?.copyWith(fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 14),
                                const SizedBox(width: 3),
                                Text(
                                  recipe.time,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(fontSize: 11),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  Icons.local_fire_department,
                                  size: 14,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  recipe.calories != null
                                      ? '${recipe.calories} kcal'
                                      : '-- kcal',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: _WishlistButton(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WishlistButton extends StatefulWidget {
  @override
  State<_WishlistButton> createState() => _WishlistButtonState();
}

class _WishlistButtonState extends State<_WishlistButton> {
  bool wishlisted = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        wishlisted ? Icons.favorite : Icons.favorite_border,
        color: wishlisted ? Colors.red : Colors.grey,
      ),
      tooltip: wishlisted ? 'Remove from Wishlist' : 'Add to Wishlist',
      onPressed: () {
        setState(() {
          wishlisted = !wishlisted;
        });
      },
    );
  }
}
