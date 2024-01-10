<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

global $wpdb;

if (!function_exists('pos_revo_url')) {

	function pos_revo_url()
	{
		return REVO_POS_URL;
	}
}

if (!function_exists('get_order_details')) {

	function get_order_details($order_id)
	{

		// 1) Get the Order object
		$order = wc_get_order($order_id);

		// OUTPUT
		$data = [
			"type" => $order->order_type,
			"id" => $order->id,
			"post_id" => $order->post->ID,
			"post_date" => $order->post->post_date,
			"post_date_gmt" => $order->post->post_date_gmt,
			"post_content" => $order->post->post_content,
			"post_title" => $order->post->post_title,
			"post_excerp" => $order->post->post_excerpt,
			"post_status" => $order->post->post_status,
			"comment_status" => $order->post->comment_status,
			"ping_status" => $order->post->ping_status,
			"password" => $order->post->post_password,
			"post_name" => $order->post->post_name,
			"to_ping" => $order->post->to_ping,
			"pinged" => $order->post->pinged,
			"post_modified" => $order->post->post_modified,
			"post_modified_gmt" => $order->post->post_modified_gtm,
			"post_content_filtered" => $order->post->post_content_filtered,
			"post_parent" => $order->post->post_parent,
			"post_guid" => $order->post->guid,
			"menu_order" => $order->post->menu_order,
			"post_type" => $order->post->post_type,
			"mime_type" => $order->post->post_mime_type,
			"comment_count" => $order->post->comment_count,
			"post_filter" => $order->post->filter,
			"order_date" => $order->order_date,
			"modified_date" => $order->modified_date,
			"customer_message" => $order->customer_message,
			"customer_note" => $order->customer_note,
			"post_status" => $order->post_status,
			"prices_include_tax" => $order->prices_include_tax,
			"tax_display_cart" => $order->tax_display_cart,
			"display_totals_ex_tax" => $order->display_totals_ex_tax,
			"display_cart_ex_tax" => $order->display_cart_ex_tax,
			"formatted_billing_addr_protected" => $order->formatted_billing_address->protected,
			"formatted_shipping_addr_protected" => $order->formatted_shipping_address->protected,
		];

		// 2) Get the Order meta data
		$order_meta = get_post_meta($order_id);
		$meta = [
			"order_key" => $order_meta[_order_key][0],
			"order_currency" => $order_meta[_order_currency][0],
			"prices_include" => $order_meta[_prices_include_tax][0],
			"customer_user" => $order_meta[_customer_user][0],
			"billing_first_name" => $order_meta[_billing_first_name][0]
		];

		// 3) Get the order items
		$myitems = $order->get_items();
		$items = [];
		foreach ($myitems as $item_id => $item_data) {
			$dataItem = (object)[
				"id" => $item_id,
				"product_id" => $item_data['product_id'],
				"product" => (object)[
					"name" => $item_data['name'],
					"sku" => wc_get_product($item_data['product_id'])->get_sku()
				],
				"qty" => $order->get_item_meta($item_id, '_qty', true),
				"line_total" => $order->get_item_meta($item_id, '_line_total', true),
			];

			$items[] = $dataItem;
		}

		$user = (new Wc_Customer($order_meta[_customer_user][0]))->get_data();
		return compact('data', 'meta', 'items', 'user');
	}
}

