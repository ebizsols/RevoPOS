<?php

if (!defined('ABSPATH')) {
    exit;
}

class Revo_Pos_Admin_Api
{
    public static $_instance = null;

    public function __construct()
    {
        $upload = wp_upload_dir();
        $upload_dir = $upload['basedir'];
        $upload_dir = $upload_dir . '/revo-pos';
        if (!is_dir($upload_dir)) {
            mkdir($upload_dir, 0777);
        }

        require_once REVO_POS_ABSPATH . 'templates/index.php';

        add_action('admin_enqueue_scripts', array($this, 'admin_enqueue'));
        add_action('admin_menu', array($this, 'register_pages'));
    }

    public function admin_enqueue()
    {
        wp_enqueue_style('revo-pos-global-style', REVO_POS_URL . 'assets/css/global-style.css', array());
    }

    public function register_pages()
    {
        add_menu_page('Mobile Revo Settings', REVO_POS_PLUGIN_NAME, 'manage_options', REVO_POS_PLUGIN_SLUG, 'revo_pos_index_settings', pos_get_logo('black_white'));
    }

    public static function instance()
    {
        if (is_null(self::$_instance)) {
            self::$_instance = new self();
        }

        return self::$_instance;
    }
}
