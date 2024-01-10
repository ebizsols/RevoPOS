<?php

if (!defined('ABSPATH')) {
    exit;
}

class Revo_Pos_Flutter_User
{
    private $namespace;

    private $namespace_vendor;

    public static $_instance = null;

    public function __construct()
    {
        $this->namespace = REVO_POS_NAMESPACE_API;

        $this->namespace_vendor = 'wc/v2';

        add_action('rest_api_init', array($this, 'register_routes'));
    }

    public function register_routes()
    {
        register_rest_route($this->namespace, '/register', array(
            array(
                'methods'   => 'POST',
                'callback'  => array($this, 'register')
            ),
        ));

        register_rest_route($this->namespace, '/generate_auth_cookie', array(
            array(
                'methods'   => 'POST',
                'callback'  => array($this, 'generate_auth_cookie')
            ),
        ));

        register_rest_route($this->namespace, '/fb_connect', array(
            array(
                'methods'   => 'GET',
                'callback'  => array($this, 'fb_connect')
            ),
        ));

        register_rest_route($this->namespace, '/sms_login', array(
            array(
                'methods'   => 'GET',
                'callback'  => array($this, 'sms_login')
            ),
        ));

        register_rest_route($this->namespace, '/firebase_sms_login', array(
            array(
                'methods'   => 'GET',
                'callback'  => array($this, 'firebase_sms_login')
            ),
        ));

        register_rest_route($this->namespace, '/apple_login', array(
            array(
                'methods'   => 'POST',
                'callback'  => array($this, 'apple_login')
            ),
        ));

        register_rest_route($this->namespace, '/google_login', array(
            array(
                'methods'   => 'GET',
                'callback'  => array($this, 'google_login')
            ),
        ));

        register_rest_route($this->namespace, '/post_comment', array(
            array(
                'methods'   => 'POST',
                'callback'  => array($this, 'post_comment')
            ),
        ));

        register_rest_route($this->namespace, '/get_currentuserinfo', array(
            array(
                'methods'   => 'POST',
                'callback'  => array($this, 'get_currentuserinfo')
            ),
        ));

        register_rest_route($this->namespace, '/update_user_profile', array(
            array(
                'methods'   => 'POST',
                'callback'  => array($this, 'update_user_profile')
            ),
        ));

        register_rest_route($this->namespace, '/send-email-forgot-password', array(
            array(
                'methods'   => 'POST',
                'callback'  => array($this, 'send_email_forgot_password')
            ),
        ));


        register_rest_route($this->namespace_vendor,  '/upload-image', array(
            array(
                'methods' => WP_REST_Server::CREATABLE,
                'callback' => array($this, 'upload_image'),
                'args' => $this->get_params_upload()
            ),
        ));
        register_rest_route($this->namespace_vendor,  '/input-produk', array(
            array(
                'methods' => WP_REST_Server::CREATABLE,
                'callback' => array($this, 'flutter_create_product'),
            ),
        ));
        register_rest_route($this->namespace_vendor,  '/delete-produk', array(
            array(
                'methods' => WP_REST_Server::CREATABLE,
                'callback' => array($this, 'flutter_delete_product'),
            ),
        ));

        register_rest_route($this->namespace,  '/list-produk-gerai', array(
            array(
                'methods' => "POST",
                'callback' => array($this, 'flutter_get_products'),
            ),
        ));
    }

