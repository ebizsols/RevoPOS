import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:revo_pos/core/config/app_config.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/currency_converter.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/core/utils/multicurrency_format.dart';
import 'package:revo_pos/core/utils/url_to_file.dart';
import 'package:revo_pos/layers/data/models/attribute_model.dart';
import 'package:revo_pos/layers/data/models/variation_data_model.dart';
import 'package:revo_pos/layers/domain/entities/product_variation.dart';
import 'package:revo_pos/layers/presentation/products/notifier/attribute_notifier.dart';
import 'package:revo_pos/layers/presentation/products/notifier/products_notifier.dart';
import 'package:revo_pos/layers/presentation/products/page/product_variation_page.dart';
import 'package:revo_pos/layers/presentation/products/widget/bottom_sheet_category.dart';
import 'package:revo_pos/layers/presentation/revo_pos_button.dart';
import 'package:revo_pos/layers/presentation/revo_pos_chip.dart';
import 'package:revo_pos/layers/presentation/revo_pos_dropdown.dart';
import 'package:revo_pos/layers/domain/entities/category.dart';
import 'package:revo_pos/layers/domain/entities/product.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/layers/presentation/products/notifier/form_product_notifier.dart';
import 'package:revo_pos/layers/presentation/products/widget/form_attribute.dart';
import 'package:revo_pos/layers/presentation/products/widget/item_image_picker.dart';
import 'package:revo_pos/layers/presentation/revo_pos_snackbar.dart';

import '../../revo_pos_loading.dart';
import '../../revo_pos_text_field.dart';

class FormProductPage extends StatefulWidget {
  final Product? product;
  final bool? isEdit;

  const FormProductPage({Key? key, this.product, this.isEdit})
      : super(key: key);

  @override
  _FormProductPageState createState() => _FormProductPageState();
}

