import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/layers/data/models/attribute_model.dart';
import 'package:revo_pos/layers/data/models/variation_data_model.dart';
import 'package:revo_pos/layers/presentation/products/notifier/attribute_notifier.dart';
import 'package:revo_pos/layers/presentation/products/notifier/form_product_notifier.dart';
import 'package:revo_pos/layers/presentation/revo_pos_button.dart';
import 'package:revo_pos/layers/presentation/revo_pos_chip.dart';
import 'package:revo_pos/layers/presentation/revo_pos_dropdown.dart';
import 'package:revo_pos/layers/presentation/revo_pos_text_field.dart';

class AddVariantPage extends StatefulWidget {
  final List<Attribute>? listAttr;
  final bool isEdit;
  final VariationData? variant;
  final int? index;
  const AddVariantPage(
      {Key? key, this.listAttr, this.isEdit = false, this.variant, this.index})
      : super(key: key);

  @override
  State<AddVariantPage> createState() => _AddVariantPageState();
}

class _AddVariantPageState extends State<AddVariantPage> {
  TextEditingController productStock = new TextEditingController();
  TextEditingController weight = new TextEditingController();
  TextEditingController length = new TextEditingController();
  TextEditingController width = new TextEditingController();
  TextEditingController height = new TextEditingController();
  TextEditingController regPrice = new TextEditingController();
  TextEditingController salePrice = new TextEditingController();
  TextEditingController skuController = new TextEditingController();

  List<Attribute> listAttribute = [];
  List<VariationData> listvariant = [];
  bool isManageStock = false;
  String? stockStatus;

  AttributeNotifier? attributeNotifier;

  @override
  void initState() {
    super.initState();
    attributeNotifier = Provider.of<AttributeNotifier>(context, listen: false);
    listAttribute = widget.listAttr!;
    if (!widget.isEdit) {
      for (int i = 0; i < listAttribute.length; i++) {
        listAttribute[i].selectedTerm = listAttribute[i].term![0];
      }
    }

    if (widget.isEdit) {
      weight.text = widget.variant!.weight!;
      length.text = widget.variant!.length!;
      printLog("variant stock : ${widget.variant!.varManageStock}");
      if (widget.variant!.varManageStock == "yes") {
        isManageStock = true;
      }
      width.text = widget.variant!.width!;
      height.text = widget.variant!.height!;
      regPrice.text = widget.variant!.varRegularPrice!;
      salePrice.text = widget.variant!.varSalePrice!;
      stockStatus = widget.variant!.varStockStatus ?? "instock";
      if (isManageStock) {
        productStock.text = widget.variant!.varStock!;
      }
      for (int i = 0; i < listAttribute.length; i++) {
        for (int j = 0; j < listAttribute[i].term!.length; j++) {
          for (int k = 0; k < widget.variant!.listVariationAttr!.length; k++) {
            if (listAttribute[i].term![j].name ==
                    widget.variant!.listVariationAttr![k].option.toString() &&
                listAttribute[i].term![j].taxonomy ==
                    widget.variant!.listVariationAttr![k].attributeName) {
              printLog(
                  "masuk sini ${listAttribute[i].term![j].name} - ${widget.variant!.listVariationAttr![k].option.toString()}");
              listAttribute[i].selectedTerm = listAttribute[i].term![j];
            }
          }
        }
        print(json.encode(listAttribute[i].selectedTerm));
      }
      if (widget.variant!.varManageStock! == 'no') {
        isManageStock = false;
      } else if (widget.variant!.varManageStock! == 'yes' &&
          stockStatus == "instock") {
        isManageStock = true;
      }
    }
  }

