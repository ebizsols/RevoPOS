import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/layers/domain/entities/product_variation.dart';
import 'package:revo_pos/layers/presentation/revo_pos_chip.dart';

import '../../revo_pos_text_field.dart';
import 'item_image_picker.dart';

class FormOption extends StatefulWidget {
  final ProductVariation? variation;
  final bool withAdd;
  final Function() onAddVariant;

  const FormOption({Key? key, this.variation, required this.withAdd, required this.onAddVariant}) : super(key: key);

  @override
  _FormOptionState createState() => _FormOptionState();
}

class _FormOptionState extends State<FormOption> {

  TextEditingController variationController = TextEditingController();
  TextEditingController normalPriceController = TextEditingController();
  TextEditingController salePriceController = TextEditingController();
  TextEditingController skuController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController lengthController = TextEditingController();
  TextEditingController widthController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController totalStockController = TextEditingController();
  ImagePicker picker = ImagePicker();

  int? selectedStockStatus;

  @override
  void initState() {
    super.initState();

    if (widget.variation != null) {
      normalPriceController.text = widget.variation?.displayRegularPrice.toString() ?? "";
      salePriceController.text = widget.variation?.displayPrice?.toString() ?? "";
      variationController.text = widget.variation?.attributes?.attributeSize ?? "";
      skuController.text = widget.variation?.sku ?? "";
      weightController.text = widget.variation?.weight?.toString() ?? "";
      lengthController.text = widget.variation?.dimensions?.length?.toString() ?? "";
      widthController.text = widget.variation?.dimensions?.width?.toString() ?? "";
      heightController.text = widget.variation?.dimensions?.height?.toString() ?? "";
      // totalStockController.text = widget.attribute.stock?.toString() ?? "";
      //
      selectedStockStatus = widget.variation!.isInStock! ? 0 : 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Option",
          style: Theme.of(context).textTheme.headline6,
        ),

        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: RevoPosTextField(
                controller: variationController,
                hintText: "Example: S, M, L",
                maxLines: 1,
                onChanged: (value) {

                },
              ),
            ),

            if (widget.withAdd) IconButton(
              icon: FaIcon(
                FontAwesomeIcons.plusCircle,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: widget.onAddVariant,
            )
          ],
        ),

        _buildTextField(
          withTopPadding: true,
          text: "Normal price",
          hintText: "Rp",
          controller: normalPriceController,
          keyboardType: TextInputType.number,
          maxLines: 1,
        ),

        _buildTextField(
          withTopPadding: true,
          text: "Sale price",
          hintText: "Rp",
          controller: salePriceController,
          keyboardType: TextInputType.number,
          maxLines: 1,
        ),

        _buildTextField(
          withTopPadding: true,
          text: "SKU",
          hintText: "SKU",
          controller: skuController,
          maxLines: 1,
        ),

        _buildTextField(
          withTopPadding: true,
          text: "Weight (kg)",
          hintText: "Weight (kg)",
          controller: weightController,
          keyboardType: TextInputType.number,
          maxLines: 1,
        ),

        const SizedBox(height: 12),
        Text(
          "Dimension",
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: RevoPosTextField(
                controller: lengthController,
                hintText: "Length",
                maxLines: 1,
                keyboardType: TextInputType.number,
                onChanged: (value) {

                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RevoPosTextField(
                controller: widthController,
                hintText: "Width",
                maxLines: 1,
                keyboardType: TextInputType.number,
                onChanged: (value) {

                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RevoPosTextField(
                controller: heightController,
                hintText: "Height",
                maxLines: 1,
                keyboardType: TextInputType.number,
                onChanged: (value) {

                },
              ),
            ),
          ],
        ),

        _buildTextField(
          withTopPadding: true,
          text: "Total stock",
          hintText: "",
          controller: totalStockController,
          keyboardType: TextInputType.number,
          maxLines: 1,
        ),

        const SizedBox(height: 12),
        Text(
          "Stock status",
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 44,
          child: ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: ["Available", "Out of stock", "In pending order"].length,
            itemBuilder: (_, index) {
              return RevoPosChip(
                text: ["Available", "Out of stock", "In pending order"][index],
                isEnabled: true,
                isSelected: index == selectedStockStatus,
                onTap: () {
                  setState(() => selectedStockStatus = index);
                },
              );
            },
            separatorBuilder: (_, index) => const SizedBox(width: 8),
          ),
        ),

        const SizedBox(height: 12),
        _buildImage(),
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
    String? src;
    if (widget.variation != null) {
      src = widget.variation?.image?.src;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 72,
              child: InkWell(
                onTap: () => _showBottomSheetImage(isGallery: true),
                borderRadius: BorderRadius.circular(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: src == null
                    ? Image.asset(
                      "assets/images/placeholder_upload.png",
                      fit: BoxFit.cover,
                    )
                    : Image.network(
                      src,
                      fit: BoxFit.cover,
                    ),
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

  Future _pickImage(ImageSource source, {bool? isGallery}) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        if (isGallery != null && isGallery) {
          // context.read<FormProductNotifier>().addImageGallery(pickedFile);
        } else {
          // context.read<FormProductNotifier>().setImageMain(pickedFile);
        }
      });
      Navigator.pop(context);
    }
  }

  _showBottomSheetImage({bool? isGallery}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: RevoPosMediaQuery.getWidth(context) * 0.5,
              height: 8,
              decoration: BoxDecoration(
                color: colorWhite,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12)
                ),
              ),
            ),

            const SizedBox(height: 8),
            Container(
                decoration: BoxDecoration(
                  color: colorWhite,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20)
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      ItemImagePicker(
                        title: "Gallery",
                        icon: FontAwesomeIcons.image,
                        onTap: () => _pickImage(
                            ImageSource.gallery,
                            isGallery: isGallery
                        ),
                      ),

                      ItemImagePicker(
                        title: "Camera",
                        icon: FontAwesomeIcons.camera,
                        onTap: () => _pickImage(
                            ImageSource.camera,
                            isGallery: isGallery
                        ),
                      ),
                    ],
                  ),
                )
            )
          ],
        );
      },
    );
  }
}
