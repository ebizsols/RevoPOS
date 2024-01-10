import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:revo_pos/core/config/app_config.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/core/utils/currency_converter.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/core/utils/multicurrency_format.dart';
import 'package:revo_pos/layers/data/models/attribute_model.dart';
import 'package:revo_pos/layers/data/models/variation_data_model.dart';
import 'package:revo_pos/layers/presentation/products/notifier/attribute_notifier.dart';
import 'package:revo_pos/layers/presentation/products/page/add_variant_page.dart';
import 'package:revo_pos/layers/presentation/products/page/select_attribute_page.dart';
import 'package:revo_pos/layers/presentation/revo_pos_button.dart';
import 'package:revo_pos/layers/presentation/revo_pos_loading.dart';

class ProductVariationPage extends StatefulWidget {
  const ProductVariationPage({Key? key}) : super(key: key);

  @override
  State<ProductVariationPage> createState() => _ProductVariationPageState();
}

class _ProductVariationPageState extends State<ProductVariationPage> {
  AttributeNotifier? attributeNotifier;
  int lengthListAttribute = 0;
  List<Attribute> listAttr = [];
  List<VariationData> listVariant = [];
  bool edit = false;

  @override
  void initState() {
    super.initState();
    attributeNotifier = Provider.of<AttributeNotifier>(context, listen: false);
    lengthListAttribute = attributeNotifier!.listAttribute.length;
    inputDataToList();
  }

