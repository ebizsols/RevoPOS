import 'package:flutter/material.dart';

class ItemCategoryChild extends StatelessWidget {
  final String? name;
  final String? image;
  final Function() onTap;

  const ItemCategoryChild({Key? key, required this.onTap, this.name, this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  image ?? "assets/images/category_dummy_1.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 8),
            Text(
              name ?? "",
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyText1,
            )
          ],
        ),
      ),
    );
  }
}
