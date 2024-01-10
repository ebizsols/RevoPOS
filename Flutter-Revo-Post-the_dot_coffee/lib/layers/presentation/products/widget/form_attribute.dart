import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/layers/data/models/product_variation_model.dart';
import 'package:revo_pos/layers/domain/entities/product_attribute.dart';
import 'package:revo_pos/layers/domain/entities/product_variation.dart';
import 'package:revo_pos/layers/presentation/products/widget/form_option.dart';

import '../../revo_pos_text_field.dart';

class FormAttrtibute extends StatefulWidget {
  final bool? withImage;
  final bool withAdd;
  final ProductAttribute attribute;
  final List<ProductVariation>? variations;

  const FormAttrtibute({Key? key, this.withImage, required this.withAdd, required this.attribute, this.variations}) : super(key: key);

  @override
  _FormAttrtibuteState createState() => _FormAttrtibuteState();
}

class _FormAttrtibuteState extends State<FormAttrtibute> {

  TextEditingController attributeController = TextEditingController();
  List<ProductVariation>? variations;

  @override
  void initState() {
    super.initState();
    variations = widget.variations;

    attributeController.text = widget.attribute.name ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          withTopPadding: true,
          text: "Attribute",
          controller: attributeController,
          maxLines: 1,
        ),

        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: variations?.length ?? 0,
              itemBuilder: (_, index) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorDisabled)
                  ),
                  child: FormOption(
                    variation: variations![index],
                    withAdd: index == variations!.length - 1,
                    onAddVariant: () {
                      setState(() {
                        var variation = ProductVariationModel(
                          isInStock: true,
                          displayRegularPrice: 0,
                        );
                        variations!.add(variation);
                      });
                    },
                  ),
                );
              },
              separatorBuilder: (_, index) => const SizedBox(height: 20),
            )
          ],
        ),
      ],
    );
  }

  _buildTextField({required bool withTopPadding, required String text, String? hintText, int? maxLines, TextInputType? keyboardType, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (withTopPadding) const SizedBox(height: 12),
        Text(
          text,
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 4),
        RevoPosTextField(
          controller: controller,
          hintText: hintText,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: (value) {

          },
        )
      ],
    );
  }

  _buildImage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 72,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset(
                    "assets/images/item_dummy_2.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Max :3MB. Format : jpg, jpeg, png. Size : 140 x 140",
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: Colors.grey
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
