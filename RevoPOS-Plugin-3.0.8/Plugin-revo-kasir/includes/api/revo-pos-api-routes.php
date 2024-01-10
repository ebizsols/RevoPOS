<?php

if (!defined('ABSPATH')) {
    exit;
}

add_action('rest_api_init', function () {
    pos_security_0auth();

    register_rest_route(REVO_POS_NAMESPACE_API, '/home-api', array(
        'methods'  => WP_REST_Server::READABLE,
        'callback' => 'revo_pos_rest_home',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/home-api/slider', array(
        'methods'  => WP_REST_Server::READABLE,
        'callback' => 'revo_pos_rest_slider',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/home-api/categories', array(
        'methods'  => WP_REST_Server::READABLE,
        'callback' => 'revo_pos_rest_categories',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/home-api/mini-banner', array(
        'methods'  => WP_REST_Server::READABLE,
        'callback' => 'revo_pos_rest_mini_banner',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/home-api/flash-sale', array(
        'methods'  => WP_REST_Server::READABLE,
        'callback' => 'revo_pos_rest_flash_sale',
        'permission_callback' => '__return_true'
    ));
    
    register_rest_route(REVO_POS_NAMESPACE_API, '/home-api/extend-products', array(
        'methods'  => WP_REST_Server::READABLE,
        'callback' => 'revo_pos_rest_extend_products',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/home-api/hit-products', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_rest_hit_products',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/home-api/recent-view-products', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_rest_get_hit_products',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/home-api/intro-page', array(
        'methods'  => WP_REST_Server::READABLE,
        'callback' => 'revo_pos_rest_get_intro_page',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/home-api/splash-screen', array(
        'methods'  => WP_REST_Server::READABLE,
        'callback' => 'revo_pos_rest_get_splash_screen',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/home-api/general-settings', array(
        'methods'  => WP_REST_Server::READABLE,
        'callback' => 'revo_pos_rest_get_general_settings',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/home-api/add-remove-wistlist', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_rest_add_remove_wistlist',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/home-api/list-product-wistlist', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_rest_list_wistlist',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/home-api/popular-categories', array(
        'methods'  => WP_REST_Server::READABLE,
        'callback' => 'revo_pos_popular_categories',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/home-api/key-firebase', array(
        'methods'  => WP_REST_Server::READABLE,
        'callback' => 'revo_pos_rest_key_firebase',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/home-api/input-token-firebase', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_rest_token_user_firebase',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/home-api/check-produk-variation', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_rest_check_variation',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/home-api/list-orders', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_rest_list_orders',
        'permission_callback' => '__return_true'
    ));
    
    register_rest_route(REVO_POS_NAMESPACE_API, '/home-api/print-invoice', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_rest_print_invoice',
        'permission_callback' => '__return_true'
    ));
    
    register_rest_route(REVO_POS_NAMESPACE_API, '/home-api/list-review-user', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_rest_list_review',
        'permission_callback' => '__return_true'
    ));
    
    register_rest_route(REVO_POS_NAMESPACE_API, '/home-api/list-notification', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_rest_list_notification',
        'permission_callback' => '__return_true'
    ));
    
    register_rest_route(REVO_POS_NAMESPACE_API, '/home-api/read-notification', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_rest_read_notification',
        'permission_callback' => '__return_true'
    ));
    
    register_rest_route(REVO_POS_NAMESPACE_API, '/list-categories', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_rest_categories_list',
        'permission_callback' => '__return_true'
    ));
    
    register_rest_route(REVO_POS_NAMESPACE_API, '/insert-review', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_rest_insert_review',
        'permission_callback' => '__return_true'
    ));
    
    register_rest_route(REVO_POS_NAMESPACE_API, '/get-barcode', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_rest_get_barcode',
        'permission_callback' => '__return_true'
    ));
    
    register_rest_route(REVO_POS_NAMESPACE_API, '/product/details', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_rest_product_details',
        'permission_callback' => '__return_true'
    ));
    
    register_rest_route(REVO_POS_NAMESPACE_API, '/product/lists', array(
        'methods'  => 'GET',
        'callback' => 'revo_pos_rest_product_lists',
        'permission_callback' => '__return_true'
    ));
    
    register_rest_route(REVO_POS_NAMESPACE_API, '/set-intro-page', array(
        'methods'  => 'GET',
        'callback' => 'revo_pos_rest_intro_page_status',
        'permission_callback' => '__return_true'
    ));
    
    register_rest_route(REVO_POS_NAMESPACE_API, '/disabled-service', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_rest_disabled_service',
        'permission_callback' => '__return_true'
    ));
    
    register_rest_route(REVO_POS_NAMESPACE_API, '/list-produk', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_rest_list_product',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/update-status-order', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_rest_update_order_status',
        'permission_callback' => '__return_true'
    ));

    // register_rest_route( REVO_POS_NAMESPACE_API, '/report-orders', array(
    //   'methods'  => 'POST',
    //   'callback' => 'revo_pos_report_orders',
    //   'permission_callback' => '__return_true'
    // ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/print-inv', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_print_inv',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/general-setting', array(
        'methods'  => 'GET',
        'callback' => function () {
            throwJson([
                "decimal_separator" => wc_get_price_decimal_separator(),
                "currency_symbol" => get_woocommerce_currency_symbol(),
                "thousand_sparator" => wc_get_price_thousand_separator(),
            ]);
        },
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/get-all-categories', array(
        'methods'  => 'GET',
        'callback' => 'get_pos_all_categories',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/wc-attributes-term', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_attributes_term',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/users', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_users',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/check-validate-cookie', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_validate_cookie',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/report/stocks', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_report_stocks',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/report/stocks-update', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_report_stocks_update',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/report/orders', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_report_orders',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/shipping-methods', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_shipping_methods',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/product/check-price', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_product_check_price',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/apply-coupon', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_apply_coupon',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/place-order', array(
        'methods'  => 'POST',
        'callback' => 'revo_pos_place_order',
        'permission_callback' => '__return_true'
    ));

    register_rest_route(REVO_POS_NAMESPACE_API, '/products/categories', array(
        'methods'  => 'GET',
        'callback' => 'revo_pos_get_product_categories',
        'permission_callback' => '__return_true'
    ));
});