    public function register()
    {
        $json = file_get_contents('php://input');
        $params = json_decode($json);
        $usernameReq = $params->username;
        $emailReq = $params->email;
        $secondsReq = $params->seconds;
        $nonceReq = $params->nonce;
        $roleReq = $params->role;
        if ($roleReq && $roleReq != "subscriber" && $roleReq != "wcfm_vendor" && $roleReq != "seller") {
            return self::sendError("invalid_role", "Role is invalid.", 400);
        }
        $userPassReq = $params->user_pass;
        $userLoginReq = $params->user_login;
        $userEmailReq = $params->user_email;
        $notifyReq = $params->notify;

        $username = sanitize_user($usernameReq);

        $email = sanitize_email($emailReq);

        if ($secondsReq) {
            $seconds = (int) $secondsReq;
        } else {
            $seconds = 120960000;
        }
        if (!validate_username($username)) {
            return self::sendError("invalid_username", "Username is invalid.", 400);
        } elseif (username_exists($username)) {
            return self::sendError("existed_username", "Username already exists.", 400);
        } else {
            if (!is_email($email)) {
                return self::sendError("invalid_email", "E-mail address is invalid.", 400);
            } elseif (email_exists($email)) {
                return self::sendError("existed_email", "E-mail address is already in use.", 400);
            } else {
                if (!$userPassReq) {
                    $params->user_pass = wp_generate_password();
                }

                $allowed_params = array(
                    'user_login', 'user_email', 'user_pass', 'display_name', 'user_nicename', 'user_url', 'nickname', 'first_name',
                    'last_name', 'description', 'rich_editing', 'user_registered', 'role', 'jabber', 'aim', 'yim',
                    'comment_shortcuts', 'admin_color', 'use_ssl', 'show_admin_bar_front',
                );

                $dataRequest = $params;

                foreach ($dataRequest as $field => $value) {
                    if (in_array($field, $allowed_params)) {
                        $user[$field] = trim(sanitize_text_field($value));
                    }
                }

                $user['role'] = $roleReq ? sanitize_text_field($roleReq) : get_option('default_role');
                $user_id = wp_insert_user($user);

                if (is_wp_error($user_id)) {
                    return self::sendError($user_id->get_error_code(), $user_id->get_error_message(), 400);
                }

                // if ($userPassReq && $notifyReq && $notifyReq == 'no') {
                //     $notify = '';
                // } elseif ($notifyReq && $notifyReq != 'no') {
                //     $notify = $notifyReq;
                // }

                // if ($user_id) {
                //     wp_new_user_notification($user_id, '', $notify);
                // }
            }
        }

        $expiration = time() + apply_filters('auth_cookie_expiration', $seconds, $user_id, true);
        $cookie = wp_generate_auth_cookie($user_id, $expiration, 'logged_in');

        return array(
            "cookie" => $cookie,
            "user_id" => $user_id,
        );
    }

    public function generate_auth_cookie()
    {
        $json = file_get_contents('php://input');
        $params = json_decode($json);

        if (!isset($params->username) || !isset($params->username)) {
            return self::sendError("invalid_login", "Invalid params", 400);
        }

        $username = $params->username;
        $password = $params->password;

        if ($params->seconds) {
            $seconds = (int) $params->seconds;
        } else {
            $seconds = 1209600;
        }

        $user = wp_authenticate($username, $password);

        if (is_wp_error($user)) {
            return self::sendError($user->get_error_code(), "Invalid username/email and/or password.", 400);
        }

        $isSeller = in_array("administrator", $user->roles) || in_array("shop_manager", $user->roles) || in_array("wcfm_vendor", $user->roles);
        if (!$isSeller) {
            return self::sendError("invalid_role", "You are not seller", 403);
        }

        $expiration = time() + apply_filters('auth_cookie_expiration', $seconds, $user->ID, true);
        $cookie = wp_generate_auth_cookie($user->ID, $expiration, 'logged_in');
        preg_match('|src="(.+?)"|', get_avatar($user->ID, 512), $avatar);

        return array(
            "cookie" => $cookie,
            "cookie_name" => LOGGED_IN_COOKIE,
            "user" => array(
                "id" => $user->ID,
                "username" => $user->user_login,
                "nicename" => $user->user_nicename,
                "email" => $user->user_email,
                "url" => $user->user_url,
                "registered" => $user->user_registered,
                "displayname" => $user->display_name,
                "firstname" => $user->user_firstname,
                "lastname" => $user->last_name,
                "nickname" => $user->nickname,
                "description" => $user->user_description,
                "capabilities" => $user->wp_capabilities,
                "role" => $user->roles,
                "avatar" => $avatar[1],
            ),
        );
    }

