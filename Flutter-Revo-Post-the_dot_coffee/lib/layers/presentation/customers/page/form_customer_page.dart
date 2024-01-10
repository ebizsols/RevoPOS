import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/layers/data/models/countries_model.dart';
import 'package:revo_pos/layers/presentation/customers/notifier/customers_notifier.dart';
import 'package:revo_pos/layers/presentation/revo_pos_button.dart';
import 'package:revo_pos/layers/domain/entities/customer.dart';

import '../../revo_pos_loading.dart';
import '../../revo_pos_text_field.dart';

class FormCustomerPage extends StatefulWidget {
  final Customer? customer;

  const FormCustomerPage({Key? key, this.customer}) : super(key: key);

  @override
  _FormCustomerPageState createState() => _FormCustomerPageState();
}

class _FormCustomerPageState extends State<FormCustomerPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController companyController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  CustomersNotifier? customersNotifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      customersNotifier =
          Provider.of<CustomersNotifier>(context, listen: false);
      context.read<CustomersNotifier>().fetchCountries().then((value) {
        if (value) {
          if (widget.customer != null) {
            printLog(widget.customer!.toString());
            customersNotifier!.setCountries(widget.customer!.billing!.country);
            customersNotifier!.setStates(widget.customer!.billing!.state);
            printLog(
                json.encode(
                    Provider.of<CustomersNotifier>(context, listen: false)
                        .selectedStates),
                name: "Selected state");
            firstNameController.text = widget.customer!.firstName!;
            lastNameController.text = widget.customer!.lastName!;
            emailController.text = widget.customer!.email!;
            phoneController.text = widget.customer!.billing!.phone!;
            usernameController.text = widget.customer!.username!;
            addressController.text = widget.customer!.billing!.address1!;
            cityController.text = widget.customer!.billing!.city!;
            stateController.text = widget.customer!.billing!.state!;
            companyController.text = widget.customer!.billing!.company!;
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Form(
              key: formKey,
              child: Consumer<CustomersNotifier>(
                builder: (context, value, child) {
                  return value.loading
                      ? const Center(child: RevoPosLoading())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                                withTopPadding: false,
                                controller: usernameController,
                                text: "Username",
                                hintText: "Username",
                                maxLines: 1,
                                isNeeded: true,
                                enable: widget.customer == null),
                            _buildTextField(
                                withTopPadding: true,
                                controller: firstNameController,
                                text: "First name",
                                hintText: "First name",
                                maxLines: 1,
                                isNeeded: true),
                            _buildTextField(
                                withTopPadding: true,
                                text: "Last name",
                                hintText: "Last name",
                                controller: lastNameController,
                                maxLines: 1,
                                isNeeded: true),
                            _buildTextField(
                                withTopPadding: true,
                                text: "Company name",
                                hintText: "Company name",
                                controller: companyController,
                                maxLines: 1,
                                isNeeded: false),
                            _buildDropdown("Countries", value, 'countries'),
                            _buildDropdown("State/Province", value, 'states'),
                            // _buildTextField(
                            //     withTopPadding: true,
                            //     text: "State/Province",
                            //     hintText: "State/Province",
                            //     controller: stateController,
                            //     maxLines: 1,
                            //     isNeeded: false),
                            _buildTextField(
                                withTopPadding: true,
                                text: "Town/City",
                                hintText: "Town/City",
                                controller: cityController,
                                maxLines: 1,
                                isNeeded: false),
                            _buildTextField(
                                withTopPadding: true,
                                text: "Address",
                                hintText: "Address",
                                controller: addressController,
                                maxLines: 1,
                                isNeeded: false),
                            _buildTextField(
                                withTopPadding: true,
                                text: "Phone number",
                                hintText: "Phone number",
                                controller: phoneController,
                                keyboardType: TextInputType.number,
                                maxLines: 1,
                                isNeeded: true,
                                enable: true),
                            Container(
                              margin: const EdgeInsets.only(top: 5, left: 5),
                              child: Text(
                                "Example : 628123456789",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(color: colorDanger, fontSize: 12),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                Text(
                                  "Email",
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                const SizedBox(height: 4),
                                RevoPosTextField(
                                  controller: emailController,
                                  hintText: "Email",
                                  maxLines: 1,
                                  enabled: true,
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (value) {
                                    // emailController.text =
                                    //     phoneController.text + "@${url.substring(8)}";
                                  },
                                  validator: (value) {
                                    if (value != null && value.isEmpty) {
                                      return "Email cannot be empty";
                                    } else if (value!.contains(" ") ||
                                        !value.contains('@') ||
                                        !value.contains('.')) {
                                      return "Please enter a valid email";
                                    }
                                    return null;
                                  },
                                )
                              ],
                            ),
                            // _buildTextField(
                            //     withTopPadding: true,
                            //     text: "Email",
                            //     hintText: "Email",
                            //     controller: emailController,
                            //     keyboardType: TextInputType.emailAddress,
                            //     maxLines: 1,
                            //     isNeeded: true,
                            //     enable: true),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: RevoPosButton(
                                  text: "Submit",
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      setState(() {});
                                      showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (context) {
                                            return const RevoPosLoading();
                                          });
                                      if (widget.customer != null) {
                                        context
                                            .read<CustomersNotifier>()
                                            .convertJsonToModel(
                                                type: 'edit',
                                                username:
                                                    usernameController.text,
                                                id: widget.customer!.id!,
                                                email: emailController.text,
                                                firstName:
                                                    firstNameController.text,
                                                lastName:
                                                    lastNameController.text,
                                                company: companyController.text,
                                                address: addressController.text,
                                                state: customersNotifier!
                                                            .selectedStates ==
                                                        null
                                                    ? ""
                                                    : customersNotifier!
                                                        .selectedStates!.code,
                                                countries: Provider.of<
                                                            CustomersNotifier>(
                                                        context,
                                                        listen: false)
                                                    .selectedCountries!
                                                    .code,
                                                city: cityController.text,
                                                phone: phoneController.text,
                                                onSubmit: (result, isLoading) {
                                                  printLog(
                                                      isLoading.toString());
                                                  if (!isLoading) {
                                                    Navigator.pop(context);
                                                    if (result['id'] != null) {
                                                      Navigator.pop(
                                                          context, 200);
                                                      Navigator.pop(
                                                          context, 200);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              const SnackBar(
                                                        content: Text(
                                                            "Customer updated"),
                                                        backgroundColor:
                                                            Colors.green,
                                                      ));
                                                    } else if (result[
                                                            'message'] !=
                                                        null) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              SnackBar(
                                                        content: Text(
                                                            result['message']),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ));
                                                    }
                                                  }
                                                });
                                      } else {
                                        context
                                            .read<CustomersNotifier>()
                                            .convertJsonToModel(
                                                type: 'new',
                                                id: 0,
                                                username:
                                                    usernameController.text,
                                                email: emailController.text,
                                                firstName:
                                                    firstNameController.text,
                                                lastName:
                                                    lastNameController.text,
                                                company: companyController.text,
                                                address: addressController.text,
                                                state: customersNotifier!
                                                            .selectedStates ==
                                                        null
                                                    ? ""
                                                    : customersNotifier!
                                                        .selectedStates!.code,
                                                countries: Provider.of<
                                                            CustomersNotifier>(
                                                        context,
                                                        listen: false)
                                                    .selectedCountries!
                                                    .code,
                                                city: cityController.text,
                                                phone: phoneController.text,
                                                onSubmit: (result, isLoading) {
                                                  printLog(
                                                      isLoading.toString());
                                                  if (!isLoading) {
                                                    Navigator.pop(context);
                                                    if (result['id'] != null) {
                                                      Navigator.pop(
                                                          context, 200);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              const SnackBar(
                                                        content: Text(
                                                            "Customer added"),
                                                        backgroundColor:
                                                            Colors.green,
                                                      ));
                                                    } else if (result[
                                                            'message'] !=
                                                        null) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              SnackBar(
                                                        content: Text(
                                                            result['message']),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ));
                                                    }
                                                  }
                                                });
                                      }
                                    }
                                  }),
                            ),
                          ],
                        );
                },
              ),
            )),
      ),
    );
  }

  _buildAppBar() {
    return AppBar(
      title: Text("${widget.customer == null ? "New" : "Edit"} Customer"),
    );
  }

  _buildTextField(
      {required bool withTopPadding,
      required String text,
      String? hintText,
      int? maxLines,
      TextInputType? keyboardType,
      required TextEditingController controller,
      bool? isNeeded,
      bool? enable = true}) {
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
          enabled: enable,
          keyboardType: keyboardType,
          onChanged: (value) {
            emailController.text =
                phoneController.text + "@${url.substring(8)}";
          },
          validator: (value) {
            if (isNeeded!) {
              if (value != null && value.isEmpty) {
                return "$text cannot be empty";
              }
            }
            return null;
          },
        )
      ],
    );
  }

  String? country;

  _buildDropdown(String? label, CustomersNotifier? value, String? type) {
    var _value;
    if (value != null) {
      if (type == 'countries' && value.selectedCountries != null) {
        _value = value.selectedCountries!.code;
      } else if (type == 'states' && value.selectedStates != null) {
        _value = value.selectedStates!.code;
      }
    }
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            "$label",
            style: Theme.of(context).textTheme.headline6,
          ),
          Container(
            child: DropdownButton(
              isExpanded: true,
              borderRadius: BorderRadius.circular(10),
              underline: Container(
                height: 1.0,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFBDBDBD),
                      width: 1.0,
                    ),
                  ),
                ),
              ),
              hint: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text("Choose $label")),
              value: _value,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: type == 'countries'
                  ? value!.countries!.map((CountriesModel items) {
                      return DropdownMenuItem(
                          value: items.code,
                          child: Container(
                            child: Text(
                              items.name!,
                              style: TextStyle(
                                  color: _value != items.code
                                      ? Colors.black45
                                      : null),
                            ),
                          ));
                    }).toList()
                  : value!.selectedCountries!.states!.map((States items) {
                      return DropdownMenuItem(
                          value: items.code,
                          child: Container(
                            child: Text(
                              items.name!,
                              style: TextStyle(
                                  color: _value != items.code
                                      ? Colors.black45
                                      : null),
                            ),
                          ));
                    }).toList(),
              onChanged: (val) {
                if (type == 'countries') {
                  context
                      .read<CustomersNotifier>()
                      .setCountries(val.toString());
                  setState(() {
                    country = val.toString();
                    stateController.clear();
                  });
                } else if (type == 'states') {
                  context.read<CustomersNotifier>().setStates(val.toString());

                  setState(() {
                    stateController.text = val.toString();
                  });
                }
              },
            ),
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
