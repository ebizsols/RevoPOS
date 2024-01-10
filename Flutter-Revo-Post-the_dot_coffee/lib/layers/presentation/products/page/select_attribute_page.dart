import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/layers/data/models/attribute_model.dart';
import 'package:revo_pos/layers/presentation/products/notifier/attribute_notifier.dart';
import 'package:revo_pos/layers/presentation/revo_pos_loading.dart';

class SelectAttributePage extends StatefulWidget {
  const SelectAttributePage({Key? key}) : super(key: key);

  @override
  State<SelectAttributePage> createState() => _SelectAttributePageState();
}

class _SelectAttributePageState extends State<SelectAttributePage> {
  bool value = false;
  bool shouldPop = false;
  AttributeNotifier? attributeNotifier;

  void initState() {
    super.initState();
    attributeNotifier = Provider.of<AttributeNotifier>(context, listen: false);
  }

  Future<bool> checkIsValid() async {
    for (int i = 0; i < attributeNotifier!.listAttribute.length; i++) {
      if (attributeNotifier!.listAttribute[i].selected) {
        for (int j = 0;
            j < attributeNotifier!.listAttribute[i].term!.length;
            j++) {
          if (attributeNotifier!.listAttribute[i].term![j].selected) {
            setState(() {
              shouldPop = true;
            });
            attributeNotifier!.listAttribute[i].selectedTerm =
                attributeNotifier!.listAttribute[i].term!.first;
          }
        }
      }
    }
    if (!shouldPop) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("please select attribute first"),
        backgroundColor: Colors.black,
      ));
    }
    return shouldPop;
  }

  @override
  Widget build(BuildContext context) {
    final attributes = context.select((AttributeNotifier n) => n.listAttribute);
    return WillPopScope(
      onWillPop: () async {
        checkIsValid().then((value) {
          Navigator.pop(context, value);
        });
        return true;
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: attributeNotifier!.isLoadingAttribute
            ? RevoPosLoading()
            : SingleChildScrollView(
                physics: ScrollPhysics(),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildCheckBox(context, attributes),
                    ]),
              ),
      ),
    );
  }

  _buildAppBar() => AppBar(
        backgroundColor: colorWhite,
        iconTheme: IconThemeData(color: colorBlack),
        title: const Text("Select Attribute"),
        leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              checkIsValid().then((value) {
                if (value) {
                  Navigator.pop(context, true);
                }
              });
            }),
      );

  _buildCheckBox(context, List<Attribute> i) => Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemCount: i.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Checkbox(
                              value: i[index].selected,
                              onChanged: (val) {
                                setState(() {
                                  i[index].selected = val!;
                                });
                              }),
                          Text(
                            i[index].label.toString(),
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: i[index].selected,
                      child: Container(
                        padding: EdgeInsets.only(left: 20),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          itemCount: i[index].term!.length,
                          itemBuilder: (context, j) {
                            return i[index].term![j].name != "All"
                                ? Container(
                                    child: Row(children: [
                                      Checkbox(
                                          value: i[index].term![j].selected,
                                          onChanged: (val) {
                                            setState(() {
                                              i[index].term![j].selected = val!;
                                              i[index].selectedTerm =
                                                  i[index].term!.first;
                                            });
                                          }),
                                      Text(
                                        i[index].term![j].name.toString(),
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ]),
                                  )
                                : Container();
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );
}
