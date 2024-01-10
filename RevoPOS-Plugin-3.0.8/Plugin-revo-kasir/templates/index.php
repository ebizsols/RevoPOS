<?php

	function revo_pos_input_license(){
		include plugin_dir_path( __FILE__ ) . 'license_code.php';
	}

	function revo_pos_index_settings(){
		$cek = pos_cek_internal_license_code();

		if ($cek == true) {
			include(plugin_dir_path( __FILE__ ) . 'main_page.php');
		} else {
			revo_pos_input_license();
		}
	}
