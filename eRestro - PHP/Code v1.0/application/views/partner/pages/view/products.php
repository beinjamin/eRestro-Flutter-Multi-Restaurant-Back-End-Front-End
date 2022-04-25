<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4>View Product</h4>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a class="text text-info" href="<?= base_url('partner/home') ?>">Home</a></li>
                        <li class="breadcrumb-item active">View Product</li>
                    </ol>
                </div>
            </div>
        </div><!-- /.container-fluid -->
    </section>
    <section class="content">

        <!-- Default box -->
        <div class="card card-solid">
            <div class="card-body">
                <div class="row">
                    <div class="col-12 col-sm-6">
                        <div class="col-12 text-center">
                            <div class="tab-pane active" id="pic-1">
                                <a href="<?= $product_details[0]['image'] ?>" data-toggle="lightbox" data-gallery="product-gallery">
                                    <img src="<?= $product_details[0]['image'] ?>" class="w-100" /> </a>
                            </div>
                        </div>
                    </div>
                    <div class="col-12 col-sm-6">
                        <h3 class="my-2"><?= $product_details[0]['name'] ?></h3>
                        <small><?= ucwords(str_replace('_', ' ', $product_details[0]['type'])) ?></small>
                        <h6 class="my-3"><?= $product_details[0]['short_description'] ?></h6>
                        <hr>
                        <div class="col-12 col-sm-12 text-sm">
                            <h6 class="my-3"><?= 'Category : <span class="text-info">' . ucfirst($product_details[0]['category_name']) . '</span>' ?></h6>
                        </div>
                        <div class="py-2 px-3 mt-4">
                            <div class="col-md-12 mb-3">
                                <input type="text" class="kv-fa rating-loading" value="<?= $product_details[0]['rating'] ?>" data-size="sm" title="" readonly>
                                <?= (isset($product_rating['rating'][0]['no_of_rating']) && $product_rating['rating'][0]['no_of_rating'] > 0 && !empty($product_rating['rating'][0]['no_of_rating'])) ?  'Total : ' . $product_rating['rating'][0]['no_of_rating'] . ' ratings' : '' ?>
                            </div>
                            <?php
                            if (!empty($product_details[0]['type'])) {
                                //Case 1 : Simple Product(simple product)
                                if ($product_details[0]['type'] == 'simple_product') {
                            ?>
                                    <h2 class="mb-0">
                                        <?= ($product_variants[0]['special_price'] != null && $product_variants[0]['special_price'] > 0) ? $currency . $product_variants[0]['special_price'] : $currency . $product_variants[0]['price'] ?>
                                    </h2>

                                <?php
                                }
                                //Case 2 & 3 : Product level(variable product) ||  Variant level(variable product)
                                if ($product_details[0]['type'] == 'variable_product') {
                                    $price = "";
                                ?>
                                    <h3 class="">Variants</h3>
                                    <table class="table table-sm">
                                        <thead class="thead-light">
                                            <tr>
                                                <th>Row Id</th>
                                                <th>Variants</th>
                                                <th>Price</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <?php
                                            $i = 1;
                                            $flag = 0;
                                            //   foreach ($product_details[0]['variants'] as $row) {
                                            foreach ($product_variants as $row) {
                                                if ($row['special_price'] != null && $row['special_price'] > 0) {
                                                    $price = $row['special_price'];
                                                    $flag = 1;
                                                    $strike_off_price = $row['price'];
                                                } else {
                                                    $price = $row['price'];
                                                    //   $strike_off_price = $row['price'];
                                                }
                                            ?>
                                                <tr class='<?= ($row['status'] == 7) ? "table-danger" : (($row['status'] == 0) ? "table-warning" : ""); ?>'>
                                                    <td><?= $row['id'] ?> <small><?= ($row['status'] == 7) ? "Trashed" : (($row['status'] == 0) ? "Deactived" : ""); ?></small> <?= ($row['status'] == 7) ? "<a href='" . base_url('partner/product/change_variant_status/' . $row['id'] . '/1/' . $product_details[0]['id']) . "' title='Restore variant'>Restore</a>" : (($row['status'] == 0) ? "<a href='" . base_url('partner/product/change_variant_status/' . $row['id'] . '/1/' . $product_details[0]['id']) . "' title='Activate variant'>Activate</a>" : "<a href='" . base_url('partner/product/change_variant_status/' . $row['id'] . '/0/' . $product_details[0]['id']) . "' title='Deactivate variant'>Deactivate</a> | <a href='" . base_url('partner/product/change_variant_status/' . $row['id'] . '/7/' . $product_details[0]['id']) . "' title='Move variant to Trash'>Trash</a>") ?> </td>
                                                    <td><?= str_replace(',', ' | ', $row['variant_values']) ?></td>
                                                    <td><?= (($flag == 1 && isset($strike_off_price) && !empty($strike_off_price)) ? $currency . $price . ' <sup class="text-danger"><s>' . $currency . $strike_off_price . '</s></sup>' : $currency . $price)  ?></td>
                                                </tr>
                                            <?php
                                                $i++;
                                                $flag = 0;
                                            } ?>
                                        </tbody>
                                    </table>
                                <?php
                                }
                            }
                            if (!empty($product_details[0]['attributes'])) {
                                ?>
                                <h3>Attributes</h3>
                                <table class="table table-sm">
                                    <thead class="thead-light">
                                        <tr>
                                            <th>Row</th>
                                            <th>Attributes</th>
                                            <th>Values</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <?php
                                        $i = 1;
                                        foreach ($product_details[0]['attributes'] as $row) {
                                        ?>
                                            <tr>
                                                <td><?= $i ?></td>
                                                <td><?= $row['attr_name'] ?></td>
                                                <td><?= str_replace(',', ' | ', $row['value']) ?></td>
                                            </tr>
                                        <?php
                                            $i++;
                                        } ?>
                                    </tbody>
                                </table>
                            <?php
                            } ?>
                        </div>


                    </div>
                </div>
                <div class="row mt-4">
                    <nav class="w-100">
                        <?php
                        $rating_active = (empty($product_details[0]['description']) && !empty($product_rating['product_rating'])) ? 'active show' : '';
                        ?>
                        <div class="nav nav-tabs" id="product-tab" role="tablist">
                            <?php if (!empty($product_rating['product_rating'])) { ?> <a class="nav-item nav-link <?= $rating_active ?>" id="product-rating-tab" data-toggle="tab" href="#product-rating" role="tab" aria-controls="product-rating" aria-selected="false">Rating</a><?php } ?>
                            </dv>
                    </nav>
                    <div class="tab-content p-3 col-md-12" id="nav-tabContent">
                        <?php
                        if (!empty($product_rating['product_rating'])) {
                        ?>
                            <input type="hidden" name="product_id" id="product_id" value="<?= (isset($product_details[0]['id']) && !empty($product_details[0]['id'])) ? $product_details[0]['id'] : 'null' ?>"/>
                            <div class="tab-pane <?= $rating_active ?>" id="product-rating" role="tabpanel" aria-labelledby="product-rating-tab">
                                <table class='table-striped' id='product-rating-table' data-toggle="table" data-url="<?= base_url('partner/product/get_rating_list') ?>" data-click-to-select="true" data-side-pagination="server" data-pagination="true" data-page-list="[5, 10, 20, 50, 100, 200]" data-search="true" data-show-columns="true" data-show-refresh="true" data-trim-on-search="false" data-sort-name="id" data-sort-order="desc" data-mobile-responsive="true" data-toolbar="" data-show-export="true" data-maintain-selected="true" data-query-params="product_rating_query_params">
                                    <thead>
                                        <tr>
                                            <th data-field="id" data-sortable="true">ID</th>
                                            <th data-field="username" data-width='500' data-sortable="false" class="col-md-6">Username</th>
                                            <th data-field="rating" data-sortable="false">Rating</th>
                                            <th data-field="comment" data-sortable="false">Comment</th>
                                            <th data-field="images" data-sortable="true">Images</th>
                                            <th data-field="data_added" data-sortable="false">Data added</th>
                                            <th data-field="operate" data-sortable="false">Operate</th>
                                        </tr>
                                    </thead>
                                </table>
                            </div>
                        <?php
                        }
                        ?>
                    </div>
                </div>
            </div>
            <!-- /.card-body -->
        </div>
        <!-- /.card -->

    </section>
</div>
<!-- /.content -->
