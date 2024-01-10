<?php

if (!defined('ABSPATH')) {
    exit;
}

class Revo_Pos_Installation
{
    /**
     * Plugin activator
     */
    public static function plugin_activator()
    {
        if (!pos_check_exist_database('revo_pos_mobile_variable')) {
            global $wpdb;

            $revo_pos_mobile_variable = "CREATE TABLE `revo_pos_mobile_variable` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `slug` varchar(55) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
                `title` varchar(55) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
                `image` TEXT CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
                `description` TEXT CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
                `sort` tinyint(2) NOT NULL DEFAULT 0,
                `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
                `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
                `update_at` timestamp NULL,
            PRIMARY KEY (`id`) USING BTREE)";

            $wpdb->query($wpdb->prepare($revo_pos_mobile_variable, []));

            if (!pos_check_exist_database('revo_pos_access_key')) {
                $revo_pos_access_key = "CREATE TABLE `revo_pos_access_key` (
                    `id` int(11) NOT NULL AUTO_INCREMENT,
                    `firebase_server_key` TEXT NULL DEFAULT NULL,
                    `firebase_api_key` TEXT NULL DEFAULT NULL,
                    `firebase_auth_domain` TEXT NULL DEFAULT NULL,
                    `firebase_database_url` TEXT NULL DEFAULT NULL,
                    `firebase_project_id` TEXT NULL DEFAULT NULL,
                    `firebase_storage_bucket` TEXT NULL DEFAULT NULL,
                    `firebase_messaging_sender_id` TEXT NULL DEFAULT NULL,
                    `firebase_app_id` TEXT NULL DEFAULT NULL,
                    `firebase_measurement_id` TEXT NULL DEFAULT NULL,
                    `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
                PRIMARY KEY (`id`) USING BTREE)";

                $wpdb->query($wpdb->prepare($revo_pos_access_key, []));
            }

            if (!pos_check_exist_database('revo_pos_token_firebase')) {
                $revo_pos_token_firebase = "CREATE TABLE `revo_pos_token_firebase` (
                    `id` int(11) NOT NULL AUTO_INCREMENT,
                    `token` TEXT NULL DEFAULT NULL,
                    `user_id` varchar(55) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
                    `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
                    `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
                    PRIMARY KEY (`id`) USING BTREE)";
                $wpdb->query($wpdb->prepare($revo_pos_token_firebase, []));
            }

            if (!pos_check_exist_database('revo_pos_notification')) {
                $revo_pos_notification = "CREATE TABLE `revo_pos_notification` (
                    `id` int(11) NOT NULL AUTO_INCREMENT,
                    `user_id` varchar(55) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
                    `target_id` varchar(55) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
                    `type` varchar(55) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
                    `message` TEXT CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
                    `is_read` tinyint(1) NOT NULL DEFAULT 0,
                    `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
                PRIMARY KEY (`id`) USING BTREE)";

                $wpdb->query($wpdb->prepare($revo_pos_notification, []));
            }

            if (!pos_check_exist_database('revo_conversations')) {
                $revo_conversations = "CREATE TABLE `revo_conversations` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `sender_id` int(11) NOT NULL,
                `receiver_id` int(11) NOT NULL,
                `is_delete_sender` tinyint(2) NOT NULL DEFAULT 0,
                `is_delete_receiver` tinyint(2) NOT NULL DEFAULT 0,
                `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
                PRIMARY KEY (`id`) USING BTREE,
                KEY (`sender_id`) USING BTREE,
                KEY (`receiver_id`) USING BTREE );";

                $wpdb->query($wpdb->prepare($revo_conversations, []));
            }

            if (!pos_check_exist_database('revo_conversation_messages')) {
                $revo_conversation_messages = "CREATE TABLE `revo_conversation_messages` (
                    `id` int(11) NOT NULL AUTO_INCREMENT,
                    `conversation_id` int(11) NOT NULL,
                    `sender_id` int(11) NOT NULL,
                    `receiver_id` int(11) NOT NULL,
                    `message` varchar(1000) NOT NULL,
                    `image` TEXT NULL DEFAULT NULL,
                    `is_read` tinyint(2) NOT NULL DEFAULT 0,
                    `type` enum('store','product','order','chat') NOT NULL DEFAULT 'chat',
                    `post_id` int(11) NOT NULL,
                    `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
                    PRIMARY KEY (`id`) USING BTREE,
                    KEY (`post_id`) USING BTREE,
                    KEY (`sender_id`) USING BTREE,
                    KEY (`receiver_id`) USING BTREE,
                    KEY (`conversation_id`) USING BTREE );";