    public function get_currentuserinfo()
    {
        global $json_api;
        $json = file_get_contents('php://input');
        $params = json_decode($json);

        $cookie = $params->cookie;
        if (!isset($cookie)) {
            return self::sendError("invalid_login", "You must include a 'cookie' var in your request. Use the `generate_auth_cookie` method.", 401);
        }

        $user_id = wp_validate_auth_cookie($cookie, 'logged_in');
        if (!$user_id) {
            return self::sendError("invalid_login", "You must include a 'cookie' var in your request. Use the `generate_auth_cookie` method.", 401);
        }
        $user = get_userdata($user_id);
        preg_match('|src="(.+?)"|', get_avatar($user->ID, 32), $avatar);
        $data = array(
            "user" => array(
                "id" => $user->ID,
                "username" => $user->user_login,
                "nicename" => $user->user_nicename,
                "email" => $user->user_email,
                "url" => $user->user_url,
                "registered" => $user->user_registered,
                "displayname" => $user->display_name,
                "firstname" => $user->user_firstname,
                "lastname" => $user->last_name,
                "nickname" => $user->nickname,
                "description" => $user->user_description,
                "capabilities" => $user->wp_capabilities,
                "role" => $user->roles,
                "avatar" => $avatar[1]
            )
        );

        global $wc_points_rewards;
        if (isset($wc_points_rewards)) {
            $points_balance = WC_Points_Rewards_Manager::get_users_points($user_id);
            $points_label   = $wc_points_rewards->get_points_label($points_balance);
            $count        = apply_filters('wc_points_rewards_my_account_points_events', 5, $user_id);
            $current_page = empty($current_page) ? 1 : absint($current_page);

            $args = array(
                'calc_found_rows' => true,
                'orderby' => array(
                    'field' => 'date',
                    'order' => 'DESC',
                ),
                'per_page' => $count,
                'paged'    => $current_page,
                'user'     => $user_id,
            );
            $total_rows = WC_Points_Rewards_Points_Log::$found_rows;
            $events = WC_Points_Rewards_Points_Log::get_points_log_entries($args);

            $data['poin'] = array(
                'points_balance' => $points_balance,
                'points_label'   => $points_label,
                'total_rows'     => $total_rows,
                'page'   => $current_page,
                'count'          => $count,
                'events'         => $events
            );
        }

        return $data;
    }

    public function update_user_profile()
    {
        global $json_api;
        $json = file_get_contents('php://input');
        $params = json_decode($json);
        $cookie = $params->cookie;

        if (!isset($cookie)) {
            return self::sendError("invalid_login", "You must include a 'cookie' var in your request. Use the `generate_auth_cookie` method.", 401);
        }
        $user_id = wp_validate_auth_cookie($cookie, 'logged_in');
        if (!$user_id) {
            return self::sendError("invalid_login", "You must include a 'cookie' var in your request. Use the `generate_auth_cookie` method.", 401);
        }

        $user_update = array('ID' => $user_id);
        if ($params->user_pass) {
            $user = get_user_by('id', $user_id);
            $pass_check = wp_check_password($params->old_pass, $user->data->user_pass, $user_id);
            if (!$pass_check) {
                return self::sendError("invalid_login", "wrong password!", 401);
            }
            $user_update['user_pass'] = $params->user_pass;
        }

        if ($params->user_nicename) {
            $user_update['user_nicename'] = $params->user_nicename;
        }
        if ($params->user_email) {
            $user_update['user_email'] = $params->user_email;
        }
        if ($params->user_url) {
            $user_update['user_url'] = $params->user_url;
        }
        if ($params->display_name) {
            $user_update['display_name'] = $params->display_name;
        }
        if ($params->first_name) {
            $user_update['first_name'] = $params->first_name;
        }
        if ($params->last_name) {
            $user_update['last_name'] = $params->last_name;
        }

        $user_data = wp_update_user($user_update);

        if (is_wp_error($user_data)) {
            // There was an error; possibly this user doesn't exist.
            $return['is_success'] = false;
            $return['cookie'] = $token;
        } else {
            $expiration = time() + apply_filters('auth_cookie_expiration', 120960000, $user_id, true);
            $return['is_success'] = true;
            $return['cookie'] = wp_generate_auth_cookie($user_id, $expiration, 'logged_in');
        }

        return $return;
    }

