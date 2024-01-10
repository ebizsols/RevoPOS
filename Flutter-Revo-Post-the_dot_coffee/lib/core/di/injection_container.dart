import 'package:get_it/get_it.dart';
import 'package:revo_pos/layers/data/repositories/auth_repository_impl.dart';
import 'package:revo_pos/layers/data/repositories/cart_repository_impl.dart';
import 'package:revo_pos/layers/data/repositories/category_repository_impl.dart';
import 'package:revo_pos/layers/data/repositories/chat_repository_impl.dart';
import 'package:revo_pos/layers/data/repositories/coupon_repository_impl.dart';
import 'package:revo_pos/layers/data/repositories/customer_repository_impl.dart';
import 'package:revo_pos/layers/data/repositories/order_repository_impl.dart';
import 'package:revo_pos/layers/data/repositories/product_repository_impl.dart';
import 'package:revo_pos/layers/data/repositories/report_repository_impl.dart';
import 'package:revo_pos/layers/data/repositories/setting_repository_impl.dart';
import 'package:revo_pos/layers/data/repositories/store_repository_impl.dart';
import 'package:revo_pos/layers/data/sources/local/cart_local_data_source.dart';
import 'package:revo_pos/layers/data/sources/local/category_local_data_source.dart';
import 'package:revo_pos/layers/data/sources/local/product_local_data_source.dart';
import 'package:revo_pos/layers/data/sources/remote/auth_remote_data_source.dart';
import 'package:revo_pos/layers/data/sources/remote/category_remote_data_source.dart';
import 'package:revo_pos/layers/data/sources/remote/chat_remote_data_source.dart';
import 'package:revo_pos/layers/data/sources/remote/coupon_remote_data_source.dart';
import 'package:revo_pos/layers/data/sources/remote/customer_remote_data_source.dart';
import 'package:revo_pos/layers/data/sources/remote/order_remote_data_source.dart';
import 'package:revo_pos/layers/data/sources/remote/product_remote_data_source.dart';
import 'package:revo_pos/layers/data/sources/remote/reports_remote_data_source.dart';
import 'package:revo_pos/layers/data/sources/remote/setting_remote_data_source.dart';
import 'package:revo_pos/layers/data/sources/remote/store_remote_data_source.dart';
import 'package:revo_pos/layers/domain/repositories/auth_repository.dart';
import 'package:revo_pos/layers/domain/repositories/cart_repository.dart';
import 'package:revo_pos/layers/domain/repositories/category_repository.dart';
import 'package:revo_pos/layers/domain/repositories/chat_repository.dart';
import 'package:revo_pos/layers/domain/repositories/coupon_repository.dart';
import 'package:revo_pos/layers/domain/repositories/customer_repository.dart';
import 'package:revo_pos/layers/domain/repositories/order_repository.dart';
import 'package:revo_pos/layers/domain/repositories/product_repository.dart';
import 'package:revo_pos/layers/domain/repositories/report_repository.dart';
import 'package:revo_pos/layers/domain/repositories/setting_repository.dart';
import 'package:revo_pos/layers/domain/repositories/store_repository.dart';
import 'package:revo_pos/layers/domain/usecases/auth/check_validate_cookie_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/auth/get_settings_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/auth/login_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/chat/get_chat_lists_detail_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/chat/get_chat_lists_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/chat/send_chat_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/checkout/add_to_cart_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/checkout/decrease_qty_product_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/checkout/get_cart_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/checkout/increase_qty_product_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/checkout/remove_cart_product_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/coupon/apply_coupon_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/coupon/get_coupon_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/customer/add_customer_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/customer/delete_customer_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/customer/get_customer_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/customer/update_customer_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/order/check_price_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/order/create_order_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/order/get_order_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/order/get_payment_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/order/get_shipping_method_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/order/place_order_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/order/print_inv_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/order/update_status_order_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/product/chek_variation_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/product/delete_product_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/product/get_attribute_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/product/insert_image_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/product/insert_product_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/product/scan_product_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/reports/get_report_orders_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/reports/get_report_stock_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/reports/update_report_stock_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/setting/user_settings_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/store/add_store_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/category/get_categories_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/product/get_products_usecase.dart';
import 'package:revo_pos/layers/domain/usecases/store/get_stores_usecase.dart';
import 'package:revo_pos/layers/presentation/auth/notifier/login_notifier.dart';
import 'package:revo_pos/layers/presentation/auth/notifier/store_notifier.dart';
import 'package:revo_pos/layers/presentation/chat/notifier/chat_notifier.dart';
import 'package:revo_pos/layers/presentation/customers/notifier/customers_notifier.dart';
import 'package:revo_pos/layers/presentation/orders/notifier/detail_order_notifier.dart';
import 'package:revo_pos/layers/presentation/orders/notifier/orders_notifier.dart';
import 'package:revo_pos/layers/presentation/pos/notifier/categories_notifier.dart';
import 'package:revo_pos/layers/presentation/pos/notifier/draft_notifier.dart';
import 'package:revo_pos/layers/presentation/main/notifier/main_notifier.dart';
import 'package:revo_pos/layers/presentation/pos/notifier/payment_notifier.dart';
import 'package:revo_pos/layers/presentation/pos/notifier/pos_notifier.dart';
import 'package:revo_pos/layers/presentation/products/notifier/attribute_notifier.dart';
import 'package:revo_pos/layers/presentation/products/notifier/form_product_notifier.dart';
import 'package:revo_pos/layers/presentation/products/notifier/products_notifier.dart';
import 'package:revo_pos/layers/presentation/reports/notifier/reports_notifier.dart';
import 'package:revo_pos/layers/presentation/settings/notifier/settings_notifier.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ===================== NOTIFIERS ========================
  // Auth
  sl.registerFactory(
      () => LoginNotifier(loginUsecase: sl(), settingsUsecase: sl()));

  // Home
  sl.registerFactory(() => MainNotifier());
  sl.registerFactory(() => PosNotifier(
      getCategoriesUsecase: sl(),
      getProductsUsecase: sl(),
      scanProductUsecase: sl(),
      checkValidateCookieUsecase: sl()));

  // Pos
  sl.registerFactory(() => DraftNotifier());
  sl.registerFactory(() => PaymentNotifier(
      addToCartUsecase: sl(),
      getCartUsecase: sl(),
      decreaseQtyUsecase: sl(),
      increaseQtyUsecase: sl(),
      removeCartProductUsecase: sl(),
      getCouponUsecase: sl(),
      applyCouponUsecase: sl(),
      checkVariationUsecase: sl(),
      createOrderUsecase: sl(),
      getShippingMethodUsecase: sl(),
      checkPriceUsecase: sl(),
      placeOrderUsecase: sl()));
  sl.registerFactory(() => CategoriesNotifier(getCategoriesUsecase: sl()));

  // Products
  sl.registerFactory(() =>
      ProductsNotifier(getProductsUsecase: sl(), deleteProductUsecase: sl()));
  sl.registerFactory(() => FormProductNotifier(
      getCategoriesUsecase: sl(), insertProductUsecase: sl()));
  sl.registerFactory(() => AttributeNotifier(
        getAttributeUsecase: sl(),
      ));

  // Reports
  sl.registerFactory(() => ReportsNotifier(
      getReportStockUsecase: sl(),
      updateReportStockUsecase: sl(),
      getReportOrdersUsecase: sl()));

  // Orders
  sl.registerFactory(() => DetailOrderNotifier(
      printInvUsecase: sl(),
      userSettingsUsecase: sl(),
      getCustomerUsecase: sl()));
  sl.registerFactory(() => OrdersNotifier(
      getOrderUsecase: sl(),
      updateStatusOrderUsecase: sl(),
      getPaymentUsecase: sl()));

  // Store
  sl.registerFactory(
      () => StoreNotifier(getStoresUsecase: sl(), addStoreUsecase: sl()));

  // Customer
  sl.registerFactory(() => CustomersNotifier(
      getCustomersUsecase: sl(),
      addCustomersUsecase: sl(),
      updateCustomersUsecase: sl(),
      deleteCustomersUsecase: sl()));

  // Settings
  sl.registerFactory(() => SettingsNotifier());

  // Chat
  sl.registerFactory(() => ChatNotifier(
      chatListsUsecase: sl(),
      settingsUsecase: sl(),
      chatDetailListUsecase: sl(),
      sendChatUsecase: sl(),
      insertImageUsecase: sl()));

  // ===================== USECASES ========================
  // Category
  sl.registerLazySingleton(() => GetCategoriesUsecase(sl()));

  // Product
  sl.registerLazySingleton(() => GetProductsUsecase(sl()));
  sl.registerLazySingleton(() => DeleteProductUsecase(sl()));
  sl.registerLazySingleton(() => InsertProductUsecase(sl()));
  sl.registerLazySingleton(() => ScanProductUsecase(sl()));
  sl.registerLazySingleton(() => CheckVariationUsecase(sl()));
  sl.registerLazySingleton(() => GetAttributeUsecase(sl()));
  sl.registerLazySingleton(() => InsertImageUsecase(sl()));

  // Store
  sl.registerLazySingleton(() => GetStoresUsecase(sl()));
  sl.registerLazySingleton(() => AddStoreUsecase(sl()));

  //Auth
  sl.registerLazySingleton(() => LoginUsecase(sl()));
  sl.registerLazySingleton(() => GetSettingsUsecase(sl()));
  sl.registerLazySingleton(() => CheckValidateCookieUsecase(sl()));

  //Customer
  sl.registerLazySingleton(() => GetCustomersUsecase(sl()));
  sl.registerLazySingleton(() => AddCustomersUsecase(sl()));
  sl.registerLazySingleton(() => UpdateCustomersUsecase(sl()));
  sl.registerLazySingleton(() => DeleteCustomersUsecase(sl()));
  sl.registerLazySingleton(() => GetCustomerUsecase(sl()));

  //Order
  sl.registerLazySingleton(() => GetOrderUsecase(sl()));
  sl.registerLazySingleton(() => UpdateStatusOrderUsecase(sl()));
  sl.registerLazySingleton(() => CreateOrderUsecase(sl()));
  sl.registerLazySingleton(() => PrintInvUsecase(sl()));
  sl.registerLazySingleton(() => GetPaymentUsecase(sl()));
  sl.registerLazySingleton(() => GetShippingMethodUsecase(sl()));
  sl.registerLazySingleton(() => CheckPriceUsecase(sl()));
  sl.registerLazySingleton(() => PlaceOrderUsecase(sl()));

  //Cart
  sl.registerLazySingleton(() => AddToCartUsecase(sl()));
  sl.registerLazySingleton(() => GetCartUsecase(sl()));
  sl.registerLazySingleton(() => IncreaseQtyProductUsecase(sl()));
  sl.registerLazySingleton(() => DecreaseQtyProductUsecase(sl()));
  sl.registerLazySingleton(() => RemoveCartProductUsecase(sl()));

  //Coupon
  sl.registerLazySingleton(() => GetCouponUsecase(sl()));
  sl.registerLazySingleton(() => ApplyCouponUsecase(sl()));

  //Setting
  sl.registerLazySingleton(() => GetUserSettingsUsecase(sl()));

  //Chat
  sl.registerLazySingleton(() => GetChatListsUsecase(sl()));
  sl.registerLazySingleton(() => GetChatListsDetailUsecase(sl()));
  sl.registerLazySingleton(() => SendChatUsecase(sl()));

  //Report
  sl.registerLazySingleton(() => GetReportStockUsecase(sl()));
  sl.registerLazySingleton(() => UpdateReportStockUsecase(sl()));
  sl.registerLazySingleton(() => GetReportOrdersUsecase(sl()));

  // ===================== REPOSITORIES ========================
  // Category
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(localDataSource: sl(), remoteDataSource: sl()),
  );

  // Product
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );

  // Store
  sl.registerLazySingleton<StoreRepository>(
    () => StoreRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Auth
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Customer
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Order
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Cart
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(
      localDataSource: sl(),
    ),
  );

  // Coupon
  sl.registerLazySingleton<CouponRepository>(
    () => CouponRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Setting
  sl.registerLazySingleton<SettingRepository>(
    () => SettingRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Chat
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  //Report
  sl.registerLazySingleton<ReportRepository>(
      () => ReportRepositoryImpl(remoteDataSource: sl()));

  // ===================== SOURCES ========================
  // Category
  sl.registerLazySingleton<CategoryLocalDataSource>(
    () => CategoryLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(),
  );

  // Product
  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(),
  );

  // Store
  sl.registerLazySingleton<StoreRemoteDataSource>(
    () => StoreRemoteDataSourceImpl(),
  );

  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );

  // Customer
  sl.registerLazySingleton<CustomerRemoteDataSource>(
    () => CustomerRemoteDataSourceImpl(),
  );

  // Order
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(),
  );

  // Cart
  sl.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(),
  );

  // Coupon
  sl.registerLazySingleton<CouponRemoteDataSource>(
    () => CouponRemoteDataSourceImpl(),
  );

  // Setting
  sl.registerLazySingleton<SettingRemoteDataSource>(
    () => SettingRemoteDataSourceImpl(),
  );

  // Chat
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(),
  );

  // Report
  sl.registerLazySingleton<ReportsRemoteDataSource>(
      () => ReportsRemoteDataSourceImpl());
}
