import 'package:flutter/material.dart';
import 'package:revo_pos/core/constant/constants.dart';

class ItemCategoryPos extends StatelessWidget {
  final String? name;
  final String? image;
  final bool isSelected;
  final Function() onTap;

  const ItemCategoryPos(
      {Key? key,
      this.name,
      this.image,
      required this.isSelected,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isSelected ? 0 : 2,
        color: isSelected ? Theme.of(context).colorScheme.secondary : colorWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.transparent,
            width: 2
          )
        ),
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(12),
          child: AspectRatio(
            aspectRatio: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FractionallySizedBox(
                  widthFactor: 0.5,
                  child: LayoutBuilder(
                    builder: (_, constraint) {
                      if (image != null) {
                        if (image!.startsWith('asset')) {
                          return Icon(Icons.category_rounded, color: colorPrimary, size: 30,);
                        }

                        return Image.network(
                          image!,
                          fit: BoxFit.cover,
                        );
                      }

                      return Image.asset(
                        "assets/images/placeholder_image.png",
                        fit: BoxFit.cover,
                      );
                    },
                  )
                ),
                const SizedBox(height: 8),
                Text(
                  name ?? "All",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                    color: isSelected
                      ? Theme.of(context).primaryColor
                      : colorBlack,
                    fontWeight: FontWeight.bold,
                    fontSize: 12
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
