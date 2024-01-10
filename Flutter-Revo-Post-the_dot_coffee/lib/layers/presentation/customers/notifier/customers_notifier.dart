import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/layers/data/models/countries_model.dart';
import 'package:revo_pos/layers/data/models/customer_model.dart';
import 'package:revo_pos/layers/domain/entities/customer.dart';
import 'package:revo_pos/layers/domain/usecases/customer/add_customer_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/customer/delete_customer_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/customer/get_customer_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/customer/update_customer_usecase.dart';

class CustomersNotifier with ChangeNotifier {
  final GetCustomersUsecase _getCustomersUsecase;
  final AddCustomersUsecase _addCustomersUsecase;
  final UpdateCustomersUsecase _updateCustomersUsecase;
  final DeleteCustomersUsecase _deleteCustomersUsecase;

  CustomersNotifier({
    required GetCustomersUsecase getCustomersUsecase,
    required AddCustomersUsecase addCustomersUsecase,
    required UpdateCustomersUsecase updateCustomersUsecase,
    required DeleteCustomersUsecase deleteCustomersUsecase,
  })  : _getCustomersUsecase = getCustomersUsecase,
        _addCustomersUsecase = addCustomersUsecase,
        _updateCustomersUsecase = updateCustomersUsecase,
        _deleteCustomersUsecase = deleteCustomersUsecase;

  List<Customer>? customers = [];
  List<Customer>? tempList;

  bool isLoading = false;
  int customerPage = 1;
  int customerLimit = 10;
  CustomerModel? customer;

  Future<void> getCustomers({required String search, int? price}) async {
    isLoading = true;
    notifyListeners();

    final result = await _getCustomersUsecase(CustomerParams(
        search: search,
        page: customerPage,
        perPage: customerLimit,
        price: price ?? 0));

    result.fold((l) {
      customers = [];
    }, (r) {
      tempList = [];
      tempList!.addAll(r);
      List<Customer> list = List.from(customers!);
      list.addAll(tempList!);
      customers = list;
      if (tempList!.length % 10 == 0) {
        customerPage++;
      }
    });
    isLoading = false;
    notifyListeners();
  }

  Future<void> addCustomer(
      {required CustomerModel customer,
      required Function(Map<String, dynamic>, bool) onSubmit}) async {
    isLoading = true;
    notifyListeners();

    final result =
        await _addCustomersUsecase(AddCustomerParams(customer: customer));

    result.fold((l) {
      Map<String, dynamic> data = {"message": 'Error when added customer'};
      isLoading = false;
      printLog('Failed');
      onSubmit(data, isLoading);
    }, (r) {
      isLoading = false;
      onSubmit(r!, isLoading);
      printLog('Success');
    });

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateCustomer(
      {required CustomerModel customer,
      required int id,
      required Function(Map<String, dynamic>, bool) onSubmit}) async {
    isLoading = true;
    notifyListeners();

    final result = await _updateCustomersUsecase(
        UpdateCustomerParams(customer: customer, id: id));

    result.fold((l) {
      Map<String, dynamic> data = {"message": 'Error when updating customer'};
      isLoading = false;
      printLog('Failed');
      onSubmit(data, isLoading);
    }, (r) {
      isLoading = false;
      onSubmit(r!, isLoading);
      printLog('Success');
    });

    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteCustomer(
      {required int id,
      required Function(Map<String, dynamic>, bool) onSubmit}) async {
    isLoading = true;
    notifyListeners();

    final result = await _deleteCustomersUsecase(DeleteCustomerParams(id: id));

    result.fold((l) {
      Map<String, dynamic> data = {"message": 'Error when deleting customer'};
      isLoading = false;
      printLog('Failed');
      onSubmit(data, isLoading);
    }, (r) {
      isLoading = false;
      onSubmit(r!, isLoading);
      printLog('Success');
    });

    isLoading = false;
    notifyListeners();
  }

  bool loading = false;
  List<CountriesModel>? countries;
  States? selectedStates;
  CountriesModel? selectedCountries;
  String? countryName = "";
  String? stateName = "";
  Future<bool> fetchCountries() async {
    loading = true;
    bool _isSuccess = false;
    notifyListeners();
    try {
      var response =
          await baseAPI!.getAsync('data/countries', printedLog: true);

      countries = [];
      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);

        for (Map item in responseJson) {
          countries!.add(CountriesModel.fromJson(item));
        }
        for (int i = 0; i < countries!.length; i++) {
          if (countries![i].code == "ID") {
            selectedCountries = countries![i];
          }
        }
        for (int j = 0; j < selectedCountries!.states!.length; j++) {
          if (selectedCountries!.states![j].code == "JI") {
            selectedStates = selectedCountries!.states![j];
          }
        }
        loading = false;
        _isSuccess = true;
        notifyListeners();
      } else {
        loading = false;
        _isSuccess = false;
        notifyListeners();
      }
    } catch (e) {
      loading = false;
      _isSuccess = false;
      notifyListeners();
    }
    return _isSuccess;
  }

  setCountries(value) {
    if (value != null) {
      print(value);
      countries!.forEach((element) {
        if (element.code == value) {
          print("Found");
          countryName = element.name;
          selectedCountries = element;
          notifyListeners();
          if (selectedCountries!.states!.isNotEmpty) {
            printLog("states : ${selectedCountries!.states!.first}");
            for (int j = 0; j < selectedCountries!.states!.length; j++) {
              if (selectedCountries!.code == "ID" &&
                  selectedCountries!.states![j].code == "JI") {
                selectedStates = selectedCountries!.states![j];
                break;
              } else {
                selectedStates = selectedCountries!.states!.first;
              }
            }
          } else {
            selectedStates = null;
          }
        }
      });
    }
    notifyListeners();
  }

  setStates(value) {
    if (selectedCountries!.states!.isNotEmpty) {
      List<States> _states = selectedCountries!.states!;
      selectedStates = value == null ? null : _states.first;
      if (value != null) {
        print(value);
        _states.forEach((element) {
          if (element.code == value) {
            print("Found");
            stateName = element.name;
            selectedStates = element;
          }
        });
      }
    }
    notifyListeners();
  }

  resetPage() {
    customerPage = 1;
    customers = [];
    tempList = [];
    notifyListeners();
  }

  updateLimit(int value) {
    customerLimit = value;
    notifyListeners();
  }

  convertJsonToModel(
      {required String username,
      required String firstName,
      required String lastName,
      String? company,
      String? address,
      String? countries,
      String? state,
      String? city,
      required String email,
      required String phone,
      required int id,
      required Function(Map<String, dynamic>, bool) onSubmit,
      required String type}) {
    CustomerModel _customer;
    Map<String, dynamic> data = {
      "id": id,
      "email": email,
      "first_name": firstName,
      "last_name": lastName,
      if (type == 'new') "username": username,
      "billing": {
        "first_name": firstName,
        "last_name": lastName,
        "company": company,
        "address_1": address,
        "address_2": "",
        "city": city,
        "state": state,
        "postcode": "",
        "country": countries,
        "email": email,
        "phone": phone
      },
      "shipping": {
        "first_name": firstName,
        "last_name": lastName,
        "company": company,
        "address_1": address,
        "address_2": "",
        "city": city,
        "state": state,
        "postcode": "",
        "country": countries
      }
    };
    _customer = CustomerModel.fromJson(data);
    printLog(json.encode(_customer), name: "data customer");
    customer = _customer;
    if (type == 'edit') {
      updateCustomer(customer: customer!, onSubmit: onSubmit, id: id);
    } else {
      addCustomer(customer: customer!, onSubmit: onSubmit);
    }
    notifyListeners();
  }
}