if (!function_exists('pos_columnIsExists')) {

	function pos_columnIsExists($table, $column)
	{
		global $wpdb;

		$row = $wpdb->get_results("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
				WHERE table_name = '$table' AND column_name = '$column'");

		if (empty($row)) {
			return false;
		}
		return true;
	}
}

if (!function_exists('pos_get_page')) {

	function pos_get_page($page_name)
	{
		return plugin_dir_path(__FILE__) . 'page/' . $page_name;
	}
}

if (!function_exists('pos_dd')) {

	function pos_dd(...$p)
	{
		var_dump($p);
		die;
	}
}

if (!function_exists('pos_get_html')) {
	function pos_get_html($data)
	{
		// start buffering html, dont send to browser,
		// note no white space at start of html after php end tag.

		// exit;
		ob_start();
		include plugin_dir_path(__FILE__) . "/invoices/invoice1.php";
		//=========   HTML CODE BEGINS ENDS BEFORE THE BEGINING PHP TAG ====================

		global $html;
		$html = ob_get_contents(); // get all html in buffer to the $html global variable
		ob_end_clean(); // clean the buffer
		return $html; // return html
	}
}

if (!function_exists('toPdf')) {

	function toPdf($params)
	{
		$html = pos_get_html($params);
		// $html = "<span>hello world</span>";
		$options = new Options();
		// $options->set('defaultFont', 'Courier');
		$options->set('isRemoteEnabled', TRUE);
		$options->set('debugKeepTemp', TRUE);
		$options->set('isHtml5ParserEnabled', true);
		//$options->set('chroot', '');
		$dompdf = new Dompdf($options);
		$dompdf->loadHtml($html);
		$savein = WP_CONTENT_DIR . "/uploads/revo/";
		$dompdf->render();
		// $canvas = $dompdf->get_canvas();
		// $font = Font_Metrics::get_font("arial", "normal","12px");
		//
		// // the same call as in my previous example
		// $canvas->page_text(540, 773, "Page {PAGE_NUM} of {PAGE_COUNT}",
		//                $font, 6, array(0,0,0));

		$pdf = $dompdf->output();      // gets the PDF as a string
		$filename = date("Y-m-d-His") . ".pdf";
		file_put_contents($savein . str_replace("/", "-", $filename), $pdf);    // save the pdf file on server
		unset($html);
		unset($dompdf);

		return $savein . $filename;
		// exit;
	}
}

if (!function_exists('generateInv')) {
	function generateInv($data, $fileName = null)
	{
		$uploads_url = WP_CONTENT_URL . "/uploads/revo/";
		$target_dir = WP_CONTENT_DIR . "/uploads/revo/";

		if (!$fileName) {
			$fileName =  md5(date("Y-m-d H:i:s")) . ".jpg";
		}

		if (file_exists("$target_dir$fileName")) {
			return $uploads_url . $fileName;
		}
		// return phpinfo();
		// Create new object
		$pdf = toPdf($data);
		$im = new Imagick();
		$im->setResolution(300, 300);
		$im->readImage($pdf . "[0]");
		$im->setImageFormat("jpeg");
		$im->writeImage("$target_dir$fileName");
		$im->clear();
		$im->destroy();

		if (file_exists($pdf)) {
			unlink($pdf);
		}

		return $uploads_url . $fileName;
	}
}

if (!function_exists('pos_get_logo')) {

	function pos_get_logo($type = 'color')
	{
		return REVO_POS_URL . ($type == 'color' ? 'assets/images/logo/logo-revo.png' : 'assets/images/logo/logo-bw.png');
	}
}

if (!function_exists('pos_check_exist_database')) {
	function pos_check_exist_database($tablename)
	{
		global $wpdb;
		
		if ($wpdb) {
			$exit_tabel = " SHOW TABLES LIKE '$tablename' ";
			if (count($wpdb->get_results($exit_tabel)) == 0) {
				return false;
			}
		}

		return true;
	}
}

if (!function_exists('throwJson')) {
	function throwJson($response, $code = 200)
	{
		header('Content-Type: application/json');
		http_response_code($code);
		echo json_encode($response);
		exit;
	}
}

if (!function_exists('pos_createThumbnail')) {

	function pos_createThumbnail($src, $dest, $targetWidth, $targetHeight = null)
	{

		// 1. Load the image from the given $src
		// - see if the file actually exists
		// - check if it's of a valid image type
		// - load the image resource

		// get the type of the image
		// we need the type to determine the correct loader
		$type = exif_imagetype($src);

		// if no valid type or no handler found -> exit
		if (!$type || !IMAGE_HANDLERS[$type]) {
			return null;
		}

		// load the image with the correct loader
		$image = call_user_func(IMAGE_HANDLERS[$type]['load'], $src);

		// no image found at supplied location -> exit
		if (!$image) {
			return null;
		}


		// 2. Create a thumbnail and resize the loaded $image
		// - get the image dimensions
		// - define the output size appropriately
		// - create a thumbnail based on that size
		// - set alpha transparency for GIFs and PNGs
		// - draw the final thumbnail

		// get original image width and height
		$width = imagesx($image);
		$height = imagesy($image);

		// maintain aspect ratio when no height set
		if ($targetHeight == null) {

			// get width to height ratio
			$ratio = $width / $height;

			// if is portrait
			// use ratio to scale height to fit in square
			if ($width > $height) {
				$targetHeight = floor($targetWidth / $ratio);
			}
			// if is landscape
			// use ratio to scale width to fit in square
			else {
				$targetHeight = $targetWidth;
				$targetWidth = floor($targetWidth * $ratio);
			}
		}

		// create duplicate image based on calculated target size
		$thumbnail = imagecreatetruecolor($targetWidth, $targetHeight);

		// set transparency options for GIFs and PNGs
		if ($type == IMAGETYPE_GIF || $type == IMAGETYPE_PNG) {

			// make image transparent
			imagecolortransparent(
				$thumbnail,
				imagecolorallocate($thumbnail, 0, 0, 0)
			);

			// additional settings for PNGs
			if ($type == IMAGETYPE_PNG) {
				imagealphablending($thumbnail, false);
				imagesavealpha($thumbnail, true);
			}
		}

		// copy entire source image to duplicate image and resize
		imagecopyresampled(
			$thumbnail,
			$image,
			0,
			0,
			0,
			0,
			$targetWidth,
			$targetHeight,
			$width,
			$height
		);


		// 3. Save the $thumbnail to disk
		// - call the correct save method
		// - set the correct quality level

		// save the duplicate version of the image to disk
		return call_user_func(
			IMAGE_HANDLERS[$type]['save'],
			$thumbnail,
			$dest,
			IMAGE_HANDLERS[$type]['quality']
		);
	}
}

if (!function_exists('pos_compress')) {

	function pos_compress($source, $destination, $quality)
	{

		$info = getimagesize($source);
		if ($info['mime'] == 'image/jpeg')
			$image = imagecreatefromjpeg($source);

		elseif ($info['mime'] == 'image/gif')
			$image = imagecreatefromgif($source);

		elseif ($info['mime'] == 'image/png')
			$image = imagecreatefrompng($source);

		imagejpeg($image, $destination, $quality);

		return $destination;
	}
}

if (!function_exists('pos_get_products_id')) {
	function pos_get_products_id($args)
	{
		$all_product = [];
		$products = wc_get_products($args);
		foreach ($products as $key => $value) {
			// array_push($all_product,[
			//     'id' => $value->get_id(),
			// ]);
			$all_product[] = $value->get_id();
		}
		return $all_product;
	}
}

if (!function_exists('pos_get_categorys')) {
	function pos_get_categorys()
	{
		$categories = get_terms(['taxonomy' => 'product_cat']);
		$all_categories = [];
		foreach ($categories as $key => $value) {
			# code...
			array_push($all_categories, [
				'id' => $value->term_id,
				'text' => $value->name
			]);
		}
		return json_encode($all_categories);
	}
}

if (!function_exists('pos_load_flutter_mobile_app')) {
	function pos_load_flutter_mobile_app()
	{
		require REVO_POS_ABSPATH . 'includes/classes/class-revo-pos-mobile-app-public.php';

		return new Revo_POS_Mobile_App_Public();
	}
}

if (!function_exists('pos_get_categorys_detail')) {
	function pos_get_categorys_detail($id)
	{
		$categorie = get_terms(['term_taxonomy_id' => $id]);
		return $categorie;
	}
}

if (!function_exists('pos_current_url')) {
	function pos_current_url()
	{
		global $wp;
		return add_query_arg($wp->query_vars);
	}
}

if (!function_exists('pos_formatted_date')) {

	function pos_formatted_date($timestamp, $format = "d/m/Y - H:i")
	{

		return date($format, strtotime($timestamp));
	}
}

if (!function_exists('pos_cek_is_active')) {

	function pos_cek_is_active($data)
	{

		return '<span class="badge ' . ($data == 1 ? 'badge-success' : 'badge-danger') . ' p-2">' . ($data == 1 ? 'Active' : 'Non Active') . '</span>';
	}
}

if (!function_exists('pos_cek_type')) {

	function pos_cek_type($type)
	{
		$data['image'] = '';
		$data['text'] = '';
		if ($type == 'special') {
			$data['image'] = pos_revo_url() . '/assets/images/example_special.jpg';
			$data['text'] = 'Pannel 1 ( Default : Special )';
		}

		if ($type == 'our_best_seller') {
			$data['image'] = pos_revo_url() . '/assets/images/example_bestseller.jpg';
			$data['text'] = 'Pannel 2 ( Default : Our Best Seller )';
		}

		if ($type == 'recomendation') {
			$data['image'] = pos_revo_url() . '/assets/images/example_recomend.jpg';
			$data['text'] = 'Pannel 2 ( Default : Recomendation )';
		}

		$data['text'] = '<span class="badge badge-primary p-2">' . $data['text'] . '</span>';
		return $data;
	}
}

if (!function_exists('pos_cek_flash_sale_end')) {

	function pos_cek_flash_sale_end()
	{

		global $wpdb;

		$date = date('Y-m-d H:i:s');

		$get = $wpdb->get_results("SELECT id FROM `revo_flash_sale` WHERE is_deleted = 0 AND start < '" . $date . "' AND end < '" . $date . "' AND is_active = 1", OBJECT);

		foreach ($get as $key => $value) {
			$query = $wpdb->update(
				'revo_flash_sale',
				['is_active' =>  '0'],
				array('id' => $value->id)
			);
		}
	}
}

if (!function_exists('pos_buttonQuestion')) {

	function pos_buttonQuestion()
	{

		return '<a href="javascript:void(0)" data-toggle="modal" data-target="#question" class="badge py-1 px-2  badge-secondary rounded"><i class="fa fa-question font-size-15 font-weight-normal"></i></a>';
	}
}

if (!function_exists('pos_get_user')) {

	function pos_get_user($email)
	{

		$user = get_user_by('email', $email);

		return $user;
	}
}

if (!function_exists('pos_get_authorization_header')) {
	function pos_get_authorization_header()
	{
		if (!empty($_SERVER['HTTP_AUTHORIZATION'])) {
			return wp_unslash($_SERVER['HTTP_AUTHORIZATION']); // WPCS: sanitization ok.
		}

		if (function_exists('getallheaders')) {
			$headers = getallheaders();
			// Check for the authoization header case-insensitively.
			foreach ($headers as $key => $value) {
				if ('authorization' === strtolower($key)) {
					return $value;
				}
			}
		}

		return '';
	}
}

if (!function_exists('pos_security_0auth')) {

	function pos_security_0auth()
	{
		$current_url 		 = home_url($_SERVER['REQUEST_URI']);
		$current_url 		 = explode('/', $current_url);
		$pluginUrlFromParams = strtolower($current_url[4]);
		$pluginName  		 = strtolower(REVO_POS_PLUGIN_SLUG);
		$current_url 		 = end($current_url);

		if ($pluginName == $pluginUrlFromParams && $current_url != 'disabled-service') {
			require_once REVO_POS_ABSPATH . 'includes/classes/class-revo-pos-authentication.php';

			$cek = pos_cek_internal_license_code();

			if ($cek == false) {
				$result = ['status' => 'error', 'message' => 'input license first !'];
				echo json_encode($result);
				exit();
			}
		}
	}
}

if (!function_exists('pos_query_revo_pos_mobile_variable')) {

	function pos_query_revo_pos_mobile_variable($slug, $order_by = 'created_at')
	{
		global $wpdb;
		return $wpdb->get_results("SELECT * FROM `revo_pos_mobile_variable` WHERE `slug` IN ($slug) AND is_deleted = 0 ORDER BY $order_by DESC", OBJECT);
	}
}

if (!function_exists('pos_query_check_plugin_active')) {

	function pos_query_check_plugin_active($search)
	{

		$active_plugins = get_option('active_plugins');

		foreach ($active_plugins as $plugin) {

			if (str_contains($plugin, $search)) {

				return true;
			}
		}

		return false;
	}
}

if (!function_exists('pos_check_live_chat')) {

	function pos_check_live_chat()
	{

		$query_LiveChatStatus = pos_query_revo_pos_mobile_variable('"live_chat_status"', 'sort');
		$liveChatStatus = empty($query_LiveChatStatus) ? 'hide' : $query_LiveChatStatus[0]->description;

		if ($liveChatStatus == 'hide') {
			$result = ['status' => 'error', 'message' => 'Live chat disabled !'];
		}

		$check_revopos_active = pos_query_check_plugin_active('Revo-woocomerce-plugin');

		if (!$check_revopos_active) {
			$result = ['status' => 'error', 'message' => 'Plugin RevoShop not installed or activated !'];
		}

		if ($check_revopos_active && $liveChatStatus == 'show') {
			$result = true;
		}

		return $result;
	}
}

if (!function_exists('pos_query_hit_products')) {

	function pos_query_hit_products($id, $user_id)
	{
		global $wpdb;
		return $wpdb->get_row("SELECT count(id) as is_wistlist FROM `revo_hit_products` WHERE products = '$id' AND user_id = '$user_id' AND type = 'wistlist'", OBJECT);
	}
}

if (!function_exists('pos_query_all_hit_products')) {

	function pos_query_all_hit_products($user_id)
	{
		global $wpdb;
		return $wpdb->get_results("SELECT * FROM `revo_hit_products` WHERE user_id = '$user_id' AND type = 'wistlist'", OBJECT);
	}
}

if (!function_exists('pos_insert_update_MV')) {

	function pos_insert_update_MV($where, $id,  $desc)
	{
		global $wpdb;

		$query_data = $where;
		$query_data['description'] = $desc;

		$success = 0;
		if ($id != 0) {
			$where['id'] = $id;
			$wpdb->update('revo_pos_mobile_variable', $query_data, $where);
			if (@$wpdb->show_errors == false) {
				$success = 1;
			}
		} else {
			$wpdb->insert('revo_pos_mobile_variable', $query_data);
			if (@$wpdb->insert_id > 0) {
				$success = 1;
			}
		}

		return $success;
	}
}

if (!function_exists('pos_access_key')) {

	function pos_access_key()
	{
		global $wpdb;
		$query = "SELECT * FROM `revo_pos_access_key` ORDER BY created_at DESC limit 1";
		return $wpdb->get_row($query, OBJECT);
	}
}

if (!function_exists('shop_access_key')) {

	function shop_access_key()
	{
		global $wpdb;
		$query = "SELECT * FROM `revo_access_key` ORDER BY created_at DESC limit 1";
		return $wpdb->get_row($query, OBJECT);
	}
}

if (!function_exists('pos_get_products_woocomerce')) {

	function pos_get_products_woocomerce($layout, $api, $request)
	{
		$params = array('order' => 'desc', 'orderby' => 'date');
		if (isset($layout['category'])) {
			$params['category'] = $layout['category'];
		}
		if (isset($layout['tag'])) {
			$params['tag'] = $layout['tag'];
		}
		if (isset($layout['feature'])) {
			$params['feature'] = $layout['feature'];
		}

		$request->set_query_params($params);

		$response = $api->get_items($request);
		return $response->get_data();
	}
}

if (!function_exists('pos_send_FCM')) {

	function pos_send_FCM($token, $notification, $extend)
	{

		// $data = pos_access_key();
		$data = shop_access_key();

		$server_key = $data->firebase_server_key;

		if ($server_key) {
			$body = array(
				"notification" => $notification,
				"to" => $token,
				"data" => $extend
			);

			$body = json_encode($body);
			// $body = '{ "notification": { "title": "coba title", "body": "coba body" }, "to" : "cAayzcaKRjykBzw_3LxnEN:APA91bFJi8zxwtA1rRRXkQ1P5NM2vo-6ZiMLa6zRFcATw6eImYZLun7EK79Rs7ro9ojjDMwkcTIU3Vj4SLQiqL4tXixuqUU_ZStEpEaiG5tWyWVmDceIghMaK-jJBsMfkT7s2MH5N2Gy" }';
			$curl = curl_init();
			curl_setopt_array($curl, array(
				CURLOPT_URL => "https://fcm.googleapis.com/fcm/send",
				CURLOPT_RETURNTRANSFER => true,
				CURLOPT_ENCODING => "",
				CURLOPT_MAXREDIRS => 10,
				CURLOPT_TIMEOUT => 30,
				CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
				CURLOPT_CUSTOMREQUEST => "POST",
				CURLOPT_HTTPHEADER => array(
					"Content-Type: application/json",
					"Authorization: key=$server_key"
				),
				CURLOPT_POSTFIELDS => $body,
			));

			$response = curl_exec($curl);

			$err = curl_error($curl);

			curl_close($curl);

			if ($err) {
				return 'error';
			}

			return json_decode($response);
		}

		return 'error';
	}
}

if (!function_exists('pos_cek_raw')) {

	function pos_cek_raw($key = '')
	{
		$json = file_get_contents('php://input');
		$params = json_decode($json);


		if ($params and $key) {
			if (@$params->$key) {
				$text = $params->$key;

				//    			// Strip HTML Tags
				// $clear = strip_tags($text);
				// // Clean up things like &amp;
				// $clear = html_entity_decode($clear);
				// // Strip out any url-encoded stuff
				// $clear = urldecode($clear);
				// // Replace Multiple spaces with single space
				// $clear = preg_replace('/ +/', ' ', $clear);
				// // Trim the string of leading/trailing space
				// $clear = trim($clear);

				return $text;
			}
		}

		return '';
	}
}

if (!function_exists('pos_rv_total_sales')) {

	function pos_rv_total_sales($product)
	{
		$product_id = $product->get_id();
		if (!$product) {
			return 0;
		}

		$total_sales = is_a($product, 'WC_Product_Variation') ? get_post_meta($product_id, 'total_sales', true) : $product->get_total_sales();

		return $total_sales;
	}
}

if (!function_exists('pos_load_Revo_POST_Mobile_App_Public')) {

	function pos_load_Revo_POST_Mobile_App_Public()
	{
		require REVO_POS_ABSPATH . 'includes/classes/class-revo-pos-mobile-app-public.php';

		return new Revo_POS_Mobile_App_Public();
	}
}

if (!function_exists('pos_get_popular_categories')) {

	function pos_get_popular_categories()
	{
		global $wpdb;
		$data_categories = $wpdb->get_results("SELECT title,categories FROM revo_popular_categories WHERE is_deleted = 0 ORDER BY created_at DESC", OBJECT);

		return $data_categories;
	}
}

if (!function_exists('pos_revo_pos_cek_license_code')) {

	function pos_revo_pos_cek_license_code($data)
	{

		$body = array(
			"domain" => $_SERVER['SERVER_NAME'],
			"key" => $data['description'],
			"product_type" => "revo_pos",
			"useEnvato" => $data['title'] == 'envato'
		);

		$body = json_encode($body);
		$curl = curl_init();
		curl_setopt_array($curl, array(
			CURLOPT_URL => "https://activation.revoapps.net/wp-json/license/confirm",
			CURLOPT_RETURNTRANSFER => true,
			CURLOPT_ENCODING => "",
			CURLOPT_MAXREDIRS => 10,
			CURLOPT_TIMEOUT => 30,
			CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
			CURLOPT_CUSTOMREQUEST => "POST",
			CURLOPT_HTTPHEADER => array(
				"Content-Type: application/json",
			),
			CURLOPT_POSTFIELDS => $body,
		));

		$response = curl_exec($curl);

		$err = curl_error($curl);

		curl_close($curl);

		if ($err) {
			return 'error';
		}

		return json_decode($response);
	}
}

if (!function_exists('pos_data_seeder')) {
	function pos_data_seeder($type)
	{

		if ($type == 'splashscreen') {
			$data = array(
				'slug' => 'splashscreen',
				'title' => '',
				'image' => pos_get_logo(),
				'description' => 'Welcome',
			);
		}

		if ($type == 'intro_page_status') {
			$data = array(
				'slug' => 'intro_page_status',
				'title' => '',
				'image' => pos_get_logo(),
				'description' => 'show',
			);
		}

		if ($type == 'kontak_wa') {
			$data = array(
				'slug' => 'kontak',
				'title' => 'wa',
				'image' => '',
				'description' => '',
			);
		}

		if ($type == 'kontak_phone') {
			$data = array(
				'slug' => 'kontak',
				'title' => 'phone',
				'image' => '',
				'description' => '',
			);
		}

		if ($type == 'kontak_sms') {
			$data = array(
				'slug' => 'sms',
				'title' => 'link sms',
				'image' => '',
				'description' => '',
			);
		}

		if ($type == 'about') {
			$data = array(
				'slug' => 'about',
				'title' => 'link about',
				'image' => '',
				'description' => '',
			);
		}

		if ($type == 'privacy_policy') {
			$data = array(
				'slug' => 'privacy_policy',
				'title' => 'link Privacy Policy',
				'image' => '',
				'description' => '',
			);
		}

		if ($type == 'term_condition') {
			$data = array(
				'slug' => 'term_condition',
				'title' => 'link term & condition',
				'image' => '',
				'description' => '',
			);
		}

		if ($type == 'license_code') {
			$data = array(
				'slug' => 'revo_pos_license_code',
				'title' => '',
				'image' => '',
				'description' => '',
			);
		}

		if ($type == 'cs') {
			$data = array(
				'slug' => 'cs',
				'title' => 'customer service',
				'image' => '',
				'description' => '',
			);
		}

		if ($type == 'logo') {

			if (strpos(pos_revo_url(), '.revoapps.ids') !== false) {
				$image = pos_get_logo();
			} else {
				$image = pos_revo_url() . 'assets/images/logo/icon-pos.png';
			}

			$data = array(
				'slug' => 'logo',
				'title' => 'Mobile Revo Apps',
				'image' => $image,
				'description' => '',
			);
		}

		if ($type == 'intro_page_1') {
			$data = array(
				'slug' => 'intro_page',
				'title' => 'Manage Everything',
				'image' => pos_revo_url() . 'assets/images/revo-woo-onboarding-01.jpg',
				'description' => 'Completely manage your store from the dashboard, including onboarding/intro changes, sliding banners, posters, home, and many more.',
			);
		}

		if ($type == 'intro_page_2') {
			$data = array(
				'slug' => 'intro_page',
				'title' => 'Support All Payments',
				'image' => pos_revo_url() . 'assets/images/revo-woo-onboarding-02.jpg',
				'description' => 'Pay for the transaction using all the payment methods you want. Including paypal, razorpay, bank transfer, BCA, Mandiri, gopay, or ovo.',
			);
		}

		if ($type == 'intro_page_3') {
			$data = array(
				'slug' => 'intro_page',
				'title' => "Support All Shipping Methods",
				'image' => pos_revo_url() . 'assets/images/revo-woo-onboarding-03.jpg',
				'description' => "The shipping method according to your choice, which is suitable for your business. All can be arranged easily.",
			);
		}

		if ($type == 'empty_images_1') {
			$data = array(
				'slug' => 'empty_image',
				'title' => "404_images",
				'image' => pos_revo_url() . 'assets/images/404.png',
				'description' => "450 x 350px",
			);
		}

		if ($type == 'empty_images_2') {
			$data = array(
				'slug' => 'empty_image',
				'title' => "thanks_order",
				'image' => pos_revo_url() . 'assets/images/thanks_order.png',
				'description' => "600 x 420px",
			);
		}

		if ($type == 'empty_images_3') {
			$data = array(
				'slug' => 'empty_image',
				'title' => "empty_transaksi",
				'image' => pos_revo_url() . 'assets/images/no_transaksi.png',
				'description' => "260 x 300px",
			);
		}

		if ($type == 'empty_images_4') {
			$data = array(
				'slug' => 'empty_image',
				'title' => "search_empty",
				'image' => pos_revo_url() . 'assets/images/search_empty.png',
				'description' => "260 x 300px",
			);
		}

		if ($type == 'empty_images_5') {
			$data = array(
				'slug' => 'empty_image',
				'title' => "login_required",
				'image' => pos_revo_url() . 'assets/images/404.png',
				'description' => "260 x 300px",
			);
		}

		return $data;
	}
}

if (!function_exists('pos_cek_internal_license_code')) {
	function pos_cek_internal_license_code()
	{
		global $wpdb;

		$now = date('Y-m-d H:i:s');
		$query = "SELECT update_at FROM `revo_pos_mobile_variable` WHERE slug = 'revo_pos_license_code' AND description != '' AND update_at is not NULL";
		$get = $wpdb->get_row($query, OBJECT);

		if (!empty($get)) {
			if ($get->update_at > $now) {
				return true;
			}
		}

		return false;
	}
}

if (!function_exists('get_image_by_term_id')) {
	function get_image_by_term_id($id = NULL)
	{
		$image = NULL;
		if (!empty($id)) {
			$thumbnail_id = get_term_meta($id, 'thumbnail_id', true);
			$image = wp_get_attachment_url($thumbnail_id);
		}

		return $image;
	}
}

if (!function_exists('pos_get_conversations')) {

	function pos_get_conversations($user_id, $receiver_id = NULL)
	{
		global $wpdb;

		$where = 'rc.sender_id = ' . $user_id . ' OR rc.receiver_id = ' . $user_id;
		if ($receiver_id) {
			$where = '( rc.sender_id = ' . $user_id . ' AND rc.receiver_id = ' . $receiver_id . ' ) OR ( rc.receiver_id = ' . $user_id . ' AND rc.sender_id = ' . $receiver_id . ' )';
		}

		$query = "SELECT rc.*, 
						(SELECT rcm.message FROM `revo_conversation_messages` rcm WHERE ($where) AND rcm.conversation_id = rc.id ORDER BY rcm.created_at DESC LIMIT 1) AS last_message,
						(SELECT rcm.created_at FROM `revo_conversation_messages` rcm WHERE ($where) AND rcm.conversation_id = rc.id ORDER BY rcm.created_at DESC LIMIT 1) AS created_chat,
						(SELECT count(rcm.id) FROM `revo_conversation_messages` rcm WHERE rcm.receiver_id = $user_id AND rcm.conversation_id = rc.id AND rcm.is_read = 1) AS unread,
						CASE
						   when rc.sender_id != $user_id then 'seller'
						   when rc.receiver_id != $user_id then 'buyer'
						END as status
						FROM `revo_conversations` rc WHERE $where GROUP BY rc.id ORDER BY created_chat DESC ";

		if ($receiver_id) {
			return $wpdb->get_row($query, OBJECT);
		} else {
			return $wpdb->get_results($query, OBJECT);
		}
	}
}

if (!function_exists('pos_get_conversations_detail')) {

	function pos_get_conversations_detail($user_id, $chat_id = NULL)
	{
		global $wpdb;

		$where = ' (rcm.sender_id = ' . $user_id . ' OR rcm.receiver_id = ' . $user_id . ') ';
		if ($chat_id) {
			$where .= ' AND rcm.conversation_id = ' . $chat_id;
		}

		// if ($chat_id) {
		// 	$where .= ' AND rcm.conversation_id = '.$chat_id;
		// }

		$seller_id = cek_raw('seller_id');
		if ($seller_id) {
			$where .= ' AND rc.receiver_id = ' . $seller_id;
		}

		$data['is_read'] = 0;
		$wpdb->update('revo_conversation_messages', $data, ['is_read' => 1, 'receiver_id' => $user_id, 'conversation_id' => $chat_id]);

		$query = " SELECT 
						rcm.conversation_id as chat_id,
						rcm.sender_id,
						rcm.receiver_id,
						rcm.message,
						rcm.type,
						rcm.image,
						rcm.post_id,
						CASE
						   when LOCATE('http',rcm.message) > 0 then 'image'
						   when LOCATE('https',rcm.message) > 0 then 'image'
						   else  'text'
						END as type_message,
						CASE
						   when rcm.sender_id = rc.sender_id then 'seller'
						   when rcm.sender_id = rc.receiver_id then 'buyer'
						END as status,
						CASE
						   when rcm.sender_id = $user_id then 'right'
						   when rcm.receiver_id = $user_id then 'left'
						END as potition,
						rcm.created_at
					FROM `revo_conversation_messages` as rcm INNER JOIN `revo_conversations` as rc on rcm.conversation_id = rc.id  WHERE $where GROUP BY rcm.id ORDER BY rcm.created_at ASC ";
		return $wpdb->get_results($query, OBJECT);
	}
}

if ( ! function_exists( 'revo_url' ) ) {
	function revo_url() {
		return REVO_WOO_URL;
	}
}

if ( ! function_exists( 'throwJson' ) ) {
	function throwJson( $response, $code = 200 ) {
		header( 'Content-Type: application/json' );
		http_response_code( $code );
		echo json_encode( $response );
		exit;
	}
}

if ( ! function_exists( 'get_posts_fields' ) ) {

	function get_posts_fields( $args = array() ) {
		$valid_fields = array(
			'ID'             => '%d',
			'post_author'    => '%d',
			'post_type'      => '%s',
			'post_mime_type' => '%s',
			'post_title'     => false,
			'post_name'      => '%s',
			'post_date'      => '%s',
			'post_modified'  => '%s',
			'menu_order'     => '%d',
			'post_parent'    => '%d',
			'post_excerpt'   => false,
			'post_content'   => false,
			'post_status'    => '%s',
			'comment_status' => false,
			'ping_status'    => false,
			'to_ping'        => false,
			'pinged'         => false,
			'comment_count'  => '%d'
		);
		$defaults     = array(
			'post_type'      => 'post',
			'post_status'    => 'publish',
			'orderby'        => 'post_date',
			'order'          => 'DESC',
			'posts_per_page' => get_option( 'posts_per_page' ),
		);
		global $wpdb;
		$args  = wp_parse_args( $args, $defaults );
		$where = "";
		foreach ( $valid_fields as $field => $can_query ) {
			if ( isset( $args[ $field ] ) && $can_query ) {
				if ( $where != "" ) {
					$where .= " AND ";
				}
				$where .= $wpdb->prepare( $field . " = " . $can_query, $args[ $field ] );
			}
		}
		if ( isset( $args['search'] ) && is_string( $args['search'] ) ) {
			if ( $where != "" ) {
				$where .= " AND ";
			}
			$where .= $wpdb->prepare( "post_title LIKE %s", "%" . $args['search'] . "%" );
		}
		if ( isset( $args['include'] ) ) {
			if ( is_string( $args['include'] ) ) {
				$args['include'] = explode( ',', $args['include'] );
			}
			if ( is_array( $args['include'] ) ) {
				$args['include'] = array_map( 'intval', $args['include'] );
				if ( $where != "" ) {
					$where .= " OR ";
				}
				$where .= "ID IN (" . implode( ',', $args['include'] ) . ")";
			}
		}
		if ( isset( $args['exclude'] ) ) {
			if ( is_string( $args['exclude'] ) ) {
				$args['exclude'] = explode( ',', $args['exclude'] );
			}
			if ( is_array( $args['exclude'] ) ) {
				$args['exclude'] = array_map( 'intval', $args['exclude'] );
				if ( $where != "" ) {
					$where .= " AND ";
				}
				$where .= "ID NOT IN (" . implode( ',', $args['exclude'] ) . ")";
			}
		}
		extract( $args );
		$iscol = false;
		if ( isset( $fields ) ) {
			if ( is_string( $fields ) ) {
				$fields = explode( ',', $fields );
			}
			if ( is_array( $fields ) ) {
				$fields = array_intersect( $fields, array_keys( $valid_fields ) );
				if ( count( $fields ) == 1 ) {
					$iscol = true;
				}
				$fields = implode( ',', $fields );
			}
		}
		if ( empty( $fields ) ) {
			$fields = '*';
		}
		if ( ! in_array( $orderby, $valid_fields ) ) {
			$orderby = 'post_date';
		}
		if ( ! in_array( strtoupper( $order ), array( 'ASC', 'DESC' ) ) ) {
			$order = 'DESC';
		}
		if ( ! intval( $posts_per_page ) && $posts_per_page != - 1 ) {
			$posts_per_page = $defaults['posts_per_page'];
		}
		if ( $where == "" ) {
			$where = "1";
		}
		$q = "SELECT $fields FROM $wpdb->posts WHERE " . $where;
		$q .= " ORDER BY $orderby $order";
		if ( $posts_per_page != - 1 ) {
			$q .= " LIMIT $posts_per_page";
		}

		return $iscol ? $wpdb->get_col( $q ) : $wpdb->get_results( $q );
	}
}

if ( ! function_exists( 'get_page' ) ) {

	function get_page( $page_name ) {
		return plugin_dir_path( __FILE__ ) . 'page/' . $page_name;
	}
}

if ( ! function_exists( 'get_logo' ) ) {

	function get_logo( $type = 'color' ) {
		return revo_url() . ( $type == 'color' ? 'assets/images/logo-revo.png' : 'assets/images/logo-bw.png' );
	}
}

if ( ! function_exists( 'check_exist_database' ) ) {

	function check_exist_database( $tablename ) {
		global $wpdb;

		if ( $wpdb ) {
			$exit_tabel = " SHOW TABLES LIKE '$tablename' ";

			if ( count( $wpdb->get_results( $exit_tabel ) ) == 0 ) {
				return false;
			}
		}

		return true;
	}
}

if ( ! function_exists( 'createThumbnail' ) ) {

	function createThumbnail( $src, $dest, $targetWidth, $targetHeight = null ) {

		// 1. Load the image from the given $src
		// - see if the file actually exists
		// - check if it's of a valid image type
		// - load the image resource

		// get the type of the image
		// we need the type to determine the correct loader
		$type = exif_imagetype( $src );

		// if no valid type or no handler found -> exit
		if ( ! $type || ! IMAGE_HANDLERS[ $type ] ) {
			return null;
		}

		// load the image with the correct loader
		$image = call_user_func( IMAGE_HANDLERS[ $type ]['load'], $src );

		// no image found at supplied location -> exit
		if ( ! $image ) {
			return null;
		}


		// 2. Create a thumbnail and resize the loaded $image
		// - get the image dimensions
		// - define the output size appropriately
		// - create a thumbnail based on that size
		// - set alpha transparency for GIFs and PNGs
		// - draw the final thumbnail

		// get original image width and height
		$width  = imagesx( $image );
		$height = imagesy( $image );

		// maintain aspect ratio when no height set
		if ( $targetHeight == null ) {

			// get width to height ratio
			$ratio = $width / $height;

			// if is portrait
			// use ratio to scale height to fit in square
			if ( $width > $height ) {
				$targetHeight = floor( $targetWidth / $ratio );
			}
			// if is landscape
			// use ratio to scale width to fit in square
			else {
				$targetHeight = $targetWidth;
				$targetWidth  = floor( $targetWidth * $ratio );
			}
		}

		// create duplicate image based on calculated target size
		$thumbnail = imagecreatetruecolor( $targetWidth, $targetHeight );

		// set transparency options for GIFs and PNGs
		if ( $type == IMAGETYPE_GIF || $type == IMAGETYPE_PNG ) {

			// make image transparent
			imagecolortransparent(
				$thumbnail,
				imagecolorallocate( $thumbnail, 0, 0, 0 )
			);

			// additional settings for PNGs
			if ( $type == IMAGETYPE_PNG ) {
				imagealphablending( $thumbnail, false );
				imagesavealpha( $thumbnail, true );
			}
		}

		// copy entire source image to duplicate image and resize
		imagecopyresampled(
			$thumbnail,
			$image,
			0,
			0,
			0,
			0,
			$targetWidth,
			$targetHeight,
			$width,
			$height
		);


		// 3. Save the $thumbnail to disk
		// - call the correct save method
		// - set the correct quality level

		// save the duplicate version of the image to disk
		return call_user_func(
			IMAGE_HANDLERS[ $type ]['save'],
			$thumbnail,
			$dest,
			IMAGE_HANDLERS[ $type ]['quality']
		);
	}
}

if ( ! function_exists( 'compress' ) ) {

	function compress( $source, $destination, $quality ) {

		$info = getimagesize( $source );
		if ( $info['mime'] == 'image/jpeg' ) {
			$image = imagecreatefromjpeg( $source );
		} elseif ( $info['mime'] == 'image/gif' ) {
			$image = imagecreatefromgif( $source );
		} elseif ( $info['mime'] == 'image/png' ) {
			$image = imagecreatefrompng( $source );
		}

		imagejpeg( $image, $destination, $quality );

		return $destination;
	}
}

if ( ! function_exists( 'get_products_id' ) ) {
	function get_products_id( $args ) {
		$all_product = [];
		$products    = wc_get_products( $args );
		foreach ( $products as $key => $value ) {
			// array_push($all_product,[
			//     'id' => $value->get_id(),
			// ]);
			$all_product[] = $value->get_id();
		}

		return $all_product;
	}
}

if ( ! function_exists( 'get_categorys' ) ) {
	function get_categorys() {
		$categories     = get_terms( [ 'taxonomy' => 'product_cat' ] );
		$all_categories = [];
		foreach ( $categories as $key => $value ) {
			# code...
			array_push( $all_categories, [
				'id'   => $value->term_id,
				'text' => $value->name
			] );
		}

		return json_encode( $all_categories );
	}
}

if ( ! function_exists( 'get_categorys_detail' ) ) {
	function get_categorys_detail( $id ) {
		$categorie = get_terms( [ 'term_taxonomy_id' => $id ] );

		return $categorie;
	}
}

if ( ! function_exists( 'current_url' ) ) {
	function current_url() {
		global $wp;

		return add_query_arg( $wp->query_vars );
	}
}


if ( ! function_exists( 'formatted_date' ) ) {

	function formatted_date( $timestamp, $format = "d/m/Y - H:i" ) {

		return date( $format, strtotime( $timestamp ) );
	}
}

if ( ! function_exists( 'cek_is_active' ) ) {

	function cek_is_active( $data ) {

		return '<span class="badge ' . ( $data == 1 ? 'badge-success' : 'badge-danger' ) . ' p-2">' . ( $data == 1 ? 'Active' : 'Non Active' ) . '</span>';
	}
}

if ( ! function_exists( 'cek_type' ) ) {

	function cek_type( $type ) {
		$data['image'] = '';
		$data['text']  = '';
		if ( $type == 'special' ) {
			$data['image'] = revo_url() . '/assets/images/example_special.jpg';
			$data['text']  = 'Pannel 1 ( Default : Special )';
		}

		if ( $type == 'our_best_seller' ) {
			$data['image'] = revo_url() . '/assets/images/example_bestseller.jpg';
			$data['text']  = 'Pannel 2 ( Default : Our Best Seller )';
		}

		if ( $type == 'recomendation' ) {
			$data['image'] = revo_url() . '/assets/images/example_recomend.jpg';
			$data['text']  = 'Pannel 2 ( Default : Recomendation )';
		}

		$data['text'] = '<span class="badge badge-primary p-2">' . $data['text'] . '</span>';

		return $data;
	}
}

if ( ! function_exists( 'cek_flash_sale_end' ) ) {

	function cek_flash_sale_end() {

		global $wpdb;

		$date = date( 'Y-m-d H:i:s' );

		$get = $wpdb->get_results( "SELECT id FROM `revo_flash_sale` WHERE is_deleted = 0 AND start < '" . $date . "' AND end < '" . $date . "' AND is_active = 1", OBJECT );

		foreach ( $get as $key => $value ) {
			$query = $wpdb->update(
				'revo_flash_sale',
				[ 'is_active' => '0' ],
				array( 'id' => $value->id )
			);
		}
	}
}

if ( ! function_exists( 'get_user' ) ) {

	function get_user( $email ) {

		$user = get_user_by( 'email', $email );

		return $user;
	}
}

if ( ! function_exists( 'get_authorization_header' ) ) {
	function get_authorization_header() {
		if ( ! empty( $_SERVER['HTTP_AUTHORIZATION'] ) ) {
			return wp_unslash( $_SERVER['HTTP_AUTHORIZATION'] ); // WPCS: sanitization ok.
		}

		if ( function_exists( 'getallheaders' ) ) {
			$headers = getallheaders();
			// Check for the authoization header case-insensitively.
			foreach ( $headers as $key => $value ) {
				if ( 'authorization' === strtolower( $key ) ) {
					return $value;
				}
			}
		}

		return '';
	}
}

if ( ! function_exists( 'security_0auth' ) ) {

	function security_0auth() {
		$current_url = home_url( $_SERVER['REQUEST_URI'] );
		$current_url = explode( '/', $current_url );
		$current_url = end( $current_url );

		if ( $current_url != 'disabled-service' ) {
			require_once REVO_WOO_ABSPATH . 'includes/classes/class-revo-woo-authentication.php';

			$cek = cek_internal_license_code();

			if ( $cek == false ) {
				$result = [ 'status' => 'error', 'message' => 'input license first !' ];
				echo json_encode( $result );
				exit();
			}
		}
	}
}

if ( ! function_exists( 'query_check_plugin_active' ) ) {

	function query_check_plugin_active( $search ) {

		$active_plugins = get_option( 'active_plugins' );

		foreach ( $active_plugins as $plugin ) {

			if ( strpos( $plugin, $search ) !== false ) {

				if ( strpos( $plugin, 'revo-kasir' ) ) {

					$cek = cek_internal_license_code_pos();

					if ( $cek == true ) {

						return true;
					}
				} else {
					return true;
				}
			}

			// if ( str_contains($plugin, $search) ) {

			// 	$cek = cek_internal_license_code_pos();

			// 		if ($cek == true) {
			// 			return true;
			// 		}

			// }

		}

		return false;
	}
}

if ( ! function_exists( 'check_live_chat' ) ) {

	function check_live_chat() {

		$query_LiveChatStatus = pos_query_revo_pos_mobile_variable( '"live_chat_status"', 'sort' );
		$liveChatStatus       = empty( $query_LiveChatStatus ) ? 'hide' : $query_LiveChatStatus[0]->description;

		if ( $liveChatStatus == 'hide' ) {
			$result = [ 'status' => 'error', 'message' => 'Live chat disabled !' ];
		}

		$check_revopos_active = query_check_plugin_active( 'Plugin-revo-kasir' );

		if ( ! $check_revopos_active ) {
			$result = [ 'status' => 'error', 'message' => 'Plugin RevoPOS not installed or activated !' ];
		}

		if ( $check_revopos_active && $liveChatStatus == 'show' ) {
			$result = true;
		}

		return $result;
	}
}

if ( ! function_exists( 'query_hit_products' ) ) {

	function query_hit_products( $id, $user_id ) {
		global $wpdb;

		return $wpdb->get_row( "SELECT count(id) as is_wistlist FROM `revo_hit_products` WHERE products = '$id' AND user_id = '$user_id' AND type = 'wistlist'", OBJECT );
	}
}

if ( ! function_exists( 'query_all_hit_products' ) ) {

	function query_all_hit_products( $user_id ) {
		global $wpdb;

		return $wpdb->get_results( "SELECT * FROM `revo_hit_products` WHERE user_id = '$user_id' AND type = 'wistlist'", OBJECT );
	}
}

if ( ! function_exists( 'insert_update_MV' ) ) {

	function insert_update_MV( $where, $id, $desc ) {
		global $wpdb;

		$query_data                = $where;
		$query_data['description'] = $desc;

		$success = 0;
		if ( $id != 0 ) {
			$where['id']   = $id;
			$update_status = $wpdb->update( 'revo_mobile_variable', $query_data, $where );

			if ( $update_status !== false ) {
				$success = 1;
			}
		} else {
			$wpdb->insert( 'revo_mobile_variable', $query_data );
			if ( $wpdb->insert_id > 0 ) {
				$success = 1;
			}
		}

		return $success;
	}
}

if ( ! function_exists( 'access_key' ) ) {

	function access_key() {
		global $wpdb;
		$query = "SELECT * FROM `revo_pos_access_key` ORDER BY created_at DESC limit 1";

		return $wpdb->get_row( $query, OBJECT );
	}
}

if ( ! function_exists( 'get_products_woocomerce' ) ) {

	function get_products_woocomerce( $layout, $api, $request ) {
		$params = array( 'order' => 'desc', 'orderby' => 'date' );
		if ( isset( $layout['category'] ) ) {
			$params['category'] = $layout['category'];
		}
		if ( isset( $layout['tag'] ) ) {
			$params['tag'] = $layout['tag'];
		}
		if ( isset( $layout['feature'] ) ) {
			$params['feature'] = $layout['feature'];
		}

		$request->set_query_params( $params );

		$response = $api->get_items( $request );

		return $response->get_data();
	}
}

if ( ! function_exists( 'send_FCM' ) ) {

	function send_FCM( $token, $notification, $extend ) {

		$data = access_key();

		$server_key = $data->firebase_server_key;

		if ( $server_key ) {
			$body = array(
				"notification" => $notification,
				"to"           => $token,
				"data"         => $extend
			);

			$body = json_encode( $body );
			// $body = '{ "notification": { "title": "coba title", "body": "coba body" }, "to" : "cAayzcaKRjykBzw_3LxnEN:APA91bFJi8zxwtA1rRRXkQ1P5NM2vo-6ZiMLa6zRFcATw6eImYZLun7EK79Rs7ro9ojjDMwkcTIU3Vj4SLQiqL4tXixuqUU_ZStEpEaiG5tWyWVmDceIghMaK-jJBsMfkT7s2MH5N2Gy" }';
			$curl = curl_init();
			curl_setopt_array( $curl, array(
				CURLOPT_URL            => "https://fcm.googleapis.com/fcm/send",
				CURLOPT_RETURNTRANSFER => true,
				CURLOPT_ENCODING       => "",
				CURLOPT_MAXREDIRS      => 10,
				CURLOPT_TIMEOUT        => 30,
				CURLOPT_HTTP_VERSION   => CURL_HTTP_VERSION_1_1,
				CURLOPT_CUSTOMREQUEST  => "POST",
				CURLOPT_HTTPHEADER     => array(
					"Content-Type: application/json",
					"Authorization: key=$server_key"
				),
				CURLOPT_POSTFIELDS     => $body,
			) );

			$response = curl_exec( $curl );

			$err = curl_error( $curl );

			curl_close( $curl );

			if ( $err ) {
				return 'error';
			}

			return json_decode( $response );
		}

		return 'error';
	}
}

if ( ! function_exists( 'cek_raw' ) ) {

	function cek_raw( $key = '' ) {
		$json   = file_get_contents( 'php://input' );
		$params = json_decode( $json );


		if ( $params and $key ) {
			if ( @$params->$key ) {
				$text = $params->$key;

				//    			// Strip HTML Tags
				// $clear = strip_tags($text);
				// // Clean up things like &amp;
				// $clear = html_entity_decode($clear);
				// // Strip out any url-encoded stuff
				// $clear = urldecode($clear);
				// // Replace Multiple spaces with single space
				// $clear = preg_replace('/ +/', ' ', $clear);
				// // Trim the string of leading/trailing space
				// $clear = trim($clear);

				return $text;
			}
		}

		return '';
	}
}

if ( ! function_exists( 'get_user_token' ) ) {

	function get_user_token( $where = '' ) {
		global $wpdb;
		// $query = "SELECT token,user_id FROM `revo_token_firebase` $where GROUP BY token ORDER BY created_at DESC";
		$query = "SELECT token,user_id FROM `revo_token_firebase` $where ORDER BY created_at DESC";

		return $wpdb->get_results( $query, OBJECT );
	}
}

if ( ! function_exists( 'pos_get_user_token' ) ) {

	function pos_get_user_token( $where = '' ) {
		global $wpdb;
		$query = "SELECT token FROM `revo_pos_token_firebase` $where GROUP BY token ORDER BY created_at DESC";

		return $wpdb->get_results( $query, OBJECT );
	}
}

if ( ! function_exists( 'rv_total_sales' ) ) {

	function rv_total_sales( $product ) {
		$product_id = $product->get_id();
		if ( ! $product ) {
			return 0;
		}

		$total_sales = is_a( $product, 'WC_Product_Variation' ) ? get_post_meta( $product_id, 'total_sales', true ) : $product->get_total_sales();

		return $total_sales;
	}
}

if ( ! function_exists( 'get_popular_categories' ) ) {

	function get_popular_categories() {
		global $wpdb;
		$data_categories = $wpdb->get_results( "SELECT title,categories FROM revo_popular_categories WHERE is_deleted = 0 ORDER BY created_at DESC", OBJECT );

		return $data_categories;
	}
}

if ( ! function_exists( 'cek_license_code' ) ) {
	function cek_license_code( $data ) {

		$body = array(
			"domain"       => $_SERVER['SERVER_NAME'],
			"key"          => $data['description'],
			"product_type" => "revo_shop",
			"useEnvato"    => $data['title'] == 'envato'
		);

		$body = json_encode( $body );
		$curl = curl_init();
		curl_setopt_array( $curl, array(
			CURLOPT_URL            => "https://activation.revoapps.net/wp-json/license/confirm",
			CURLOPT_RETURNTRANSFER => true,
			CURLOPT_ENCODING       => "",
			CURLOPT_MAXREDIRS      => 10,
			CURLOPT_TIMEOUT        => 30,
			CURLOPT_HTTP_VERSION   => CURL_HTTP_VERSION_1_1,
			CURLOPT_CUSTOMREQUEST  => "POST",
			CURLOPT_HTTPHEADER     => array(
				"Content-Type: application/json",
			),
			CURLOPT_POSTFIELDS     => $body,
		) );

		$response = curl_exec( $curl );

		$err = curl_error( $curl );

		curl_close( $curl );

		if ( $err ) {
			return 'error';
		}

		return json_decode( $response );
	}
}

if ( ! function_exists( 'data_default_seeder' ) ) {
	function data_default_seeder( $type ) {

		if ( $type == 'splashscreen' ) {
			$data = array(
				'slug'        => 'splashscreen',
				'title'       => '',
				'image'       => revo_url() . 'assets/images/default_logo.png',
				'description' => 'Welcome',
			);
		}

		if ( $type == 'intro_page_status' ) {
			$data = array(
				'slug'        => 'intro_page_status',
				'title'       => '',
				'image'       => get_logo(),
				'description' => 'show',
			);
		}

		if ( $type == 'kontak_wa' ) {
			$data = array(
				'slug'        => 'kontak',
				'title'       => 'wa',
				'image'       => '',
				'description' => '62987654321',
			);
		}

		if ( $type == 'kontak_phone' ) {
			$data = array(
				'slug'        => 'kontak',
				'title'       => 'phone',
				'image'       => '',
				'description' => '62987654321',
			);
		}

		if ( $type == 'kontak_sms' ) {
			$data = array(
				'slug'        => 'sms',
				'title'       => 'link sms',
				'image'       => '',
				'description' => '62987654321',
			);
		}

		if ( $type == 'sms' ) {
			$data = array(
				'slug'        => 'kontak',
				'title'       => 'sms',
				'image'       => '',
				'description' => '62987654321',
			);
		}

		if ( $type == 'about' ) {
			$data = array(
				'slug'        => 'about',
				'title'       => 'link about',
				'image'       => '',
				'description' => get_site_url(),
			);
		}

		if ( $type == 'privacy_policy' ) {
			$data = array(
				'slug'        => 'privacy_policy',
				'title'       => 'link Privacy Policy',
				'image'       => '',
				'description' => get_site_url(),
			);
		}

		if ( $type == 'term_condition' ) {
			$data = array(
				'slug'        => 'term_condition',
				'title'       => 'link term & condition',
				'image'       => '',
				'description' => get_site_url(),
			);
		}

		if ( $type == 'license_code' ) {
			$data = array(
				'slug'        => 'license_code',
				'title'       => '',
				'image'       => '',
				'description' => '',
			);
		}

		if ( $type == 'cs' ) {
			$data = array(
				'slug'        => 'cs',
				'title'       => 'customer service',
				'image'       => '',
				'description' => '',
			);
		}

		if ( $type == 'logo' ) {
			$data = array(
				'slug'        => 'logo',
				'title'       => 'Mobile Revo Apps',
				'image'       => revo_url() . 'assets/images/default_logo.png',
				'description' => '',
			);
		}

		if ( $type == 'intro_page_1' ) {
			$data = array(
				'slug'        => 'intro_page',
				'title'       => '{"title": "Manage Everything"}',
				'image'       => revo_url() . 'assets/images/revo-woo-onboarding-01.jpg',
				'description' => '{"description": "Completely manage your store from the dashboard, including onboarding/intro changes, sliding banners, posters, home, and many more."}',
				'sort'        => 1,
			);
		}

		if ( $type == 'intro_page_2' ) {
			$data = array(
				'slug'        => 'intro_page',
				'title'       => '{"title": "Support All Payments"}',
				'image'       => revo_url() . 'assets/images/revo-woo-onboarding-02.jpg',
				'description' => '{"description": "Pay for the transaction using all the payment methods you want. Including paypal, razorpay, bank transfer, BCA, Mandiri, gopay, or ovo."}',
				'sort'        => 2,
			);
		}

		if ( $type == 'intro_page_3' ) {
			$data = array(
				'slug'        => 'intro_page',
				'title'       => '{"title": "Support All Shipping Methods"}',
				'image'       => revo_url() . 'assets/images/revo-woo-onboarding-03.jpg',
				'description' => '{"description": "The shipping method according to your choice, which is suitable for your business. All can be arranged easily."}',
				'sort'        => 3,
			);
		}

		if ( $type == 'empty_images_1' ) {
			$data = array(
				'slug'        => 'empty_image',
				'title'       => "404_images",
				'image'       => revo_url() . 'assets/images/404.png',
				'description' => "450 x 350px",
			);
		}

		if ( $type == 'empty_images_2' ) {
			$data = array(
				'slug'        => 'empty_image',
				'title'       => "thanks_order",
				'image'       => revo_url() . 'assets/images/thanks_order.png',
				'description' => "600 x 420px",
			);
		}

		if ( $type == 'empty_images_3' ) {
			$data = array(
				'slug'        => 'empty_image',
				'title'       => "empty_transaksi",
				'image'       => revo_url() . 'assets/images/no_transaksi.png',
				'description' => "260 x 300px",
			);
		}

		if ( $type == 'empty_images_4' ) {
			$data = array(
				'slug'        => 'empty_image',
				'title'       => "search_empty",
				'image'       => revo_url() . 'assets/images/search_empty.png',
				'description' => "260 x 300px",
			);
		}

		if ( $type == 'empty_images_5' ) {
			$data = array(
				'slug'        => 'empty_image',
				'title'       => "login_required",
				'image'       => revo_url() . 'assets/images/404.png',
				'description' => "260 x 300px",
			);
		}

		if ( $type == 'empty_images_6' ) {
			$data = array(
				'slug'        => 'empty_image',
				'title'       => "coupon_empty",
				'image'       => revo_url() . 'assets/images/404.png',
				'description' => "260 x 300px",
			);
		}

		if ( $type == 'app_primary_color' ) {
			$data = array(
				'slug'        => 'app_color',
				'title'       => 'primary',
				'description' => 'ED1D1D',
			);
		}

		if ( $type == 'app_secondary_color' ) {
			$data = array(
				'slug'        => 'app_color',
				'title'       => 'secondary',
				'description' => '960000',
			);
		}

		if ( $type == 'app_button_color' ) {
			$data = array(
				'slug'        => 'app_color',
				'title'       => 'button_color',
				'description' => 'ffffff',
			);
		}

		if ( $type == 'app_text_button_color' ) {
			$data = array(
				'slug'        => 'app_color',
				'title'       => 'text_button_color',
				'description' => 'ffffff',
			);
		}

		if ( strpos( $type, 'slider_banner_' ) !== false ) {
			global $wpdb;
			$post = $wpdb->get_row( "SELECT ID, post_title, post_type FROM {$wpdb->prefix}posts WHERE post_status = 'publish' AND post_type IN ('product', 'post') ORDER BY RAND()" );

			if ( empty( $post ) ) {
				$post             = new stdClass;
				$post->ID         = null;
				$post->post_type  = '';
				$post->post_title = '';
			}

			$explode_type      = explode( '_', $type );
			$key_slider_banner = end( $explode_type );
			$default_images    = [
				'https://demoonlineshop.revoapps.id/wp-content/uploads/revo/1a612234199c4d98097f75d5b1b828d4.jpg',
				'https://demoonlineshop.revoapps.id/wp-content/uploads/revo/f4bdb48bad2c59f21ec023e8822fd526.jpg',
				'https://demoonlineshop.revoapps.id/wp-content/uploads/revo/d0ed1e07b24da8066041c1b38c986d09.jpg',
				'https://demoonlineshop.revoapps.id/wp-content/uploads/revo/028a4e2b376760a7200d349f468eb619.jpg',
				'https://demoonlineshop.revoapps.id/wp-content/uploads/revo/c299684c6f59ed3184a224c19219b8a3.jpg'
			];

			$data = array(
				'order_by'     => $key_slider_banner,
				'product_id'   => $post->ID,
				'title'        => 'Slider ' . $key_slider_banner,
				'images_url'   => $default_images[ $key_slider_banner - 1 ],
				'product_name' => $post->post_type == 'post' ? 'blog|' . $post->post_title : $post->post_title,
				'is_active'    => 1,
				'is_deleted'   => 0,
				'created_at'   => date( 'Y-m-d H:i:s' ),
			);
		}

		if ( strpos( $type, 'home_categories_' ) !== false ) {
			$category = array_values( get_categories( [
				'limit'    => 1,
				'order'    => 'rand',
				'order_by' => 'rand'
			] ) );

			$explode_type      = explode( '_', $type );
			$key_home_category = end( $explode_type );
			$default_images    = [
				'https://demoonlineshop.revoapps.id/wp-content/uploads/revo/e9477daf9ef38c531840b1b2838929a7.png',
				'https://demoonlineshop.revoapps.id/wp-content/uploads/revo/8edb4a06456630656290a2602a405731.png',
				'https://demoonlineshop.revoapps.id/wp-content/uploads/revo/b3b6a4decfb91c94f55f4229967ee3b7.png',
				'https://demoonlineshop.revoapps.id/wp-content/uploads/revo/b5dac440aaa37463c46b536a37201bb1.png'
			];

			$data = array(
				'order_by'      => $key_home_category,
				'image'         => $default_images[ $key_home_category - 1 ],
				'category_id'   => ! empty( $category ) ? $category[0]->term_id : '',
				'category_name' => ! empty( $category ) ? '{"title": "' . $category[0]->name . '"}' : '',
				'is_active'     => 1,
				'is_deleted'    => 0,
				'created_at'    => date( 'Y-m-d H:i:s' ),
			);
		}

		if ( strpos( $type, 'poster_banner_' ) !== false ) {
			global $wpdb;
			$post = $wpdb->get_row( "SELECT ID, post_title, post_type FROM {$wpdb->prefix}posts WHERE post_status = 'publish' AND post_type IN ('product', 'post') ORDER BY RAND()" );

			if ( empty( $post ) ) {
				$post             = new stdClass;
				$post->ID         = null;
				$post->post_type  = '';
				$post->post_title = '';
			}

			$explode_type      = explode( '_', $type );
			$key_poster_banner = end( $explode_type );
			$default_images    = [
				'https://demoonlineshop.revoapps.id/wp-content/uploads/revo/680eccbc05e6686bf936058177f47f94.jpg',
				'https://demoonlineshop.revoapps.id/wp-content/uploads/revo/50650c799c0e3b3e3aa35ab570cad909.jpg',
				'https://demoonlineshop.revoapps.id/wp-content/uploads/revo/b8fd6b4442d4c0829c16efe304d271a1.jpg',
				'https://demoonlineshop.revoapps.id/wp-content/uploads/revo/79e42f73613c01731b60b5255c1bdfa7.jpg',
				'https://demoonlineshop.revoapps.id/wp-content/uploads/revo/92ccabcff6f706c382f6106e3a342e04.jpg',
				'https://demoonlineshop.revoapps.id/wp-content/uploads/revo/1084db46cb5335fe7d3f53df890d2aed.jpg',
				'https://demoonlineshop.revoapps.id/wp-content/uploads/revo/9ec13a9ed5e217e1fc71d42005cb1b04.jpg',
				'https://demoonlineshop.revoapps.id/wp-content/uploads/revo/9e7922ce10be9a9d325f82b3952a86bd.jpg',
				'https://demoonlineshop.revoapps.id/wp-content/uploads/revo/a5db5bd1947780641d79bdfad9858436.jpg',
				'https://demoonlineshop.revoapps.id/wp-content/uploads/revo/df41f9e1d2bf582595984ffd8c709e42.png'
			];

			$data = array(
				'order_by'     => $key_poster_banner,
				'product_id'   => $post->ID,
				'product_name' => $post->post_type == 'post' ? 'blog|' . $post->post_title : $post->post_title,
				'image'        => $default_images[ $key_poster_banner - 1 ],
				'type'         => $key_poster_banner <= 4 ? 'Special Promo' : ( $key_poster_banner == 10 ? 'Blog Banner' : 'Love These Items' ),
				'is_active'    => 1,
				'is_deleted'   => 0,
				'created_at'   => date( 'Y-m-d H:i:s' ),
			);
		}

		if ( $type == 'flash_sale' ) {
			global $wpdb;
			$products = $wpdb->get_results( "SELECT ID, post_title FROM {$wpdb->prefix}posts WHERE post_status = 'publish' AND post_type = 'product' ORDER BY RAND() lIMIT 3" );

			if ( empty( $products ) ) {
				$ids_product = null;
			} else {
				$ids_product = '[';

				foreach ( $products as $p_key => $p ) {
					$ids_product .= '"' . $p->ID . '"';
					$ids_product .= array_key_last( $products ) != $p_key ? ',' : '';
				}

				$ids_product .= ']';
			}

			$data = array(
				'title'      => 'Flash Sale 1',
				'start'      => date( 'Y-m-d 00:00:00' ),
				'end'        => date( 'Y-m-d 23:59:59', strtotime( '+30 days' ) ),
				'products'   => $ids_product,
				'image'      => 'https://demoonlineshop.revoapps.id/wp-content/uploads/revo/2d96d786490aa68582926d3860071b3e.png',
				'is_active'  => 1,
				'is_deleted' => 0,
				'created_at' => date( 'Y-m-d H:i:s' ),
			);
		}

		if ( $type == 'popular_categories' ) {
			$categories = array_values( get_categories( [
				'limit'    => 3,
				'order'    => 'rand',
				'order_by' => 'rand'
			] ) );

			if ( empty( $categories ) ) {
				$ids_category = null;
			} else {
				$ids_category = '[';

				foreach ( $categories as $c_key => $c ) {
					$ids_category .= '"' . $c->term_id . '"';
					$ids_category .= array_key_last( $categories ) != $c_key ? ',' : '';
				}

				$ids_category .= ']';
			}

			$data = array(
				'title'      => 'Popular Category 1',
				'categories' => $ids_category,
				'is_deleted' => 0,
				'created_at' => date( 'Y-m-d H:i:s' ),
			);
		}

		if ( $type == 'searchbar' ) {
			$data = array(
				'slug'        => 'searchbar_text',
				'title'       => 'Search Bar Text',
				'description' => json_encode( array(
					"text_1" => "Coca Cola",
					"text_2" => "Bread Toaster",
					"text_3" => "Apple Macbook",
					"text_4" => "Vegetables Salad",
					"text_5" => "Fresh Lemon"
				) )
			);
		}

		if ( $type == 'sosmed_link' ) {
			$sosmed            = new stdClass;
			$sosmed->whatsapp  = "https://wa.me/62345678901";
			$sosmed->facebook  = "https://www.facebook.com/myrevoapps/";
			$sosmed->instagram = "https://www.instagram.com/myrevoapps/";
			$sosmed->youtube   = "https://www.youtube.com/watch?v=myrevoapps";
			$sosmed->tiktok    = "https://www.tiktok.com/@myrevoapps";

			$data = array(
				'slug'        => 'sosmed_link',
				'title'       => 'Social Media Link',
				'image'       => '',
				'description' => json_encode( $sosmed ),
			);
		}

		if ( strpos( $type, 'additional_products_' ) !== false ) {
			global $wpdb;
			$products = $wpdb->get_results( "SELECT ID, post_title FROM {$wpdb->prefix}posts WHERE post_status = 'publish' AND post_type = 'product' ORDER BY RAND() LIMIT 3" );

			if ( empty( $products ) ) {
				$ids_product = null;
			} else {
				$ids_product = '[';

				foreach ( $products as $p_key => $p ) {
					$ids_product .= '"' . $p->ID . '"';
					$ids_product .= array_key_last( $products ) != $p_key ? ',' : '';
				}

				$ids_product .= ']';
			}

			$explode_type      = explode( '_', $type );
			$key_poster_banner = end( $explode_type );
			$data_default      = [
				1 => [
					'type'        => 'special',
					'title'       => 'Special Promo : App Only',
					'description' => 'For You',
				],
				2 => [
					'type'        => 'our_best_seller',
					'title'       => 'Best Seller',
					'description' => 'Get The Best Products',
				],
				3 => [
					'type'        => 'recomendation',
					'title'       => 'Recomendations For You',
					'description' => 'Recommendation Products',
				]
			];

			$data = array(
				'type'        => $data_default[ $key_poster_banner ]['type'],
				'title'       => $data_default[ $key_poster_banner ]['title'],
				'description' => $data_default[ $key_poster_banner ]['description'],
				'products'    => $ids_product
			);
		}

		return $data;
	}
}

if ( ! function_exists( 'cek_internal_license_code' ) ) {
	function cek_internal_license_code() {
		global $wpdb;

		$now   = date( 'Y-m-d H:i:s' );
		$query = "SELECT update_at FROM `revo_mobile_variable` WHERE slug = 'license_code' AND description != '' AND update_at is not NULL";
		$get   = $wpdb->get_row( $query, OBJECT );

		if ( ! empty( $get ) ) {
			if ( $get->update_at > $now ) {
				return true;
			}
		}

		return false;
	}
}

if ( ! function_exists( 'cek_internal_license_code_pos' ) ) {
	function cek_internal_license_code_pos() {
		global $wpdb;

		$now   = date( 'Y-m-d H:i:s' );
		$query = "SELECT update_at FROM `revo_pos_mobile_variable` WHERE slug = 'revo_pos_license_code' AND description != '' AND update_at is not NULL";
		$get   = $wpdb->get_row( $query, OBJECT );

		if ( ! empty( $get ) ) {
			if ( $get->update_at > $now ) {
				return true;
			}
		}

		return false;
	}
}

if ( ! function_exists( 'get_conversations' ) ) {

	function get_conversations( $user_id, $receiver_id = null ) {
		global $wpdb;

		$where = 'rc.sender_id = ' . $user_id . ' OR rc.receiver_id = ' . $user_id;
		if ( $receiver_id ) {
			$where = '( rc.sender_id = ' . $user_id . ' AND rc.receiver_id = ' . $receiver_id . ' ) OR ( rc.receiver_id = ' . $user_id . ' AND rc.sender_id = ' . $receiver_id . ' )';
		}

		$query = "SELECT rc.*, 
						(SELECT rcm.message FROM `revo_conversation_messages` rcm WHERE ($where) AND rcm.conversation_id = rc.id ORDER BY rcm.created_at DESC LIMIT 1) AS last_message,
						(SELECT rcm.created_at FROM `revo_conversation_messages` rcm WHERE ($where) AND rcm.conversation_id = rc.id ORDER BY rcm.created_at DESC LIMIT 1) AS created_chat,
						(SELECT count(rcm.id) FROM `revo_conversation_messages` rcm WHERE rcm.receiver_id = $user_id AND rcm.conversation_id = rc.id AND rcm.is_read = 1) AS unread,
						CASE
						   when rc.sender_id != $user_id then 'seller'
						   when rc.receiver_id != $user_id then 'buyer'
						END as status
						FROM `revo_conversations` rc WHERE $where GROUP BY rc.id ORDER BY created_chat DESC ";

		if ( $receiver_id ) {
			return $wpdb->get_row( $query, OBJECT );
		} else {
			return $wpdb->get_results( $query, OBJECT );
		}
	}
}

if ( ! function_exists( 'get_conversations_detail' ) ) {

	function get_conversations_detail( $user_id, $chat_id = null ) {
		global $wpdb;

		$where = ' (rcm.sender_id = ' . $user_id . ' OR rcm.receiver_id = ' . $user_id . ') ';
		if ( $chat_id ) {
			$where .= ' AND rcm.conversation_id = ' . $chat_id;
		}

		// if ($chat_id) {
		// 	$where .= ' AND rcm.conversation_id = '.$chat_id;
		// }

		$seller_id = cek_raw( 'seller_id' );
		if ( $seller_id ) {
			$where .= ' AND rc.receiver_id = ' . $seller_id;
		}

		$data['is_read'] = 0;
		$wpdb->update( 'revo_conversation_messages', $data, [
			'is_read'         => 1,
			'receiver_id'     => $user_id,
			'conversation_id' => $chat_id
		] );

		$query = " SELECT 
						rcm.conversation_id as chat_id,
						rcm.sender_id,
						rcm.receiver_id,
						rcm.message,
						rcm.type,
						rcm.image,
						rcm.post_id,
						CASE
						   when LOCATE('http',rcm.message) > 0 then 'image'
						   when LOCATE('https',rcm.message) > 0 then 'image'
						   else  'text'
						END as type_message,
						CASE
						   when rcm.sender_id = rc.sender_id then 'seller'
						   when rcm.sender_id = rc.receiver_id then 'buyer'
						END as status,
						CASE
						   when rcm.sender_id = $user_id then 'right'
						   when rcm.receiver_id = $user_id then 'left'
						END as potition,
						rcm.created_at
					FROM `revo_conversation_messages` as rcm INNER JOIN `revo_conversations` as rc on rcm.conversation_id = rc.id  WHERE $where GROUP BY rcm.id ORDER BY rcm.created_at ASC ";

		return $wpdb->get_results( $query, OBJECT );
	}
}

if ( ! function_exists( 'get_oauth_parameters' ) ) {

	function get_oauth_parameters() {
		$params = array_merge( $_GET, $_POST ); // WPCS: CSRF ok.
		$params = wp_unslash( $params );

		$header = '';

		if ( ! empty( $_SERVER['HTTP_AUTHORIZATION'] ) ) {
			$header = wp_unslash( $_SERVER['HTTP_AUTHORIZATION'] ); // WPCS: sanitization ok.
		}

		if ( function_exists( 'getallheaders' ) ) {
			$headers = getallheaders();
			// Check for the authoization header case-insensitively.
			foreach ( $headers as $key => $value ) {
				if ( 'authorization' === strtolower( $key ) ) {
					$header = $value;
				}
			}
		}

		if ( ! empty( $header ) ) {
			// Trim leading spaces.
			$header        = trim( $header );
			$header_params = parse_header( $header );

			if ( ! empty( $header_params ) ) {
				$params = array_merge( $params, $header_params );
			}
		}

		$param_names = array(
			'oauth_consumer_key',
			'oauth_timestamp',
			'oauth_nonce',
			'oauth_signature',
			'oauth_signature_method',
		);

		$errors   = array();
		$have_one = false;

		// Check for required OAuth parameters.
		foreach ( $param_names as $param_name ) {
			if ( empty( $params[ $param_name ] ) ) {
				$errors[] = $param_name;
			} else {
				$have_one = true;
			}
		}

		// All keys are missing, so we're probably not even trying to use OAuth.
		if ( ! $have_one ) {
			return array();
		}

		// If we have at least one supplied piece of data, and we have an error,
		// then it's a failed authentication.
		if ( ! empty( $errors ) ) {
			$message = sprintf(
			/* translators: %s: amount of errors */
				_n( 'Missing OAuth parameter %s', 'Missing OAuth parameters %s', count( $errors ), 'woocommerce' ),
				implode( ', ', $errors )
			);

			$this->set_error( new WP_Error( 'woocommerce_rest_authentication_missing_parameter', $message, array( 'status' => 401 ) ) );

			return array();
		}

		return $params;
	}

	function parse_header( $header ) {
		if ( 'OAuth ' !== substr( $header, 0, 6 ) ) {
			return array();
		}

		// From OAuth PHP library, used under MIT license.
		$params = array();
		if ( preg_match_all( '/(oauth_[a-z_-]*)=(:?"([^"]*)"|([^,]*))/', $header, $matches ) ) {
			foreach ( $matches[1] as $i => $h ) {
				$params[ $h ] = urldecode( empty( $matches[3][ $i ] ) ? $matches[4][ $i ] : $matches[3][ $i ] );
			}
			if ( isset( $params['realm'] ) ) {
				unset( $params['realm'] );
			}
		}

		return $params;
	}
}

if ( ! function_exists( 'get_blogs' ) ) {
	function get_blogs() {
		$blogs    = get_posts();
		$all_blog = [];
		foreach ( $blogs as $key => $value ) {
			array_push( $all_blog, [
				'id'   => $value->ID,
				'text' => $value->post_title
			] );
		}

		return json_encode( $all_blog );
	}
}

if ( ! function_exists( 'get_attributes' ) ) {
	function get_attributes( $id = null ) {
		if ( is_null( $id ) ) {
			$attributes = wc_get_attribute_taxonomies();

			$all_attributes = [];
			foreach ( $attributes as $key => $value ) {
				array_push( $all_attributes, [
					'id'   => $value->attribute_id,
					'text' => $value->attribute_label
				] );
			}

			return json_encode( $all_attributes );
		}

		return wc_get_attribute( $id );
	}
}

if ( ! function_exists( 'includes_frontend' ) ) {
	function includes_frontend( $callback = null ) {
		if ( defined( 'WC_ABSPATH' ) ) {
			// WC 3.6+ - Cart and other frontend functions are not included for REST requests.
			include_once WC_ABSPATH . 'includes/wc-cart-functions.php';
			include_once WC_ABSPATH . 'includes/wc-notice-functions.php';
			include_once WC_ABSPATH . 'includes/wc-template-hooks.php';
		}

		if ( null === WC()->session ) {
			$session_class = apply_filters( 'woocommerce_session_handler', 'WC_Session_Handler' );

			WC()->session = new $session_class();
			WC()->session->init();
		}

		if ( null === WC()->customer ) {
			WC()->customer = new WC_Customer( get_current_user_id(), true );
		}

		if ( null === $callback ) {
			if ( null === WC()->cart ) {
				WC()->cart = new WC_Cart();
			}
		} else {
			return $callback();
		}
	}
}

if ( ! function_exists( 'get_json_data' ) ) {
	function get_json_data( $url, $path, $file_name, $search ) {

		global $wp_filesystem;

		$file_url  = $url . $file_name . '.json';
		$file_path = $path . $file_name . '.json';

		try {
			require_once ABSPATH . 'wp-admin/includes/file.php';

			if ( is_null( $wp_filesystem ) ) {
				WP_Filesystem();
			}

			if ( ! $wp_filesystem instanceof WP_Filesystem_Base || ( is_wp_error( $wp_filesystem->errors ) && $wp_filesystem->errors->get_error_code() ) ) {
				throw new Exception( 'WordPress Filesystem Abstraction classes is not available', 1 );
			}

			if ( ! $wp_filesystem->exists( $file_path ) ) {
				throw new Exception( 'JSON file is not exists or unreadable', 1 );
			}

			$json = $wp_filesystem->get_contents( $file_path );
		} catch ( Exception $e ) {
			$json = wp_remote_retrieve_body( wp_remote_get( esc_url_raw( $file_url ) ) );
		}

		$json_data = json_decode( $json, true );

		if ( ! $json_data ) {
			return false;
		}

		if ( $search ) {
			$datas = [];
			foreach ( $json_data as $row ) {
				if ( array_intersect_assoc( $search, $row ) === $search ) {
					array_push( $datas, $row );
				}
			}

			return $datas;
		}

		return $json_data;
	}
}