    public function send_email_forgot_password()
    {
        include '../wp-load.php';

        $json = file_get_contents('php://input');
        $params = json_decode($json);
        $login = $params->email;

        if (empty($login)) {
            $json = array('status' => 'error', 'message' => 'Please enter login user detail');
            echo json_encode($json);
            exit;
        }

        $userdata = get_user_by('email', $login);

        if (empty($userdata)) {
            $userdata = get_user_by('login', $login);
        }

        if (empty($userdata)) {
            $json = array('code' => '101', 'msg' => 'User not found');
            echo json_encode($json);
            exit;
        }

        $user      = new WP_User(intval($userdata->ID));
        $reset_key = get_password_reset_key($user);
        $wc_emails = WC()->mailer()->get_emails();
        $wc_emails['WC_Email_Customer_Reset_Password']->trigger($user->user_login, $reset_key);

        $result = ['status' => 'success', 'message' => 'Password reset link has been sent to your registered email !'];
        echo json_encode($result);
        exit;
    }

    public function get_params_upload()
    {
        $params = array(
            'media_attachment' => array(
                'required'          => false,
                'description'       => __('Image encoded as base64.', 'image-from-base64'),
                'type'              => 'string'
            ),
            'title' => array(
                'required'          => false,
                'description'       => __('The title for the object.', 'image-from-base64'),
                'type'              => 'json'
            ),
            'media_path' => array(
                'description'       => __('Path to directory where file will be uploaded.', 'image-from-base64'),
                'type'              => 'string'
            )
        );
        return $params;
    }

    public function upload_image($request)
    {
        $response = array();
        $json = file_get_contents('php://input');
        $params = json_decode($json);
        try {
            $request['media_path'] = (@$params->media_path != '' ? $params->media_path : '');
            $request['title'] = array('rendered' => (@$params->title != '' ? $params->title : ''));
            $request['media_attachment'] = (@$params->media_attachment != '' ? $params->media_attachment : '');
            $filename = $request['title']['rendered'];
            $img = $request['media_attachment'];
            if (!empty($request['media_path'])) {
                $this->upload_dir = $request['media_path'];
                $this->upload_dir = '/' . trim($this->upload_dir, '/');
                add_filter('upload_dir', array($this, 'change_wp_upload_dir'));
            }

            if (!class_exists('WP_REST_Attachments_Controller')) {
                throw new Exception('WP API not installed.');
            }
            $media_controller = new WP_REST_Attachments_Controller('attachment');
            $decoded = base64_decode($img);

            $permission_check = $media_controller->create_item_permissions_check($request);
            if (is_wp_error($permission_check)) {
                throw new Exception($permission_check->get_error_message());
            }

            $request->set_body($decoded);
            $request->add_header('Content-Disposition', "attachment;filename=\"{$filename}\"");
            $result = $media_controller->create_item($request);
            $response = rest_ensure_response($result);
        } catch (Exception $e) {
            $response['result'] = "error";
            $response['message'] = $e->getMessage();

            return $response;
        }

        if (!empty($request['media_path'])) {
            remove_filter('upload_dir', array($this, 'change_wp_upload_dir'));
            // $response = $request['id'];
        }

        $return = array(
            'id' => $response->data['id'],
            'image' => $response->data['source_url'],
        );

        return $return;
    }