  updateVariation(int index) {
    if (isManageStock && productStock.text.isEmpty) {
      return ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Stock quantity shouldn't empty")));
    }
    List<VariationAttributesModel> listVariantAttr = [];
    for (int i = 0; i < listAttribute.length; i++) {
      VariationAttributesModel varModel = VariationAttributesModel(
          attributeName: listAttribute[i].term![0].taxonomy,
          id: int.parse(listAttribute[i].id!),
          option: listAttribute[i].selectedTerm!.name! == "All"
              ? ""
              : listAttribute[i].selectedTerm!.name!);
      listVariantAttr.add(varModel);
    }
    print(regPrice.text);
    var _tempRegPrice = regPrice.text.replaceAll(new RegExp(r'[^0-9.]'), '');
    var _tempSalePrice = salePrice.text.replaceAll(new RegExp(r'[^0-9.]'), '');
    print(_tempRegPrice);
    //Check Form
    if (_tempRegPrice != "0.00" && regPrice.text.isNotEmpty) {
      attributeNotifier!.updateVariant(
          index: index,
          height: height.text,
          length: length.text,
          id: widget.variant!.variableProductId,
          regPrice: _tempRegPrice.toString(),
          salePrice: _tempSalePrice.toString(),
          stockStatus: stockStatus == null ? "instock" : stockStatus!,
          manageStock: isManageStock ? "yes" : "no",
          weight: weight.text,
          width: width.text,
          stock: productStock.text,
          listVariantAttr: listVariantAttr);
      Navigator.pop(context);
    } else {
      return ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Regular Price shouldn't empty")));
    }
  }