class _FormProductPageState extends State<FormProductPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController youtubeLinkController = TextEditingController();

  TextEditingController normalPriceController = TextEditingController();
  TextEditingController salePriceController = TextEditingController();
  TextEditingController skuController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController lengthController = TextEditingController();
  TextEditingController widthController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController totalStockController = TextEditingController();

  ImagePicker picker = ImagePicker();
  String? stockStatus = "instock";
  bool isManageStock = false;
  AttributeNotifier? attributeNotifier;

  String attributes = '';
  String priceMin = '';
  String priceMax = '';
  String price = '';
  String weightMin = '';
  String weightMax = '';
  String weightString = '';
  List<String> tempLabel = [];
  List<double> tempPrice = [];
  List<String> tempWeight = [];
  List<Attribute> listAttr = [];
  List<VariationData> listVar = [];
  bool cekList = true;

  final _formKey = GlobalKey<FormState>();

  getDataVariation() {
    tempLabel.clear();
    tempPrice.clear();
    //Start Attributes
    printLog("Attribute : ${attributeNotifier!.listAttribute.length}");
    for (int i = 0; i < attributeNotifier!.listAttribute.length; i++) {
      if (attributeNotifier!.listAttribute[i].selected == true) {
        tempLabel.add(attributeNotifier!.listAttribute[i].label!);
        attributes = tempLabel.join(", ");
      }
    }
    //END attributes
    //Start Price and Weight
    if (attributeNotifier!.listVariant.length > 0) {
      for (int i = 0; i < attributeNotifier!.listVariant.length; i++) {
        if (attributeNotifier!.listVariant[i].deleteProductVariant == null) {
          if (attributeNotifier!.listVariant[i].varSalePrice != null &&
              attributeNotifier!.listVariant[i].varSalePrice != "" &&
              attributeNotifier!.listVariant[i].varSalePrice != "0") {
            tempPrice.add(
                double.parse(attributeNotifier!.listVariant[i].varSalePrice!));
          } else {
            tempPrice.add(double.parse(
                attributeNotifier!.listVariant[i].varRegularPrice!));
          }
          tempWeight.add(attributeNotifier!.listVariant[i].weight!);
        } else if (attributeNotifier!.listVariant.length == 1 &&
            attributeNotifier!.listVariant[i].deleteProductVariant == "yes") {
          cekList = false;
        }
      }
    }
    if (tempPrice.length > 0 && tempWeight.length > 0) {
      tempWeight.sort();
      tempPrice.sort();
      weightMin = tempWeight.first;
      weightMax = tempWeight.last;
      priceMin = MultiCurrency.convert(tempPrice.first, context);
      priceMax = MultiCurrency.convert(tempPrice.last, context);
    }

    if (tempPrice.length == 1) {
      price = priceMin;
    } else if (priceMin == priceMax) {
      price = priceMin;
    } else {
      price = "${priceMin.toString()} - ${priceMax.toString()}";
    }
    if (tempWeight.length == 1) {
      weightString = weightMin + " kg";
    } else if (weightMin == weightMax) {
      weightString = weightMin + " kg";
    } else {
      weightString = "${weightMin.toString()} - ${weightMax.toString()} kg";
    }
    //END price and Weight
  }

  checkVariationEdit() {
    if (widget.product != null &&
        widget.product!.variations!.isNotEmpty &&
        widget.isEdit!) {
      //SET ATTRIBUTE
      for (int i = 0; i < widget.product!.attributes!.length; i++) {
        String id = widget.product!.attributes![i].id.toString();
        String name = widget.product!.attributes![i].name!;
        Term term;
        List<Term> listTerm = [];
        for (int j = 0;
            j < widget.product!.attributes![i].options!.length;
            j++) {
          for (int k = 0; k < attributeNotifier!.listAttribute.length; k++) {
            print(
                "attribute label : ${attributeNotifier!.listAttribute[k].label}");
            for (int l = 0;
                l < attributeNotifier!.listAttribute[k].term!.length;
                l++) {
              if (widget.product!.attributes![i].options![j]['name']
                      .toString() ==
                  attributeNotifier!.listAttribute[k].term![l].name) {
                // if (widget.product!.attributes![i].options![j] ==
                //     attributeNotifier!.listAttribute[k].term![l].name) {
                term = attributeNotifier!.listAttribute[k].term![l];
                printLog("term name : ${json.encode(term)}");
                term.selected = true;
                listTerm.add(term);
                //printLog("list attribute length : ${json.encode(listTerm)}");
                // }
              }
            }
          }
        }
        listAttr.add(Attribute(
          id: id,
          name: name,
          label: name,
          term: listTerm,
        ));
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AttributeNotifier>().setListAttribute(listAttr);
      });
      //SET LISTVARIANT
      for (int i = 0; i < widget.product!.variations!.length; i++) {
        print("MASUK SINI");
        String? height, length, width, weight;
        String? regularPrice,
            salePrice,
            statusStock,
            manageStock,
            stock,
            productId;
        VariationAttributesModel varAttr;
        List<VariationAttributesModel>? listVarAttr = [];
        height = widget.product!.variations![i].dimensions!.height.toString();
        length = widget.product!.variations![i].dimensions!.length.toString();
        width = widget.product!.variations![i].dimensions!.width.toString();
        weight = widget.product!.variations![i].weight;
        productId = widget.product!.variations![i].variationId.toString();
        regularPrice =
            widget.product!.variations![i].displayRegularPrice.toString();
        salePrice = "0";
        if (widget.product!.variations![i].displayRegularPrice !=
            widget.product!.variations![i].displayPrice) {
          salePrice = widget.product!.variations![i].displayPrice.toString();
        }
        statusStock = widget.product!.variations![i].isInStock!
            ? "instock"
            : "outofstock";
        if (!widget.product!.variations![i].isInStock!) {
          manageStock = "no";
        } else if (widget.product!.variations![i].isInStock! &&
            widget.product!.variations![i].maxQty == "") {
          manageStock = "no";
        } else if (widget.product!.variations![i].isInStock! &&
            widget.product!.variations![i].maxQty != "") {
          manageStock = "yes";
          stock = widget.product!.variations![i].maxQty.toString();
        }
        String? attributeName, option, tempAttributeName;
        int ctr = widget.product!.variations![i].option!.length, id;
        List<String> temp = [];

        for (int j = 0; j < ctr; j++) {
          attributeName = widget.product!.variations![i].option![j].key;
          temp = attributeName!.split("_");
          tempAttributeName = temp[1] + "_" + temp[2];
          id = widget.product!.attributes![j].id!;
          option = widget.product!.variations![i].option![j].value == ""
              ? "All"
              : widget.product!.variations![i].option![j].value!;
          varAttr = VariationAttributesModel(
              id: id, attributeName: tempAttributeName, option: option);
          printLog("Variation option : ${tempAttributeName.toString()}");
          listVarAttr.add(varAttr);
        }
        printLog("ListVarAttr : ${json.encode(listVarAttr)}");
        listVar.add(VariationData(
            variableProductId: productId,
            height: height,
            length: length,
            varManageStock: manageStock,
            varRegularPrice: regularPrice,
            varSalePrice: salePrice,
            varStock: stock,
            varStockStatus: statusStock,
            weight: weight,
            width: width,
            listVariationAttr: listVarAttr));
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          context.read<AttributeNotifier>().setListVariant(listVar);
        });
        printLog("listVar : ${attributeNotifier!.listVariant.length}");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    attributeNotifier = Provider.of<AttributeNotifier>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<FormProductNotifier>().reset();
      context.read<AttributeNotifier>().reset();
      context.read<FormProductNotifier>().getCategories();
      context
          .read<AttributeNotifier>()
          .fetchAttribute(cookie: AppConfig.data!.getString("cookie"))
          .then((value) {
        checkVariationEdit();
      });
    });

    if (widget.product != null && widget.isEdit!) {
      nameController.text = widget.product!.name ?? "";
      descriptionController.text = widget.product!.description ?? "";
      youtubeLinkController.text = widget.product!.externalUrl ?? "";
      skuController.text = widget.product?.sku ?? "";

      if (widget.product!.attributes == null ||
          widget.product!.attributes!.isEmpty) {
        printLog("Masuk if");
        normalPriceController.text =
            widget.product?.regularPrice?.toString() ?? "";
        salePriceController.text = widget.product?.salePrice?.toString() ?? "";
        weightController.text = widget.product?.weight?.toString() ?? "";
        lengthController.text =
            widget.product?.dimensions?.length?.toString() ?? "";
        widthController.text =
            widget.product?.dimensions?.width?.toString() ?? "";
        heightController.text =
            widget.product?.dimensions?.height?.toString() ?? "";
      }

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        context.read<FormProductNotifier>().setProductData(
            widget.product!.attributes != null &&
                    widget.product!.attributes!.isNotEmpty
                ? "Variable"
                : "Simple");

        if (widget.product!.categories != null) {
          context
              .read<FormProductNotifier>()
              .setSelectedCategories(widget.product!.categories!);
        }

        if (widget.product!.images != null &&
            widget.product!.images!.isNotEmpty) {
          await UrlToFile.download(widget.product!.images![0].src!)
              .then((value) {
            context.read<FormProductNotifier>().setImageMain(XFile(value.path));
          });

          if (widget.product!.images!.length > 1) {
            printLog("length : ${widget.product!.images!.length - 1}");
            widget.product!.images!.sublist(1).forEach((image) async {
              await UrlToFile.download(image.src!).then((value) {
                context
                    .read<FormProductNotifier>()
                    .addImageGallery(XFile(value.path));
              });
            });
          }
        }
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        context.read<FormProductNotifier>().setProductData("Simple");
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    descriptionController.dispose();
    youtubeLinkController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cookie = AppConfig.data!.getString('cookie');

    final selectedCategories =
        context.select((FormProductNotifier n) => n.selectedCategories);
    final categories = context.select((FormProductNotifier n) => n.categories);
    final isLoadingCategories =
        context.select((FormProductNotifier n) => n.isLoadingCategories);

    final productData =
        context.select((FormProductNotifier n) => n.productData);

    // final insert = context.select((FormProductNotifier n) => n.statusInsert);
    // final isLoadingInsert = context.select((FormProductNotifier n) => n.isLoadingInsert);

    final imageMain = context.select((FormProductNotifier n) => n.imageMain);
    final galleryImages =
        context.select((FormProductNotifier n) => n.listGalleryImages);

    final stockStatuses =
        context.select((FormProductNotifier n) => n.listStockStatus);
    final selectedStockStatus =
        context.select((FormProductNotifier n) => n.selectedStockStatus);

    return Scaffold(
      appBar: _buildAppBar(),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImage(file: imageMain),

                  _buildGallery(),

                  const SizedBox(height: 32),
                  _buildTextField(
                      withTopPadding: false,
                      controller: nameController,
                      text: "Product name",
                      hintText: "Name",
                      maxLines: 1,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Name must not be empty";
                        }
                        return null;
                      }),

                  _buildTextField(
                      withTopPadding: true,
                      text: "Description",
                      controller: descriptionController,
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Description must not be empty";
                        }
                        return null;
                      }),

                  _buildCategory(
                      selected: selectedCategories,
                      categories: categories,
                      isLoading: isLoadingCategories),

                  // const SizedBox(height: 12),
                  // Text(
                  //   "Sub category",
                  //   style: Theme.of(context).textTheme.headline6,
                  // ),
                  // const SizedBox(height: 4),
                  // RevoPosDropdown(
                  //   value: "A",
                  //   items: const ["A", "B", "C"],
                  //   itemBuilder: (value) => DropdownMenuItem(
                  //     value: value,
                  //     child: Text(
                  //       value
                  //     )
                  //   ),
                  //   onChanged: (value) { },
                  // ),

                  // _buildTextField(
                  //   withTopPadding: true,
                  //   text: "Youtube link",
                  //   controller: youtubeLinkController,
                  //   maxLines: 2,
                  // ),

                  const SizedBox(height: 32),
                  Text(
                    "Product type",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(height: 4),
                  RevoPosDropdown(
                    value: productData,
                    items: const ["Simple", "Variable"],
                    itemBuilder: (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                    onChanged: (value) => context
                        .read<FormProductNotifier>()
                        .setProductData(value),
                  ),
                  productData == "Variable"
                      ? _buildTextField(
                          withTopPadding: true,
                          text: "SKU",
                          hintText: "SKU",
                          controller: skuController,
                          maxLines: 1,
                        )
                      : const SizedBox(),

                  LayoutBuilder(builder: (_, constraint) {
                    // if (productData == "Variable") {
                    //   return Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       const SizedBox(height: 32),
                    //       ListView.separated(
                    //         shrinkWrap: true,
                    //         physics: const NeverScrollableScrollPhysics(),
                    //         itemCount: widget.product?.attributes?.length ?? 1,
                    //         itemBuilder: (_, index) => FormAttrtibute(
                    //           attribute: widget.product!.attributes![index],
                    //           variations: widget.product!.variations,
                    //           withImage: true,
                    //           withAdd: index ==
                    //               widget.product!.attributes!.length - 1,
                    //         ),
                    //         separatorBuilder: (_, index) =>
                    //             const SizedBox(height: 20),
                    //       ),
                    //     ],
                    //   );
                    // } else {
                    return productData == "Simple"
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField(
                                  withTopPadding: true,
                                  text: "Normal price",
                                  hintText: "Rp",
                                  controller: normalPriceController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9]')),
                                  ],
                                  maxLines: 1,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Normal price must not be empty";
                                    }
                                    return null;
                                  }),
                              _buildTextField(
                                withTopPadding: true,
                                text: "Sale price",
                                hintText: "Rp",
                                controller: salePriceController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]')),
                                ],
                                maxLines: 1,
                                // validator: (value) {
                                //   if (value == null || value.isEmpty) {
                                //     return "Sale price must not be empty";
                                //   }
                                //   return null;
                                // }
                              ),
                              _buildTextField(
                                  withTopPadding: true,
                                  text: "SKU",
                                  hintText: "SKU",
                                  controller: skuController,
                                  maxLines: 1,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "SKU must not be empty";
                                    }
                                    return null;
                                  }),
                              _buildTextField(
                                withTopPadding: true,
                                text: "Weight (kg)",
                                hintText: "Weight (kg)",
                                controller: weightController,
                                keyboardType: TextInputType.number,
                                maxLines: 1,
                                // validator: (value) {
                                //   if (value == null || value.isEmpty) {
                                //     return "Weight must not be empty";
                                //   }
                                //   return null;
                                // }
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
                                      onChanged: (value) {},
                                      // validator: (value) {
                                      //   if (value == null || value.isEmpty) {
                                      //     return "Length must not be empty";
                                      //   }
                                      //   return null;
                                      // }
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RevoPosTextField(
                                      controller: widthController,
                                      hintText: "Width",
                                      maxLines: 1,
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {},
                                      // validator: (value) {
                                      //   if (value == null || value.isEmpty) {
                                      //     return "Width must not be empty";
                                      //   }
                                      //   return null;
                                      // }
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RevoPosTextField(
                                      controller: heightController,
                                      hintText: "Height",
                                      maxLines: 1,
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {},
                                      // validator: (value) {
                                      //   if (value == null || value.isEmpty) {
                                      //     return "Height must not be empty";
                                      //   }
                                      //   return null;
                                      // }
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildCheckBox(),
                              const SizedBox(height: 12),
                              Visibility(
                                visible: !isManageStock,
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Stock status",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      ),
                                      const SizedBox(height: 4),
                                      SizedBox(
                                        height: 44,
                                        child: ListView.separated(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: stockStatuses.length,
                                          itemBuilder: (_, index) {
                                            return RevoPosChip(
                                              text: stockStatuses[index],
                                              isEnabled: true,
                                              isSelected:
                                                  index == selectedStockStatus,
                                              onTap: () {
                                                context
                                                    .read<FormProductNotifier>()
                                                    .setSelectedStockStatus(
                                                        index);
                                                if (stockStatuses[index] ==
                                                    "In Stock") {
                                                  setState(() {
                                                    stockStatus = "instock";
                                                  });
                                                } else {
                                                  setState(() {
                                                    stockStatus = "outofstock";
                                                  });
                                                }
                                              },
                                            );
                                          },
                                          separatorBuilder: (_, index) =>
                                              const SizedBox(width: 8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: isManageStock,
                                child: _buildTextField(
                                  withTopPadding: true,
                                  text: "Total stock",
                                  hintText: "",
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty && isManageStock) {
                                      return "Total stock";
                                    }
                                    return null;
                                  },
                                  controller: totalStockController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9]')),
                                  ],
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          )
                        : GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ProductVariationPage(),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 12),
                              height: 40,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: Text(
                                        "Product Variation",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Container(
                                    child: const Icon(
                                      Icons.arrow_right,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                    //}
                  }),
                  productData == "Variable" ? _buildListVariant() : Container(),
                  Divider(),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: RevoPosButton(
                        text: "Submit",
                        onPressed: () async {
                          printLog(salePriceController.text.toString(),
                              name: "Product type");
                          if (productData == "Simple") {
                            if (_formKey.currentState!.validate() &&
                                selectedCategories.isNotEmpty &&
                                selectedStockStatus != null &&
                                imageMain != null &&
                                cookie != null &&
                                productData != null) {
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (_) => const RevoPosLoading());

                              context.read<FormProductNotifier>().getBase64();

                              context
                                  .read<FormProductNotifier>()
                                  .insertProduct(
                                    cookie: cookie,
                                    id: widget.product != null
                                        ? widget.product!.id!.toString()
                                        : null,
                                    name: nameController.text,
                                    description: descriptionController.text,
                                    regularPrice:
                                        int.parse(normalPriceController.text),
                                    salePrice: salePriceController.text.isEmpty
                                        ? 0
                                        : int.parse(salePriceController.text),
                                    weight: weightController.text.isEmpty
                                        ? 0
                                        : double.parse(weightController.text),
                                    width: widthController.text.isEmpty
                                        ? 0
                                        : double.parse(widthController.text),
                                    height: heightController.text.isEmpty
                                        ? 0
                                        : double.parse(heightController.text),
                                    length: lengthController.text.isEmpty
                                        ? 0
                                        : double.parse(lengthController.text),
                                    sku: skuController.text,
                                    idCategories: selectedCategories
                                        .map((e) => e.termId ?? e.id!)
                                        .toList(),
                                    type: productData,
                                    stockStatus: isManageStock
                                        ? "instock"
                                        : stockStatus! == null
                                            ? "instock"
                                            : stockStatus,
                                    variationData: productData == "Variable"
                                        ? attributeNotifier!.listVariant
                                        : null,
                                    manageStock: isManageStock,
                                    stock: totalStockController.text == ""
                                        ? 0
                                        : int.parse(totalStockController.text),
                                    titleImage: imageMain.name,
                                  )
                                  .then((value) async {
                                Navigator.pop(context);
                                printLog("value : ${value}");
                                if (widget.product != null) {
                                  Navigator.pop(context);
                                }

                                if (value!.id != null) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((timeStamp) {
                                    context.read<ProductsNotifier>().reset();
                                    context
                                        .read<ProductsNotifier>()
                                        .getProducts();
                                  });
                                  Navigator.pop(context);
                                } else {}
                              });
                            } else {
                              RevoPosSnackbar(
                                      text: "Please fill in all data.",
                                      context: context)
                                  .showSnackbar();
                            }
                          } else if (productData == "Variable") {
                            if (_formKey.currentState!.validate() &&
                                selectedCategories.isNotEmpty &&
                                imageMain != null &&
                                cookie != null &&
                                productData != null &&
                                attributeNotifier!.listVariant.isNotEmpty) {
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (_) => const RevoPosLoading());

                              context.read<FormProductNotifier>().getBase64();
                              attributeNotifier!.getProdAttribute();
                              context
                                  .read<FormProductNotifier>()
                                  .insertProduct(
                                    cookie: cookie,
                                    id: widget.product != null
                                        ? widget.product!.id!.toString()
                                        : null,
                                    name: nameController.text,
                                    description: descriptionController.text,
                                    idCategories: selectedCategories
                                        .map((e) => e.termId ?? e.id!)
                                        .toList(),
                                    type: productData.toLowerCase(),
                                    productAttribute:
                                        attributeNotifier!.listProductAttribute,
                                    variationData: productData == "Variable"
                                        ? attributeNotifier!.listVariant
                                        : null,
                                    titleImage: imageMain.name,
                                    sku: skuController.text,
                                  )
                                  .then((value) async {
                                Navigator.pop(context);
                                printLog("value : ${value}");
                                if (widget.product != null) {
                                  Navigator.pop(context);
                                }

                                if (value!.id != null) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((timeStamp) {
                                    context.read<ProductsNotifier>().reset();
                                    context.read<AttributeNotifier>().reset();
                                    context
                                        .read<ProductsNotifier>()
                                        .getProducts();
                                  });
                                  Navigator.pop(context);
                                } else {}
                              });
                            } else {
                              RevoPosSnackbar(
                                      text: "Please fill in all data.",
                                      context: context)
                                  .showSnackbar();
                            }
                          }
                        }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildAppBar() => AppBar(
        backgroundColor: colorWhite,
        iconTheme: IconThemeData(color: colorBlack),
        title: Text("${widget.product != null ? "Edit" : "New"} Product"),
      );

  _buildCheckBox() => Container(
        margin: EdgeInsets.only(top: 15),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: isManageStock,
              onChanged: (val) {
                setState(() {
                  isManageStock = !isManageStock;
                });
              },
              activeColor: colorPrimary,
            ),
          ),
          Text(
            "Manage Stock",
            style: Theme.of(context).textTheme.headline6,
          )
        ]),
      );

  _buildListVariant() =>
      Consumer<AttributeNotifier>(builder: (((context, value, child) {
        if (value.listVariant.isNotEmpty) {
          getDataVariation();
        }
        return value.listVariant.isEmpty && cekList
            ? Container()
            : Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    child: Row(
                      children: [
                        Text("Attributes",
                            style: TextStyle(
                                color: Colors.black38,
                                fontWeight: FontWeight.bold)),
                        Spacer(),
                        Text(attributes,
                            style: TextStyle(
                                color: Colors.black38,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    child: Row(
                      children: [
                        Text("Price",
                            style: TextStyle(
                                color: Colors.black38,
                                fontWeight: FontWeight.bold)),
                        Spacer(),
                        Text(price,
                            style: TextStyle(
                                color: Colors.black38,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    child: Row(
                      children: [
                        Text("Weight",
                            style: TextStyle(
                                color: Colors.black38,
                                fontWeight: FontWeight.bold)),
                        Spacer(),
                        Text(weightString,
                            style: TextStyle(
                                color: Colors.black38,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              );
      })));

  _buildImage({XFile? file}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          child: FractionallySizedBox(
            widthFactor: 0.4,
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: file == null
                    ? Image.asset(
                        "assets/images/placeholder_image.png",
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(file.path),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Center(
            child: RevoPosButton(
                text: "Upload image", onPressed: _showBottomSheetImage),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: Center(
            child: Text(
              "Max :3MB. Format : jpg, jpeg, png. Size : 600 x 600",
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  _buildGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          "Gallery",
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 72,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child:
                Consumer<FormProductNotifier>(builder: (context, value, child) {
              return Row(
                children: [
                  if (value.listGalleryImages.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ListView.separated(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: value.listGalleryImages.length,
                        itemBuilder: (_, index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Image.file(
                                    File(value.listGalleryImages[index].path),
                                    width: 72,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                  top: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () {
                                      context
                                          .read<FormProductNotifier>()
                                          .removeImageGallery(index);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                          color: colorDanger,
                                          borderRadius:
                                              BorderRadius.circular(32)),
                                      child: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: colorWhite,
                                      ),
                                    ),
                                  ))
                            ],
                          );
                        },
                        separatorBuilder: (_, index) =>
                            const SizedBox(width: 8),
                      ),
                    ),
                  InkWell(
                    onTap: () => _showBottomSheetImage(isGallery: true),
                    borderRadius: BorderRadius.circular(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.asset(
                          "assets/images/placeholder_upload.png",
                          width: 72,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  _buildCategory(
      {required List<Category> selected,
      List<Category?>? categories,
      required bool isLoading}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          "Category",
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selected
                  .map((e) => RevoPosChip(
                      text: e.name ?? "",
                      rightIcon: Icons.close,
                      isEnabled: true,
                      isSelected: true,
                      onTap: () {
                        // var newSelected = selected;
                        // newSelected.remove(e);
                        setState(() {
                          context
                              .read<FormProductNotifier>()
                              .removeSelectedCategories(e.id ?? e.termId!);
                        });
                      }))
                  .toList(),
            ),
            RevoPosChip(
                text: "Add",
                leftIcon: Icons.add,
                isEnabled: true,
                isSelected: false,
                onTap: () {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    context.read<FormProductNotifier>().getCategories();
                  });
                  setState(() {
                    _showBottomSheetCategories(
                        selected: selected,
                        categories: categories,
                        isLoading: isLoading);
                  });
                })
          ],
        ),
      ],
    );
  }

  _buildTextField(
      {required bool withTopPadding,
      required String text,
      required TextEditingController controller,
      String? hintText,
      int? maxLines,
      TextInputType? keyboardType,
      List<TextInputFormatter>? inputFormatters,
      String? Function(String?)? validator}) {
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
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: (value) {},
        )
      ],
    );
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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
            Container(
                decoration: BoxDecoration(
                  color: colorWhite,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      ItemImagePicker(
                        title: "Gallery",
                        icon: FontAwesomeIcons.image,
                        onTap: () => _pickImage(ImageSource.gallery,
                            isGallery: isGallery),
                      ),
                      ItemImagePicker(
                        title: "Camera",
                        icon: FontAwesomeIcons.camera,
                        onTap: () => _pickImage(ImageSource.camera,
                            isGallery: isGallery),
                      ),
                    ],
                  ),
                ))
          ],
        );
      },
    );
  }

  _showBottomSheetCategories(
      {required List<Category> selected,
      List<Category?>? categories,
      required bool isLoading}) {
    categories ??= List.generate(6, (index) => null);

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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
            Container(
                height: RevoPosMediaQuery.getHeight(context) - 150,
                decoration: BoxDecoration(
                  color: colorWhite,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: BottomSheetCategory(
                  selected: selected,
                  categories: categories,
                  isLoading: isLoading,
                ))
          ],
        );
      },
    ).whenComplete(() {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        context.read<FormProductNotifier>().getCategories();
      });
    });
  }

  Future _pickImage(ImageSource source, {bool? isGallery}) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        if (isGallery != null && isGallery) {
          context.read<FormProductNotifier>().addImageGallery(pickedFile);
        } else {
          context.read<FormProductNotifier>().setImageMain(pickedFile);
        }
      });
      Navigator.pop(context);
    }
  }
}