    public function create_product_variation($product_id, $variation_data)
    {
        // Get the Variable product object (parent)
        $product = wc_get_product($product_id);

        $variation_post = array(
            'post_title'  => $product->get_name(),
            'post_name'   => 'product-' . $product_id . '-variation',
            'post_status' => 'publish',
            'post_parent' => $product_id,
            'post_type'   => 'product_variation',
            'guid'        => $product->get_permalink()
        );

        // Creating the product variation
        $variation_id = wp_insert_post($variation_post);

        // Get an instance of the WC_Product_Variation object
        $variation = new WC_Product_Variation($variation_id);

        // Iterating through the variations attributes
        foreach ($variation_data['attributes'] as $attribute => $term_name) {
            $taxonomy = 'pa_' . $attribute; // The attribute taxonomy

            // If taxonomy doesn't exists we create it (Thanks to Carl F. Corneil)
            if (!taxonomy_exists($taxonomy)) {
                register_taxonomy(
                    $taxonomy,
                    'product_variation',
                    array(
                        'hierarchical' => false,
                        'label' => ucfirst($attribute),
                        'query_var' => true,
                        'rewrite' => array('slug' => sanitize_title($attribute)), // The base slug
                    ),
                );
            }

            // Check if the Term name exist and if not we create it.
            if (!term_exists($term_name, $taxonomy))
                wp_insert_term($term_name, $taxonomy); // Create the term

            $term_slug = get_term_by('name', $term_name, $taxonomy)->slug; // Get the term slug

            // Get the post Terms names from the parent variable product.
            $post_term_names =  wp_get_post_terms($product_id, $taxonomy, array('fields' => 'names'));

            // Check if the post term exist and if not we set it in the parent variable product.
            if (!in_array($term_name, $post_term_names))
                wp_set_post_terms($product_id, $term_name, $taxonomy, true);

            // Set/save the attribute data in the product variation
            update_post_meta($variation_id, 'attribute_' . $taxonomy, $term_slug);
        }

        ## Set/save all other data

        // SKU
        if (!empty($variation_data['sku']))
            $variation->set_sku($variation_data['sku']);

        // Prices
        if (empty($variation_data['sale_price'])) {
            throwJson(["nohand"]);
            $variation->set_price($variation_data['regular_price']);
        } else {
            $variation->set_price($variation_data['sale_price']);
            $variation->set_sale_price($variation_data['sale_price']);
        }
        $variation->set_regular_price($variation_data['regular_price']);

        // Stock
        if (!empty($variation_data['stock_qty'])) {
            $variation->set_stock_quantity($variation_data['stock_qty']);
            $variation->set_manage_stock(true);
            $variation->set_stock_status('');
        } else {
            $variation->set_manage_stock(false);
        }

        $variation->set_weight($variation_data['weight']); // weight (reseting)
        $variation->set_width($variation_data['width']); // weight (reseting)
        $variation->set_length($variation_data['length']); // weight (reseting)
        $variation->set_height($variation_data['height']); // weight (reseting)

        $variation->save(); // Save the data
    }