  void inputDataToList() {
    listAttr.clear();
    for (int i = 0; i < attributeNotifier!.listAttribute.length; i++) {
      if (attributeNotifier!.listAttribute[i].selected) {
        setState(() {
          listAttr.add(attributeNotifier!.listAttribute[i]);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        padding: EdgeInsets.all(8),
        child: Column(children: [
          Expanded(
            child: SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(children: [
                _buildAttributeButton(),
                _buildListVariation(),
                _buildButtonAddVariation(),
              ]),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: RevoPosButton(
              text: "Submit",
              onPressed: () {
                setState(() {});
                //attributeNotifier!.getProdAttribute();
                Navigator.pop(context);
              },
            ),
          ),
        ]),
      ),
    );
  }

  _buildAppBar() => AppBar(
        backgroundColor: colorWhite,
        iconTheme: IconThemeData(color: colorBlack),
        title: Text("Product Variation"),
      );

  _buildAttributeButton() => Container(
        margin: EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SelectAttributePage(),
              ),
            ).then(
              (value) {
                printLog("value attribute : $value");
                if (value) {
                  inputDataToList();
                }
              },
            );
          },
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Attribute",
                      style: Theme.of(context).textTheme.headline6),
                  SizedBox(
                    height: 8,
                  ),
                  _buildListAttribute(),
                ],
              ),
              Spacer(),
              Container(
                child: Icon(
                  Icons.arrow_right,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );

  _buildListAttribute() => Container(
        child: listAttr.length == 0
            ? Text("Please select attributes first (Min 1 attribute)",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14))
            : Container(
                width: 300,
                height: 30,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: listAttr.length,
                  itemBuilder: ((context, index) {
                    return Container(
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all()),
                      child: Text(
                        listAttr[index].label.toString(),
                        style: TextStyle(fontSize: 14),
                      ),
                    );
                  }),
                ),
              ),
      );

  _buildButtonAddVariation() => Container(
        margin: EdgeInsets.only(top: 5),
        padding: EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () {
            if (listAttr.length > 0) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddVariantPage(listAttr: listAttr),
                  ));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("please select attribute first"),
                backgroundColor: Colors.black,
              ));
            }
          },
          child: Row(
            children: [
              Icon(
                Icons.add_circle,
                color: Colors.black,
              ),
              SizedBox(
                width: 10,
              ),
              Text("Add Variation Product")
            ],
          ),
        ),
      );

  _buildListVariation() =>
      Consumer<AttributeNotifier>(builder: ((context, value, child) {
        return attributeNotifier!.listVariant.length == 0
            ? Container()
            : Container(
                child: ListView.builder(
                    itemCount: attributeNotifier!.listVariant.length,
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemBuilder: (context, index) {
                      return attributeNotifier!
                                  .listVariant[index].deleteProductVariant !=
                              null
                          ? Container()
                          : Container(
                              margin: const EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        offset: Offset(-1, 0),
                                        color: Colors.grey.withOpacity(0.40),
                                        blurRadius: 3),
                                  ],
                                  border: Border.all(
                                      color: Colors.grey, width: 0.3)),
                              child: ExpansionTile(
                                title:
                                    Text("Variation ${(index + 1).toString()}"),
                                collapsedIconColor: Colors.black,
                                collapsedTextColor: Colors.black,
                                textColor: Colors.black,
                                iconColor: Colors.black,
                                subtitle: Container(
                                  width: 100,
                                  height: 50,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemCount: attributeNotifier!
                                          .listVariant[index]
                                          .listVariationAttr!
                                          .length,
                                      itemBuilder: ((context, j) {
                                        return Row(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 3),
                                              padding: EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    color: Colors.grey.shade300,
                                                    width: 0.3),
                                              ),
                                              child: Text(
                                                  attributeNotifier!
                                                              .listVariant[
                                                                  index]
                                                              .listVariationAttr![
                                                                  j]
                                                              .option! ==
                                                          ""
                                                      ? "All"
                                                      : attributeNotifier!
                                                          .listVariant[index]
                                                          .listVariationAttr![j]
                                                          .option!,
                                                  style:
                                                      TextStyle(fontSize: 12)),
                                            ),
                                          ],
                                        );
                                      })),
                                ),
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text("Regular Price",
                                                style: TextStyle(
                                                    color: Colors.black38,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Spacer(),
                                            Text(
                                                '${MultiCurrency.convert(double.parse(attributeNotifier!.listVariant[index].varRegularPrice!), context)}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))
                                          ],
                                        ),
                                        attributeNotifier!.listVariant[index]
                                                        .varSalePrice !=
                                                    "0.00" &&
                                                attributeNotifier!
                                                        .listVariant[index]
                                                        .varSalePrice !=
                                                    "0" &&
                                                attributeNotifier!
                                                        .listVariant[index]
                                                        .varSalePrice !=
                                                    ""
                                            ? Row(
                                                children: [
                                                  Text("Sale Price",
                                                      style: TextStyle(
                                                          color: Colors.black38,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Spacer(),
                                                  Text(
                                                      '${MultiCurrency.convert(double.parse(value.listVariant[index].varSalePrice!), context)}',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold))
                                                ],
                                              )
                                            : Container(),
                                        Row(
                                          children: [
                                            Text("Stock Status",
                                                style: TextStyle(
                                                    color: Colors.black38,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Spacer(),
                                            Text(
                                                '${attributeNotifier!.listVariant[index].varStockStatus}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text("Weight",
                                                style: TextStyle(
                                                    color: Colors.black38,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Spacer(),
                                            Text(
                                                '${attributeNotifier!.listVariant[index].weight} kg',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Dimension",
                                                style: TextStyle(
                                                    color: Colors.black38,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Spacer(),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  'Width ${attributeNotifier!.listVariant[index].width} cm',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  softWrap: true,
                                                ),
                                                Text(
                                                  'Length ${attributeNotifier!.listVariant[index].length} cm',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  'Height ${attributeNotifier!.listVariant[index].height} cm',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                child: IconButton(
                                                  icon: const Icon(Icons.edit),
                                                  onPressed: () {
                                                    setState(() {
                                                      edit = true;
                                                    });
                                                    for (int i = 0;
                                                        i < listAttr.length;
                                                        i++) {
                                                      for (int j = 0;
                                                          j <
                                                              value
                                                                  .listVariant[
                                                                      index]
                                                                  .listVariationAttr!
                                                                  .length;
                                                          j++) {
                                                        for (int k = 0;
                                                            k <
                                                                listAttr[i]
                                                                    .term!
                                                                    .length;
                                                            k++) {
                                                          if (value
                                                                  .listVariant[
                                                                      index]
                                                                  .listVariationAttr![
                                                                      j]
                                                                  .option ==
                                                              listAttr[i]
                                                                  .term![k]
                                                                  .name) {
                                                            printLog("name :");
                                                            value
                                                                    .listAttribute[
                                                                        i]
                                                                    .selectedTerm =
                                                                value
                                                                    .listAttribute[
                                                                        i]
                                                                    .term![k];
                                                            printLog(
                                                                "selectedterm : ${json.encode(value.listAttribute[i].term![j])}");
                                                          }
                                                        }
                                                      }
                                                    }
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                AddVariantPage(
                                                                  listAttr:
                                                                      listAttr,
                                                                  isEdit: edit,
                                                                  variant: attributeNotifier!
                                                                          .listVariant[
                                                                      index],
                                                                  index: index,
                                                                )));
                                                  },
                                                ),
                                              ),
                                              Container(
                                                child: IconButton(
                                                  icon:
                                                      const Icon(Icons.delete),
                                                  onPressed: () {
                                                    print("delete");
                                                    attributeNotifier!
                                                        .deleteVariant(index);
                                                  },
                                                ),
                                              ),
                                            ])
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                    }),
              );
      }));
}
