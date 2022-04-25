<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title><?= $title ?></title>
    <!-- Tell the browser to be responsive to screen width -->
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="icon" href="<?= base_url() . get_settings('favicon') ?>" type="image/gif" sizes="16x16">
    <!-- Bootstrap Switch -->
    <link rel="stylesheet" href="<?= base_url('assets/admin/css/bootstrap-switch.min.css') ?>">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="<?= base_url('assets/admin/css/all.min.css') ?>">
    <!-- Ionicons -->
    <link rel="stylesheet" href="<?= base_url('assets/admin/css/ionicons.min.css') ?>">
    <!-- Tempusdominus Bbootstrap 4 -->
    <link rel="stylesheet" href="<?= base_url('assets/admin/css/tempusdominus-bootstrap-4.min.css') ?>">
    <!-- iCheck -->
    <link rel="stylesheet" href="<?= base_url('assets/admin/css/icheck-bootstrap.min.css') ?>">
    <!-- Dropzone -->
    <link rel="stylesheet" href="<?= base_url('assets/admin/css/dropzone.css') ?>">
    <!-- JQVMap -->
    <link rel="stylesheet" href="<?= base_url('assets/admin/css/jqvmap.min.css') ?>">
    <!-- Ekko Lightbox -->
    <link rel="stylesheet" href="<?= base_url('assets/admin/ekko-lightbox/ekko-lightbox.css') ?>">
    <!-- Theme style -->
    <link rel="stylesheet" href="<?= base_url('assets/admin/dist/css/adminlte.min.css') ?>">
    <!-- overlayScrollbars -->
    <link rel="stylesheet" href="<?= base_url('assets/admin/css/OverlayScrollbars.min.css') ?>">
    <!-- Daterange picker -->
    <link rel="stylesheet" href="<?= base_url('assets/admin/css/daterangepicker.css') ?>">
    <!-- summernote -->
    <link rel="stylesheet" href="<?= base_url('assets/admin/summernote/summernote-bs4.css') ?>">
    <!-- Toastr -->
    <link rel="stylesheet" href="<?= base_url('assets/admin/css/iziToast.min.css') ?>">
    <!-- Select2 -->
    <link rel="stylesheet" href="<?= base_url('assets/admin/css/select2.min.css') ?>">
    <link rel="stylesheet" href="<?= base_url('assets/admin/css/select2-bootstrap4.min.css') ?>">
    <!-- Sweet Alert -->
    <link rel="stylesheet" href="<?= base_url('assets/admin/css/sweetalert2.min.css') ?>">
    <!-- Chartist -->
    <link rel="stylesheet" href="<?= base_url('assets/admin/css/chartist.css') ?>">
    <!-- JS tree -->
    <link rel="stylesheet" href="<?= base_url('assets/admin/css/style.min.css') ?>">
    <link rel="stylesheet" href="<?= base_url('assets/admin/css/star-rating.min.css') ?>">
    <link rel="stylesheet" href="<?= base_url('assets/admin/css/theme.css') ?>">
    
    <link rel="stylesheet" href="<?= base_url('assets/admin/css/fonts.css') ?>">
    <link rel="stylesheet" href="<?= base_url('assets/admin/css/bootstrap-table.min.css') ?>">
    <link rel="stylesheet" href="<?= base_url('assets/admin/css/jquery.fancybox.min.css') ?>" />
    <!-- Custom CSS -->
    <link rel="stylesheet" href="<?= base_url('assets/admin/custom/custom.css') ?>">
    <!-- jQuery -->
    <script src="<?= base_url('assets/admin/js/jquery.min.js') ?>"></script>
    <!-- Star rating js -->
    <script type="text/javascript" src="<?= base_url('assets/admin/js/star-rating.js') ?>"></script>
    <script type="text/javascript" src="<?= base_url('assets/admin/js/theme.min.js') ?>"></script>
    <link rel="stylesheet" href="<?= base_url('assets/admin/css/tagify.min.css') ?>">
    <script type="text/javascript">
        base_url = "<?= base_url() ?>";
        csrfName = "<?= $this->security->get_csrf_token_name() ?>";
        csrfHash = "<?= $this->security->get_csrf_hash() ?>";
        form_name = '<?= '#' . $main_page . '_form' ?>';
    </script>
</head>