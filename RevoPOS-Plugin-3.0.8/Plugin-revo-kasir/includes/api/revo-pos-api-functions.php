<?php

if (!defined('ABSPATH')) {
    exit;
}

function revo_pos_rest_home()
{
	$rest_slider = revo_pos_rest_slider('get');
	$rest_categories = revo_pos_rest_categories('get');

	$result['main_slider'] 	    = $rest_slider;
	$result['mini_categories']  = $rest_categories;
	$result['mini_banner'] 		= revo_pos_rest_mini_banner('result');
	$result['general_settings'] = revo_pos_rest_get_general_settings('result');

	$get_intro = revo_pos_rest_get_intro_page('result');
	$result    = array_merge($result, $get_intro);

	$revo_loader = pos_load_flutter_mobile_app();
	$result['products_flash_sale'] 		= revo_pos_rest_product_flash_sale('result', $revo_loader);
	$result['products_special'] 		= revo_pos_rest_additional_products('result', 'special', $revo_loader);
	$result['products_our_best_seller'] = revo_pos_rest_additional_products('result', 'our_best_seller', $revo_loader);
	$result['products_recomendation'] 	= revo_pos_rest_additional_products('result', 'recomendation', $revo_loader);

	echo json_encode($result);
	exit();
}

function revo_pos_rest_product_details()
{
	global $wpdb;
	
	$revo_loader = pos_load_flutter_mobile_app();
	$search  = pos_cek_raw('product_id') ?? get_page_by_path(pos_cek_raw('slug'), OBJECT, 'product');
	$product = wc_get_product($search);
	
	return $revo_loader->pos_reformat_product_result($product);
}

function revo_pos_rest_product_lists()
{
	global $wpdb;
	$revo_loader = pos_load_flutter_mobile_app();

	$args = [
		'limit' => pos_cek_raw('perPage') ?? 1,
		'page' => pos_cek_raw('page') ?? 10,
		'featured' => pos_cek_raw('featured'),
		'category' => pos_cek_raw('category'),
		'orderby' => pos_cek_raw('orderby') ?? 'date',
		'order'  => pos_cek_raw('order') ?? 'ASC',
	];

	if ($parent = pos_cek_raw('parent')) {
		$args['parent'] = $parent;
	}
	if ($include = pos_cek_raw('include')) {
		$args['include'] = $include;
	}
	if ($search = pos_cek_raw('search')) {
		$args['like_name'] = $search;
	}

	$products = wc_get_products($args);
	$results = array();
	foreach ($products as $i => $product) {
		array_push($results, $revo_loader->pos_reformat_product_result($product));
	}

	echo json_encode($results);
	exit;
}

