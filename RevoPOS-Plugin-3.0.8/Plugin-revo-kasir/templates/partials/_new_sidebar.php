<aside id="sidebar-left" class="sidebar-left">

    <div class="sidebar-header" style="height: auto;">
        <div class="sidebar-title text-center">
            <img src="<?php echo pos_get_logo() ?>" class="img-fluid mr-3 py-3" style="width: 100px">
        </div>
        <!-- <div class="sidebar-toggle hidden-xs" data-toggle-class="sidebar-left-collapsed" data-target="html" data-fire-event="sidebar-left-toggle">
            <i class="fa fa-bars" aria-label="Toggle sidebar"></i>
        </div> -->
    </div>

    <div class="nano">
        <div class="nano-content">
            <nav id="menu" class="nav-main" role="navigation">
                <?php global $revo_plugin_name; ?>
                <ul class="nav nav-main mr-0">
                    <li class="w-100 <?php echo $_GET['page'] == REVO_POS_PLUGIN_SLUG ? 'nav-active' : '' ?>">
                        <a href="<?php echo admin_url( 'admin.php?page='.REVO_POS_PLUGIN_SLUG, 'admin' ); ?>">
                            <i class="fa fa-home" aria-hidden="true"></i>
                            <span>Dashboard</span>
                        </a>
                    </li>
                </ul>
            </nav>

        </div>

        <script>
            // Maintain Scroll Position
            if (typeof localStorage !== 'undefined') {
                if (localStorage.getItem('sidebar-left-position') !== null) {
                    var initialPosition = localStorage.getItem('sidebar-left-position'),
                        sidebarLeft = document.querySelector('#sidebar-left .nano-content');

                    sidebarLeft.scrollTop = initialPosition;
                }
            }
        </script>


    </div>
</aside>