  submitVariation() {
    if (isManageStock && productStock.text.isEmpty) {
      return ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Stock quantity shouldn't empty")));
    }
    List<VariationAttributesModel> listVariantAttr = [];
    for (int i = 0; i < listAttribute.length; i++) {
      VariationAttributesModel varModel = VariationAttributesModel(
          attributeName: listAttribute[i].term![0].taxonomy,
          id: int.parse(listAttribute[i].id!),
          option: listAttribute[i].selectedTerm!.name == "All"
              ? ""
              : listAttribute[i].selectedTerm!.name);
      listVariantAttr.add(varModel);
    }

    if (regPrice.text.isNotEmpty) {
      attributeNotifier!.submitVariant(
          height: height.text,
          length: length.text,
          regPrice: regPrice.text,
          salePrice: salePrice.text,
          stockStatus: stockStatus == null ? "instock" : stockStatus!,
          manageStock: isManageStock ? "yes" : "no",
          weight: weight.text,
          width: width.text,
          stock: productStock.text,
          variableSku: skuController.text,
          listVariantAttr: listVariantAttr);

      Navigator.pop(context, true);
    } else {
      return ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Regular Price shouldn't empty")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final stockStatuses =
        context.select((FormProductNotifier n) => n.listStockStatus);
    final selectedStockStatus =
        context.select((FormProductNotifier n) => n.selectedStockStatus);

    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
          child: Container(
        margin: EdgeInsets.only(left: 15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildDropDownAttr(),
          Divider(),
          _buildCheckBoxStock(),
          const SizedBox(
            height: 12,
          ),
          Visibility(
              visible: !isManageStock,
              child: Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          itemCount: stockStatuses.length,
                          itemBuilder: (_, index) {
                            return RevoPosChip(
                              text: stockStatuses[index],
                              isEnabled: true,
                              isSelected: index == selectedStockStatus,
                              onTap: () {
                                print("index : ${index}");
                                context
                                    .read<FormProductNotifier>()
                                    .setSelectedStockStatus(index);
                                if (stockStatuses[index] == "In Stock") {
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
                      const SizedBox(height: 4),
                    ]),
              )),
          Visibility(
            visible: isManageStock,
            child: _buildTextField(
              withTopPadding: true,
              text: "Total stock",
              hintText: "",
              controller: productStock,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              maxLines: 1,
            ),
          ),
          Divider(),
          _buildTextField(
              withTopPadding: false,
              text: "Weight (kg)",
              controller: weight,
              keyboardType: TextInputType.number,
              hintText: "kg"),
          const SizedBox(height: 12),
          Text(
            "Dimension (cm)",
            style: Theme.of(context).textTheme.headline6,
          ),
          _buildTextFieldDimension(),
          Divider(),
          _buildTextField(
            withTopPadding: true,
            text: "SKU",
            controller: skuController,
          ),
          _buildTextField(
              withTopPadding: true,
              text: "Regular price",
              hintText: "",
              controller: regPrice,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              maxLines: 1,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Regular price must not be empty";
                }
                return null;
              }),
          _buildTextField(
              withTopPadding: true,
              text: "Sale price",
              hintText: "",
              controller: salePrice,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              maxLines: 1,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Sale price must not be empty";
                }
                return null;
              }),
          Divider(),
          const SizedBox(height: 20),
          Container(
            margin: EdgeInsets.only(right: 15),
            child: SizedBox(
              width: double.infinity,
              child: RevoPosButton(
                  text: "Submit",
                  onPressed: () async {
                    if (widget.isEdit) {
                      updateVariation(widget.index!);
                    } else {
                      submitVariation();
                    }
                  }),
            ),
          ),
          const SizedBox(height: 20),
        ]),
      )),
    );
  }

  _buildAppBar() => AppBar(
        backgroundColor: colorWhite,
        iconTheme: IconThemeData(color: colorBlack),
        title: Text("Add Variation"),
      );

  _buildDropDownAttr() => ListView.builder(
      shrinkWrap: true,
      itemCount: listAttribute.length,
      itemBuilder: ((context, index) {
        return Container(
          margin: EdgeInsets.only(top: 20, right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                listAttribute[index].label!,
                style: Theme.of(context).textTheme.headline6,
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                width: double.infinity,
                padding: EdgeInsets.only(left: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: colorWhite,
                  border: Border.all(
                    color: colorDisabled,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    isExpanded: true,
                    onChanged: (value) {
                      setState(() {
                        value = value;
                      });
                      for (int i = 0;
                          i < listAttribute[index].term!.length;
                          i++) {
                        if (value == listAttribute[index].term![i].slug) {
                          setState(() {
                            listAttribute[index].selectedTerm =
                                listAttribute[index].term![i];
                          });
                        }
                      }
                    },
                    dropdownColor: colorWhite,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      size: 26,
                    ),
                    value: listAttribute[index].selectedTerm!.slug,
                    items: <DropdownMenuItem<String>>[
                      for (int i = 0;
                          i < listAttribute[index].term!.length;
                          i++)
                        if (listAttribute[index].term![i].selected)
                          DropdownMenuItem(
                            child: Text(
                                listAttribute[index].term![i].name.toString()),
                            value: listAttribute[index].term![i].slug,
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }));

  _buildCheckBoxStock() => Container(
        margin: EdgeInsets.only(top: 10),
        child: Row(children: [
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
          SizedBox(
            width: 8,
          ),
          Text(
            "Manage Stock",
            style: Theme.of(context).textTheme.headline6,
          )
        ]),
      );

  _buildTextFieldDimension() => Container(
        margin: EdgeInsets.only(right: 15, top: 4),
        child: Row(
          children: [
            Expanded(
              child: RevoPosTextField(
                  controller: length,
                  hintText: "Length",
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {},
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Length must not be empty";
                    }
                    return null;
                  }),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RevoPosTextField(
                  controller: width,
                  hintText: "Width",
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {},
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Width must not be empty";
                    }
                    return null;
                  }),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RevoPosTextField(
                  controller: height,
                  hintText: "Height",
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {},
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Height must not be empty";
                    }
                    return null;
                  }),
            ),
          ],
        ),
      );

  _buildTextField(
      {required bool withTopPadding,
      required String text,
      required TextEditingController controller,
      String? hintText,
      int? maxLines,
      TextInputType? keyboardType,
      List<TextInputFormatter>? inputFormatters,
      String? Function(String?)? validator}) {
    return Container(
      margin: EdgeInsets.only(right: 15),
      child: Column(
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
      ),
    );
  }
}