    public function flutter_create_product()
    {
        $json = file_get_contents('php://input');
        $params = json_decode($json);
        $cookie = @$params->cookie;
        $post_id = @$params->product_id;
        $parent_id = @$params->parent_id;
        $product_atribute = @$params->product_atribute;

        if (empty($cookie)) {
            return self::sendError("invalid_login", "You must include a 'cookie' var in your request. Use the `generate_auth_cookie` method.", 401);
        }

        $user_id = wp_validate_auth_cookie($cookie, 'logged_in');
        if (!$user_id) {
            return self::sendError("invalid_login", "You must include a 'cookie' var in your request. Use the `generate_auth_cookie` method.", 401);
        }

        $user = get_userdata($user_id);

        $isSeller = in_array("administrator", $user->roles) || in_array("shop_manager", $user->roles) || in_array("wcfm_vendor", $user->roles);
        if (!$isSeller) {
            return self::sendError("invalid_role", "You must be seller to create product", 403);
        }

        $args = array(
            'post_author'  => $user_id,
            'post_content' => @$params->content,
            'post_status'  => @$params->status ?? "draft", // (Draft | Pending | Publish)
            'post_title'   => @$params->title,
            'post_parent'  => '',
            'post_type'    => "product"
        );

        if (!empty($parent_id)) {
            $args['post_parent'] = $parent_id;
            $args['post_type'] = 'product_variation';
        }

        // Create a simple WooCommerce product
        if (!empty($post_id)) {
            global $WCFM, $WCFMmp;

            if (!is_null($WCFM)) {
                $vendor_id = $WCFM->wcfm_vendor_support->wcfm_get_vendor_id_from_product($post_id);

                if ($vendor_id != $user_id) {
                    return self::sendError("invalid_vendor", "You must include a 'cookie' var in your request. Use the `generate_auth_cookie` method.", 401);
                }
            }

            $args['ID'] = $post_id;
            wp_update_post($args);
        } else {
            $post_id = wp_insert_post($args);
        }

        $product = wc_get_product($post_id);

        if (!$product) {
            return self::sendError("not_found", "Product not found !", 404);
        }

        try {
            // set price
            if (@$params->regular_price != '') {
                $product->set_regular_price(@$params->regular_price);
            }

            if (@$params->sale_price != '' && @$params->sale_price != 0) {
                $product->set_sale_price(@$params->sale_price);
            }
            // end price

            // set date
            if (@$params->date_on_sale_from != '') {
                $product->set_date_on_sale_from(@$params->date_on_sale_from);
            }

            if (@$params->date_on_sale_from_gmt != '') {
                $product->set_date_on_sale_from(@$params->date_on_sale_from_gmt ? strtotime(@$params->date_on_sale_from_gmt) : null);
            }

            if (@$params->date_on_sale_to != '') {
                $product->set_date_on_sale_to(@$params->date_on_sale_to);
            }

            if (@$params->date_on_sale_to_gmt != '') {
                $product->set_date_on_sale_to(@$params->date_on_sale_to_gmt ? strtotime(@$params->date_on_sale_to_gmt) : null);
            }
            // end date

            if (!empty($params->sku)) {
                $product->set_sku($params->sku);
            }

            if (@$params->categories != '') {
                wp_set_object_terms($post_id, @$params->categories, 'product_cat');
            }

            // dimensions
            if (@$params->dimensions->weight != '') {
                $product->set_weight(@$params->dimensions->weight);
            }

            if (@$params->dimensions->length != '') {
                $product->set_length(@$params->dimensions->length);
            }

            if (@$params->dimensions->width != '') {
                $product->set_width(@$params->dimensions->width);
            }

            if (@$params->dimensions->height != '') {
                $product->set_height(@$params->dimensions->height);
            }
            // end dimensions

            if (@$params->manage_stock) {
                $product->set_manage_stock(true);
                $product->set_stock_quantity(@$params->stock_quantity >= 1 ? $params->stock_quantity : 1); // integer
            } else {
                $product->set_manage_stock(false);
                $product->set_stock_status(@$params->stock_status); // 'instock', 'outofstock' or 'onbackorder'
            }

            if (@$params->image_ids != '') {
                if (is_array($params->image_ids) == true) {
                    if (count($params->image_ids) > 0) {
                        //    $image_ids = '';
                        for ($i = 0; $i < count($params->image_ids); $i++) {
                            if ($i > 0) {
                                $image_ids[] = $params->image_ids[$i]->id;
                            }
                        }
                        if ($image_ids != '') {
                            update_post_meta($post_id, '_product_image_gallery', implode(",", $image_ids));
                        }
                        set_post_thumbnail($post_id, @$params->image_ids[0]->id);
                    }
                }
            }

            if (@$params->product_type === 'variable') {
                wp_set_object_terms($post_id, @$params->product_type ?? "variable", 'product_type');
            } else {
                wp_set_object_terms($post_id, @$params->product_type ?? "simple", 'product_type');
            }

            $product->save();

            if (!empty($product_atribute)) {

                foreach ($product_atribute as $data) {

                    if ('pa_' === substr($data->taxonomy_name, 0, 3)) {
                        $attribute_id = wc_attribute_taxonomy_id_by_name($data->taxonomy_name);
                    }

                    $attribute_object = new WC_Product_Attribute();

                    $attribute_object->set_id($attribute_id);
                    $attribute_object->set_name($data->taxonomy_name);
                    $attribute_object->set_options($data->options);
                    $attribute_object->set_position(0);
                    $attribute_object->set_visible($data->visible == true ? 1 : 0);
                    $attribute_object->set_variation($data->variation == true ? 1 : 0);
                    $attributes[] = $attribute_object;
                }

                $product->set_attributes($attributes);

                $product->save();
            }

            // Create a variable WooCommerce product
            if (@$params->product_type === "variable") {
                // change product type
                $product_type = empty(@$params->product_type) ? WC_Product_Factory::get_product_type($post_id) : sanitize_title(wp_unslash(@$params->product_type));
                $classname    = WC_Product_Factory::get_product_classname($post_id, $product_type ? $product_type : 'simple');
                $product      = new $classname($post_id);

                $product->set_props(array('children' => 'grouped' === $product_type ? self::prepare_children() : null));

                $product->save();

                if ($product->is_type('variable')) {
                    $product->get_data_store()->sync_variation_names($product, @$params->title, @$params->title);
                }

                do_action('woocommerce_process_product_meta_' . $product_type, $post_id);
                // end change product type

                if (!empty($params->variation_data)) {
                    foreach ($params->variation_data as $var_data) {
                        // delete variant product data
                        $delete_product_variation = false;

                        if ($var_data->delete_product_variant == "yes") {

                            $delete_product_variation = true;

                            wp_delete_post($var_data->variable_product_id, $force_delete = false);
                        }
                        // end delete variant product data

                        if ($delete_product_variation == false) {

                            $variation_id = null;
                            $status_update_product_variation = false;

                            if (empty($var_data->variable_product_id)) {

                                // create data posts & post meta

                                $product_id       = intval($post_id);
                                $post             = get_post($product_id); // phpcs:ignore
                                $product_object   = wc_get_product_object('variable', $product_id); // Forces type to variable in case product is unsaved.
                                $variation_object = wc_get_product_object('variation');
                                $variation_object->set_parent_id($product_id);
                                $variation_object->set_attributes(array_fill_keys(array_map('sanitize_title', array_keys($product_object->get_variation_attributes())), ''));
                                $variation_id   = $variation_object->save();
                                $variation      = get_post($variation_id);
                                $variation_data = array_merge(get_post_custom($variation_id), wc_get_product_variation_attributes($variation_id)); // kept for BW compatibility.
                                include __DIR__ . '/admin/meta-boxes/views/html-variation-admin.php';

                                // end create data posts & post meta

                            } elseif ($var_data->variable_product_id >= 1) {

                                // get data variable post id if update

                                $variation_id = $var_data->variable_product_id;
                                $status_update_product_variation = true;

                                // end get data variable post id if update

                            }

                            // set data variant product

                            $stock = null;
                            $variation = wc_get_product_object('variation', $variation_id);

                            if ($var_data->variable_stock) {
                                $stock = wc_stock_amount(wp_unslash($var_data->variable_stock));
                            }

                            $data_regular = array(
                                'status'            => 'publish',
                                'regular_price'     => isset($var_data->variable_regular_price) ? wc_clean(wp_unslash($var_data->variable_regular_price)) : null,
                                'sale_price'        => isset($var_data->variable_sale_price) && $var_data->variable_sale_price != 0 ? wc_clean(wp_unslash($var_data->variable_sale_price)) : null,
                                'stock_status'      => isset($var_data->variable_stock_status) ? wc_clean(wp_unslash($var_data->variable_stock_status)) : null,
                                'sku'               => isset($var_data->variable_sku) ? wc_clean(wp_unslash($var_data->variable_sku)) : '',
                                'weight'            => isset($var_data->variable_weight) ? wc_clean(wp_unslash($var_data->variable_weight)) : '',
                                'length'            => isset($var_data->variable_length) ? wc_clean(wp_unslash($var_data->variable_length)) : '',
                                'width'             => isset($var_data->variable_width) ? wc_clean(wp_unslash($var_data->variable_width)) : '',
                                'height'            => isset($var_data->variable_height) ? wc_clean(wp_unslash($var_data->variable_height)) : '',
                            );

                            $data_stock = array(
                                'manage_stock'      => isset($var_data->variable_manage_stock),
                                'stock_quantity'    => $stock
                            );

                            if ($var_data->variable_manage_stock == "yes") {
                                $data_setprops = array_merge($data_regular, $data_stock);
                            } else {
                                $data_setprops = array_merge($data_regular);
                            }

                            $errors = $variation->set_props($data_setprops);

                            $args = array(
                                'post_title' => $params->title,
                                'post_excerpt' => ''
                            );

                            $args['ID'] = $variation_id;

                            wp_update_post($args);

                            // end set data variant product

                            foreach ($var_data->variation_attributes as $att_data) {
                                // set variant product each attribute on post meta

                                $meta_key = "attribute_" . $att_data->attribute_name;

                                update_post_meta($variation_id, $meta_key, $att_data->option);

                                // end set variant product each attribute on post meta

                                // set post_title & post_excerpt

                                $post = get_post($variation_id);

                                $post_title = $post->post_title;
                                $post_excerpt = $post->post_excerpt;

                                if (!empty($att_data->option)) {

                                    $args = array(
                                        'post_title' => $post_title . ' - ' . $att_data->option,
                                        'post_excerpt' => ($post_excerpt) . ($post_excerpt != '' ? ', ' : '') . ($att_data->attribute_name . ': ' . $att_data->option)
                                    );

                                    $args['ID'] = $variation_id;

                                    wp_update_post($args);
                                }

                                // end set post_title & post_excerpt
                            }

                            if (is_wp_error($errors)) {
                                // WC_Admin_Meta_Boxes::add_error( $errors->get_error_message() );

                                $variation->delete(true);

                                throw new Exception($errors->get_error_message());
                            }

                            do_action('woocommerce_admin_process_variation_object', $variation, $i);

                            if (is_plugin_active('polylang/polylang.php')) {
                                pll_set_post_language($variation_id, pll_default_language());
                            }

                            $variation->save();

                            do_action('woocommerce_save_product_variation', $variation_id, $i);
                        }
                    }
                }
            }

            if (is_plugin_active('polylang/polylang.php')) {
                pll_set_post_language($post_id, pll_default_language());
            }

            $product = wc_get_product($post_id);

            return $product->get_data();
        } catch (\Exception $th) {
            if (empty($params->product_id)) {
                wp_delete_post($post_id);
            }

            return self::sendError("error", $th->getMessage(), 400);
        }
    }

