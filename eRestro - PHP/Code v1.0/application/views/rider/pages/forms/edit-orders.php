<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <!-- Main content -->
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h4>View Order</h4>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a class="text text-info" href="<?= base_url('admin/home') ?>">Home</a></li>
                        <li class="breadcrumb-item active">Orders</li>
                    </ol>
                </div>
            </div>
        </div><!-- /.container-fluid -->
    </section>
    <section class="content">
        <div class="container-fluid">
            <div class="row">
                <div class="modal fade" id="add-ons-model" tabindex="-1" role="dialog" aria-hidden="true">
                    <div class="modal-dialog modal-xl">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title">View Product Item Add Ons</h5>
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                    <span aria-hidden="true">&times;</span>
                                </button>
                            </div>
                            <div class="modal-body">
                                <table class="table table-striped table-hover">
                                    <thead>
                                        <tr>
                                            <th scope="col">Id</th>
                                            <th scope="col">Product Name</th>
                                            <th scope="col">Add On</th>
                                            <th scope="col">Quantity</th>
                                            <th scope="col">Price</th>
                                            <th scope="col">Total</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <?php
                                        $final_price_add_ons = 0;
                                        $i = 1;
                                        foreach ($items as $row) {
                                            if (isset($row['add_ons']) && !empty($row['add_ons']) && $row['add_ons'] != "" && $row['add_ons'] != "[]") {
                                                $add_ons = json_decode($row['add_ons'], true);
                                                foreach ($add_ons as $row1) {
                                                    $final_price_add_ons += intval($row1['qty']) * intval($row1['price']);
                                        ?>
                                                    <tr>
                                                        <th><?= $i ?></th>
                                                        <td><?= $row['pname'] ?></td>
                                                        <td><?= $row1['title'] ?></td>
                                                        <td><?= $row1['qty'] ?></td>
                                                        <td><?= intval($row1['price']) ?></td>
                                                        <td><?= intval($row1['qty']) * intval($row1['price']) ?></td>
                                                    </tr>
                                        <?php
                                                    $i++;
                                                }
                                            }
                                        } ?>
                                    </tbody>
                                </table>

                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-12">
                    <!-- The time line -->
                    <section class="time-line-box text-center">
                        <div class="swiper-wrapper col-12">
                            <?php
                            $status = json_decode($order_detls[0]['status']);
                            $status_wise_class = [
                                'pending' => ['fa fa-xs fa-history', 'bg-secondary'],
                                'confirmed' => ['fa fa-xs fa-level-down-alt', 'bg-indigo'],
                                'preparing' => ['fa fa-xs fa-people-carry ', 'bg-navy'],
                                'out_for_delivery' => ['fa fa-xs fa-shipping-fast ', 'bg-yellow'],
                                'delivered' => ['fa fa-xs fa-user-check ', 'bg-success'],
                                'cancelled' => ['fa fa-xs fa-times-circle ', 'bg-red'],
                            ];
                            foreach ($status as $row) {
                            ?>
                                <div class="swiper-slide">
                                    <div class="max-auto col-md-6 offset-md-3">
                                        <div class="<?= $status_wise_class[$row[0]][1] ?> pt-2 pb-2 rounded"> <span class="fa-lg"><i class="<?= $status_wise_class[$row[0]][0] ?>"></i></span></div>
                                    </div>
                                    <div class="timestamp m-1"><small class="date"><i class="fas fa-clock"></i>&nbsp;<?= strtoupper($row[1]) ?> </small> </div>
                                    <div class="status text-bold"><span> <?= strtoupper($row[0]) ?> </span></div>
                                </div>
                            <?php } ?>

                        </div>
                    </section>
                </div>
                <div class="col-md-12">
                    <div class="card card-info">
                        <div class="card-body">
                            <div class="card card-widget widget-user-2">
                                <div class="widget-user-header bg-navy">
                                    <h5 class="text-left"> Order Items</h5>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col">
                                    <p class="h5">Partner Name: <span class="text text-primary"><?= output_escaping($restro_data[0]['partner_name']); ?> </span></p>
                                    <p class="h6">Partner Address: <span class="text text-primary"><?= $restro_data[0]['address']; ?> </span></p>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col">
                                    <a class="btn btn-danger" data-options="{&quot;iframe&quot; : {&quot;css&quot; : {&quot;width&quot; : &quot;80%&quot;, &quot;height&quot; : &quot;80%&quot;}}}" href="https://www.google.com/maps/search/?api=1&amp;query=<?= $restro_data[0]['restro_lat']; ?>,<?= $restro_data[0]['restro_lng']; ?>&hl=es;z=14&amp;output=embed">
                                        <i class="fas fa-map-marked-alt" aria-hidden="true"></i> Locate partner</a>
                                </div>
                            </div>
                            <hr>
                            <div class="row">
                                <div class="card-header">
                                    <h6 class="mb-0 text-left"><small><a href='javascript:void(0)' data-toggle='modal' id="view_add_on" data-target='#add-ons-model' class='btn btn-info' title='View Add Ons'>Add Ons</a></small></h6>
                                </div>
                            </div>
                            <?php $total = 0;
                            $tax_amount = 0;
                            foreach ($items as $item) {
                                $item['discounted_price'] = ($item['discounted_price'] == '') ? 0 : $item['discounted_price'];
                                $total += $subtotal = ($item['quantity'] != 0 && ($item['discounted_price'] != '' && $item['discounted_price'] > 0) && $item['price'] > $item['discounted_price']) ? ($item['price'] - $item['discounted_price']) : ($item['price'] * $item['quantity']);
                                $tax_amount += $item['tax_amount'];
                                $total += $subtotal = $tax_amount;
                            ?>
                                <div class="row">
                                    <div class="col">
                                        <div class="card card-2">
                                            <div class="card-body">
                                                <div class="media">
                                                    <div class="sq align-self-center ">
                                                        <a href='<?= base_url() . $item['product_image'] ?>' data-toggle='lightbox' data-gallery='order-images' class="order-product-image mx-2">
                                                            <img src='<?= base_url() . $item['product_image'] ?>' class="img-fluid" />
                                                        </a>
                                                    </div>
                                                    <div class="media-body my-auto text-right">
                                                        <div class="row my-auto flex-column flex-md-row">
                                                            <div class="col my-auto mx-2">
                                                                <h6 class="mb-0 text-left"><?= (strlen($item['pname']) > 25) ? substr($item['pname'], 0, 25) . "..." : $item['pname'] ?></h6>
                                                                <?php if (isset($item['product_variants']) && !empty($item['product_variants'])) { ?>
                                                                    <h6 class="mb-0 text-left"><small><?= str_replace(',', ' | ', $item['product_variants'][0]['variant_values']) ?></small></h6>
                                                                <?php } ?>
                                                            </div>
                                                            <div class="col-auto my-auto">
                                                                <div class="price mb-2 list-view-price">
                                                                    Price: <?= $settings['currency'] . number_format($item['price'] + $item['tax_amount']) ?>
                                                                    <?php if (isset($item['discounted_price']) && !empty($item['discounted_price'])) { ?>
                                                                        <span class="striped-price"><?= $settings['currency'] . number_format($item['discounted_price']) ?>
                                                                        </span>
                                                                    <?php } ?>
                                                                    <a href=" <?= BASE_URL('admin/product/view-product?edit_id=' . $item['product_id'] . '') ?>" title="View Product" class="btn btn-info btn-xs">
                                                                        <i class="fa fa-eye"></i>
                                                                    </a>
                                                                </div>
                                                            </div>
                                                            <div class="col my-auto"> Variant ID : <?= $item['product_variant_id'] ?> </div>
                                                            <div class="col my-auto"> Qty : <?= $item['quantity'] ?></div>
                                                            <div class="col my-auto"> Type: <?= ucwords(str_replace('_', ' ', $item['product_type'])); ?> </div>
                                                            <div class="col my-auto">
                                                                <h6 class="mb-0"><?= $settings['currency'] . number_format($item['price'] * $item['quantity']) ?></h6>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            <?php } ?>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="card card-info">
                                        <div class="card-header bg-navy border-0 h5">Customer Details</div>
                                        <div class="card-body">
                                            <div class="card card-widget widget-user-2">
                                                <div class="widget-user-header bg-info">
                                                    <input type="hidden" name="hidden" id="order_id" value="<?php echo $order_detls[0]['id']; ?>">

                                                    <div class="widget-user-image">
                                                        <img class="img-circle elevation-2" src="<?= base_url(AVTAR_IMAGE) ?>" alt="User Avatar">
                                                    </div>
                                                    <h5 class="widget-user-desc"><?= $order_detls[0]['uname']; ?></h5>
                                                    <h6 class="widget-user-desc"><?= $order_detls[0]['address']; ?></h6>
                                                </div>
                                                <div class="card-footer p-0">
                                                    <ul class="nav flex-column">
                                                        <li class="nav-item">
                                                            <a href="javascript:void(0)" class="nav-link text-dark">Contact <span class="float-right text-primary"><?= (defined('ALLOW_MODIFICATION') && ALLOW_MODIFICATION == 0) ? str_repeat("X", strlen($order_detls[0]['mobile']) - 3) . substr($order_detls[0]['mobile'], -3) : $order_detls[0]['mobile']; ?></span></a>
                                                        </li>
                                                        <li class="nav-item">
                                                            <a href="javascript:void(0)" class="nav-link text-dark">Email <span class="float-right text-primary"><?= (defined('ALLOW_MODIFICATION') && ALLOW_MODIFICATION == 0) ? str_repeat("X", strlen($order_detls[0]['email']) - 3) . substr($order_detls[0]['email'], -3) : $order_detls[0]['email']; ?></span></a>
                                                        </li>
                                                        <li class="nav-item">
                                                            <a href="javascript:void(0)" class="nav-link text-dark">User Wallet Balance(<?= $settings['currency'] ?>)<span class="float-right text-primary"><?= $order_detls[0]['user_balance']; ?></span>
                                                            </a>
                                                        </li>
                                                        <li class="nav-item">
                                                            <a href="javascript:void(0)" class="nav-link text-dark">Order Date<span class="float-right text-primary"> <?= date('d-M-Y, g:i A - D', strtotime($order_detls[0]['date_added'])); ?></span></a>
                                                        </li>
                                                    </ul>
                                                </div>
                                                <a class="btn btn-danger" data-options="{&quot;iframe&quot; : {&quot;css&quot; : {&quot;width&quot; : &quot;80%&quot;, &quot;height&quot; : &quot;80%&quot;}}}" href="https://www.google.com/maps/search/?api=1&amp;query=<?= $order_detls[0]['user_lat']; ?>,<?= $order_detls[0]['user_lng']; ?>&hl=es;z=14&amp;output=embed"><i class="fas fa-map-marked-alt" aria-hidden="true"></i> Locate Customer</a>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="card card-info">
                                        <div class="card-body">
                                            <div class="card card-widget widget-user-2">
                                                <div class="widget-user-header bg-navy">
                                                    <h5 class="text-center">Payment Details</h5>
                                                </div>
                                                <div class="card-footer p-0">
                                                    <ul class="nav flex-column">
                                                        <li class="nav-item">
                                                            <a href="javascript:void(0)" class="nav-link text-dark">Payment Method<span class="float-right text-primary"><?= $order_detls[0]['payment_method']; ?></span></a>
                                                        </li>
                                                        <li class="nav-item">
                                                            <a href="javascript:void(0)" class="nav-link text-dark">Total(<?= $settings['currency'] ?>)<span class="float-right text-primary" id='amount'>
                                                                    <?= '+ ' . number_format($order_detls[0]['order_total']);
                                                                    $total = $order_detls[0]['order_total']; ?></span>
                                                            </a>
                                                        </li>
                                                        <li class="nav-item">
                                                            <a href="javascript:void(0)" class="nav-link text-dark">Delivery Charge(<?= $settings['currency'] ?>)<span class="float-right text-primary"><?php echo '+ ' . $order_detls[0]['delivery_charge'];
                                                                                                                                                                                                        $total = $total + $order_detls[0]['delivery_charge']; ?></span></a>
                                                        </li>
                                                        <li class="nav-item">
                                                            <a href="javascript:void(0)" class="nav-link text-dark">Delivery Tip(<?= $settings['currency'] ?>)<span class="float-right text-primary"><?php echo '+ ' . $order_detls[0]['delivery_tip'];
                                                                                                                                                                                                        $total = $total + $order_detls[0]['delivery_tip']; ?></span></a>
                                                        </li>
                                                        <li class="nav-item">
                                                            <a href="javascript:void(0)" class="nav-link text-dark">Wallet Balance(<?= $settings['currency'] ?>) <span class="float-right text-primary"><?php echo  '- ' . $order_detls[0]['wallet_balance'];
                                                                                                                                                                                                        $total = $total - $order_detls[0]['wallet_balance'];  ?></span></a>
                                                        </li>
                                                        <li class="nav-item">
                                                            <a href="javascript:void(0)" class="nav-link text-dark">Promo Code Discount (<?= $settings['currency'] ?>)<span class="float-right text-primary">
                                                                    <?php echo '- ' . $order_detls[0]['promo_discount'];
                                                                    $total = floatval($total - $order_detls[0]['promo_discount']); ?></span>
                                                            </a>
                                                        </li>
                                                        <input type="hidden" name="total_amount" id="total_amount" value="<?php echo $order_detls[0]['order_total'] + $order_detls[0]['delivery_charge'] ?>">
                                                        <input type="hidden" name="final_amount" id="final_amount" value="<?php echo $order_detls[0]['final_total']; ?>">
                                                        <input type="hidden" id="final_total" name="final_total" value="<?= $total; ?>">
                                                        <li class="nav-item">
                                                            <a href="javascript:void(0)" class="nav-link bg-info">
                                                                Payable Total(<?= $settings['currency'] ?>) <span class="float-right"><?= $total; ?></span>
                                                            </a>
                                                        </li>

                                                    </ul>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <!-- /.widget-user -->
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <table class="table table-borderless">
                                        <tbody>
                                            <tr>
                                                <th class="col-2">Status <span class='text-danger text-sm'>*</span></th>
                                                <td>
                                                    <select name="status" id="status" class="form-control" data-isjson="true" data-orderid="<?= $order_detls[0]['id']; ?>">
                                                        <option value="">Select</option>
                                                        <option value="out_for_delivery" <?= (isset($order_detls[0]['active_status']) && $order_detls[0]['active_status'] == 'out_for_delivery') ? 'selected' : '' ?>>Out For Delivery</option>
                                                        <option value="delivered" <?= (isset($order_detls[0]['active_status']) && $order_detls[0]['active_status'] == 'delivered') ? 'selected'  : '' ?>>Delivered</option>
                                                        <option value="cancelled" <?= (isset($order_detls[0]['active_status']) && $order_detls[0]['active_status'] == 'cancelled') ? 'selected'  : '' ?>>Cancel</option>
                                                    </select>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2">
                                                    <div class="form-group">
                                                        <button type="submit" class="btn btn-info update_status_rider" data-id="<?= $order_detls[0]['id']; ?>" data-otp-system='<?= ($order_detls[0]['item_otp'] != 0) ? '1' : '0' ?>' id="submit_btn">Update Order</button>
                                                    </div>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>

                            </div>
                        </div>
                    </div>
                    <!--/.card-->
                </div>

                <!--/.col-md-12-->
            </div>
            <!-- /.row -->
        </div><!-- /.container-fluid -->
    </section>
    <!-- /.content -->
</div>