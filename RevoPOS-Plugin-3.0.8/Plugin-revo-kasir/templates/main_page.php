<?php
  global $wpdb;

  $query_logo = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'logo' LIMIT 1";
  $query_splash = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'splashscreen' LIMIT 1";
  $query_kontak = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'kontak' LIMIT 3 ";
  $query_cs = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'cs'";
  $query_pp = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'privacy_policy'";
  $query_about = "SELECT * FROM `revo_mobile_variable` WHERE slug = 'about'";

  $data_logo = $wpdb->get_row($query_logo, OBJECT);
  $data_splash = $wpdb->get_row($query_splash, OBJECT);
  $data_cs = $wpdb->get_row($query_cs, OBJECT);
  $data_pp = $wpdb->get_row($query_pp, OBJECT);
  $data_about = $wpdb->get_row($query_about, OBJECT);
  $data_kontak = $wpdb->get_results($query_kontak, OBJECT);

  if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if ($_FILES["fileToUploadSplash"]["name"]) {
      $query_data = array(
                      'slug' => 'splashscreen',
                      'image' => '',
                      'description' => $_POST['description'],
                    );

      $alert = array(
              'type' => 'error',
              'title' => 'Failed to Change SplashScreen !',
              'message' => 'Required Image',
          );

      $uploads_url = WP_CONTENT_URL."/uploads/revo/";
      $target_dir = WP_CONTENT_DIR."/uploads/revo/";
      $target_file = $target_dir . basename($_FILES["fileToUploadSplash"]["name"]);
      $imageFileType = strtolower(pathinfo($target_file,PATHINFO_EXTENSION));
      $newname =  md5(date("Y-m-d H:i:s")) . "." . $imageFileType;
      $is_upload_error = 0;
      if($_FILES["fileToUploadSplash"]["size"] > 0){

          if ($_FILES["fileToUploadSplash"]["size"] > 2000000) {
            $alert = array(
              'type' => 'error',
              'title' => 'Uploads Error !',
              'message' => 'your file is too large. max 2Mb',
            );
            $is_upload_error = 1;
          }

          if($imageFileType != "jpg" && $imageFileType != "png" && $imageFileType != "jpeg" ) {
            $alert = array(
              'type' => 'error',
              'title' => 'Uploads Error !',
              'message' => 'only JPG, JPEG & PNG files are allowed.',
            );
            $is_upload_error = 1;
          }

          if ($is_upload_error == 0) {
            if ($_FILES["fileToUploadSplash"]["size"] > 500000) {
              compress($_FILES["fileToUploadSplash"]["tmp_name"],$target_dir.$newname,90);
              $query_data['image'] = $uploads_url.$newname;
            }else{
              move_uploaded_file($_FILES["fileToUploadSplash"]["tmp_name"], $target_dir.$newname);
              $query_data['image'] = $uploads_url.$newname;
            }
          }
      }

      if ($query_data['image'] != '') {
        if ($data_splash == NULL || empty($data_splash)) {

              $wpdb->insert('revo_mobile_variable',$query_data);

              if (@$wpdb->insert_id > 0) {
                $alert = array(
                  'type' => 'success',
                  'title' => 'Success !',
                  'message' => 'Splashscreen Updated Successfully',
                );
              }

        }else{

            $where = ['id' => $data_splash->id];
            $wpdb->update('revo_mobile_variable',$query_data,$where);

            if (@$wpdb->show_errors == false) {
              $alert = array(
                'type' => 'success',
                'title' => 'Success !',
                'message' => 'Splashscreen Updated Successfully',
              );
            }

        }
      }

      $_SESSION["alert"] = $alert;

      $data_splash = $wpdb->get_row($query_splash, OBJECT);
    }
    if ($_FILES["fileToUploadLogo"]["name"]) {
      $query_data = array(
                      'slug' => 'logo',
                      'title' => $_POST['title'],
                      'image' => '',
                      'description' => 'logo',
                    );

      $alert = array(
              'type' => 'error',
              'title' => 'Failed to Change Logo !',
              'message' => 'Required Image',
          );

      $uploads_url = WP_CONTENT_URL."/uploads/revo/";
      $target_dir = WP_CONTENT_DIR."/uploads/revo/";
      $target_file = $target_dir . basename($_FILES["fileToUploadLogo"]["name"]);
      $imageFileType = strtolower(pathinfo($target_file,PATHINFO_EXTENSION));
      $newname =  md5(date("Y-m-d H:i:s")) . "." . $imageFileType;
      $is_upload_error = 0;
      if($_FILES["fileToUploadLogo"]["size"] > 0){

          if ($_FILES["fileToUploadLogo"]["size"] > 2000000) {
            $alert = array(
              'type' => 'error',
              'title' => 'Uploads Error Logo !',
              'message' => 'your file is too large. max 2Mb',
            );
            $is_upload_error = 1;
          }

          if($imageFileType != "jpg" && $imageFileType != "png" && $imageFileType != "jpeg" ) {
            $alert = array(
              'type' => 'error',
              'title' => 'Uploads Error Logo !',
              'message' => 'only JPG, JPEG & PNG files are allowed.',
            );
            $is_upload_error = 1;
          }

          if ($is_upload_error == 0) {
            if ($_FILES["fileToUploadLogo"]["size"] > 500000) {
              compress($_FILES["fileToUploadLogo"]["tmp_name"],$target_dir.$newname,90);
              $query_data['image'] = $uploads_url.$newname;
            }else{
              move_uploaded_file($_FILES["fileToUploadLogo"]["tmp_name"], $target_dir.$newname);
              $query_data['image'] = $uploads_url.$newname;
            }
          }
      }

      if ($query_data['image'] != '') {
        if ($data_logo == NULL || empty($data_logo)) {

              $wpdb->insert('revo_mobile_variable',$query_data);

              if (@$wpdb->insert_id > 0) {
                $alert = array(
                  'type' => 'success',
                  'title' => 'Success !',
                  'message' => 'Logo Updated Successfully',
                );
              }

        }else{

            $where = ['id' => $data_logo->id];
            $wpdb->update('revo_mobile_variable',$query_data,$where);

            if (@$wpdb->show_errors == false) {
              $alert = array(
                'type' => 'success',
                'title' => 'Success !',
                'message' => 'Logo Updated Successfully',
              );
            }

        }
      }

      $_SESSION["alert"] = $alert;

      $data_logo = $wpdb->get_row($query_logo, OBJECT);
    }

    if (@$_POST['slug']) {
      if ($_POST['slug'] == 'kontak') {

        $success = 0;
        $where_wa = array(
          'slug' => 'kontak',
          'title' => 'wa',
        );

        $success = insert_update_MV($where_wa,$_POST['id_wa'],$_POST['number_wa']);

        $where_phone = array(
          'slug' => 'kontak',
          'title' => 'phone',
        );

        $success = insert_update_MV($where_phone,$_POST['id_tel'],$_POST['number_tel']);

        $where_sms = array(
          'slug' => 'kontak',
          'title' => 'sms',
        );

        $success = insert_update_MV($where_sms,$_POST['id_sms'],$_POST['number_sms']);

        if ($success > 0) {
          $data_kontak = $wpdb->get_results($query_kontak, OBJECT);
          $alert = array(
            'type' => 'success',
            'title' => 'Success !',
            'message' => 'Contact Updated Successfully',
          );
        }else{
          $alert = array(
            'type' => 'error',
            'title' => 'error !',
            'message' => 'Contact Failed to Update',
          );
        }

        $_SESSION["alert"] = $alert;

      }

      if ($_POST['slug'] == 'url') {
        $success = 0;

        for ($i=1; $i < 4; $i++) {
            $query_data = array(
              'slug' => $_POST['slug'.$i],
              'title' => $_POST['title'.$i],
              'description' => $_POST['description'.$i],
            );

          if ($_POST['id'.$i] != 0) {
            $where = ['id' => $_POST['id'.$i]];
            $wpdb->update('revo_mobile_variable',$query_data,$where);

            if (@$wpdb->show_errors == false) {
              $success = 1;
            }
          }else{
            $wpdb->insert('revo_mobile_variable',$query_data);
            if (@$wpdb->insert_id > 0) {
              $success = 1;
            }
          }
        }

        if ($success) {
          $data_cs = $wpdb->get_row($query_cs, OBJECT);
          $data_about = $wpdb->get_row($query_about, OBJECT);
          $data_pp = $wpdb->get_row($query_pp, OBJECT);

          $alert = array(
            'type' => 'success',
            'title' => 'Success !',
            'message' => $_POST['title'].' Success to Update',
          );
        }else{
          $alert = array(
            'type' => 'error',
            'title' => 'error !',
            'message' => $_POST['title'].' Failed to Update',
          );
        }

        $_SESSION["alert"] = $alert;
      }
    }
  }
?>

<!doctype html>
<html class="fixed sidebar-light">
<?php include (plugin_dir_path( __FILE__ ).'partials/_css.php'); ?>
<body>
  <?php include (plugin_dir_path( __FILE__ ).'partials/_header.php'); ?>
  <div class="container-fluid">
    <?php include (plugin_dir_path( __FILE__ ).'partials/_alert.php'); ?>
    <section class="panel">
      <div class="inner-wrapper pt-0">
      <!-- start: sidebar -->
      <?php include (plugin_dir_path( __FILE__ ).'partials/_new_sidebar.php'); ?>
      <!-- end: sidebar -->

      <section role="main" class="content-body p-0">
          <section class="panel mb-3">
            <div class="panel-body">
             <div class="card-body text-center"> <img src="https://img.icons8.com/bubbles/200/000000/trophy.png">
                 <h4>CONGRATULATIONS!</h4>
                 <p>your license / purchase code is activated.</p>
             </div>
            </div>
          </section>
      </section>
    </div>
    </section>
  </div>
</body>
<?php include (plugin_dir_path( __FILE__ ).'partials/_js.php'); ?>
</html>