function revo_pos_rest_additional_products($type = 'rest', $product_type, $revo_loader)
{

	global $wpdb;

	$where = '';

	if ($product_type == 'special') {
		$where = "AND type = 'special'";
	} elseif ($product_type == 'our_best_seller') {
		$where = "AND type = 'our_best_seller'";
	} elseif ($product_type == 'recomendation') {
		$where = "AND type = 'recomendation'";
	}

	$products = $wpdb->get_results("SELECT * FROM `revo_extend_products` WHERE is_deleted = 0 AND is_active = 1 $where  ORDER BY id DESC", OBJECT);

	$result = [];
	$list_products = [];
	foreach ($products as $key => $value) {

		if (!empty($value->products)) {
			$_POST['include'] = $value->products;
			$list_products = $revo_loader->get_products();
		}


		array_push($result, [
			'title' => $value->title,
			'description' => $value->description,
			'products' => $list_products,
		]);
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_rest_product_flash_sale($type = 'rest', $revo_loader)
{
	global $wpdb;
	pos_cek_flash_sale_end();
	$date = date('Y-m-d H:i:s');
	$data_flash_sale = $wpdb->get_results("SELECT * FROM `revo_flash_sale` WHERE is_deleted = 0 AND start <= '" . $date . "' AND end >= '" . $date . "' AND is_active = 1  ORDER BY id DESC LIMIT 1", OBJECT);

	$result = [];
	$list_products = [];
	foreach ($data_flash_sale as $key => $value) {
		if (!empty($value->products)) {
			$_POST['include'] = $value->products;
			$list_products = $revo_loader->get_products();
		}
		array_push($result, [
			'id' => (int) $value->id,
			'title' => $value->title,
			'start' => $value->start,
			'end' => $value->end,
			'image' => $value->image,
			'products' => $list_products,
		]);
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_index_home()
{
	$rest_slider = revo_pos_rest_slider('get');
	$rest_categories = rest_categories('get');

	$result['slider'] = $rest_slider;
	$result['categories'] = $rest_categories;

	echo json_encode($result);
	exit();
}

function revo_pos_rest_slider($type = 'rest')
{
	global $wpdb;
	$data_banner = $wpdb->get_results("SELECT * FROM revo_mobile_slider WHERE is_deleted = 0 ORDER BY order_by DESC", OBJECT);
	$result = [];
	foreach ($data_banner as $key => $value) {
		array_push($result, [
			'product' => (int) $value->product_id,
			'title_slider' => $value->title,
			'image' => $value->images_url,
		]);
	}

	if (empty($result)) {
		for ($i = 0; $i < 3; $i++) {
			array_push($result, [
				'product' => (int) '0',
				'title_slider' => '',
				'image' => pos_revo_url() . 'assets/images/default_banner.png',
			]);
		}
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_print_inv($type = 'rest')
{

	global $wpdb;

	$id = pos_cek_raw("id_order");
	$nama_toko = pos_cek_raw("nama_toko");
	$no_hp_toko = pos_cek_raw("no_hp_toko");
	$alamat_toko = pos_cek_raw("alamat_toko");

	$errors = [];

	if (!$id) {
		array_push($errors, "id_orders");
	}

	if (!$nama_toko) {
		array_push($errors, "nama_toko");
	}
	if (!$no_hp_toko) {
		array_push($errors, "no_hp_toko");
	}
	if (!$alamat_toko) {
		array_push($errors, "alamat_toko");
	}

	if (count($errors)) {
		throwJson(['message' => implode(", ", $errors) . ' is required'], 422);
	}

	$data = [
		'orders' => [
			(object)[
				'product' => (object)[
					'name' => "kursi gaming",
					'sku' => "kks328",
				],
				"qty" => 111121
			],
			(object)[
				'product' => (object)[
					'name' => "hard case iphone pro michat",
					'sku' => "kks328",
				],
				"qty" => 111121
			],
			(object)[
				'product' => (object)[
					'name' => "redmi xs max 125gb",
					'sku' => "kks328",
				],
				"qty" => 111121
			],
			(object)[
				'product' => (object)[
					'name' => "mac-q",
					'sku' => "kks328",
				],
				"qty" => 111121
			],
		],
		'resi' => '7124487AF',
		'expedisi' => 'RJE',
		'penerima' => 'Royali',
		'kecamatan' => 'Margorejo',
		'pengirim' => 'Pablo',
		'nohp_pengirim' => '076558901+87',
		'nohp_penerima' => '081234567869',
		'alamat_pengirim' => 'Texas Holdem Poker',
		'alamat_pelanggan' => 'Jl. Gajayana Pesisir Pantai Kuyang',
		'kota' => 'Melbourne',
		'provinsi' => 'provinsi',
		'berat_produk' => 'gaberat',
		'no_inv' => '0987658790oj'
	];

	$order = wc_get_order($id);
	$order_data = $order->get_data();
	$order_items = $order->get_items();

	$items = [];
	foreach ($order->get_items() as $item_id => $item) {
		// //Get the product ID
		// $product_id = $item->get_product_id();
		//
		// //Get the variation ID
		// $variation_id = $item->get_variation_id();
		//
		// //Get the WC_Product object
		$product = $item->get_product();

		$items[] = (object)[
			'product' => (object)[
				'name' => $item->get_name(),
				'sku' => $product->get_sku(),
			],
			'weight' => (int)$product->get_weight(),
			'qty' => $item->get_quantity(),
		];
	}

	$billorshipp = "billing"; // billing or shipping

	$data['orders'] = $items;
	$data['pengirim'] = $nama_toko;
	$data['penerima'] = $order_data["billing"]['first_name'] . " " . $order_data["billing"]['last_name'];
	$data['expedisi'] = $order->get_shipping_method();
	$data['alamat_pelanggan'] = $order_data["shipping"]['address_1'] . " " . $order_data["shipping"]['address_2'];
	$data['alamat_pengirim'] = $alamat_toko; //get_option( 'woocommerce_store_address' );
	$data['pos'] = $order_data["billing"]['postcode'];
	$data['kota'] = $order_data["billing"]['city'];
	$data['provinsi'] = "";
	$data['kecamatan'] = $order_data["billing"]['state'];
	$data['no_inv'] = "#" . $order->get_order_number();
	$data['berat_produk'] = array_sum(array_column($items, "weight"));
	$data['nohp_pengirim'] = $no_hp_toko;

	$inv = generateInv($data);

	throwJson(['inv_url' => $inv, 'message' => 'success']);
}

function revo_pos_rest_mini_banner($type = 'rest')
{
	global $wpdb;

	$where = '';
	if (isset($_GET['blog_banner'])) {
		$where = "AND type = 'Blog Banner' ";
	}
	$data_banner = $wpdb->get_results("SELECT * FROM revo_list_mini_banner WHERE is_deleted = 0 $where ORDER BY order_by ASC", OBJECT);

	$result = [];
	if (isset($_GET['blog_banner'])) {

		foreach ($data_banner as $key => $value) {
			if ($value->type == 'Blog Banner') {
				$result[] = [
					'product' => (int) $value->product_id,
					'title_slider' => ($value->title != NULL ? $value->title : ''),
					'type' => $value->type,
					'image' => $value->image,
				];
			} else {
				$result[] = array(
					'product' => (int) '0',
					'title_slider' => '',
					'type' => 'Blog Banner',
					'image' => pos_revo_url() . 'assets/images/defalt_mini_banner.png',
				);
			}

			break;
		}
	} else {
		$result_1 = [];
		$type_1 = 'Special Promo';
		$result_2 = [];
		$type_2 = 'Love These Items';

		foreach ($data_banner as $key => $value) {
			if ($value->type == $type_1) {
				array_push($result_1, [
					'product' => (int) $value->product_id,
					'title_slider' => ($value->title != NULL ? $value->title : ''),
					'type' => $value->type,
					'image' => $value->image,
				]);
			}

			if ($value->type == $type_2) {
				array_push($result_2, [
					'product' => (int) $value->product_id,
					'title_slider' => ($value->title != NULL ? $value->title : ''),
					'type' => $value->type,
					'image' => $value->image,
				]);
			}
		}

		if (count($result_1) < 4) {
			$total_result_1 = 4 - count($result_1);
			for ($i = 0; $i < $total_result_1; $i++) {
				array_push($result_1, [
					'product' => (int) '0',
					'title_slider' => '',
					'type' => $type_1,
					'image' => pos_revo_url() . 'assets/images/defalt_mini_banner.png',
				]);
			}
		}

		if (count($result_2) < 4) {
			$total_result_2 = 4 - count($result_2);
			for ($i = 0; $i < $total_result_2; $i++) {
				array_push($result_2, [
					'product' => (int) '0',
					'title_slider' => '',
					'type' => $type_2,
					'image' => pos_revo_url() . 'assets/images/defalt_mini_banner.png',
				]);
			}
		}

		$result = array_merge($result_1, $result_2);
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_rest_categories($type = 'rest')
{
	global $wpdb;
	$data_banner = $wpdb->get_results("SELECT * FROM revo_list_categories WHERE is_deleted = 0 ORDER BY order_by DESC", OBJECT);
	$result = [];

	if (isset($_GET['show_popular'])) {
		array_push($result, [
			'categories' => (int) '9911',
			'title_categories' => 'Popular Categories',
			'image' => pos_revo_url() . 'assets/images/popular.png',
		]);
	}

	foreach ($data_banner as $key => $value) {
		array_push($result, [
			'categories' => (int) $value->category_id,
			'title_categories' => $value->category_name,
			'image' => $value->image,
		]);
	}

	if (empty($result)) {
		for ($i = 0; $i < 5; $i++) {
			array_push($result, [
				'categories' => (int) '0',
				'title_categories' => 'Dummy Categories',
				'image' => pos_revo_url() . 'assets/images/default_categories.png',
			]);
		}
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_rest_categories_list($type = 'rest')
{
	global $wpdb;

	$result = [];

	$taxonomy     = 'product_cat';
	$orderby      = 'name';
	$show_count   = 1;      // 1 for yes, 0 for no
	$pad_counts   = 0;      // 1 for yes, 0 for no
	$hierarchical = 1;      // 1 for yes, 0 for no
	$title        = '';
	$empty        = 0;

	$args = array(
		'taxonomy'     => $taxonomy,
		//'orderby'      => $orderby,
		'show_count'   => $show_count,
		'pad_counts'   => $pad_counts,
		'hierarchical' => $hierarchical,
		'title'     => $title,
		'hide_empty'   => $empty,
		'menu_order' => 'asc',
		'parent' => 0
	);

	if (pos_cek_raw('page')) {
		$args['offset'] = pos_cek_raw('page');
	}

	if (pos_cek_raw('limit')) {
		$args['number'] = pos_cek_raw('limit');
	}

	if (!pos_cek_raw('parent')) {
		$data_categories = get_popular_categories();
		if (!empty($data_categories)) {
			array_push($result, [
				'id' => (int) '9911',
				'title' => 'Popular Categories',
				'description' => '',
				'parent' => 0,
				'count' => 0,
				'image' => pos_revo_url() . 'assets/images/popular.png',
			]);
		}

		$categories = get_categories($args);
		foreach ($categories as $key => $value) {
			if ($value->name != 'Uncategorized') {
				$image_id = get_term_meta($value->term_id, 'thumbnail_id', true);
				$image = '';

				if ($image_id) {
					$image = wp_get_attachment_url($image_id);
				}

				$terms = get_terms([
					'taxonomy'    => 'product_cat',
					'hide_empty'  => false,
					'parent'      => $value->term_id
				]);


				array_push($result, [
					'id' => $value->term_id,
					'title' => wp_specialchars_decode($value->name),
					'description' => $value->description,
					'parent' => $value->parent,
					'count' => count($terms),
					'image' => $image,
				]);
			}
		}
	} else {
		$categories = get_terms([
			'taxonomy'    => 'product_cat',
			'hide_empty'  => false,
			'parent'      => pos_cek_raw('parent')
		]);

		foreach ($categories as $key => $value) {
			$image_id = get_term_meta($value->term_id, 'thumbnail_id', true);
			$image = '';

			if ($image_id) {
				$image = wp_get_attachment_url($image_id);
			}


			array_push($result, [
				'id' => $value->term_id,
				'title' => wp_specialchars_decode($value->name),
				'description' => $value->description,
				'parent' => $value->parent,
				'count' => 0,
				'image' => $image,
			]);
		}
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_popular_categories($type = 'rest')
{
	global $wpdb;

	$data_categories = get_popular_categories();
	$result = [];
	if (!empty($data_categories)) {
		foreach ($data_categories as $key) {
			$categories = json_decode($key->categories);
			$list = [];
			if (is_array($categories)) {
				for ($i = 0; $i < count($categories); $i++) {
					$image = wp_get_attachment_url(get_term_meta($categories[$i], 'thumbnail_id', true));
					$list[] = array(
						'id' => $categories[$i],
						'name' => get_terms('product_cat', ['include' => $categories[$i], 'hide_empty' => false], true)[0]->name,
						'image' => ($image == false ? pos_revo_url() . 'assets/images/defalt_mini_banner.png' : $image)
					);
				}
				if (!empty($list)) {
					$result[] = array(
						'title' => $key->title,
						'categories' => $list,
					);
				}
			}
		}
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_rest_flash_sale($type = 'rest')
{
	global $wpdb;
	pos_cek_flash_sale_end();
	$date = date('Y-m-d H:i:s');
	$data_flash_sale = $wpdb->get_results("SELECT * FROM `revo_flash_sale` WHERE is_deleted = 0 AND start <= '" . $date . "' AND end >= '" . $date . "' AND is_active = 1  ORDER BY id DESC LIMIT 1", OBJECT);

	$result = [];
	$list_products = [];
	foreach ($data_flash_sale as $key => $value) {
		if (!empty($value->products)) {
			$get_products = json_decode($value->products);
			if (is_array($get_products)) {
				$list_products = implode(",", $get_products);
			}
		}
		array_push($result, [
			'id' => (int) $value->id,
			'title' => $value->title,
			'start' => $value->start,
			'end' => $value->end,
			'image' => $value->image,
			'products' => implode(",", json_decode($value->products)),
		]);
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_rest_extend_products($type = 'rest')
{

	global $wpdb;

	$where = '';

	$typeGet = '';
	if (isset($_GET['type'])) {
		$typeGet = $_GET['type'];

		if ($typeGet == 'special') {
			$where = "AND type = 'special'";
		}

		if ($typeGet == 'our_best_seller') {
			$where = "AND type = 'our_best_seller'";
		}

		if ($typeGet == 'recomendation') {
			$where = "AND type = 'recomendation'";
		}
	}

	$products = $wpdb->get_results("SELECT * FROM `revo_extend_products` WHERE is_deleted = 0 AND is_active = 1 $where  ORDER BY id DESC", OBJECT);

	$result = [];
	$list_products = "";
	if (!empty($products)) {
		foreach ($products as $key => $value) {
			if (!empty($value->products)) {
				$get_products = json_decode($value->products);
				if (is_array($get_products)) {
					$list_products = implode(",", $get_products);
				}
			}
			array_push($result, [
				'title' => $value->title,
				'description' => $value->description,
				'products' => $list_products,
			]);
		}
	} else {
		array_push($result, [
			'title' => $typeGet,
			'description' => "",
			'products' => "",
		]);
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_rest_get_barcode($type = 'rest')
{

	global $wpdb;

	$code = pos_cek_raw('code');

	if (!empty($code)) {
		$table_name = $wpdb->prefix . 'postmeta';

		$get = $wpdb->get_row("SELECT * FROM `$table_name` WHERE `meta_value` LIKE '$code'", OBJECT);
		if (!empty($get)) {
			$result['id'] = (int)$get->post_id;
		} else {
			$result = ['status' => 'error', 'message' => 'code not found !'];
		}
	} else {
		$result = ['status' => 'error', 'message' => 'code required !'];
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_rest_hit_products($type = 'rest')
{

	global $wpdb;

	$cookie = pos_cek_raw('cookie');

	$result = ['status' => 'error', 'message' => 'Login required !'];
	if ($cookie) {
		$user_id = wp_validate_auth_cookie($cookie, 'logged_in');
		if (!$user_id) {
			$result = ['status' => 'error', 'message' => 'User Tidak ditemukan !'];
		} else {
			$id_product = pos_cek_raw('product_id');
			$ip_address = pos_cek_raw('ip_address');

			$result = ['status' => 'error', 'message' => 'Tidak dapat Hit Products !'];

			if (!empty($id_product) and !empty($ip_address)) {

				$date = date('Y-m-d');

				$products = $wpdb->get_results("SELECT * FROM `revo_hit_products` WHERE products = '$id_product' AND type = 'hit' AND ip_address = '$ip_address' AND user_id = '$user_id' AND created_at LIKE '%$date%'", OBJECT);

				if (empty($products)) {

					$wpdb->insert(
						'revo_hit_products',
						[
							'products' => $id_product,
							'ip_address' => $ip_address,
							'user_id' => $user_id,
						]
					);

					if (empty($wpdb->show_errors())) {

						$result = ['status' => 'success', 'message' => 'Berhasil Hit Products !'];
					} else {

						$result = ['status' => 'error', 'message' => 'Server Error 500 !'];
					}
				} else {

					$result = ['status' => 'error', 'message' => 'Hit Product Hanya Bisa dilakukan sekali sehari !'];
				}
			}
		}
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_rest_insert_review($type = 'rest')
{

	global $wpdb;

	$cookie = pos_cek_raw('cookie');

	$result = ['status' => 'error', 'message' => 'Login required !'];
	if ($cookie) {
		$user_id = wp_validate_auth_cookie($cookie, 'logged_in');
		if (!$user_id) {
			$result = ['status' => 'error', 'message' => 'User Tidak ditemukan !'];
		} else {
			$user = get_userdata($user_id);

			$comment_id = wp_insert_comment(array(
				'comment_post_ID'      => pos_cek_raw('product_id'), // <=== The product ID where the review will show up
				'comment_author'       => $user->first_name . ' ' . $user->last_name,
				'comment_author_email' => $user->user_email, // <== Important
				'comment_author_url'   => '',
				'comment_content'      => pos_cek_raw('comments'),
				'comment_type'         => '',
				'comment_parent'       => 0,
				'user_id'              => $user_id, // <== Important
				'comment_author_IP'    => '',
				'comment_agent'        => '',
				'comment_date'         => date('Y-m-d H:i:s'),
				'comment_approved'     => 0,
			));

			// HERE inserting the rating (an integer from 1 to 5)
			update_comment_meta($comment_id, 'rating', pos_cek_raw('rating'));

			$result = ['status' => 'success', 'message' => 'insert rating success !'];
		}
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_rest_get_hit_products($type = 'rest')
{

	global $wpdb;

	$cookie = pos_cek_raw('cookie');

	if ($cookie) {
		$user_id = wp_validate_auth_cookie($cookie, 'logged_in');
		if (!$user_id) {
			$result = ['status' => 'error', 'message' => 'User Tidak ditemukan !'];
		} else {

			$products = $wpdb->get_results("SELECT * FROM `revo_hit_products` WHERE user_id = '$user_id' AND type = 'hit' GROUP BY products ORDER BY created_at DESC", OBJECT);

			$list_products = '';

			if (!empty($products)) {
				$list_products = [];
				foreach ($products as $key => $value) {
					$list_products[] = $value->products;
				}
				if (!empty($list_products)) {
					$list_products = implode(",", $list_products);
				}
			} else {

				// $where = array(
				// 			'limit' => 10,
				// 			'orderby' => 'rand',
				// 		);

				// $list_products = get_products_id($where);

				// $list_products = implode(",",$list_products);

			}

			$result = [
				'status' => 'success',
				'products' => $list_products,
			];
		}
	} else {
		$result = ['status' => 'error', 'message' => 'Login required !'];
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_rest_intro_page_status($type = 'rest')
{
	global $wpdb;
	$get = pos_query_revo_pos_mobile_variable('"intro_page_status"', 'sort');
	$status = $_GET['status'];
	if (empty($get)) {
		$wpdb->insert('revo_mobile_variable', array(
			'slug' => 'intro_page_status',
			'title' => '',
			'image' => pos_query_revo_pos_mobile_variable('"splashscreen"')[0]->image,
			'description' => $status
		));
	} else {
		$wpdb->query(
			$wpdb
				->prepare("
					UPDATE revo_mobile_variable
					SET description='$status'
					WHERE slug='intro_page_status'
				")
		);
	}
	return $status;
}

function revo_pos_rest_get_general_settings($type = 'rest')
{
	global $wpdb;

	$query_pp = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'privacy_policy'";
	$data_pp = $wpdb->get_row($query_pp, OBJECT);
	$query_tc = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'term_condition'";
	$data_tc = $wpdb->get_row($query_tc, OBJECT);

	$result['wa'] = pos_data_seeder('kontak_wa');
	$result['sms'] = pos_data_seeder('kontak_sms');
	$result['phone'] = pos_data_seeder('kontak_phone');
	$result['about'] = pos_data_seeder('about');
	$result['privacy_policy'] = $data_pp ?? pos_data_seeder('privacy_policy');
	$result['term_condition'] = $data_tc ?? pos_data_seeder('term_condition');
	$result['cs'] = pos_data_seeder('cs');
	$result['logo'] = pos_data_seeder('logo');

	// $get = pos_query_revo_pos_mobile_variable('"kontak","about","cs","privacy_policy","logo","empty_image","term_condition"','sort');
	$get_pos = pos_query_revo_pos_mobile_variable('"kontak","about","cs","privacy_policy","empty_image","term_condition"', 'sort');
	$get_woo = pos_query_revo_pos_mobile_variable('"logo"', 'sort');
	$get = array_merge($get_pos, $get_woo);

	$intro_page = true;
	if (!empty($get)) {
		foreach ($get as $key) {

			if ($key->slug == 'kontak') {
				$result[$key->title] = [
					'slug' => $key->slug,
					"title" => $key->title,
					"image" => $key->image,
					"description" => $key->description
				];
			} elseif ($key->slug == 'intro_page') {
				$result['intro'][] = [
					'slug' => $key->slug,
					"title" => $key->title,
					"image" => $key->image,
					"description" => $key->description
				];

				$intro_page = false;
			} elseif ($key->slug == 'empty_image') {
				$result[$key->slug][] = [
					'slug' => $key->slug,
					"title" => $key->title,
					"image" => $key->image,
					"description" => $key->description
				];
			} else {
				$result[$key->slug] = [
					'slug' => $key->slug,
					"title" => $key->title,
					"image" => $key->image,
					"description" => $key->description
				];
			}
		}

		$result["link_playstore"] = [
			'slug' => "playstore",
			"title" => "link playstore",
			"image" => "",
			"description" => "https://play.google.com/store"
		];
		$currency = get_woocommerce_currency_symbol();

		$result["currency"] = [
			'slug' => "currency",
			"title" => get_option('woocommerce_currency'),
			"image" => wp_specialchars_decode(get_woocommerce_currency_symbol($currency)),
			"description" => wp_specialchars_decode($currency)
		];

		$result["format_currency"] = [
			'slug' => wc_get_price_decimals(),
			"title" => wc_get_price_decimal_separator(),
			"image" => wc_get_price_thousand_separator(),
			"description" => "Slug : Number of decimals , title : Decimal separator, image : Thousand separator"
		];
	}

	if (empty($result['empty_image'])) {
		$result['empty_image'][] = pos_data_seeder('empty_images_1');
		$result['empty_image'][] = pos_data_seeder('empty_images_2');
		$result['empty_image'][] = pos_data_seeder('empty_images_3');
		$result['empty_image'][] = pos_data_seeder('empty_images_4');
		$result['empty_image'][] = pos_data_seeder('empty_images_5');
	}

	if ($intro_page) {
		for ($i = 1; $i < 4; $i++) {
			$result['intro'][] = pos_data_seeder('intro_page_' . $i);
		}
	}
	
	$result['barcode_active'] = is_plugin_active('yith-woocommerce-barcodes-premium/init.php') ? true : false;
	$result['livechat_to_revowoo'] = is_plugin_active('Plugin-revo-kasir-main/index.php') ? (is_plugin_active('Revo-woocomerce-plugin-main/index.php') ? (pos_query_revo_pos_mobile_variable('"live_chat_status"', 'sort')[0]->description == "show" ? true : false) : false) : false;

	$result['wholesale'] = is_plugin_active('woocommerce-wholesale-prices/woocommerce-wholesale-prices.bootstrap.php');

	$first_admin = get_users([
		'role' => 'administrator',
		'orderby' => [
			'ID' => 'ASC'
		]
	])[0];

	$query_unread_messages = $wpdb->get_row("SELECT COUNT(id) as count_messages FROM `revo_conversation_messages` WHERE receiver_id = {$first_admin->ID} AND is_read = 1", OBJECT);
	$result['unread_message'] = (int) $query_unread_messages->count_messages;

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_rest_get_intro_page($type = 'rest')
{

	global $wpdb;

	$get = pos_query_revo_pos_mobile_variable('"intro_page","splashscreen"', 'sort');

	$result['splashscreen'] = pos_data_seeder('splashscreen');
	$intropagestatus = pos_query_revo_pos_mobile_variable('"intro_page_status"', 'sort'); // ?? [0=>(object)["description"=>""]];
	$result['intro_page_status'] = count($intropagestatus) ? $intropagestatus[0]->description : "";

	$intro_page = true;
	if (!empty($get)) {
		foreach ($get as $key) {

			if ($key->slug == 'splashscreen') {
				$result['splashscreen'] =  [
					'slug' => $key->slug,
					"title" => '',
					"image" => $key->image,
					"description" => $key->description
				];
			}

			if ($key->slug == 'intro_page') {
				$result['intro'][] = [
					'slug' => $key->slug,
					"title" => $key->title,
					"image" => $key->image,
					"description" => $key->description
				];

				$intro_page = false;
			}
		}
	}

	if ($intro_page) {
		for ($i = 1; $i < 4; $i++) {
			$result['intro'][] = pos_data_seeder('intro_page_' . $i);
		}
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_rest_add_remove_wistlist($type = 'rest')
{
	global $wpdb;

	$result['product_id'] = pos_cek_raw('product_id');
	$user_id = wp_validate_auth_cookie(pos_cek_raw('cookie'), 'logged_in');
	if ($user_id) {
		if (!empty($result['product_id'])) {
			$get = query_hit_products($result['product_id'], $user_id);
			if (@pos_cek_raw('check')) {
				if ($get->is_wistlist == 0) {
					$result['type'] = 'check';
					$result['message'] = false;
				} else {
					$result['type'] = 'check';
					$result['message'] = true;
				}
			} else {
				if ($get->is_wistlist == 0) {

					$wpdb->insert(
						'revo_hit_products',
						[
							'products' => $result['product_id'],
							'ip_address' => '',
							'type' => 'wistlist',
							'user_id' => $user_id,
						]
					);

					if (empty($wpdb->show_errors())) {
						$result['type'] = 'add';
						$result['message'] = 'success';
					} else {
						$result['type'] = 'add';
						$result['message'] = 'error';
					}
				} else {
					$product_id = $result['product_id'];
					$wpdb->query($wpdb->prepare("DELETE FROM `revo_hit_products` WHERE products = '$product_id' AND user_id = '$user_id' AND type = 'wistlist'"));

					if (empty($wpdb->show_errors())) {
						$result['type'] = 'remove';
						$result['message'] = 'success';
					} else {
						$result['type'] = 'remove';
						$result['message'] = 'error';
					}
				}
			}
		} else {
			$result['type'] = 'Empty Product id !';
			$result['message'] = 'error';
		}
	} else {
		$result['type'] = 'Users tidak ditemukan !';
		$result['message'] = 'error';
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_rest_list_wistlist($type = 'rest')
{
	global $wpdb;
	$list_products = '';

	$cookie = pos_cek_raw('cookie');

	$user_id = wp_validate_auth_cookie($cookie, 'logged_in');
	if ($user_id) {
		$get = query_all_hit_products($user_id);
		if (!empty($get)) {
			$list_products = [];
			foreach ($get as $key) {
				$list_products[] = $key->products;
			}
			if (is_array($list_products)) {
				$list_products = implode(",", $list_products);
			}
		}
	}

	$result = [
		'products' => $list_products
	];

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_rest_key_firebase($type = 'rest')
{

	$key = pos_access_key();
	$result = array(
		"serverKey" => 'AAAALwNKHLc:APA91bGY_AkY01vJ_aGszm7yIjLaNbaAM1ivPlfigeFscdSVuUx3drCRGxyIRgLTe7nLB-5_5rF_ShlmqVXCUmrSd_uaJdcEV43MLxUeFrzmKCzyZzBB7AUlziIGxIH0phtw5VNqgY2Z',
		"apiKey" => 'AIzaSyCYkikCSaf91MbO6f3xEkUgFRDqHeNZgNE',
		"authDomain" => 'revo-woo.firebaseapp.com',
		"databaseURL" => 'https://revo-woo.firebaseio.com',
		"projectId" => 'revo-woo',
		"storageBucket" => 'revo-woo.appspot.com',
		"messagingSenderId" => '201918651575',
		"appId" => '1:201918651575:web:dda924debfb0121cf3c132',
		"measurementId" => 'G-HNR4L3Z0JE',
	);

	if (isset($key->firebase_server_key)) {
		$result['serverKey'] = $key->firebase_server_key;
	}

	if (isset($key->firebase_api_key)) {
		$result['apiKey'] = $key->firebase_api_key;
	}

	if (isset($key->firebase_auth_domain)) {
		$result['authDomain'] = $key->firebase_auth_domain;
	}

	if (isset($key->firebase_database_url)) {
		$result['authDomain'] = $key->firebase_database_url;
	}

	if (isset($key->firebase_database_url)) {
		$result['databaseURL'] = $key->firebase_database_url;
	}

	if (isset($key->firebase_project_id)) {
		$result['projectId'] = $key->firebase_project_id;
	}

	if (isset($key->firebase_storage_bucket)) {
		$result['storageBucket'] = $key->firebase_storage_bucket;
	}

	if (isset($key->firebase_messaging_sender_id)) {
		$result['messagingSenderId'] = $key->firebase_messaging_sender_id;
	}

	if (isset($key->firebase_app_id)) {
		$result['appId'] = $key->firebase_app_id;
	}

	if (isset($key->firebase_measurement_id)) {
		$result['measurementId'] = $key->firebase_measurement_id;
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_rest_token_user_firebase($type = 'rest')
{

	global $wpdb;

	$data['token'] = pos_cek_raw('token');
	$cookie = pos_cek_raw('cookie');

	$result = ['status' => 'error', 'message' => 'Gagal Input Token !'];
	$insert = true;

	if (!empty($data['token'])) {
		if ($cookie) {
			$user_id = wp_validate_auth_cookie($cookie, 'logged_in');
			if ($user_id) {
				$data['user_id'] = $user_id;
				$get = get_user_token(" WHERE user_id = '$user_id'  ");
				if (!empty($get)) {
					$insert = false;
					$wpdb->update('revo_pos_token_firebase', $data, ['user_id' => $user_id]);
					if (@$wpdb->show_errors == false) {
						$result = ['status' => 'success', 'message' => 'Update Token Berhasil !'];
					}
				}
			}
		}

		if ($insert) {
			$wpdb->insert('revo_pos_token_firebase', $data);
			if (@$wpdb->show_errors == false) {
				$result = ['status' => 'success', 'message' => 'Insert Token Berhasil !'];
			}
		}
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_rest_print_invoice($type = 'rest')
{

	global $wpdb;
	$order_id = pos_cek_raw("order_id");
	$cookie = pos_cek_raw('cookie');
	$user_id = wp_validate_auth_cookie($cookie, 'logged_in');

	if (!$order_id || !$user_id) throwJson(['message' => "error", "status" => "error"], 422);

	$order = get_order_details($order_id);
	throwJson($order);


	$data = [
		'orders' => $order['items'],
		'resi' => '7124487AF',
		'expedisi' => 'RJE',
		'penerima' => $order['user']['first_name'] . " " . $order['user']['last_name'],
		'kecamatan' => 'Margorejo',
		'pengirim' => 'Pablo',
		'nohp_pengirim' => '076558901+87',
		'nohp_penerima' => $order['user']['billing']['phone'],
		'alamat_pengirim' => 'Texas Holdem Poker',
		'alamat_pelanggan' => 'Jl. Gajayana Pesisir Pantai Kuyang',
		'kota' => 'Melbourne',
		'provinsi' => 'Sugiharjo',
		'berat_produk' => 'gaberat',
		'no_inv' => $order['meta']['order_key']
	];
	$pdf = toPdf($data);

	global $wpdb;
	$newname =  md5(date("Y-m-d H:i:s")) . ".jpg";
	$uploads_url = WP_CONTENT_URL . "/uploads/revo/";
	$target_dir = WP_CONTENT_DIR . "/uploads/revo/";
	// return phpinfo();
	// Create new object
	$im = new Imagick();
	$im->setResolution(300, 300);
	$im->readImage($pdf . "[0]");
	$im->setImageFormat("jpeg");
	$im->writeImage("$target_dir$newname");
	$im->clear();
	$im->destroy();
	echo "$uploads_url$newname";

	if (file_exists($pdf)) {
		unlink($pdf);
	}
}

function revo_pos_rest_check_variation($type = 'rest')
{

	global $wpdb;

	$product_id = pos_cek_raw('product_id');
	$variation = pos_cek_raw('variation');

	$result = ['status' => 'error', 'variation_id' => 0];

	if (!empty($product_id)) {

		if ($variation) {
			global $woocommerce;

			$data = [];
			foreach ($variation as $key) {
				$key->column_name = str_replace(" ", "-", strtolower($key->column_name));
				$data["attribute_" . $key->column_name] .= $key->value;
			}

			if ($data) {
				$data_store = new WC_Product_Data_Store_CPT();
				$product_object = wc_get_product($product_id);
				$variation_id = $data_store->find_matching_product_variation($product_object, $data);

				if ($variation_id) {
					$revo_loader = pos_load_flutter_mobile_app();

					$variableProduct = wc_get_product($variation_id);
					$result['status'] = 'success';
					$result['data'] = $revo_loader->pos_reformat_product_result($variableProduct);
					$result['variation_id'] = $variation_id;
				}
			}
		}
	}


	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_rest_list_orders($type = 'rest')
{
	global $wpdb;

	$cookie   = pos_cek_raw('cookie');
	$page     = pos_cek_raw('page');
	$limit    = pos_cek_raw('per_page');
	$order_by = pos_cek_raw('order_by');
	$order_id = pos_cek_raw('order_id');
	$status   = pos_cek_raw('status');
	$search   = pos_cek_raw('search');

	$result = [];
	if ($cookie) {
		$user_id = wp_validate_auth_cookie($cookie, 'logged_in');

		$revo_loader = pos_load_flutter_mobile_app();
		if ($order_id) {
			$customer_orders = wc_get_order($order_id);
			if ($customer_orders) {
				$get = $revo_loader->get_formatted_item_data($customer_orders);
				if (isset($get["line_items"])) {
					for ($i = 0; $i < count($get["line_items"]); $i++) {
						if ($get["line_items"][$i]["product_id"] != 0) {
							$image_id = wc_get_product($get["line_items"][$i]["product_id"])->get_image_id();
							$get["line_items"][$i]['image'] = wp_get_attachment_image_url($image_id, 'full');
						} else {
							$get["line_items"][$i]['image'] = null;
						}
					}
				}

				if ($get['customer_id'] == $user_id) {
					$result[] = $get;
				}
			}
		} else {
			if (empty($search)) {
				$where = [
					'meta_key' => '_customer_user',
					'orderby'  => 'date',
					'order'    => $order_by ? $order_by : "DESC",
					'page' 	   => $page ? $page : "1",
					'limit'    => $limit ? $limit : "10",
					'parent'   => 0,
				];

				if ($status) {
					// Order status. Options: pending, processing, on-hold, completed, cancelled, refunded, failed,trash. Default is pending.
					$where['status'] = $status;
				}

				$customer_orders = wc_get_orders($where);

				foreach ($customer_orders as $value) {
					$get = $revo_loader->get_formatted_item_data($value);

					if ($get) {
						if (isset($get["line_items"])) {
							for ($i = 0; $i < count($get["line_items"]); $i++) {
								$show = true;
								if ($get["line_items"][$i]["product_id"] != 0) {
									$image_id = wc_get_product($get["line_items"][$i]["product_id"])->get_image_id();
									$get["line_items"][$i]['image'] = wp_get_attachment_image_url($image_id, 'full');
								} else {
									$get["line_items"][$i]['image'] = null;
								}
							}
						}

						$result[] = $get;
					}
				}
			} else {
				$table_post  = $wpdb->prefix . 'postmeta';
				$table_order = $wpdb->prefix . 'wc_order_stats';

				$pagination = '';
				if (!empty($page) && !empty($limit)) {
					$page = ($page - 1) * $limit;

					$pagination = "LIMIT $page, $limit";
				}

				if (strpos($search, '#') !== false) {
					$search = explode('#', $search)[1];
					$where  = "WHERE os.order_id LIKE '%{$search}%'";
				} else {
					$where = "WHERE pm.meta_key LIKE '%_name%' AND pm.meta_value LIKE '%{$search}%' OR pm.meta_key = '_billing_phone' AND pm.meta_value LIKE '%{$search}%'";
				}

				$new_query = "SELECT os.order_id FROM {$table_order} os INNER JOIN {$table_post} pm ON os.order_id = pm.post_id {$where} GROUP BY os.order_id {$pagination}";
				$post_meta_query = $wpdb->get_results($new_query, OBJECT);

				foreach ($post_meta_query as $query) {
					$_order = wc_get_order($query->order_id);
					if (!$_order) {
						continue;
					}

					$get = $revo_loader->get_formatted_item_data($_order);

					if ($get) {
						if (!empty($status) && $status !== $get['status']) {
							continue;
						}

						if (isset($get["line_items"])) {
							for ($i = 0; $i < count($get["line_items"]); $i++) {
								$show = true;
								if ($get["line_items"][$i]["product_id"] != 0) {
									$image_id = wc_get_product($get["line_items"][$i]["product_id"])->get_image_id();
									$get["line_items"][$i]['image'] = wp_get_attachment_image_url($image_id, 'full');
								} else {
									$get["line_items"][$i]['image'] = null;
								}
							}
						}

						$result[] = $get;
					}
				}
			}
		}
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_rest_list_review($type = 'rest')
{

	$result = ['status' => 'error', 'message' => 'Login required !'];

	$cookie = pos_cek_raw('cookie');
	$limit = pos_cek_raw('limit');
	$post_id = pos_cek_raw('post_id');
	$limit = pos_cek_raw('limit');
	$page = pos_cek_raw('page');

	$args = array(
		'number'      => $limit,
		'status'      => 'approve',
		'post_status' => 'publish',
		'post_type'   => 'product',
	);

	if ($cookie) {
		$user_id = wp_validate_auth_cookie($cookie, 'logged_in');
		$args['user_id'] = $user_id;
	}

	if ($post_id) {
		$args['post_id'] = $post_id;
	}

	if ($limit) {
		$args['number'] = $limit;
	}

	if ($page) {
		$args['offset'] = $page;
	}

	$comments = get_comments($args);

	$result = [];
	foreach ($comments as $key) {
		$product = wc_get_product($key->comment_post_ID);
		$result[] = array(
			'product_id' => $key->comment_post_ID,
			'title_product' => $product->get_name(),
			'image_product' => wp_get_attachment_image_url($product->get_image_id(), 'full'),
			'content' => $key->comment_content,
			'star' => get_comment_meta($key->comment_ID, 'rating', true),
			'comment_author' => $key->comment_author,
			'user_id' => $key->user_id,
			'comment_date' => $key->comment_date,
		);
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_rest_list_notification($type = 'rest')
{

	global $wpdb;

	$result = ['status' => 'error', 'message' => 'Login required !'];

	$cookie = pos_cek_raw('cookie');

	if ($cookie) {
		$user_id = wp_validate_auth_cookie($cookie, 'logged_in');
		$data_notification = $wpdb->get_results("SELECT * FROM revo_pos_notification WHERE user_id = '$user_id' AND type = 'order'  AND is_read = 0 ORDER BY created_at DESC", OBJECT);

		$revo_loader = pos_load_flutter_mobile_app();
		$result = [];
		foreach ($data_notification as $key => $value) {
			$order_id = (int) $value->target_id;
			$imageProduct = "";
			if ($order_id && $imageProduct == "") {
				$customer_orders = wc_get_order($order_id);
				if ($customer_orders) {
					$get  = $revo_loader->get_formatted_item_data($customer_orders);
					if (isset($get["line_items"])) {
						for ($i = 0; $i < count($get["line_items"]); $i++) {
							$image_id = wc_get_product($get["line_items"][$i]["product_id"])->get_image_id();
							$imageProduct = wp_get_attachment_image_url($image_id, 'full') ?? get_logo();
						}
					}
				}
			}

			array_push($result, [
				'user_id' => (int) $value->product_id,
				'order_id' => (int) $value->target_id,
				'status' => $value->message,
				'image' => $imageProduct,
				'created_at' => $value->created_at,
			]);
		}
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_rest_read_notification($type = 'rest')
{

	global $wpdb;

	$result = ['status' => 'error', 'message' => 'Login required !'];

	$cookie = pos_cek_raw('cookie');
	$id = pos_cek_raw('id');

	if ($cookie) {
		$user_id = wp_validate_auth_cookie($cookie, 'logged_in');

		$data['is_read'] = 1;
		$wpdb->update('revo_pos_notification', $data, [
			'id' => $id,
			'user_id' => $user_id,
		]);
		if (@$wpdb->show_errors == false) {
			$result = ['status' => 'success', 'message' => 'Berhasil Dibaca !'];
		}
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_rest_disabled_service($type = 'rest')
{
	global $wpdb;

	$result = ['status' => 'error', 'message' => 'Cabut License Gagal !'];

	$query = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'license_code'";
	$get = $wpdb->get_row($query, OBJECT);
	if (!empty($get->description)) {
		$get = json_decode($get->description);
		if (!empty($get)) {
			if ($get = $get->license_code == pos_cek_raw('code')) {
				if ($get) {
					$data = pos_data_seeder('license_code');
					$wpdb->update('revo_mobile_variable', $data, ['slug' => 'license_code']);
					if (@$wpdb->show_errors == false) {
						$result = ['status' => 'success', 'message' => 'Cabut License Berhasil !'];
					}
				}
			}
		}
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_rest_list_product($type = 'rest')
{
	$revo_loader = pos_load_flutter_mobile_app();

	$result = $revo_loader->get_products();

	if ($type == 'rest') {
		echo json_encode($result);

		exit();
	} else {
		return $result;
	}
}

function get_pos_all_categories($type = 'rest')
{
	$result = [];

	$taxonomy     = 'product_cat';
	$orderby      = 'name';
	$show_count   = 0;      // 1 for yes, 0 for no
	$pad_counts   = 0;      // 1 for yes, 0 for no
	$hierarchical = 1;      // 1 for yes, 0 for no  
	$title        = '';
	$empty        = 0;

	$args = array(
		'taxonomy'     => $taxonomy,
		'orderby'      => $orderby,
		'show_count'   => $show_count,
		'pad_counts'   => $pad_counts,
		'hierarchical' => $hierarchical,
		'title_li'     => $title,
		'hide_empty'   => $empty
	);
	$all_categories = get_categories($args);
	foreach ($all_categories as $key => $cat) {
		$sub_categories = [];
		if ($cat->category_parent == 0) {
			$categories_id = $cat->term_id;

			$args_sub = $args;
			$args_sub['parent'] = $categories_id;
			$args_sub['child_of'] = 0;
			$sub_cats = get_categories($args_sub);
			if ($sub_cats) {
				$sub_categories_3 = [];
				foreach ($sub_cats as $sub_category) {
					$args_sub_3 = $args;
					$args_sub_3['parent'] = $sub_category->term_id;
					$args_sub_3['child_of'] = 0;
					$sub_cats_3 = get_categories($args_sub_3);

					if (!empty($sub_cats_3)) {
						foreach ($sub_cats_3 as $sub_category_3) {
							$sub_categories_3[] = array(
								'id' => $sub_category_3->term_id,
								'slug' => $sub_category_3->slug,
								'name' => $sub_category_3->name,
								'image' => get_image_by_term_id($sub_category_3->term_id),
								'sub_categories' => [],
							);
						}
					}
					$sub_categories[] = array(
						'id' => $sub_category->term_id,
						'slug' => $sub_category->slug,
						'name' => $sub_category->name,
						'image' => get_image_by_term_id($sub_category->term_id),
						'sub_categories' => $sub_categories_3,
					);
					$sub_categories_3 = [];
				}
			}

			$result[] = array(
				'id' => $categories_id,
				'slug' => $cat->slug,
				'name' => $cat->name,
				'image' => get_image_by_term_id($categories_id),
				'sub_categories' => $sub_categories,
			);
			$sub_categories = [];
		}
	}
	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_attributes_term($type = 'rest')
{

	global $wpdb;

	$cookie = cek_raw('cookie');

	$result = ['status' => 'error', 'message' => 'Login required !'];

	if ($cookie) {

		$user_id = wp_validate_auth_cookie($cookie, 'logged_in');

		if (!$user_id) {

			$result = ['status' => 'error', 'message' => 'User Tidak ditemukan !'];
		} else {

			global $wc_product_attributes;

			$attribute_taxonomies = wc_get_attribute_taxonomies();
			$attributes = array();
			$acnt = 0;

			if (!empty($attribute_taxonomies)) {

				$result = [];

				foreach ($attribute_taxonomies as $attribute_taxonomy) {

					$att_taxonomy = wc_attribute_taxonomy_name($attribute_taxonomy->attribute_name);

					$result[] = array(
						'attribute_id' => $attribute_taxonomy->attribute_id,
						'attribute_name' => $attribute_taxonomy->attribute_name,
						'attribute_label' => $attribute_taxonomy->attribute_label,
						'term' => get_terms(array(
							'taxonomy' => $att_taxonomy,
							'hide_empty' => false,
						))
					);
				}
			}
		}
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_users($type = 'rest')
{
	global $wpdb, $wc_points_rewards;

	$user_id  = cek_raw('user_id');
	$search   = cek_raw('search');
	$page 	  = cek_raw('page');
	$per_page = cek_raw('per_page');

	if (empty($user_id)) {
		$query_users = [];
		$query_users = $wpdb->get_results("SELECT ID FROM {$wpdb->prefix}users WHERE user_nicename LIKE '%{$search}%' OR user_email LIKE '%$search%'", OBJECT);
		if (!empty($query_users)) {
			$query_users = array_map(fn ($data) => (int) $data->ID, $query_users);
		}

		$query_usermeta = $wpdb->get_results("SELECT user_id FROM {$wpdb->prefix}usermeta WHERE meta_key IN ('first_name', 'last_name') AND meta_value LIKE '%$search%'" . (!empty($query_users) ? ' AND user_id NOT IN (' . implode(',', $query_users) . ')' : ''), OBJECT);
		if (!empty($query_usermeta)) {
			$query_usermeta = array_map(fn ($data) => (int) $data->user_id, $query_usermeta);
		}

		$args['include'] = array_merge(!empty($query_users) ? $query_users : [], !empty($query_usermeta) ? $query_usermeta : []);
	}

	if (!empty($page)) {
		$args['paged'] = $page;
	}

	if (!empty($per_page)) {
		$args['number'] = $per_page;
	}

	if (!empty($user_id)) {
		$args = [
			'include' => $user_id
		];
	}

	$search_users = get_users(array_merge(
		[
			'role__not_in' => ['administrator', 'shop_manager']
		],
		isset($args) ? $args : []
	));

	$result = [];
	foreach ($search_users as $u) {
		$customer = new WC_Customer($u->ID);

		if (!$customer) {
			continue;
		}

		$cust_data = $customer->get_data();

		foreach (['date_created', 'date_modified'] as $key) {
			$datetime = 'date_created' === $key ? get_date_from_gmt(gmdate('Y-m-d H:i:s', $cust_data[$key]->getTimestamp())) : $cust_data[$key];
			$cust_data[$key] = wc_rest_prepare_date_response($datetime, false);
			$cust_data[$key . '_gmt'] = wc_rest_prepare_date_response($datetime);
		}

		$formated_cust_data = [
			'id'                 => (int) $u->ID,
			'date_created'       => $cust_data['date_created'],
			'date_created_gmt'   => $cust_data['date_created_gmt'],
			'date_modified'      => $cust_data['date_modified'],
			'date_modified_gmt'  => $cust_data['date_modified_gmt'],
			'email'              => $cust_data['email'],
			'first_name'         => $cust_data['first_name'],
			'last_name'          => $cust_data['last_name'],
			'role'               => $cust_data['role'],
			'username'           => $cust_data['username'],
			'billing'            => $cust_data['billing'],
			'shipping'           => $cust_data['shipping'],
			'is_paying_customer' => $cust_data['is_paying_customer'],
			'avatar_url'         => $customer->get_avatar_url(),
			'meta_data'          => $cust_data['meta_data'],
		];

		if (isset($wc_points_rewards)) {
			list( $point_ratio, $monetary_value ) = explode( ':', get_option( 'wc_points_rewards_redeem_points_ratio', '' ) );

			$user_points    = WC_Points_Rewards_Manager::get_users_points($u->ID);
			$subtotal_order = 0;

			if ( $user_points > 0 ) {
				$count_ratio = ( ( $user_points / $point_ratio ) * $monetary_value );

				$subtotal_order = !empty(cek_raw('subtotal_order')) ? (int) cek_raw('subtotal_order') : 0;

				if ( $count_ratio < $subtotal_order ) {
					$subtotal_order = $count_ratio;
				}
			}

			$points = WC_Points_Rewards_Manager::calculate_points_for_discount( $subtotal_order );
			
			$formated_cust_data['point'] = [
				'point_redemption' => $points,
				'total_discount'   => number_format($subtotal_order, 2, '.', ','),
				'discount_coupon'  => $points != 0 ? 'wc_points_redemption_' . ( get_current_user_id() ?? random_int( 1000, 9999 ) ) . '_' . wp_date( 'Y_m_d_h_i' ) . "_{$points}_{$subtotal_order}" : "",
			];
		}

		if (!empty($user_id)) {
			$result = $formated_cust_data;	
			break;
		}

		$result[] = $formated_cust_data;
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_validate_cookie($type = 'rest')
{
	$cookie = cek_raw('cookie');

	$result = ['status' => 'error', 'message' => 'you must include cookie!'];

	if (!empty($cookie)) {
		$user_id = wp_validate_auth_cookie($cookie, 'logged_in');
		$user = get_userdata($user_id);

		if (!$user_id || !$user) {
			return [
				'status' => 'error',
				'message' => 'Invalid authentication cookie. Please log out and try to login again!'
			];
		}

		$result = [
			'status'  => 'success',
			'message' => $cookie
		];
	}


	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_report_stocks($type = 'rest')
{
	$cookie = pos_cek_raw('cookie');
	$filter = pos_cek_raw('filter');
	$search = pos_cek_raw('search');
	$product_id = pos_cek_raw('product_id');
	$page = pos_cek_raw('page');
	$per_page = pos_cek_raw('per_page');

	if ($cookie) {
		$user_id = wp_validate_auth_cookie($cookie, 'logged_in');

		if (!$user_id) {
			return [
				'status' => 'error',
				'message' => 'Invalid authentication cookie. Please log out and try to login again!'
			];
		}

		if (pos_cek_raw('show') != 'all') {
			$args = ['status' => 'publish'];
		}

		if (!empty($page)) {
			$args['paged'] = $page;
		}

		if (!empty($per_page)) {
			$args['posts_per_page'] = $per_page;
		}

		if (!empty($search)) {
			$args['s'] = $search;
		}

		// filter
		if (!empty($filter)) {
			switch ($filter) {
				case 'out of stock':
					$args['stock_status'] = 'outofstock';
					$args['stock_quantity'] = null;
					break;

				default:
					$where = "meta_key IN ('_manage_stock', '_stock_status', '_stock') AND meta_value != 'outofstock'";
					break;
			}

			if ($filter === 'available' || $filter === 'low stock') {
				global $wpdb;

				$raw_query = $wpdb->get_results("SELECT post_id, meta_key, meta_value FROM {$wpdb->prefix}postmeta WHERE {$where} ORDER BY post_id ASC", OBJECT);

				$query = [];
				foreach ($raw_query as $raw) {
					$query[$raw->post_id][$raw->meta_key] = $raw->meta_value;
				}

				$ids = [];
				foreach ($query as $id => $value) {
					$value = (object) $value;

					if ($filter === 'available') {
						if ($value->_manage_stock === 'yes' && (isset($value->_stock) && $value->_stock > 2)) {
							array_push($ids, $id);
						} else if ($value->_manage_stock === 'no' && (isset($value->_stock_status) && $value->_stock_status === 'instock')) {
							array_push($ids, $id);
						}
					}

					if ($filter === 'low stock') {
						if ($value->_manage_stock === 'yes' && (isset($value->_stock) && $value->_stock > 0 && $value->_stock <= 2)) {
							array_push($ids, $id);
						}
					}
				}

				if (empty($product_id) && !count($ids)) {
					return $ids;
				}

				$args['include'] = $ids;
			}
		}

		if (!empty($product_id)) {
			if (!empty($filter)) {
				unset($args['include']);
			}

			unset($args['search']);

			$args['include'] = [$product_id];
		}

		$products = wc_get_products($args);

		$wholesale_active = is_plugin_active('woocommerce-wholesale-prices/woocommerce-wholesale-prices.bootstrap.php');

		$result = [];
		foreach ($products as $product) {
			$_product = (object) $product->get_data();

			if ($_product->manage_stock) {
				$status = $_product->stock_status === 'onbackorder' ? 'out of stock' : ($_product->stock_quantity > 2 ? 'available' : ($_product->stock_quantity > 0 && $_product->stock_quantity <= 2 ? 'low stock' : 'out of stock'));
			} else {
				$status = $_product->stock_status === 'instock' ? 'available' : 'out of stock';
			}

			// type product variation
			$result_variations = [];
			$get_product_variations = $product->get_type() == 'variable' ? $product->get_available_variations() : null;
			foreach ($get_product_variations as $variation) {
				$product_variation = wc_get_product($variation['variation_id']);
				$product_variation_meta = $product_variation->get_meta_data();

				if ($product_variation->get_manage_stock()) {
					$product_variation_status = $product_variation->stock_status === 'onbackorder' ? 'out of stock' : ($product_variation->stock_quantity > 2 ? 'available' : ($product_variation->stock_quantity > 0 && $product_variation->stock_quantity <= 2 ? 'low stock' : 'out of stock'));
				} else {
					$product_variation_status = $product_variation->stock_status === 'instock' ? 'available' : 'out of stock';
				}

				$attributes = [];
				foreach ($variation['attributes'] as $attr_key => $attr_val) {
					$attr_key = explode('attribute_', $attr_key)[1];

					array_push($attributes, [
						'attribute' => strpos($attr_key, 'pa_') !== false ? str_replace('pa_', '', $attr_key) : $attr_key,
						'value' => !empty($attr_val) ? $attr_val : 'all'
					]);
				}

				$wholesale_variation_price_key = array_search('wholesale_customer_wholesale_price', array_column($product_variation_meta, 'key'));
				$wholesale_variation_price = 0;

				if ($wholesale_active && $wholesale_variation_price_key !== false) {
					$wholesale_variation_price = $product_variation_meta[$wholesale_variation_price_key]->value;
					$wholesale_variation_price = !empty($wholesale_variation_price) ? $wholesale_variation_price : 0;
				}

				array_push($result_variations, [
					'variation_id' => $variation['variation_id'],
					'attributes' => $attributes,
					'status' => $product_variation_status,
					'stock_quantity' => $product_variation->get_stock_quantity() <= 0 ? null : $product_variation->get_stock_quantity(),
					'stock_status' => $product_variation->get_stock_status(),
					'regular_price' => (float) $product_variation->get_regular_price(),
					'sale_price' => (float) $product_variation->get_sale_price(),
					'wholesale_price' => (float) $wholesale_variation_price
				]);
			}

			// wholesale simple product
			$_product_meta = $_product->meta_data;
			$wholesale_price_key = array_search('wholesale_customer_wholesale_price', array_column($_product_meta, 'key'));
			$wholesale_price = 0;

			if ($wholesale_active && $wholesale_price_key !== false) {
				$wholesale_price = $_product_meta[$wholesale_price_key]->value;
				$wholesale_price = !empty($wholesale_price) ? $wholesale_price : 0;
			}

			// image
			$image = "";
			$image_id = $product->get_image_id();

			if ($image_id) {
				$image = wp_get_attachment_image_url($image_id, 'full');
			}

			// format response
			array_push($result, [
				'id'   => $_product->id,
				'name' => $_product->name,
				'status' => $status,
				'product_status' => $_product->status,
				'type' 	 => $product->get_type(),
				'stock_status'   => $_product->stock_status,
				'stock_quantity' => $_product->stock_quantity,
				'regular_price'  => (float) $product->get_regular_price(),
				'sale_price' => (float) $product->get_sale_price(),
				'variations' => is_null($get_product_variations) ? [] : $result_variations,
				'image' => $image,
				'wholesale_price' => (float) $wholesale_price
			]);
		}
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_report_stocks_update($type = 'rest')
{
	$cookie = pos_cek_raw('cookie');
	$type = pos_cek_raw('type');
	$product_id = pos_cek_raw('product_id');
	$manage_stock = pos_cek_raw('manage_stock');
	$stock_status = pos_cek_raw('stock_status');
	$stock_quantity = pos_cek_raw('stock_quantity');
	$regular_price = pos_cek_raw('regular_price');
	$sale_price = (int)pos_cek_raw('sale_price');
	$variations = pos_cek_raw('variations');
	$wholesale  = pos_cek_raw('wholesale');
	$product_status  = pos_cek_raw('product_status');

	$result = ['status' => 'error', 'message' => 'you must include cookie !'];

	if ($cookie) {
		$user_id = wp_validate_auth_cookie($cookie, 'logged_in');

		if (!$user_id) {
			return [
				'status' => 'error',
				'message' => 'Invalid authentication cookie. Please log out and try to login again!'
			];
		}

		if (empty($product_id)) {
			return ['status' => 'error', 'message' => 'you must include product_id !'];
		}

		$wholesale_active = is_plugin_active('woocommerce-wholesale-prices/woocommerce-wholesale-prices.bootstrap.php');

		if ($type === 'simple') {
			$product = wc_get_product($product_id);

			if (!empty($regular_price)) {
				$product->set_regular_price($regular_price);
			}

			if ($sale_price >= 0) {

				if ($sale_price >= $regular_price) {
					return [
						'status' => 'error',
						'message' => 'Selling price must be less than the regular price'
					];
				}

				$product->set_sale_price($sale_price == 0 ? '' : $sale_price);
			}

			if (!empty($manage_stock)) {
				$product->set_manage_stock(true);

				if (!empty($stock_quantity)) {
					$product->set_stock_quantity($stock_quantity);
				}
			} else {
				$product->set_manage_stock(false);

				if (!empty($stock_status)) {
					$product->set_stock_status($stock_status);
				}
			}

			if (!empty($product_status)) {
				$product->set_status($product_status);
			}

			$product->save();

			if (!empty($wholesale) && $wholesale_active) {
				$wholesale_value = $wholesale->type === 'percentage' ? $product->get_regular_price() - ($product->get_regular_price() * $wholesale->value / 100) : $wholesale->value;

				update_post_meta($product_id, 'wholesale_customer_wholesale_price', $wholesale_value == 0 ? "" : $wholesale_value);
				update_post_meta($product_id, 'wholesale_customer_have_wholesale_price', $wholesale_value > 0 ? 'yes' : 'no');

				if ($wholesale->type === 'percentage') {
					update_post_meta($product_id, 'wholesale_customer_wholesale_percentage_discount', trim($wholesale->value));
				} else {
					delete_post_meta($product_id, 'wholesale_customer_wholesale_percentage_discount');
				}
			}
		} else if ($type === 'variable') {

			$product = wc_get_product($product_id);

			if (!empty($product_status)) {
				$product->set_status($product_status);
			}

			$product->save();

			foreach ($variations as $variation) {
				$product_variation = wc_get_product($variation->variation_id);

				if (!empty($variation->regular_price)) {
					$product_variation->set_regular_price($variation->regular_price);
				}

				if (!empty($variation->sale_price)) {
					if ($sale_price >= $regular_price) {
						return [
							'status' => 'error',
							'message' => 'Selling price must be less than the regular price'
						];
					}

					$product_variation->set_sale_price($variation->sale_price);
				}

				if (!empty($variation->manage_stock)) {
					$product_variation->set_manage_stock(true);

					if (!empty($variation->stock_quantity)) {
						$product_variation->set_stock_quantity($variation->stock_quantity);
					}
				} else {
					$product_variation->set_manage_stock(false);

					if (!empty($variation->stock_status)) {
						$product_variation->set_stock_status($variation->stock_status);
					}
				}

				$product_variation->save();

				if (!empty($variation->wholesale) && $wholesale_active) {
					$product_variation_wholesale = $variation->wholesale;

					$wholesale_value = $product_variation_wholesale->type === 'percentage' ? $product_variation->get_regular_price() - ($product_variation->get_regular_price() * $product_variation_wholesale->value / 100) : $product_variation_wholesale->value;

					update_post_meta($variation->variation_id, 'wholesale_customer_wholesale_price', $wholesale_value == 0 ? "" : $wholesale_value);
					update_post_meta($variation->variation_id, 'wholesale_customer_have_wholesale_price', $wholesale_value > 0 ? 'yes' : 'no');

					if ($product_variation_wholesale->type === 'percentage') {
						update_post_meta($variation->variation_id, 'wholesale_customer_wholesale_percentage_discount', trim($product_variation_wholesale->value));
					} else {
						delete_post_meta($variation->variation_id, 'wholesale_customer_wholesale_percentage_discount');
					}
				}
			}
		} else {
			return ['status' => 'error', 'message' => 'status is invalid !'];
		}

		$result = ['status' => 'success', 'message' => 'product data updated'];
	}


	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_report_orders($type = 'rest')
{
	$cookie     = pos_cek_raw('cookie');
	$sales_by   = pos_cek_raw('sales_by');
	$period     = pos_cek_raw('period');
	$start_date = pos_cek_raw('start_date');
	$end_date   = pos_cek_raw('end_date');

	$result = ['status' => 'error', 'message' => 'Login required !'];

	if ($cookie) {
		$user_id = wp_validate_auth_cookie($cookie, 'logged_in');

		if (!$user_id) {
			return [
				'status' => 'error',
				'message' => 'Invalid authentication cookie. Please log out and try to login again!'
			];
		}

		if (empty($sales_by) || empty($period)) {
			return [
				'status' => 'error',
				'message' => 'You must include sales_by and period !'
			];
		}

		if ($period === 'custom') {
			$_GET['start_date'] = $start_date;
			$_GET['end_date']   = $end_date;
		}

		$_GET['range'] = $period === 'week' ? '7day' : $period;

		require_once(WC()->plugin_path() . '/includes/admin/reports/class-wc-admin-report.php');

		switch ($sales_by) {
			case 'date':
				if ($period === 'custom') {
					$request_report = ['date_min' => $start_date, 'date_max' => $end_date];
				} else {
					$request_report = ['period' => $period];
				}

				$obj_report  = new WC_REST_Report_Sales_Controller();
				$report_main = $obj_report->get_items($request_report)->data[0];

				require_once(WC()->plugin_path() . '/includes/admin/reports/class-wc-report-sales-by-date.php');

				$obj_report2 = new WC_Report_Sales_By_Date();
				$obj_report2->calculate_current_range($_GET['range']);

				$report_data = $obj_report2->get_report_data();

				$max_sales = 0;
				$max_item = 0;

				foreach ($report_main['totals'] as $key_by_date => $report_by_date) {

					if ($report_by_date['sales'] > $max_sales) {
						$max_sales = $report_by_date['sales'];
					}

					if ($report_by_date['items'] > $max_item) {
						$max_item = $report_by_date['items'];
					}
				}

				$loop_y_item = (ceil($max_item / 10) * 10) / 5;

				$formated_value = 1;

				if (strlen((int) $max_sales) > 3) {
					$formated_value = pow(10, strlen((int)$max_sales) - 3);
				}

				$reformat_totals = [];
				foreach ($report_main['totals'] as $key_by_date => $report_by_date) {
					$report_by_date['net_sales'] = $report_by_date['sales'] - $report_by_date['shipping'] - $report_by_date['tax'];
					$report_by_date['net_sales_formated'] = $report_by_date['net_sales'] / $formated_value;
					$report_by_date['sales_formated'] = $report_by_date['sales'] / $formated_value;
					$report_by_date['tax_formated'] = $report_by_date['tax'] / $formated_value;
					$report_by_date['shipping_formated'] = $report_by_date['shipping'] / $formated_value;
					$report_by_date['discount_formated'] = $report_by_date['discount'] / $formated_value;
					$report_by_date['date'] = $key_by_date;

					array_push($reformat_totals, $report_by_date);
				}

				$response = new stdClass;
				$response->total_sales 	     	 = $report_main['total_sales'];
				$response->average_gross     	 = $report_data->average_total_sales;
				$response->net_sales 	     	 = $report_main['net_sales'];
				$response->average_sales     	 = $report_main['average_sales'];
				$response->total_orders      	 = $report_main['total_orders'];
				$response->total_items 	     	 = $report_main['total_items'];
				$response->total_tax 	     	 = $report_main['total_tax'];
				$response->total_shipping    	 = $report_main['total_shipping'];
				$response->total_refunds     	 = $report_main['total_refunds'];
				$response->refunded_order_items  = $report_data->refunded_order_items;
				$response->total_refunded_orders = $report_data->total_refunded_orders;
				$response->total_discount   	 = $report_main['total_discount'];
				$response->totals_grouped_by	 = $report_main['totals_grouped_by'];
				$response->max_y		     	 = ceil($max_sales / $formated_value) <= 0 ? 10 : ceil($max_sales / $formated_value);
				$response->loop_y	     		 = ceil($max_sales / $formated_value / 5) <= 0 ? 2 : ceil($max_sales / $formated_value / 5);
				$response->formated_value		 = $formated_value;
				$response->loop_y_item		 	 = $loop_y_item;
				$response->totals				 = $reformat_totals;
				$response->total_customers  	 = $report_main['total_customers'];
				break;

			case 'product':
				$step = trim(pos_cek_raw('step'));
				$_GET['product_ids'] = pos_cek_raw('product_id');

				if (empty($step) && empty(pos_cek_raw('product_id'))) {
					$response = [
						[
							'title' => 'Top Sellers',
							'slug'  => 'top_sellers'
						],
						[
							'title' => 'Top Freebies',
							'slug'  => 'top_freebies'
						],
						[
							'title' => 'Top Earners',
							'slug'  => 'top_earners'
						]
					];

					break;
				}

				if (!in_array($step, ["", 'top_sellers', 'top_freebies', 'top_earners'])) {
					$response = [
						'status' => 'error',
						'message' => 'invalid step !'
					];

					break;
				}

				require_once(WC()->plugin_path() . '/includes/admin/reports/class-wc-report-sales-by-product.php');

				$obj_report = new WC_Report_Sales_By_Product();
				$obj_report->calculate_current_range($_GET['range']);

				if (empty($_GET['product_ids'])) {
					$response = [];

					if ($step === 'top_sellers') {
						$products = $obj_report->get_order_report_data([
							'data' => [
								'_product_id' => [
									'type'            => 'order_item_meta',
									'order_item_type' => 'line_item',
									'function'        => '',
									'name'            => 'product_id',
								],
								'_qty' => [
									'type'            => 'order_item_meta',
									'order_item_type' => 'line_item',
									'function'        => 'SUM',
									'name'            => 'order_item_qty',
								]
							],
							'order_by'     => 'order_item_qty DESC',
							'group_by'     => 'product_id',
							'limit'        => 10,
							'query_type'   => 'get_results',
							'filter_range' => true,
							'order_status' => array('completed', 'processing', 'on-hold', 'refunded'),
						]);
					} else if ($step === 'top_freebies') {
						$products = $obj_report->get_order_report_data([
							'data' => [
								'_product_id' => [
									'type'            => 'order_item_meta',
									'order_item_type' => 'line_item',
									'function'        => '',
									'name'            => 'product_id',
								],
								'_qty' => [
									'type'            => 'order_item_meta',
									'order_item_type' => 'line_item',
									'function'        => 'SUM',
									'name'            => 'order_item_qty',
								],
							],
							'where_meta' => [
								[
									'type'       => 'order_item_meta',
									'meta_key'   => '_line_subtotal',
									'meta_value' => '0',
									'operator'   => '=',
								]
							],
							'order_by'     => 'order_item_qty DESC',
							'group_by'     => 'product_id',
							'limit'        => 10,
							'query_type'   => 'get_results',
							'filter_range' => true,
						]);
					} else {
						$products = $obj_report->get_order_report_data([
							'data' => [
								'_product_id' => [
									'type'            => 'order_item_meta',
									'order_item_type' => 'line_item',
									'function'        => '',
									'name'            => 'product_id',
								],
								'_line_total' => [
									'type'            => 'order_item_meta',
									'order_item_type' => 'line_item',
									'function'        => 'SUM',
									'name'            => 'order_item_total',
								]
							],
							'order_by'     => 'order_item_total DESC',
							'group_by'     => 'product_id',
							'limit'        => 10,
							'query_type'   => 'get_results',
							'filter_range' => true,
							'order_status' => array('completed', 'processing', 'on-hold', 'refunded'),
						]);
					}

					foreach ($products as $product) {
						$_product = wc_get_product($product->product_id);

						if ($_product) {
							$image = '';
							if ($_product->get_image_id()) {
								$image = wp_get_attachment_image_url($_product->get_image_id(), 'thumbnail');
							}

							array_push($response, [
								'product_id'   => $product->product_id,
								'product_name' => $_product->get_title(),
								'image'		   => $image,
								'total'		   => $step !== 'top_earners' ? $product->order_item_qty : $product->order_item_total
							]);
						}
					}
				} else {
					$product = wc_get_product($_GET['product_ids']);

					$total_sales = $obj_report->get_order_report_data([
						'data' => [
							'_line_total' => [
								'type'            => 'order_item_meta',
								'order_item_type' => 'line_item',
								'function'        => 'SUM',
								'name'            => 'order_item_amount',
							]
						],
						'where_meta' => [
							'relation' => 'OR',
							[
								'type'       => 'order_item_meta',
								'meta_key'   => array('_product_id', '_variation_id'), // phpcs:ignore WordPress.DB.SlowDBQuery.slow_db_query_meta_key
								'meta_value' => $obj_report->product_ids, // phpcs:ignore WordPress.DB.SlowDBQuery.slow_db_query_meta_value
								'operator'   => 'IN',
							]
						],
						'query_type'   => 'get_var',
						'filter_range' => true,
						'order_status' => array('completed', 'processing', 'on-hold', 'refunded'),
					]);

					$total_items = absint(
						$obj_report->get_order_report_data([
							'data' => [
								'_qty' => [
									'type'            => 'order_item_meta',
									'order_item_type' => 'line_item',
									'function'        => 'SUM',
									'name'            => 'order_item_count',
								]
							],
							'where_meta' => [
								'relation' => 'OR',
								[
									'type'       => 'order_item_meta',
									'meta_key'   => array('_product_id', '_variation_id'), // phpcs:ignore WordPress.DB.SlowDBQuery.slow_db_query_meta_key
									'meta_value' => $obj_report->product_ids, // phpcs:ignore WordPress.DB.SlowDBQuery.slow_db_query_meta_value
									'operator'   => 'IN',
								]
							],
							'query_type'   => 'get_var',
							'filter_range' => true,
							'order_status' => array('completed', 'processing', 'on-hold', 'refunded')
						])
					);

					// get orders and dates in range
					$order_item_counts = $obj_report->get_order_report_data([
						'data' => [
							'_qty' => [
								'type'            => 'order_item_meta',
								'order_item_type' => 'line_item',
								'function'        => 'SUM',
								'name'            => 'order_item_count',
							],
							'post_date' => [
								'type'     => 'post_data',
								'function' => '',
								'name'     => 'post_date',
							],
							'_product_id' => [
								'type'            => 'order_item_meta',
								'order_item_type' => 'line_item',
								'function'        => '',
								'name'            => 'product_id',
							]
						],
						'where_meta' => [
							'relation' => 'OR',
							[
								'type'       => 'order_item_meta',
								'meta_key'   => array('_product_id', '_variation_id'),
								'meta_value' => $obj_report->product_ids,
								'operator'   => 'IN',
							]
						],
						'group_by'     => 'product_id,' . $obj_report->group_by_query,
						'order_by'     => 'post_date ASC',
						'query_type'   => 'get_results',
						'filter_range' => true,
						'order_status' => array('completed', 'processing', 'on-hold', 'refunded'),
					]);

					$order_item_amounts = $obj_report->get_order_report_data([
						'data' => [
							'_line_total' => [
								'type'            => 'order_item_meta',
								'order_item_type' => 'line_item',
								'function'        => 'SUM',
								'name'            => 'order_item_amount',
							],
							'post_date' => [
								'type'     => 'post_data',
								'function' => '',
								'name'     => 'post_date',
							],
							'_product_id' => [
								'type'            => 'order_item_meta',
								'order_item_type' => 'line_item',
								'function'        => '',
								'name'            => 'product_id',
							]
						],
						'where_meta' => [
							'relation' => 'OR',
							[
								'type'       => 'order_item_meta',
								'meta_key'   => array('_product_id', '_variation_id'), // phpcs:ignore WordPress.DB.SlowDBQuery.slow_db_query_meta_key
								'meta_value' => $obj_report->product_ids, // phpcs:ignore WordPress.DB.SlowDBQuery.slow_db_query_meta_value
								'operator'   => 'IN',
							]
						],
						'group_by'     => 'product_id, ' . $obj_report->group_by_query,
						'order_by'     => 'post_date ASC',
						'query_type'   => 'get_results',
						'filter_range' => true,
						'order_status' => array('completed', 'processing', 'on-hold', 'refunded'),
					]);

					// prepare data for report
					$order_item_counts  = $obj_report->prepare_chart_data($order_item_counts, 'post_date', 'order_item_count', $obj_report->chart_interval, $obj_report->start_date, $obj_report->chart_groupby);
					$order_item_amounts = $obj_report->prepare_chart_data($order_item_amounts, 'post_date', 'order_item_amount', $obj_report->chart_interval, $obj_report->start_date, $obj_report->chart_groupby);

					$max_item  = 0;
					$max_sales = 0;

					$res_order_items = [];
					foreach ($order_item_counts as $key => $order_item) {
						if ($order_item_amounts[$key][1] > $max_sales) {
							$max_sales = $order_item_amounts[$key][1];
						}

						if ($order_item[1] > $max_item) {
							$max_item = $order_item[1];
						}

						array_push($res_order_items, [
							'date'  => $obj_report->chart_groupby === 'day' ? date('Y-m-d', substr($key, 0, -3)) : date('Y-m', substr($key, 0, -3)),
							'sales' => $order_item_amounts[$key][1],
							'items' => $order_item[1]
						]);
					}

					$formated_value = 1;

					if (strlen((int) $max_sales) > 3) {
						$formated_value = pow(10, strlen((int) $max_sales) - 3);
					}

					$reformat_totals = [];
					foreach ($res_order_items as $res_order_item) {
						$res_order_item['sales_formated'] = $res_order_item['sales'] / $formated_value;

						array_push($reformat_totals, $res_order_item);
					}

					$response = [
						'product_id'     => $product->get_id(),
						'product_name'   => $product->get_title(),
						'product_price'	 => $product->get_price(),
						'image'		     => $product->get_image_id() ? wp_get_attachment_image_url($product->get_image_id(), 'thumbnail') : '',
						'total_sales'    => $total_sales ?? 0,
						'total_items'    => $total_items ?? 0,
						'max_y'		     => ceil($max_sales / $formated_value) <= 0 ? 10 : ceil($max_sales / $formated_value),
						'loop_y'	     => ceil($max_sales / $formated_value / 5) <= 0 ? 2 : ceil($max_sales / $formated_value / 5),
						'formated_value' => $formated_value,
						'totals' 	     => $reformat_totals
					];
				}
				break;

			case 'category':
				if (!empty(pos_cek_raw('category_id'))) {
					$_GET['show_categories'] = pos_cek_raw('category_id');
				} else {
					$_GET['show_categories'] = get_terms(['taxonomy' => 'product_cat', 'fields' => 'ids']);
				}

				require_once(WC()->plugin_path() . '/includes/admin/reports/class-wc-report-sales-by-category.php');

				$obj_report = new WC_Report_Sales_By_Category();
				$obj_report->calculate_current_range($_GET['range']);

				// get item sales data
				$item_sales = [];
				$item_sales_and_times = [];

				if (!empty($obj_report->show_categories)) {
					$order_items = $obj_report->get_order_report_data([
						'data' => [
							'_product_id' => [
								'type'            => 'order_item_meta',
								'order_item_type' => 'line_item',
								'function'        => '',
								'name'            => 'product_id',
							],
							'_line_total' => [
								'type'            => 'order_item_meta',
								'order_item_type' => 'line_item',
								'function'        => 'SUM',
								'name'            => 'order_item_amount',
							],
							'post_date' => [
								'type'     => 'post_data',
								'function' => '',
								'name'     => 'post_date',
							],
						],
						'group_by'     => 'ID, product_id, post_date',
						'query_type'   => 'get_results',
						'filter_range' => true,
					]);

					if (is_array($order_items)) {
						foreach ($order_items as $order_item) {
							switch ($obj_report->chart_groupby) {
								case 'day':
									$time = strtotime(gmdate('Ymd', strtotime($order_item->post_date))) * 1000;
									break;
								case 'month':
								default:
									$time = strtotime(gmdate('Ym', strtotime($order_item->post_date)) . '01') * 1000;
									break;
							}

							$item_sales_and_times[$time][$order_item->product_id] = isset($item_sales_and_times[$time][$order_item->product_id]) ? $item_sales_and_times[$time][$order_item->product_id] + $order_item->order_item_amount : $order_item->order_item_amount;
							$item_sales[$order_item->product_id] = isset($item_sales[$order_item->product_id]) ? $item_sales[$order_item->product_id] + $order_item->order_item_amount : $order_item->order_item_amount;
						}
					}
				}

				$raw_response  = [];
				$max_sales = 0;
				foreach ($obj_report->show_categories as $category) {
					$total       = 0;
					$category    = get_term($category, 'product_cat');
					$product_ids = $obj_report->get_products_in_category($category->term_id);

					foreach ($product_ids as $id) {
						if (isset($item_sales[$id])) {
							$total += $item_sales[$id];
						}
					}

					$image = '';
					$thumbnail_id = get_term_meta($category->term_id, 'thumbnail_id', true);
					if ($thumbnail_id) {
						$image = wp_get_attachment_url($thumbnail_id);
					}

					if ($total > $max_sales) {
						$max_sales = $total;
					}

					array_push($raw_response, [
						'category_id'	 => $category->term_id,
						'category_name'  => $category->name,
						'count_products' => $category->count,
						'image'			 => $image,
						'total_sales'    => $total
					]);
				}

				$formated_value = 1;
				if (strlen((int) $max_sales) > 3) {
					$formated_value = pow(10, strlen((int) $max_sales) - 3);
				}

				$response = [];
				foreach ($raw_response as $key => $res) {
					$res['total_sales_formated'] = $res['total_sales'] / $formated_value;
					array_push($response, $res);
				}
				break;

			case 'coupon':
				$_GET['coupon_codes'] = pos_cek_raw('coupon_code');

				require_once(WC()->plugin_path() . '/includes/admin/reports/class-wc-report-coupon-usage.php');

				$obj_report = new WC_Report_Coupon_Usage();
				$obj_report->calculate_current_range($_GET['range']);

				$total_discount_query = [
					'data' => [
						'discount_amount' => [
							'type'            => 'order_item_meta',
							'order_item_type' => 'coupon',
							'function'        => 'SUM',
							'name'            => 'discount_amount',
						]
					],
					'where' => [
						[
							'key'      => 'order_item_type',
							'value'    => 'coupon',
							'operator' => '=',
						]
					],
					'query_type'   => 'get_var',
					'filter_range' => true,
					'order_types'  => wc_get_order_types('order-count')
				];

				$total_coupons_query = [
					'data' => [
						'order_item_id' => [
							'type'            => 'order_item',
							'order_item_type' => 'coupon',
							'function'        => 'COUNT',
							'name'            => 'order_coupon_count',
						],
					],
					'where' => [
						[
							'key'      => 'order_item_type',
							'value'    => 'coupon',
							'operator' => '=',
						]
					],
					'query_type'   => 'get_var',
					'filter_range' => true,
					'order_types'  => wc_get_order_types('order-count')
				];

				if (!empty($obj_report->coupon_codes)) {
					$coupon_code_query = array(
						'type'     => 'order_item',
						'key'      => 'order_item_name',
						'value'    => $obj_report->coupon_codes,
						'operator' => 'IN',
					);

					$total_discount_query['where'][] = $coupon_code_query;
					$total_coupons_query['where'][]  = $coupon_code_query;
				}

				$total_discount = $obj_report->get_order_report_data($total_discount_query);
				$total_coupons  = absint($obj_report->get_order_report_data($total_coupons_query));

				// get orders and dates in range
				$order_coupon_counts_query = [
					'data' => [
						'order_item_name' => [
							'type'            => 'order_item',
							'order_item_type' => 'coupon',
							'function'        => 'COUNT',
							'name'            => 'order_coupon_count',
						],
						'post_date' => [
							'type'     => 'post_data',
							'function' => '',
							'name'     => 'post_date',
						]
					],
					'where' => [
						[
							'key'      => 'order_item_type',
							'value'    => 'coupon',
							'operator' => '=',
						]
					],
					'group_by'     => $obj_report->group_by_query,
					'order_by'     => 'post_date ASC',
					'query_type'   => 'get_results',
					'filter_range' => true,
					'order_types'  => wc_get_order_types('order-count')
				];

				$order_discount_amounts_query = [
					'data' => [
						'discount_amount' => [
							'type'            => 'order_item_meta',
							'order_item_type' => 'coupon',
							'function'        => 'SUM',
							'name'            => 'discount_amount',
						],
						'post_date' => [
							'type'     => 'post_data',
							'function' => '',
							'name'     => 'post_date',
						]
					],
					'where' => [
						[
							'key'      => 'order_item_type',
							'value'    => 'coupon',
							'operator' => '=',
						]
					],
					'group_by'     => $obj_report->group_by_query . ', order_item_name',
					'order_by'     => 'post_date ASC',
					'query_type'   => 'get_results',
					'filter_range' => true,
					'order_types'  => wc_get_order_types('order-count'),
				];

				if (!empty($obj_report->coupon_codes)) {
					$coupon_code_query = array(
						'type'     => 'order_item',
						'key'      => 'order_item_name',
						'value'    => $obj_report->coupon_codes,
						'operator' => 'IN',
					);

					$order_coupon_counts_query['where'][]    = $coupon_code_query;
					$order_discount_amounts_query['where'][] = $coupon_code_query;
				}

				$order_coupon_counts    = $obj_report->get_order_report_data($order_coupon_counts_query);
				$order_discount_amounts = $obj_report->get_order_report_data($order_discount_amounts_query);

				// prepare data for report.
				$order_coupon_counts    = $obj_report->prepare_chart_data($order_coupon_counts, 'post_date', 'order_coupon_count', $obj_report->chart_interval, $obj_report->start_date, $obj_report->chart_groupby);
				$order_discount_amounts = $obj_report->prepare_chart_data($order_discount_amounts, 'post_date', 'discount_amount', $obj_report->chart_interval, $obj_report->start_date, $obj_report->chart_groupby);

				$max_item  = 0;
				$max_sales = 0;

				$res_coupons_item = [];
				foreach ($order_coupon_counts as $key => $order_item) {
					if ($order_discount_amounts[$key][1] > $max_sales) {
						$max_sales = $order_discount_amounts[$key][1];
					}

					if ($order_item[1] > $max_item) {
						$max_item = $order_item[1];
					}

					array_push($res_coupons_item, [
						'date' => $obj_report->chart_groupby === 'day' ? date('Y-m-d', substr($key, 0, -3)) : date('Y-m', substr($key, 0, -3)),
						'total_discount' => $order_discount_amounts[$key][1],
						'total_used' => $order_item[1]
					]);
				}

				$formated_value = 1;

				if (strlen((int) $max_sales) > 3) {
					$formated_value = pow(10, strlen((int) $max_sales) - 3);
				}

				$reformat_totals = [];
				foreach ($res_coupons_item as $value) {
					$value['total_discount_formated'] = $value['total_discount'] / $formated_value;
					array_push($reformat_totals, $value);
				}

				$loop_y_item = (ceil($max_item / 10) * 10) / 5;

				$response = [
					'total_discount' => $total_discount ?? 0,
					'coupons_used'	 => $total_coupons ?? 0,
					'coupon_code'	 => pos_cek_raw('coupon_code'),
					'max_y'		     => ceil($max_sales / $formated_value) <= 0 ? 10 : ceil($max_sales / $formated_value),
					'loop_y'	     => ceil($max_sales / $formated_value / 5) <= 0 ? 2 : ceil($max_sales / $formated_value / 5),
					'loop_y_item'	 => $loop_y_item == 0 ? 1 : $loop_y_item,
					'formated_value' => $formated_value,
					'totals'		 => $reformat_totals
				];
				break;

			default:
				$response = [
					'status'  => 'error',
					'message' => 'format sales_by is invalid !'
				];
				break;
		}

		$result = $response;
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_shipping_methods($type = 'rest')
{
	$user_id  = pos_cek_raw('user_id');
	$line_items = pos_cek_raw('line_items');

	if (empty($user_id) || empty($line_items)) {
		return [
			'status' => 'error',
			'message' => 'you must include user_id and line_items !'
		];
	}

	$user = get_userdata($user_id);
	if (!$user) {
		return [
			'status' => 'error',
			'message' => 'user not found !'
		];
	}

	wp_set_current_user($user_id, $user->user_login);
	wp_set_auth_cookie($user_id);

	// define products
	$cart_items = [];
	foreach ($line_items as $p) {
		$variation = [];

		foreach ($p->variation as $value) {
			$variation['attribute_' . $value->column_name] = $value->value;
		}

		$cart_items[] = [
			'product_id' => $p->product_id,
			'quantity' => $p->quantity,
			'variation_id' => $p->variation_id,
			'variation' => $variation
		];
	}

	$result = [];
	if (!empty($cart_items)) {
		// line items
		$line_items = [];
		$group_line_items = [];

		$subtotal_order = 0;
		$subtotal_order_with_coupon = 0;

		foreach ($cart_items as $p) {
			$p = (array) $p;

			$product_id   = $p['product_id'];
			$variation_id = $p['variation_id'];

			$product = wc_get_product((is_null($p['variation_id']) || $p['variation_id'] === 0) ? $product_id : $variation_id);

			if (!$product) {
				return [
					'status' => 'error',
					'message' => 'Product not found !'
				];
			}

			$price = $product->get_price();
			$image = wp_get_attachment_url($product->get_image_id(), 'full');

			if (!is_null($variation_id) && $variation_id !== 0) {
				$attribute = "";

				$raw_attributes = $p['variation'];

				foreach ($raw_attributes as $raw_key => $raw) {
					$attribute .= !empty($raw) ? $raw : '';
					$attribute .= array_key_last($raw_attributes) !== $raw_key ? ' - ' : '';
				}
			} else {
				$attribute = "";
			}

			// coupon code
			if (!empty($coupon_code)) {
				$coupon_free_shipping = false;

				$coupon = new WC_Coupon($coupon_code);
				$coupon_data = $coupon->get_data();

				if ($coupon_data['id'] != 0) {
					$coupon_amount = $coupon_data['amount'];
					$discount_type = $coupon_data['discount_type'];

					if ($discount_type === 'percent') {
						$coupon_price = ($p['quantity'] * $price) - (($price * $p['quantity']) * $coupon_amount / 100);
					} else if ($discount_type === 'fixed_product') {
						$coupon_price = ($p['quantity'] * $price) - $coupon_amount * $p['quantity'];
					}

					$subtotal_order_with_coupon += $coupon_price;

					if ($coupon_data['free_shipping']) {
						$coupon_free_shipping = true;
					}
				}
			}

			$data = [
				'product_id' => $product->get_id(),
				'name'  => $product->get_name(),
				'sku'   => $product->get_sku(),
				'price' => $price,
				'quantity' => (int) $p['quantity'],
				'variation_id' => $p['variation_id'],
				'variation' => $attribute,
				'subtotal_order' => (float) number_format($p['quantity'] * $price, '2', '.', ''),
				'image' => $image ? $image : '',
				'weight' => ((int) $product->get_weight() * (int) $p['quantity']) / 1000,
				'shipping_class_id' => $product->get_shipping_class_id(),
				'subtotal_coupon' => $coupon_price,
				'data' => $product
			];

			array_push($line_items, $data);
			$group_line_items[$product->get_shipping_class_id()][] = $data;

			$subtotal_order += ($p['quantity'] * $price);
		}

		if (!empty($coupon_code) && $discount_type === 'fixed_cart') {
			$subtotal_order_with_coupon = $subtotal_order - $coupon_amount;
		}

        // shipping zones
		$data_store    = WC_Data_Store::load( 'shipping-zone' );
		$raw_zones     = $data_store->get_zones();
		$shipping_zone = null;

		foreach ( $raw_zones as $raw_zone ) {
					$zone      = new WC_Shipping_Zone( $raw_zone );
					$zone_data = $zone->get_data();

					$billing_country  = $user_id === 0 ? $country_id : get_user_meta( $user_id, 'billing_country' )[0];
					$billing_state    = $user_id === 0 ? $state_id : get_user_meta( $user_id, 'billing_state' )[0];
					$billing_postcode = $user_id === 0 ? $postcode : get_user_meta( $user_id, 'billing_postcode' )[0];

					if ( count( $zone_data['zone_locations'] ) >= 1 ) {
						foreach ( $zone_data['zone_locations'] as $location ) {
							if ( $location->code === $billing_country . ':' . $billing_state ) {
								$shipping_zone = $zone;
							} else if ( $location->code === $billing_country ) {
								$shipping_zone = $zone;
							} else if ( $location->type === 'postcode' && $location->code === $billing_postcode ) {
								$shipping_zone = $zone;
							}

							if ( ! is_null( $shipping_zone ) ) {
								break;
							}
						}
					} else {
						$shipping_zone = $zone;
					}

					if ( ! is_null( $shipping_zone ) ) {
						break;
					}
				}

		if ( is_null( $shipping_zone ) ) {
					$shipping_zone = new WC_Shipping_Zone( 0 );
				}

		// shipping methods
		$result           = [];
		$shipping_methods = $shipping_zone->get_shipping_methods();

		foreach ( $shipping_methods as $shipping_method ) {
					if ( $shipping_method->enabled === 'no' ) {
						continue;
					}

					$rate_id     = $shipping_method->get_rate_id();
					$instance_id = end( explode( ':', $rate_id ) );

					$method_title = $shipping_method->get_title();
					$method_title = empty( $method_title ) ? $shipping_method->get_method_title() : $method_title;

					$data       = $shipping_method->instance_settings;
					$total_cost = 0;

					$shipping_package = [
						'contents'        => ( function ( $cart_items ) {
							foreach ( $cart_items as $cart ) {
								$cart['data']           = wc_get_product( $cart['variation_id'] != null ? $cart['variation_id'] : $cart['product_id'] );
								$result[ $cart['key'] ] = $cart;
							}

							return $result;
						} )( $cart_items ),
						'applied_coupons' => ! empty( $coupon_code ) ? [ $coupon_code ] : [],
						'contents_cost'   => $subtotal_order,
						'user'            => [
							'ID' => $user_id
						],
						'destination'     => [
							'country'   => ! empty( $cookie ) ? get_user_meta( $user_id, 'billing_country' )[0] : $country_id,
							'state'     => ! empty( $cookie ) ? get_user_meta( $user_id, 'billing_state' )[0] : $state_id,
							'city'      => ! empty( $cookie ) ? get_user_meta( $user_id, 'billing_city' )[0] : $city,
							'postcode'  => ! empty( $cookie ) ? get_user_meta( $user_id, 'billing_postcode' )[0] : $postcode,
							'address'   => ! empty( $cookie ) ? get_user_meta( $user_id, 'billing_address_1' )[0] : "$city, $subdistrict $postcode",
							'address_1' => ! empty( $cookie ) ? get_user_meta( $user_id, 'billing_address_1' )[0] : "$city, $subdistrict $postcode",
							'address_2' => ! empty( $cookie ) ? get_user_meta( $user_id, 'billing_address_2' )[0] : $subdistrict,
						],
						'cart_subtotal'   => $subtotal_order,
						'rates'           => []
					];

					if ( ! in_array( explode( ':', $rate_id )[0], [
						'flat_rate',
						'local_pickup',
						'free_shipping',
						'woongkir',
						'wcfmmp_product_shipping_by_zone'
					] ) ) {
						continue;
					} elseif ( $method_title === 'Woongkir' && is_plugin_active( 'woongkir/woongkir.php' ) ) {
						$woongkir_class = new Woongkir_Shipping_Method( $instance_id );
						$woongkir_class->calculate_shipping( $shipping_package );

						foreach ( $woongkir_class->rates as $value ) {
							$data = $value->meta_data['_woongkir_data'];

							if ( $value->get_shipping_tax() !== null ) {
								$data['cost'] += $value->get_shipping_tax();
							}

							$data['cost']         = (int) $data['cost'];
							$data['method_title'] = strtoupper( $data['courier'] . ' - ' . $data['service'] );

							$woongkir_services[] = $data;
						}

						array_push( $result, [
							'method_id'    => $rate_id,
							'method_title' => 'other_courier',
							'cost'         => 0,
							'couriers'     => $woongkir_services ?? [],
						] );

						continue;
					} else {
						// free shipping
						if ( $shipping_method instanceof WC_Shipping_Free_Shipping ) {
							$requires = $data['requires'];

							if ( $data['ignore_discounts'] === 'no' && ! empty( $coupon_code ) ) {
								$subtotal_order = $subtotal_order_with_coupon;
							}

							if ( $requires === 'coupon' && ! $coupon_free_shipping ) {
								continue;
							} elseif ( $requires === 'min_amount' && $subtotal_order < $data['min_amount'] ) {
								continue;
							} elseif ( $requires === 'either' && ( $subtotal_order >= $data['min_amount'] == false ) && ! $coupon_free_shipping ) {
								continue;
							} elseif ( $requires === 'both' ) {
								if ( ( $subtotal_order < $data['min_amount'] && ! $coupon_free_shipping ) || ( $subtotal_order < $data['min_amount'] && $coupon_free_shipping ) || ( $subtotal_order >= $data['min_amount'] && ! $coupon_free_shipping ) ) {
									continue;
								}
							}
						} // flat rate
						elseif ( $shipping_method instanceof WC_Shipping_Flat_Rate ) {
							$shipping_handler = new WC_Shipping_Flat_Rate( $instance_id );
							$shipping_handler->calculate_shipping( $shipping_package );

							foreach ( $shipping_handler->rates as $rate ) {
								$tax = 0;

								if ( ! empty( $rate->taxes ) ) {
									$tax = array_sum( $rate->taxes );
								}

								$total_cost = $rate->cost + $tax;
							}
						} // local pickup
						elseif ( $shipping_method instanceof WC_Shipping_Local_Pickup ) {
							$shipping_handler = new WC_Shipping_Local_Pickup( $instance_id );
							$shipping_handler->calculate_shipping( $shipping_package );

							foreach ( $shipping_handler->rates as $rate ) {
								$tax = 0;

								if ( ! empty( $rate->taxes ) ) {
									$tax = array_sum( $rate->taxes );
								}

								$total_cost = $rate->cost + $tax;
							}
						}
					}

					array_push( $result, [
						'method_id'    => $rate_id,
						'method_title' => $method_title,
						'cost'         => (int) $total_cost,
						'couriers'     => []
					] );
				}
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_product_check_price($type = 'rest')
{
	$user_id  = cek_raw('user_id');
	$line_items = cek_raw('line_items');

	if (empty($user_id) || empty($line_items)) {
		return [
			'status' => 'error',
			'message' => 'you must include user_id and line_items !'
		];
	}

	$user = get_userdata($user_id);
	if (!$user) {
		return [
			'status' => 'error',
			'message' => 'user not found !'
		];
	}

	$wholesale_active = is_plugin_active('woocommerce-wholesale-prices/woocommerce-wholesale-prices.bootstrap.php');

	foreach ($line_items as $line_item) {
		$product = wc_get_product(is_null($line_item->variation_id) || empty($line_item->variation_id) ? $line_item->product_id : $line_item->variation_id);

		if (!$product) {
			return ['status' => 'error', 'message' => 'product not found !'];
		}

		$price = $product->get_price();

		if ($wholesale_active) {
			$wholesale_price = get_post_meta($product->get_id(), 'wholesale_customer_wholesale_price', true);

			if (!empty($wholesale_price) && in_array('wholesale_customer', $user->roles)) {
				$price = $wholesale_price;
			}
		}

		$result[] = [
			'product_id' => $line_item->product_id,
			'variation_id' => $line_item->variation_id,
			'price' => (float)$price,
		];
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_apply_coupon($type = 'rest')
{
	$user_id  = pos_cek_raw('user_id');
	$products = pos_cek_raw('line_items');
	$coupon_code = pos_cek_raw('coupon_code');

	if (empty($coupon_code)) {
		return [
			'status' => 'error',
			'message' => 'Please enter a coupon code.'
		];
	}

	if (empty($user_id) || empty($products)) {
		return [
			'status' => 'error',
			'message' => 'You must include user_id and line_items !'
		];
	}

	$user = get_user_by('id', $user_id);
	if (!$user) {
		return [
			'status' => 'error',
			'message' => 'User not found !'
		];
	}

	wp_set_current_user($user_id, $user->user_login);
	wp_set_auth_cookie($user_id);

	$c = new WC_Coupon($coupon_code);
	$coupon = $c->get_data();

	if (!empty($coupon['email_restrictions'])) {
		$email_restrictions = substr($coupon['email_restrictions'][0], 0, 1);
		$email_user = $user->data->user_email;

		$email_restric = false;

		if ($email_restrictions == "*") {
			$email_allowed = str_replace($email_restrictions, "", $coupon['email_restrictions'][0]);

			$count_email_char = strlen($email_allowed);

			if (substr($email_user, -$count_email_char) == $email_allowed) {
				$email_restric = true;
			}
		} elseif ($email_user == $coupon['email_restrictions'][0]) {
			$email_restric = true;
		}
	} else {
		$email_restric = true;
	}

	if ($email_restric) {
		$product_ids = [];
		foreach ($products as $product_item) {
			$product_ids[] = $product_item->product_id;
		}

		usort($products, function ($a, $b) {
			return $a->product_id - $b->product_id;
		});

		$get_products = wc_get_products([
			'status'  => 'publish',
			'include' => $product_ids,
			'orderby' => 'id',
			'order'   => 'ASC',
			'limit'   => -1
		]);

		$wc_discount_class = new WC_Discounts('api');
		$items = [];

		foreach ($get_products as $key => $product) {
			if (!is_null($products[$key]->variation_id) && $products[$key]->variation_id > 0) {
				$variable_product = wc_get_product($products[$key]->variation_id);
				$price = $variable_product->get_price();
			} else {
				$price = $product->get_price();
			}

			$item                = new stdClass();
			$item->key           = $product->get_id();
			$item->object        = $product;
			$item->product       = $product;
			$item->quantity      = $products[$key]->quantity;
			$item->price         = wc_add_number_precision_deep((float) $price * (float) $item->quantity);

			array_push($items, $item);
		}

		$wc_discount_class->set_items($items);
		$response = $wc_discount_class->is_coupon_valid($c);

		if (!is_object($response)) {
			$wc_discount_class->apply_coupon($c);
			$coupon_discount_amounts = $wc_discount_class->get_discounts_by_coupon(true);
			$discount_amount = $coupon_discount_amounts[strtolower($coupon_code)];

			return [
				'status' => 'success',
				'message' => (string) $discount_amount
			];
		}
	}

	return [
		'code' => 'error',
		'message' => "can't use this coupon"
	];
}

function revo_pos_place_order($type = 'rest')
{
	$user_id 		 = cek_raw('user_id');
	$billing_address = cek_raw('billing_address');
	$products 		 = cek_raw('line_items');
	$shipping_lines  = cek_raw('shipping_lines');
	$payment_method  = cek_raw('payment_method');
	$coupon_code 	 = cek_raw('coupon_code');
	$order_notes 	 = cek_raw('order_notes');
	$coupon_lines 	 = cek_raw('coupon_lines');

	$wholesale_status = is_plugin_active('woocommerce-wholesale-prices/woocommerce-wholesale-prices.bootstrap.php');

	if (empty($billing_address) || empty($shipping_lines) || empty($payment_method)) {
		return [
			'status' => 'error',
			'message' => 'billing_address, shipping_lines, and payment required !'
		];
	}

	if (empty($user_id)) {
		return [
			'status' => 'error',
			'message' => 'you must include user_id !'
		];
	}

	$user = get_userdata($user_id);
	if (!$user) {
		return [
			'status' => 'error',
			'message' => 'Invalid authentication cookie. Please log out and try to login again!'
		];
	}

	wp_set_current_user($user_id, $user->user_login);
	wp_set_auth_cookie($user_id);

	foreach ($products as $item) {
		$variation = [];

		foreach ($item->variation as $value) {
			$variation['attribute_' . $value->column_name] = $value->value;
		}

		$cart_items[] = [
			'product_id'   => $item->product_id,
			'quantity'     => $item->quantity,
			'variation_id' => $item->variation_id,
			'variation'    => $variation
		];
	}

	$result = ['status' => 'error', 'message' => 'you must include products !'];
	if (isset($cart_items) && !empty($cart_items)) {
		if (!is_email($billing_address->email)) {
			return [
				'status' => 'error',
				'message' => 'Invalid billing email address !'
			];
		}

		$address = array(
			'first_name' => $billing_address->first_name,
			'last_name'  => $billing_address->last_name,
			'company'    => $billing_address->company,
			'email'      => $billing_address->email,
			'phone'      => $billing_address->phone,
			'address_1'  => $billing_address->address_1,
			'address_2'  => $billing_address->address_2,
			'city'       => $billing_address->city,
			'state'      => $billing_address->state,
			'postcode'   => $billing_address->postcode,
			'country'    => $billing_address->country
		);

		// start create order
		$order = wc_create_order();
		$order->set_customer_id($user_id ?? 0);
		$order->set_created_via('rest-api');

		// add products
		foreach ($cart_items as $item) {
			$item = (array) $item;

			$product_id = (is_null($item['variation_id']) || $item['variation_id'] === 0) ? $item['product_id'] : $item['variation_id'];
			$product = wc_get_product($product_id);

			if (!$product) {
				return [
					'status' => 'error',
					'message' => 'product not found'
				];
			}

			$price = $product->get_price();

			// define wholesale price
			if ($wholesale_status && !is_null($user)) {
				$wholesale_price = get_post_meta($product_id, 'wholesale_customer_wholesale_price', true);

				if (!empty($wholesale_price) && in_array('wholesale_customer', $user->roles)) {
					$price = $wholesale_price;
				}
			}

			$product_list[] = $product->get_name() . ' &times; ' . $item['quantity'];

			$order->add_product($product, $item['quantity'], [
				'total' => $price * $item['quantity'],
				'subtotal' => $price * $item['quantity'],
			]);
		}

		// add & update billing and shipping addresses
		$order->set_address($address, 'billing');
		$order->set_address($address, 'shipping');

		if ($user_id !== 0) {
			foreach ($billing_address as $billing_key => $billing_data) {
				update_user_meta($user_id, $billing_key, $billing_data);
			}
		}

		// add shipping methods
		$shipping = new WC_Order_Item_Shipping();
		$shipping->set_method_title($shipping_lines->method_title);
		$shipping->set_method_id($shipping_lines->method_id);
		$shipping->set_total($shipping_lines->cost);
		$shipping->add_meta_data('Items', implode(', ', $product_list), true);
		$order->add_item($shipping);

		// add payment method
		$order->set_payment_method($payment_method->id);
		$order->set_payment_method_title($payment_method->title);

		// define wholesale metas
		if ($wholesale_status && !is_null($user)) {
			if (in_array('wholesale_customer', $user->roles)) {
				$order->add_meta_data('is_vat_exempt', 'no');
				$order->add_meta_data('wwp_wholesale_role', 'wholesale_customer');
				$order->add_meta_data('_wwpp_order_type', 'wholesale');
				$order->add_meta_data('_wwpp_wholesale_order_type', 'wholesale_customer');
			}
		}

		// apply coupons
		if (!empty($coupon_code)) {
			$order->apply_coupon($coupon_code);
		}

		if (!empty($coupon_lines)) {
			foreach($coupon_lines as $coupon) {
				$order->apply_coupon($coupon->code);
			}
		}

		// order notes
		if (!empty($order_notes)) {
			$order->set_customer_note($order_notes);
		}

		// set status, calculate, and save
		$order->set_status('wc-on-hold');
		$order->calculate_totals();

		// save order
		$order->save();

		// payments gateway
		if (in_array($payment_method->id, ['midtrans', 'midtrans_sub_gopay']) && is_plugin_active('midtrans-woocommerce/midtrans-gateway.php')) {
			$order->update_status('wc-pending');

			if ($payment_method->id === 'midtrans') {
				$midtrans_class = new WC_Gateway_Midtrans();
			} else {
				$midtrans_class = new WC_Gateway_Midtrans_Sub_Gopay();
			}

			$pg_response = $midtrans_class->process_payment($order->get_id());

			$payment_link = $pg_response['redirect'];
		} else if ($payment_method->id === 'xendit_ovo' && is_plugin_active('woo-xendit-virtual-accounts/woocommerce-xendit-pg.php')) {
			$xendit_class = new WC_Xendit_OVO();
			$pg_response  = $xendit_class->process_payment($order->get_id());   // auto update status to pending

			$payment_link = $pg_response['redirect'];
		} else if ($payment_method->id === 'razorpay' && is_plugin_active('woo-razorpay/woo-razorpay.php')) {
			$order->update_status('wc-pending');

			$razor_class = new WC_Razorpay();
			$pg_response = $razor_class->process_payment($order->get_id());

			$payment_link = $pg_response['redirect'];
		}

		// result
		$result = $order->get_data();
		$result['payment_link'] = isset($payment_link) ? $payment_link : "";

		do_action( 'revo_pos_place_order', $cart_items, $order->get_id() );

		// reformat result
		foreach ($result['line_items'] as $line_item) {
			$temp_line_items[] = array_merge($line_item->get_data(), [
				'price' => (string) ($line_item['subtotal'] / $line_item['quantity'])
			]);
		}

		foreach ($result['shipping_lines'] as $item) {
			$temp_shipping_lines[] = [
				'method_id' => $item['method_id'],
				'method_title' => $item['method_title'],
				'total' => $item['total']
			];
		}

		$result['date_created']   = wc_rest_prepare_date_response($result['date_created'], false);
		$result['shipping_lines'] = $temp_shipping_lines;
		$result['line_items'] 	  = $temp_line_items;
		$result['subtotal_items'] = (string) $order->get_subtotal();
		$result['discount_total'] = (string) $order->get_discount_total();

		add_action('woocommerce_new_order', 'notif_new_order',  10, 1);
	}

	if ($type == 'rest') {
		echo json_encode($result);
		exit();
	} else {
		return $result;
	}
}

function revo_pos_get_product_categories($request)
{
	$search = $_GET['search'];

	$terms = get_terms('product_cat', [
		'hide_empty' => false,
		'orderby' 	 => 'id',
		'search'	 => $search
	]);

	$categories = [];
	if (!empty($terms)) {
		foreach ($terms as $term) {

			$term->level = 0;

			if ($term->parent != 0) {

				// get specific data from terms
				$array_out = array_splice($terms, array_search($term->term_id, array_column($terms, 'term_id')), 1);

				// search parent key
				$search_parent_key = array_search($term->parent, array_column($terms, 'term_id'));

				// append array_out to terms again
				array_splice($terms, $search_parent_key + 1, 0, $array_out);

				if (empty($search)) {
					// set menu level
					$term->level = $terms[$search_parent_key]->level + 1;
				}
			}
		}

		$obj_wc_rest_catagories = new WC_REST_Product_Categories_Controller();

		foreach ($terms as $item) {
			$data = $obj_wc_rest_catagories->prepare_item_for_response($item, $request)->data;
			$data['level'] = $item->level;

			if (is_null($data['image'])) {
				$data['image'] = [
					"id" => 9999,
					"date_created" => "",
					"date_created_gmt" => "",
					"date_modified" => "",
					"date_modified_gmt" => "",
					"src"  => wc_placeholder_img_src(),
					"name" => "",
					"alt"  => ""
				];
			}

			if (!$data['image']['src']) {
				$data['image']['src'] = wc_placeholder_img_src();
			}

			$categories[] = $data;
		}
	}

	return $categories;
}

function revo_pos_notif_new_order($order_id)
{
	global $wpdb;

	$order = wc_get_order($order_id);

	$order_number  = $order->get_order_number();
	$order_created = wc_get_order($order_number);

	if (!$order_created) {
		$order_created = wp_date("Y-m-d H:i:s");
	} else {
		$order_created = $order_created->get_date_created()->date("Y-m-d H:i:s");
	}

	$date 	     = new DateTime('now', new DateTimeZone(wp_timezone()->getName()));
	$user_id     = $order->get_user_id();
	$title_pos   = 'ORDER: #' . $order_number;
	$message_pos = 'ORDER STATUS IS ' . strtoupper($order->status);

	$wpdb->insert('revo_pos_notification', [
		'type'      => "order",
		'target_id' => $order_number,
		'message'   => $order->status,
		'user_id'   => $user_id,
	]);

	$get_pos = '';
	$get_pos = pos_get_user_token();

	if (!empty($get_pos)) {
		foreach ($get_pos as $key) {
			$token_pos        = $key->token;
			$notification_pos = array(
				'title' => $title_pos,
				'body'  => $message_pos,
				'icon'  => get_logo(),
			);

			$extend_pos['id']   = $order_number;
			$extend_pos['type'] = "order";

			$extend_pos['created_at'] = $order_created;
			$extend_pos['now']        = $date->format('Y-m-d H:i:s');

			$date  = new DateTime($date->format('Y-m-d H:i:s'));
			$date2 = new DateTime($order_created);

			$diff = $date->getTimestamp() - $date2->getTimestamp();

			$extend_pos['diff'] = $diff;

			// $extend_pos['is_neworder'] = $diff <= 4 ? true : false;
			$extend_pos['is_neworder'] = doing_action('woocommerce_new_order');

			send_FCM($token_pos, $notification_pos, $extend_pos);
		}
	}
}