    public function flutter_delete_product()
    {
        $json = file_get_contents('php://input');
        $params = json_decode($json);
        $cookie = @$params->cookie;
        $post_id = @$params->product_id;

        global $WCFM, $WCFMmp;

        if ($cookie == '') {
            return self::sendError("invalid_login", "You must include a 'cookie' var in your request. Use the `generate_auth_cookie` method.", 401);
        }

        $user_id = wp_validate_auth_cookie($cookie, 'logged_in');
        if (!$user_id) {
            return self::sendError("invalid_login", "You must include a 'cookie' var in your request. Use the `generate_auth_cookie` method.", 401);
        }

        $user = get_userdata($user_id);

        $isSeller = in_array("administrator", $user->roles) || in_array("shop_manager", $user->roles) || in_array("wcfm_vendor", $user->roles);
        if ($isSeller) {
            wp_delete_post($post_id);
            return ['product_id' => $post_id, 'status' => 'success'];
        }

        return ['product_id' => $post_id, 'status' => 'error'];
    }

    public function flutter_get_products($request)
    {
        $cookie = $request["cookie"];
        $user_id = $request["user_id"];

        // if (!isset($user_id) OR !isset($cookie)) {
        //     return self::sendError("invalid_login","You must include a 'cookie' var in your request. Use the `generate_auth_cookie` method.", 401);
        // }

        if ($cookie) {
            $user_id = wp_validate_auth_cookie($cookie, 'logged_in');
        }

        if (!$user_id) {
            return self::sendError("invalid_login", "You must include a 'cookie' var in your request. Use the `generate_auth_cookie` method.", 401);
        }

        $products = wc_get_products(array(
            'author' => $user_id,
            'limit' => $request["limit"],
            'page' => $request["page"],
        ));
        $ids = array();
        foreach ($products as $object) {
            $ids[] = $object->id;
        }
        if (count($ids) > 0) {
            $api = new WC_REST_Products_Controller();
            $params = array('status' => 'any', 'include' => $ids);
            $request->set_query_params($params);

            $response = $api->get_items($request);
            return $response->get_data();
        } else {
            return [];
        }
    }

    private static function sendError($code, $message, $statusCode)
    {
        return new WP_Error($code, $message, array('status' => $statusCode));
    }

    public static function instance()
    {
        if (is_null(self::$_instance)) {
            self::$_instance = new self();
        }

        return self::$_instance;
    }
}