                $wpdb->query($wpdb->prepare($revo_conversation_messages, []));
            }

            (new self)->data_seeder();
        }
    }

    /**
     * data seeder
     */
    private function data_seeder()
    {
        global $wpdb;

        // mobile variable
        $wpdb->insert('revo_pos_mobile_variable', pos_data_seeder('splashscreen'));
        $wpdb->insert('revo_pos_mobile_variable', pos_data_seeder('kontak_wa'));
        $wpdb->insert('revo_pos_mobile_variable', pos_data_seeder('kontak_phone'));
        $wpdb->insert('revo_pos_mobile_variable', pos_data_seeder('kontak_sms'));
        $wpdb->insert('revo_pos_mobile_variable', pos_data_seeder('about'));
        $wpdb->insert('revo_pos_mobile_variable', pos_data_seeder('cs'));
        $wpdb->insert('revo_pos_mobile_variable', pos_data_seeder('privacy_policy'));
        $wpdb->insert('revo_pos_mobile_variable', pos_data_seeder('term_condition'));
        $wpdb->insert('revo_pos_mobile_variable', pos_data_seeder('logo'));

        $intro_page_1 = pos_data_seeder('intro_page_1');
        $intro_page_1['sort'] = '1';
        $wpdb->insert('revo_pos_mobile_variable', $intro_page_1);

        $intro_page_2 = pos_data_seeder('intro_page_2');
        $intro_page_2['sort'] = '2';
        $wpdb->insert('revo_pos_mobile_variable', $intro_page_2);

        $intro_page_3 = pos_data_seeder('intro_page_3');
        $intro_page_3['sort'] = '3';
        $wpdb->insert('revo_pos_mobile_variable', $intro_page_3);

        for ($i = 1; $i < 6; $i++) {
            $wpdb->insert('revo_pos_mobile_variable', pos_data_seeder('empty_images_' . $i));
        }

        // access key
        $wpdb->insert('revo_pos_access_key', ['firebase_api_key' => NULL]);
    }

    /**
     * Plugin deactivator
     */
    public static function plugin_deactivator()
    {
        global $wpdb;

        $queryLC = $wpdb->get_row("SELECT id,description,update_at FROM `revo_pos_mobile_variable` WHERE slug = 'revo_pos_license_code' AND description != '' AND update_at is not NULL", OBJECT);

        if (!$queryLC) return true;

        $update = ["description" => null];
        $wpdb->update('revo_pos_mobile_variable', $update, ['id' => $queryLC->id]);

        $query_LiveChatStatus = pos_query_revo_pos_mobile_variable('"live_chat_status"', 'sort');

        if (@$wpdb->show_errors == false && !empty($query_LiveChatStatus) && $query_LiveChatStatus[0]->description == "show") {
            $update = ["description" => "hide"];
            $wpdb->update('revo_mobile_variable', $update, ['slug' => "live_chat_status"]);
        }

        $revo_pos_license_code = json_decode($queryLC->description)->license_code;
        $body = json_encode(["license_code" => $revo_pos_license_code]);
        $curl = curl_init();
        curl_setopt_array($curl, array(
            CURLOPT_URL => "https://activation.revoapps.net/wp-json/license/uninstall",
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
