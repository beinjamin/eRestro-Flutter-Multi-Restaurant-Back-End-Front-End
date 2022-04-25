"use strict";

/* ---------------------------------------------------------------------------------------------------------------------------------------------------

Common-Functions or events
 1.login-Module
 2.Product-Module
 3.Category-Module
 4.Order-Module
 5.Featured_Section-Module
 6.Notifation-Module
 7.Faq-Module
 8.Slider-Module
 9.Offer-Module
 10.Promo_code-Module
 11.Riders-Module 
 12.Settings-Module 
 13.City-Module
 14.Transaction_Module
 15.Customer-Wallet-Module   
 16.Fund-Transfer-Module
 17.Return-Request-Module
 18.Tax-Module
 19.Image Upload 
 20.Client Api Key Module  
 21.System Users
--------------------------------------------------------------------------------------------------------------------------------------------------- */


$(document).ready(function () {
    $('#loading').hide();
    var is_dark_mode = sessionStorage.getItem("dark_mode");
    $('body').toggleClass('dark-mode');
    if (is_dark_mode == 'true') {
        $('#dark-mode-icon').removeClass('fas fa-moon');
        $('#dark-mode-icon').addClass('fas fa-sun text-warning');
        $('#admin-sidebar').removeClass('main-sidebar elevation-2 sidebar-light-info');
        $('#admin-sidebar').addClass('main-sidebar elevation-2 sidebar-dark-info');
    } else {
        $('body').toggleClass('dark-mode');
        $('#admin-sidebar').removeClass('main-sidebar elevation-2 sidebar-dark-info');
        $('#admin-sidebar').addClass('main-sidebar elevation-2 sidebar-light-info');
        $('#dark-mode-icon').removeClass('fas fa-sun text-warning');
        $('#dark-mode-icon').addClass('fas fa-moon');
    }
});

var from = 'admin';
if (window.location.href.indexOf("partner/") > -1) {
    from = 'partner';
}

$(document).on('click', '#panel_dark_mode', function () {
    $('body').toggleClass('dark-mode');
    if ($('body').hasClass('dark-mode')) {
        $('#dark-mode-icon').removeClass('fas fa-moon');
        $('#dark-mode-icon').addClass('fas fa-sun text-warning');
        $('#admin-sidebar').removeClass('main-sidebar elevation-2 sidebar-light-info');
        $('#admin-sidebar').addClass('main-sidebar elevation-2 sidebar-dark-info');
        sessionStorage.setItem("dark_mode", true);
    } else {
        $('#admin-sidebar').removeClass('main-sidebar elevation-2 sidebar-dark-info');
        $('#admin-sidebar').addClass('main-sidebar elevation-2 sidebar-light-info');
        $('#dark-mode-icon').removeClass('fas fa-sun text-warning');
        $('#dark-mode-icon').addClass('fas fa-moon');
        sessionStorage.setItem("dark_mode", false);
    }
});

$.event.special.touchstart = {
    setup: function (_, ns, handle) {
        this.addEventListener("touchstart", handle, { passive: !ns.includes("noPreventDefault") });
    }
};
$(document).ready(function () {
    $('.kv-fa').rating({
        theme: 'krajee-fa',
        filledStar: '<i class="fas fa-star"></i>',
        emptyStar: '<i class="far fa-star"></i>',
        showClear: false,
        size: 'md'
    });
});


$(document).on('load-success.bs.table', '#product-rating-table', function (event) {

    $('.kv-fa').rating({
        theme: 'krajee-fa',
        filledStar: '<i class="fas fa-star"></i>',
        emptyStar: '<i class="far fa-star"></i>',
        showClear: false,
        size: 'md'
    });

});
$(document).on('load-success.bs.table', '#rider-rating-modal', function (event) {

    $('.kv-fa').rating({
        theme: 'krajee-fa',
        filledStar: '<i class="fas fa-star"></i>',
        emptyStar: '<i class="far fa-star"></i>',
        showClear: false,
        size: 'md'
    });

});

$(document).on('load-success.bs.table', '#products_table', function (event) {

    $('.kv-fa').rating({
        theme: 'krajee-fa',
        filledStar: '<i class="fas fa-star"></i>',
        emptyStar: '<i class="far fa-star"></i>',
        showClear: false,
        size: 'md'
    });

});

$(document).on('column-switch.bs.table', '#products_table', function (event) {

    $('.kv-fa').rating({
        theme: 'krajee-fa',
        filledStar: '<i class="fas fa-star"></i>',
        emptyStar: '<i class="far fa-star"></i>',
        showClear: false,
        size: 'md'
    });

});


$(document).on('click', '.delete-product-rating', function () {
    var cat_id = $(this).data('id');
    Swal.fire({
        title: 'Are You Sure!',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    type: 'GET',
                    url: base_url + 'admin/product/delete_rating',
                    data: { id: cat_id },
                    dataType: 'json'
                })
                    .done(function (response, textStatus) {
                        if (response.error == false) {
                            Swal.fire('Deleted!', response.message, 'success');
                            $('table').bootstrapTable('refresh');
                            csrfName = response['csrfName'];
                            csrfHash = response['csrfHash'];
                        } else {
                            Swal.fire('Oops...', response.message, 'warning');
                            $('table').bootstrapTable('refresh');
                            csrfName = response['csrfName'];
                            csrfHash = response['csrfHash'];
                        }
                    })
                    .fail(function (jqXHR, textStatus, errorThrown) {
                        Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                        csrfName = response['csrfName'];
                        csrfHash = response['csrfHash'];
                    });
            });
        },
        allowOutsideClick: false
    });
});




iziToast.settings({
    position: 'topRight',
});

$("[data-toggle=tooltip").tooltip();

var attributes_values_selected = [];
var variant_values_selected = [];
var value_check_array = [];
var attributes_selected_variations = [];
var attributes_values = [];
var pre_selected_attr_values = [];
var current_attributes_selected = [];
var current_variants_selected = [];
var attribute_flag = 0;
var pre_selected_attributes_name = []
var current_selected_image;
var attributes_values = [];
var all_attributes_values = [];
var counter = 0;
var variant_counter = 0;

//-------------
//- CATEGORY EISE PRODUCT SALE CHART -
//-------------
// Get context with jQuery - using jQuery's .get() method.


if (document.getElementById('piechart_3d')) {
    $.ajax({
        url: base_url + from + '/home/category_wise_product_count',
        type: 'GET',
        dataType: 'json',
        success: function (result) {
            google.charts.load("current", { packages: ["corechart"] });
            google.charts.setOnLoadCallback(drawChart);

            function drawChart() {

                var data = google.visualization.arrayToDataTable(result);

                var options = {
                    title: '',
                    is3D: true,
                };

                var chart = new google.visualization.PieChart(document.getElementById('piechart_3d'));
                chart.draw(data, options);
            }
        }
    });



    $.ajax({
        url: base_url + from + '/home/fetch_sales',
        type: 'GET',
        dataType: 'json',
        success: function (result) {
            $(window).on,
                function (e, t, a) {
                    "use strict";
                    var n, s, i, o, r, l, h, c;
                    n = function (e, t, a) {
                        var n = new Chartist.Line("#" + e, {
                            labels: t,
                            series: [a]
                        }, {
                            lineSmooth: Chartist.Interpolation.simple({
                                divisor: 2
                            }),
                            fullWidth: !0,
                            chartPadding: {
                                right: 25
                            },
                            series: {
                                "series-1": {
                                    showArea: !1
                                }
                            },
                            axisX: {
                                showGrid: !1
                            },
                            axisY: {
                                labelInterpolationFnc: function (e) {
                                    return e / 1e3 + "K"
                                },
                                scaleMinSpace: 40
                            },
                            low: 0,
                            showPoint: !1,
                            height: 300
                        });
                        n.on("created", (function (t) {
                            var a = t.svg.querySelector("defs") || t.svg.elem("defs"),
                                n = (t.svg.width(), t.svg.height(), a.elem("filter", {
                                    x: 0,
                                    y: "-10%",
                                    id: "shadow" + e
                                }, "", !0));
                            return n.elem("feGaussianBlur", {
                                in: "SourceAlpha",
                                stdDeviation: "24",
                                result: "offsetBlur"
                            }), n.elem("feOffset", {
                                dx: "0",
                                dy: "32"
                            }), n.elem("feBlend", {
                                in: "SourceGraphic",
                                mode: "multiply"
                            }), a.elem("linearGradient", {
                                id: e + "-gradient",
                                x1: 0,
                                y1: 0,
                                x2: 1,
                                y2: 0
                            }).elem("stop", {
                                offset: 0,
                                "stop-color": "rgba(22, 141, 238, 1)"
                            }).parent().elem("stop", {
                                offset: 1,
                                "stop-color": "rgba(98, 188, 246, 1)"
                            }), a
                        })).on("draw", (function (t) {
                            "line" === t.type ? t.element.attr({
                                filter: "url(#shadow" + e + ")"
                            }) : "point" === t.type && new Chartist.Svg(t.element._node.parentNode).elem("line", {
                                x1: t.x,
                                y1: t.y,
                                x2: t.x + .01,
                                y2: t.y,
                                class: "ct-point-content"
                            }), "line" !== t.type && "area" != t.type || t.element.animate({
                                d: {
                                    begin: 1e3 * t.index,
                                    dur: 1e3,
                                    from: t.path.clone().scale(1, 0).translate(0, t.chartRect.height()).stringify(),
                                    to: t.path.clone().stringify(),
                                    easing: Chartist.Svg.Easing.easeOutQuint
                                }
                            })
                        }))
                    },
                        s = result[2].day, i = {
                            name: "series-1",
                            data: result[2].total_sale
                        },
                        o = result[1].week,
                        r = {
                            name: "series-1",
                            data: result[1].total_sale
                        },
                        l = result[0].month_name,
                        h = {
                            name: "series-1",
                            data: result[0].total_sale
                        }, (c = function (e) {
                            switch ((e || a("#ecommerceChartView .chart-action").find(".active")).attr("href")) {
                                case "#scoreLineToDay":
                                    n("scoreLineToDay", s, i);
                                    break;
                                case "#scoreLineToWeek":
                                    n("scoreLineToWeek", o, r);
                                    break;
                                case "#scoreLineToMonth":
                                    n("scoreLineToMonth", l, h)
                            }
                        })(), a(".chart-action li a").on("click", (function () {
                            c(a(this))
                        }))
                }(window, document, jQuery);
        }
    });
}
$(document).on("click", '[data-toggle="lightbox"]', function (event) {
    event.preventDefault();
    $(this).ekkoLightbox();
});

var url = window.location.origin + window.location.pathname;
var $selector = $('.sidebar a[href="' + url + '"]');
$($selector).addClass('active');
$($selector).closest('ul').closest('li').addClass('menu-open');
$($selector).closest('ul').removeAttr('style');
$($selector).closest('ul').closest('li').find('a[href*="#"').addClass('active');

var tmp = [];
var permute_counter = 0;

//User defined functions
function copyToClipboard(element) {
    var $temp = $("<input>");
    $("body").append($temp);
    $temp.val($(element).text()).select();
    document.execCommand("copy");
    $temp.remove();
}

function containsAll(needles, haystack) {
    for (var i = 0; i < needles.length; i++) {
        if ($.inArray(needles[i], haystack) == -1) return false;
    }
    return true;
}

function getPermutation(args) {
    var r = [],
        max = args.length - 1;

    function helper(arr, i) {
        for (var j = 0, l = args[i].length; j < l; j++) {
            var a = arr.slice(0); // clone arr
            a.push(args[i][j]);
            if (i == max)
                r.push(a);
            else
                helper(a, i + 1);
        }
    }
    helper([], 0);
    return r;
}


function clear_form_elements(class_name) {
    jQuery("." + class_name).find(':input').each(function () {
        switch (this.type) {
            case 'password':
            case 'text':
            case 'textarea':
            case 'file':
            case 'select-one':
            case 'select-multiple':
            case 'date':
            case 'number':
            case 'tel':
            case 'email':
                jQuery(this).val('');
                break;
            case 'checkbox':
            case 'radio':
                this.checked = false;
                break;
        }
    });
}
function add_product_variant_html(type) {

    if (type == 'packet') {
        var html = "<div class='row offset-md-1 border-bottom ml-5 mr-5 mb-3'><div class='col-md-12 mt-2 remove_pro_btn'><div class='card-tools float-right'> <label>Remove</label> <button type='button' class='btn btn-tool' id='remove_product_btn'> <i class='text-danger far fa-times-circle fa-2x '></i> </button></div></div><div class='form-group col-md-4'> <label for='inputPassword' class='col-sm-4 col-form-label'>Measurement</label><div class='col-sm-10'> <span><input type='number' name='packet_measurement[]' ></span></div></div><div class='form-group col-md-4'> <label for='inputPassword' class='col-sm-6 col-form-label'>Unit</label><div class='col-sm-6'> <select class='form-control valid' name='packet_measurement_unit_id[]' aria-invalid='false'><option value='1'>kg</option><option value='2'>gm</option><option value='3'>ltr</option><option value='4'>ml</option><option value='5'>pack</option> </select></div></div><div class='form-group col-md-4'> <label for='inputPassword' class='col-sm-4 col-form-label'>Price</label><div class='col-sm-10'> <span><input type='number' class='price' name='packet_price[]'></span></div></div><div class='form-group col-md-4'> <label for='inputPassword' class='col-sm-4 col-form-label'>Discounted Price</label><div class='col-sm-10'> <span><input type='number' class='discount' name='packet_discnt[]'></span></div></div><div class='form-group col-md-4'> <label for='inputPassword' class='col-sm-4 col-form-label'>Stock</label><div class='col-sm-10'> <input type='number' name='packet_stock[]'></div></div><div class='form-group col-md-4'> <label for='inputPassword' class='col-sm-4 col-form-label'>Unit</label><div class='col-sm-6'> <select class='form-control valid' name='packet_stock_unit_id[]' aria-invalid='false'><option value='1'>kg</option><option value='2'>gm</option><option value='3'>ltr</option><option value='4'>ml</option><option value='5'>pack</option> </select></div></div><div class='form-group col-md-4'> <label for='inputPassword' class='col-sm-4 col-form-label'>Status</label><div class='col-sm-6'> <select name='packet_serve_for[]' class='form-control' required='' aria-invalid='false'><option value='Available'>Available</option><option value='Sold Out'>Sold Out</option> </select></div></div></div>";
        return html;
    } else {
        var html = '<div class="row offset-md-1 border-bottom ml-5 mr-5 mb-3"><div class="col-md-12 mt-2 remove_pro_btn"><div class="card-tools float-right"> <label>Remove</label> <button type="button" class="btn btn-tool" id="remove_product_btn"> <i class="text-danger far fa-times-circle fa-2x "></i> </button></div></div><div class="form-group col-md-3 col-12"> <label for="inputPassword" class="col-sm-12 col-form-label">Measurement</label><div class="col-12"> <span><input type="number" name="loose_measurement[]" class="col-12" ></span></div></div><div class="form-group col-md-3"> <label for="inputPassword" class="col-sm-6 col-form-label">Unit</label><div class="col-sm-12"> <select class="form-control valid" name="loose_measurement_unit_id[] col-12" aria-invalid="false"><option value="1">kg</option><option value="2">gm</option><option value="3">ltr</option><option value="4">ml</option><option value="5">pack</option> </select></div></div><div class="form-group col-md-3"> <label for="inputPassword" class="col-sm-4 col-form-label">Price</label><div class="col-sm-10"> <span><input type="number" name="loose_price[]" class="col-12 price"></span></div></div><div class="form-group col-md-3"> <label for="inputPassword" class="col-sm-12 col-form-label">Discounted Price</label><div class="col-sm-10"> <span><input type="number" name="loose_discnt[]" class="col-12 discount"></span></div></div></div>';
        return html;
    }

}

function save_attributes() {
    attributes_values = [];
    all_attributes_values = [];
    var tmp = $('.product-attr-selectbox');
    $.each(tmp, function (index) {
        var data = $(tmp[index]).closest('.row').find('.multiple_values').select2('data');
        var tmp_values = [];
        for (var i = 0; i < data.length; i++) {
            if (!$.isEmptyObject(data[i])) {
                tmp_values[i] = data[i].id;
            }
        }
        if (!$.isEmptyObject(data)) {
            all_attributes_values.push(tmp_values);
        }
        if ($(tmp[index]).find('.is_attribute_checked').is(':checked')) {
            if (!$.isEmptyObject(data)) {
                attributes_values.push(tmp_values);
            }
        }
    });
}

function create_variants(preproccessed_permutation_result = false, from) {

    var html = "";
    var is_appendable = false;
    var permutated_attribute_value = [];
    if (preproccessed_permutation_result != false) {
        var response = preproccessed_permutation_result;
        is_appendable = true;
    } else {
        var response = getPermutation(attributes_values);
    }
    var selected_variant_ids = JSON.stringify(response);
    var selected_attributes_values = JSON.stringify(attributes_values);

    $('.no-variants-added').hide();
    $.ajax({
        type: 'GET',
        url: base_url + from + '/product/get_variants_by_id',
        data: {
            variant_ids: selected_variant_ids,
            attributes_values: selected_attributes_values,
        },
        dataType: 'json',
        success: function (data) {
            var result = data['result'];
            $.each(result, function (a, b) {

                variant_counter++;
                var attr_name = 'pro_attr_' + variant_counter;
                html += '<div class="form-group move row my-auto p-2 border rounded bg-gray-light product-variant-selectbox"><div class="col-1 text-center my-auto"><i class="fas fa-sort"></i></div>';
                var tmp_variant_value_id = " ";
                $.each(b, function (key, value) {
                    tmp_variant_value_id = tmp_variant_value_id + " " + value.id;
                    html += '<div class="col-2"> <input type="text" class="col form-control" value="' + value.value + '" readonly></div>';
                });
                html += '<input type="hidden" name="variants_ids[]" value="' + tmp_variant_value_id + '"><div class="col my-auto row justify-content-center"> <a data-toggle="collapse" class="btn btn-tool text-primary" data-target="#' + attr_name + '" aria-expanded="true"><i class="fas fa-angle-down fa-2x"></i> </a> <button type="button" class="btn btn-tool remove_variants"> <i class="text-danger far fa-times-circle fa-2x "></i> </button></div><div class="col-12" id="variant_stock_management_html"><div id=' + attr_name + ' style="" class="collapse">';

                html += '<div class="form-group row"><div class="col col-xs-12"><label class="control-label">Price :</label><input type="number" name="variant_price[]" class="col form-control price varaint-must-fill-field" min="0" step="0.01"></div><div class="col col-xs-12"><label class="control-label">Special Price :</label><input type="number" name="variant_special_price[]" class="col form-control discounted_price" min="0" step="0.01"></div>';

                html += '</div></div></div></div></div>';
            });

            if (is_appendable == false) {
                $('#variants_process').html(html);
            } else {
                $('#variants_process').append(html);
            }
            $('#variants_process').unblock();
        }
    });
}

function create_attributes(value, selected_attr) {
    counter++;
    var $attribute = $('#attributes_values_json_data').find('.select_single');
    var $options = $($attribute).clone().html();
    var $selected_attrs = [];
    if (selected_attr) {
        $.each(selected_attr.split(","), function () {
            $selected_attrs.push($.trim(this));
        });
    }

    var attr_name = 'pro_attr_' + counter;

    // product-attr-selectbox
    if ($('#product-type').val() == 'simple_product') {
        var html = '<div class="form-group move row my-auto p-2 border rounded bg-gray-light product-attr-selectbox" id=' + attr_name + '><div class="col-md-1 col-sm-12 text-center my-auto"><i class="fas fa-sort"></i></div><div class="col-md-4 col-sm-12"> <select name="attribute_id[]" class="attributes select_single" data-placeholder=" Type to search and select attributes"><option value=""></option>' + $options + '</select></div><div class="col-md-4 col-sm-12"> <select name="attribute_value_ids[]" class="multiple_values" multiple="" data-placeholder=" Type to search and select attributes values"><option value=""></option> </select></div><div class="col-md-2 col-sm-6 text-center py-1 align-self-center"> <button type="button" class="btn btn-tool remove_attributes"> <i class="text-danger far fa-times-circle fa-2x "></i> </button></div></div>';
    } else {
        $('#note').removeClass('d-none');
        var html = '<div class="form-group row move my-auto p-2 border rounded bg-gray-light product-attr-selectbox" id=' + attr_name + '>' +
            '<div class="col-md-1 col-sm-12 text-center my-auto"><i class="fas fa-sort"></i></div><div class="col-md-4 col-sm-12">' +
            '<select name="attribute_id[]" class="attributes select_single" data-placeholder=" Type to search and select attributes"><option value=""></option>' + $options + '</select></div>' +
            '<div class="col-md-4 col-sm-12"> <select name="attribute_value_ids[]" class="multiple_values" multiple="" data-placeholder=" Type to search and select attributes values">' +
            '<option value=""></option> </select></div><div class="col-md-2 col-sm-6 text-center py-1 align-self-center"><input type="checkbox" name="variations[]" class="is_attribute_checked custom-checkbox mt-2">' +
            '</div><div class="col-md-1 col-sm-6 text-center py-1 align-self-center"> <button type="button" class="btn btn-tool remove_attributes"> <i class="text-danger far fa-times-circle fa-2x "></i> ' +
            '</button></div></div>';
    }
    $('#attributes_process').append(html);
    if (selected_attr) {
        if ($.inArray(value.name, $selected_attrs) > -1) {
            $("#attributes_process").find('.product-attr-selectbox').last().find('.is_attribute_checked').prop('checked', true).addClass('custom-checkbox mt-2');
            $("#attributes_process").find('.product-attr-selectbox').last().find('.remove_attributes').addClass('remove_edit_attribute').removeClass('remove_attributes');

        }
    }
    $("#attributes_process").find('.product-attr-selectbox').last().find(".attributes").select2({
        theme: 'bootstrap4',
        width: $(this).data('width') ? $(this).data('width') : $(this).hasClass('w-100') ? '100%' : 'style',
        placeholder: $(this).data('placeholder'),
        allowClear: Boolean($(this).data('allow-clear')),
    }).val(value.name);

    $("#attributes_process").find('.product-attr-selectbox').last().find(".attributes").trigger('change');
    $("#attributes_process").find('.product-attr-selectbox').last().find(".select_single").trigger('select2:select');

    var multiple_values = [];
    $.each(value.ids.split(","), function () {
        multiple_values.push($.trim(this));
    });

    $("#attributes_process").find('.product-attr-selectbox').last().find(".multiple_values").select2({
        theme: 'bootstrap4',
        width: $(this).data('width') ? $(this).data('width') : $(this).hasClass('w-100') ? '100%' : 'style',
        placeholder: $(this).data('placeholder'),
        allowClear: Boolean($(this).data('allow-clear')),
    }).val(multiple_values);
    $("#attributes_process").find('.product-attr-selectbox').last().find(".multiple_values").trigger('change');
}

function create_fetched_attributes_html(from) {
    var edit_id = $('input[name="edit_product_id"]').val();
    $.ajax({
        type: 'GET',
        url: base_url + from + '/product/fetch_attributes_by_id',
        data: {
            edit_id: edit_id,
            [csrfName]: csrfHash,
        },
        dataType: 'json',
        success: function (data) {
            csrfName = data['csrfName'];
            csrfHash = data['csrfHash'];
            var result = data['result'];

            if (!$.isEmptyObject(result.attr_values)) {

                $.each(result.attr_values, function (key, value) {
                    create_attributes(value, result.pre_selected_variants_names);
                });

                $.each(result['pre_selected_variants_ids'], function (key, val) {
                    var tempArray = [];
                    if (val.variant_ids) {
                        $.each(val.variant_ids.split(','), function (k, v) {
                            tempArray.push($.trim(v));
                        });
                        pre_selected_attr_values[key] = tempArray;
                    }
                });

                if (result.pre_selected_variants_names) {
                    $.each(result.pre_selected_variants_names.split(','), function (key, value) {
                        pre_selected_attributes_name.push($.trim(value));
                    });
                }
            } else {
                $('.no-attributes-added').show();
                $('#save_attributes').addClass('d-none');
            }
        }
    });
    return $.Deferred().resolve();
}

function search_category_wise_products() {
    var category_id = $('#category_parent').val();
    if (category_id != '') {
        $.ajax({
            data: {
                'cat_id': category_id,
            },
            type: 'GET',
            url: base_url + 'admin/product/search_category_wise_products',
            dataType: 'json',
            success: function (result) {
                var html = "";
                var i = 0;
                if (!$.isEmptyObject(result)) {
                    $.each(result, function (index, value) {
                        html += '<li class="list-group-item d-flex bg-gray-light align-items-center h-25 ui-sortable-handle" id="product_id-' + value['id'] + '">';
                        html += '<div class="col-md-1"><span> ' + i + ' </span></div>';
                        html += '<div class="col-md-3"><span> ' + value['row_order'] + ' </span></div>';
                        html += '<div class="col-md-4"><span>' + value['name'] + '</span></div>';
                        html += '<div class="col-md-4"><img src="' + base_url + value['image'] + '"  class="w-25"></div>';
                        i++;
                    });
                    $('#sortable').html(html);
                } else {

                    iziToast.error({
                        message: 'No Products Are Available',
                    });

                    html += '<li class="list-group-item d-flex justify-content-center bg-gray-light align-items-center h-25 ui-sortable-handle" id="product_id-3"><div class="col-md-12 d-flex justify-content-center"><span>No Products  Are  Available</span></div></li>';
                    $('#sortable').html(html);
                }
            }
        });
    } else {
        iziToast.error({
            message: 'Category Field Should Be Selected',
        });
    }
}



function save_product(form) {

    $('input[name="product_type"]').val($('#product-type').val());
    if ($('.simple_stock_management_status').is(':checked')) {
        $('input[name="simple_product_stock_status"]').val($('#simple_product_stock_status').val());
    } else {
        $('input[name="simple_product_stock_status"]').val('');
    }
    $('#product-type').prop('disabled', true);
    $('.product-attributes').removeClass('disabled');
    $('.product-variants').removeClass('disabled');
    $('.simple_stock_management_status').prop('disabled', true);

    var catid = $('#product_category_tree_view_html').jstree("get_selected");
    var formData = new FormData(form);
    var submit_btn = $('#submit_btn');
    var btn_html = $('#submit_btn').html();
    var btn_val = $('#submit_btn').val();
    var button_text = (btn_html != '' || btn_html != 'undefined') ? btn_html : btn_val;
    save_attributes();
    formData.append(csrfName, csrfHash);

    formData.append('category_id', catid);
    formData.append('attribute_values', all_attributes_values);

    $.ajax({
        type: 'POST',
        url: $(form).attr('action'),
        data: formData,
        beforeSend: function () {
            submit_btn.html('Please Wait..');
            submit_btn.attr('disabled', true);
        },
        cache: false,
        contentType: false,
        processData: false,
        dataType: 'json',
        success: function (result) {
            csrfName = result['csrfName'];
            csrfHash = result['csrfHash'];

            if (result['error'] == true) {
                submit_btn.html(button_text);
                submit_btn.attr('disabled', false);
                iziToast.error({
                    message: result['message'],
                });

            } else {
                submit_btn.html(button_text);
                submit_btn.attr('disabled', false);
                iziToast.success({
                    message: result['message'],
                });
                setTimeout(function () { location.reload(); }, 600);
            }
        }
    });
}


function get_variants(edit_id, from) {
    return $.ajax({
        type: 'GET',
        url: base_url + from + '/product/fetch_variants_values_by_pid',
        data: {
            edit_id: edit_id
        },
        dataType: 'json'
    })
        .done(function (data) {
            return data.responseCode != 200 ?
                $.Deferred().reject(data) : data;
        });

}

function create_fetched_variants_html(add_newly_created_variants = false, from) {

    var newArr1 = [];
    for (var i = 0; i < pre_selected_attr_values.length; i++) {
        var temp = newArr1.concat(pre_selected_attr_values[i]);
        newArr1 = [...new Set(temp)];

    }
    var newArr2 = [];
    for (var i = 0; i < attributes_values.length; i++) {
        newArr2 = newArr2.concat(attributes_values[i]);
    }


    current_attributes_selected = $.grep(newArr2, function (x) { return $.inArray(x, newArr1) < 0 });

    if (containsAll(newArr1, newArr2)) {
        var temp = [];
        if (!$.isEmptyObject(current_attributes_selected)) {
            $.ajax({
                type: 'GET',
                url: base_url + from + '/product/fetch_attribute_values_by_id',
                data: {
                    id: current_attributes_selected,
                },
                dataType: 'json',
                success: function (result) {
                    temp = result;
                    $.each(result, function (key, value) {
                        if (pre_selected_attributes_name.indexOf($.trim(value.name)) > -1) {
                            delete temp[key];
                        }
                    });
                    var resetArr = temp.filter(function () { return true; });
                    setTimeout(function () {
                        var edit_id = $('input[name="edit_product_id"]').val();
                        get_variants(edit_id, from).done(function (data) {
                            create_editable_variants(data.result, resetArr, add_newly_created_variants);
                        });
                    }, 1000);
                }
            });
        } else {
            if (attribute_flag == 0) {
                var edit_id = $('input[name="edit_product_id"]').val();
                get_variants(edit_id, from).done(function (data) {
                    create_editable_variants(data.result, false, add_newly_created_variants);
                });
            }
        }
    } else {
        var edit_id = $('input[name="edit_product_id"]').val();
        get_variants(edit_id, from).done(function (data) {
            create_editable_variants(data.result, false, add_newly_created_variants);
        });
    }
}

function create_editable_variants(data, newly_selected_attr = false, add_newly_created_variants = false) {
    if (data[0].variant_ids) {
        $('#reset_variants').show();
        var html = '';

        if (!$.isEmptyObject(attributes_values) && add_newly_created_variants == true) {
            var permuted_value_result = getPermutation(attributes_values);
        }

        $.each(data, function (a, b) {

            if (!$.isEmptyObject(permuted_value_result) && add_newly_created_variants == true) {
                var permuted_value_result_temp = permuted_value_result;
                var varinat_ids = b.variant_ids.split(',');
                $.each(permuted_value_result_temp, function (index, value) {
                    if (containsAll(varinat_ids, value)) {
                        permuted_value_result.splice(index, 1);
                    }
                });
            }

            variant_counter++;
            var attr_name = 'pro_attr_' + variant_counter;
            html += '<div class="form-group move row my-auto p-2 border rounded bg-gray-light product-variant-selectbox"><div class="col-1 text-center my-auto"><i class="fas fa-sort"></i></div>';
            html += '<input type="hidden" name="edit_variant_id[]" value=' + b.id + '>';
            var tmp_variant_value_id = "";
            var varaint_array = [];
            var varaint_ids_temp_array = [];
            var flag = 0;
            var variant_images = "";
            var image_html = "";
            if (b.images) {
                variant_images = JSON.parse(b.images);
            }

            $.each(b.variant_ids.split(","), function (key) {
                varaint_ids_temp_array[key] = $.trim(this);
            });

            $.each(b.variant_values.split(","), function (key) {
                varaint_array[key] = $.trim(this);
            });

            if (variant_images) {
                $.each(variant_images, function (img_key, img_value) {
                    image_html += '<div class="col-md-3 col-sm-12 shadow bg-white rounded m-3 p-3 text-center grow"><div class="image-upload-div"><img src=' + base_url + img_value + ' alt="Image Not Found"></div> <a href="javascript:void(0)" class="delete-img m-3" data-id="' + b.id + '" data-field="images" data-img=' + img_value + ' data-table="product_variants" data-path="uploads/media/" data-isjson="true"> <span class="btn btn-block bg-gradient-danger btn-xs"><i class="far fa-trash-alt "></i> Delete</span></a> <input type="hidden" name="variant_images[' + a + '][]"  value=' + img_value + '></div>';
                });
            }

            for (var i = 0; i < varaint_array.length; i++) {
                html += '<div class="col-2 variant_col"> <input type="hidden"  value="' + varaint_ids_temp_array[i] + '"><input type="text" class="col form-control" value="' + varaint_array[i] + '" readonly></div>';
            }
            if (newly_selected_attr != false && newly_selected_attr.length > 0) {
                for (var i = 0; i < newly_selected_attr.length; i++) {
                    var tempVariantsIds = [];
                    var tempVariantsValues = [];
                    $.each(newly_selected_attr[i].attribute_values_id.split(','), function () {
                        tempVariantsIds.push($.trim(this));
                    });
                    html += '<div class="col-2"><select class="col new-added-variant form-control" ><option value="">Select Attribute</option>';
                    $.each(newly_selected_attr[i].attribute_values.split(','), function (key) {
                        tempVariantsValues.push($.trim(this));
                        html += '<option value="' + tempVariantsIds[key] + '">' + tempVariantsValues[key] + '</option>';
                    });
                    html += '</select></div>';
                }
            }
            html += '<input type="hidden" name="variants_ids[]" value="' + b.attribute_value_ids + '"><div class="col my-auto row justify-content-center"> <a data-toggle="collapse" class="btn btn-tool text-primary" data-target="#' + attr_name + '" aria-expanded="true"><i class="fas fa-angle-down fa-2x"></i> </a> <button type="button" class="btn btn-tool remove_variants"> <i class="text-danger far fa-times-circle fa-2x "></i> </button></div><div class="col-12" id="variant_stock_management_html"><div id=' + attr_name + ' style="" class="collapse">';
            if ($('.variant_stock_status').is(':checked') && $('.variant-stock-level-type').val() == 'variable_level') {
                var selected = (b.availability == '0') ? 'selected' : ' ';
                html += '<div class="form-group row"><div class="col col-xs-12"><label class="control-label">Price :</label><input type="number" name="variant_price[]" class="col form-control price varaint-must-fill-field" value="' + b.price + '" min="0" step="0.01"></div><div class="col col-xs-12"><label class="control-label">Special Price :</label><input type="number" name="variant_special_price[]" class="col form-control discounted_price" min="0" value="' + b.special_price + '" step="0.01"></div><div class="col col-xs-12"> <label class="control-label">Sku :</label> <input type="text" name="variant_sku[]" class="col form-control varaint-must-fill-field"  value="' + b.sku + '" ></div><div class="col col-xs-12"> <label class="control-label">Total Stock :</label> <input type="text" name="variant_total_stock[]" class="col form-control varaint-must-fill-field" value="' + b.stock + '"></div><div class="col col-xs-12"> <label class="control-label">Stock Status :</label> <select type="text" name="variant_level_stock_status[]" class="col form-control varaint-must-fill-field"><option value="1">In Stock</option><option value="0"  ' + selected + '  >Out Of Stock</option> </select></div></div>';
            } else {
                html += '<div class="form-group row"><div class="col col-xs-12"><label class="control-label">Price :</label><input type="number" name="variant_price[]" class="col form-control price varaint-must-fill-field" value="' + b.price + '" min="0" step="0.01"></div><div class="col col-xs-12"><label class="control-label">Special Price :</label><input type="number" name="variant_special_price[]" class="col form-control discounted_price"  min="0" value="' + b.special_price + '" step="0.01"></div></div>';
            }
            html += '<div class="col-12 pt-3"><label class="control-label">Images :</label><div class="col-md-3"><a class="uploadFile img btn btn-primary text-white btn-sm"  data-input="variant_images[' + a + '][]" data-isremovable="1" data-is-multiple-uploads-allowed="1" data-toggle="modal" data-target="#media-upload-modal" value="Upload Photo"><i class="fa fa-upload"></i> Upload</a> </div><div class="container-fluid row image-upload-section"> ' + image_html + ' </div></div>';
            html += '</div></div></div>';

            $('#variants_process').html(html);
        });

        if (!$.isEmptyObject(attributes_values) && add_newly_created_variants == true) {
            create_variants(permuted_value_result, from);
        }

    }
}

function status_date_wise_search() {
    $('.table-striped').bootstrapTable('refresh');
}

function resetfilters() {
    $('#datepicker').val('');
    $('#media-type').val('');
    $('#start_date').val('');
    $('#end_date').val('');
    status_date_wise_search();
}

function formatRepo(repo) {

    if (repo.loading) return repo.text;
    var markup = "<div class='select2-result-repository clearfix'>" +
        "<div class='select2-result-repository__meta'>" +
        "<div class='select2-result-repository__title'>" + repo.name + "</div>";

    if (repo.description) {
        markup += "<div class='select2-result-repository__description'> In " + repo.category_name + "</div>";
    }

    return markup;
}
function formatRepo1(repo) {

    if (repo.loading) return repo.text;
    var markup = "<div class='select2-result-repository clearfix'>" +
        "<div class='select2-result-repository__meta'>" +
        "<div class='select2-result-repository__title'>" + repo.title + "</div>";

    return markup;
}

function formatRepoSelection(repo) {
    return repo.name || repo.text;
}
function formatRepoSelection1(repo) {
    return repo.title || repo.text;
}

function mediaParams(p) {
    return {
        'type': $('#media_type').val(),
        limit: p.limit,
        sort: p.sort,
        order: p.order,
        offset: p.offset,
        search: p.search
    };
}

function mediaUploadParams(p) {
    return {
        'type': $('#media-type').val(),
        "start_date": $('#start_date').val(),
        "end_date": $('#end_date').val(),
        limit: p.limit,
        sort: p.sort,
        order: p.order,
        offset: p.offset,
        search: p.search
    };
}

function home_query_params(p) {
    return {
        "start_date": $('#start_date').val(),
        "end_date": $('#end_date').val(),
        "order_status": $('#order_status').val(),
        limit: p.limit,
        sort: p.sort,
        order: p.order,
        offset: p.offset,
        search: p.search
    };
}

function queryParams(p) {
    return {
        limit: p.limit,
        sort: p.sort,
        order: p.order,
        offset: p.offset,
        search: p.search
    };
}
function ticket_queryParams(p) {
    return {
        limit: p.limit,
        sort: p.sort,
        order: p.order,
        offset: p.offset,
        search: p.search
    };
}

function customer_wallet_query_params(p) {
    return {
        transaction_type: 'wallet',
        user_type: 'members',
        limit: p.limit,
        sort: p.sort,
        order: p.order,
        offset: p.offset,
        search: p.search
    };
}
function partner_wallet_query_params(p) {
    return {
        transaction_type: 'wallet',
        user_type: 'partner',
        user_id: $('#restro_filter').val(),
        limit: p.limit,
        sort: p.sort,
        order: p.order,
        offset: p.offset,
        search: p.search
    };
}
function partner_query_params(p) {
    return {
        status_filter: $('#status_filter').val(),
        limit: p.limit,
        sort: p.sort,
        order: p.order,
        offset: p.offset,
        search: p.search
    };
}
function order_tracking_query_params(p) {
    return {
        "order_id": $('input[name="order_id"]').val(),
        limit: p.limit,
        sort: p.sort,
        order: p.order,
        offset: p.offset,
        search: p.search
    };
}

function category_query_params(p) {
    return {
        "category_id": $('#category_id').val(),
        limit: p.limit,
        sort: p.sort,
        order: p.order,
        offset: p.offset,
        search: p.search
    };
}

function product_query_params(p) {
    return {
        "category_id": $('#category_parent').val(),
        "partner_id": $('#restro_filter').val(),
        "status": $('#status_filter').val(),
        limit: p.limit,
        sort: p.sort,
        order: p.order,
        offset: p.offset,
        search: p.search
    };
}
function payment_request_queryParams(p) {
    return {
        "user_filter": $('#user_filter').val(),
        limit: p.limit,
        sort: p.sort,
        order: p.order,
        offset: p.offset,
        search: p.search
    };
}

function ratingParams(p) {
    return {
        "category_id": $('#category_parent').val(),
        limit: p.limit,
        sort: p.sort,
        order: p.order,
        offset: p.offset,
        search: p.search
    };
}

function sales_invoice_query_params(p) {
    return {
        "start_date": $('#start_date').val(),
        "end_date": $('#end_date').val(),
        "order_status": $('#order_status').val(),
        limit: p.limit,
        sort: p.sort,
        order: p.order,
        offset: p.offset,
        search: p.search
    };
}

function address_query_params(p) {
    return {
        user_id: $('#address_user_id').val(),
        limit: p.limit,
        sort: p.sort,
        order: p.order,
        offset: p.offset,
        search: p.search
    };
}

function orders_query_params(p) {
    return {
        "start_date": $('#start_date').val(),
        "end_date": $('#end_date').val(),
        "order_status": $('#order_status').val(),
        "user_id": $('#order_user_id').val(),
        "partner_id": $('#order_partner_id').val(),
        limit: p.limit,
        sort: p.sort,
        order: p.order,
        offset: p.offset,
        search: p.search
    };
}

function transaction_query_params(p) {
    return {
        transaction_type: 'transaction',
        user_id: $('#transaction_user_id').val(),
        limit: p.limit,
        sort: p.sort,
        order: p.order,
        offset: p.offset,
        search: p.search
    };
}

$(document).on('change', '.type_event_trigger', function (e, data) {
    e.preventDefault();
    var type_val = $(this).val();
    if (type_val != 'default' && type_val != ' ') {
        if (type_val == 'categories') {
            $('.slider-categories').removeClass('d-none');
            $('.notification-categories').removeClass('d-none');
            $('.slider-products').addClass('d-none');
            $('.notification-products').addClass('d-none');
        } else {
            $('.slider-products').removeClass('d-none');
            $('.notification-products').removeClass('d-none');
            $('.slider-categories').addClass('d-none');
            $('.notification-categories').addClass('d-none');
        }
    } else {
        $('.slider-categories').addClass('d-none');
        $('.slider-products').addClass('d-none');
        $('.notification-categories').addClass('d-none');
        $('.notification-products').addClass('d-none');
    }
});
if ($("input[data-bootstrap-switch]").length) {

    $("input[data-bootstrap-switch]").each(function () {
        $('input[data-bootstrap-switch]').bootstrapSwitch();
    });
}

$(document).on('click', '.edit_btn', function () {
    var id = $(this).data('id');
    var url = $(this).data('url');;
    $('.edit-modal-lg').modal('show').find('.modal-body').load(base_url + url + '?edit_id=' + id + ' .form-submit-event', function () {
        if ($("input[data-bootstrap-switch]").length) {

            $("input[data-bootstrap-switch]").each(function () {
                $('input[data-bootstrap-switch]').bootstrapSwitch();
            });
        }
        if ($('#commission_method').length) {
            $("#commission_method").trigger('change');
        }
        if ($('#attribute_value').length) {
            var attr_val_element = document.querySelector('input[name=attribute_value]');
            new Tagify(attr_val_element);
        }
        $('#category_parent').select2({
            theme: 'bootstrap4',
            width: $(this).data('width') ? $(this).data('width') : $(this).hasClass('w-100') ? '100%' : 'style',
            placeholder: $(this).data('placeholder'),
            allowClear: Boolean($(this).data('allow-clear')),
            templateResult: function (data) {
                if (!data.element) {
                    return data.text;
                }

                var $element = $(data.element);

                var $wrapper = $('<span></span>');
                $wrapper.addClass($element[0].className);

                $wrapper.text(data.text);

                return $wrapper;
            }
        });

        $('.select_multiple').each(function () {
            $(this).select2({
                theme: 'bootstrap4',
                width: $(this).data('width') ? $(this).data('width') : $(this).hasClass('w-100') ? '100%' : 'style',
                placeholder: $(this).data('placeholder'),
                allowClear: Boolean($(this).data('allow-clear')),
            });
        });

        $('.search_product').each(function () {
            $(this).select2({
                ajax: {
                    url: base_url + 'admin/product/get_product_data',
                    dataType: 'json',
                    delay: 250,
                    data: function (data) {
                        return {
                            search: data.term, // search term
                            limit: 10
                        };
                    },
                    processResults: function (response) {
                        return {
                            results: response.rows
                        };
                    },
                    cache: true
                },
                escapeMarkup: function (markup) { return markup; },
                minimumInputLength: 1,
                templateResult: formatRepo,
                templateSelection: formatRepoSelection,
                placeholder: 'Search for products',
                theme: 'bootstrap4',
                width: $(this).data('width') ? $(this).data('width') : $(this).hasClass('w-100') ? '100%' : 'style',
                placeholder: $(this).data('placeholder'),
                allowClear: Boolean($(this).data('allow-clear')),
            });
        });
        searchable_tags();
        searchable_zipcodes();
        search_category();
        setTimeout(function () {
            $('.edit-modal-lg').unblock();
        }, 2000);

    });
});

function searchable_tags() {
    var search_tags = $(".search_tags").select2({
        ajax: {
            url: base_url + from + '/tag/get_tags',
            dataType: 'json',
            delay: 250,
            data: function (params) {
                return {
                    search: params.term, // search term
                    page: params.page
                };
            },
            processResults: function (response, params) {
                // parse the results into the format expected by Select2
                // since we are using custom formatting functions we do not need to
                // alter the remote JSON data, except to indicate that infinite
                // scrolling can be used
                params.page = params.page || 1;

                return {
                    results: response.data,
                    pagination: {
                        more: (params.page * 30) < response.total
                    }
                };
            },
            cache: true
        },
        escapeMarkup: function (markup) {
            return markup;
        },
        minimumInputLength: 1,
        templateResult: formatRepo1,
        templateSelection: formatRepoSelection1,
        theme: 'bootstrap4',
        placeholder: 'Search for Tags',
        allowClear: Boolean($(this).data('allow-clear')),
    });
    return search_tags;
}
function search_category() {
    var search_category = $(".search_category").select2({
        ajax: {
            url: base_url + from + '/category/get_categories',
            dataType: 'json',
            delay: 250,
            data: function (params) {
                return {
                    search: params.term, // search term
                    page: params.page
                };
            },
            processResults: function (response, params) {
                // parse the results into the format expected by Select2
                // since we are using custom formatting functions we do not need to
                // alter the remote JSON data, except to indicate that infinite
                // scrolling can be used
                params.page = params.page || 1;

                return {
                    results: response.data,
                    pagination: {
                        more: (params.page * 30) < response.total
                    }
                };
            },
            cache: true
        },
        escapeMarkup: function (markup) {
            return markup;
        },
        minimumInputLength: 1,
        templateResult: formatRepo,
        templateSelection: formatRepoSelection,
        theme: 'bootstrap4',
        placeholder: 'Search for Category',
        allowClear: Boolean($(this).data('allow-clear')),
    });
    return search_category;
}

function searchable_zipcodes() {
    var search_zipcodes = $(".search_city").select2({
        ajax: {
            url: base_url + from + '/area/get_cities',
            dataType: 'json',
            delay: 250,
            data: function (params) {
                return {
                    search: params.term, // search term
                    page: params.page
                };
            },
            processResults: function (response, params) {
                // parse the results into the format expected by Select2
                // since we are using custom formatting functions we do not need to
                // alter the remote JSON data, except to indicate that infinite
                // scrolling can be used
                params.page = params.page || 1;

                return {
                    results: response.data,
                    pagination: {
                        more: (params.page * 30) < response.total
                    }
                };
            },
            cache: true
        },
        escapeMarkup: function (markup) {
            return markup;
        },
        minimumInputLength: 1,
        templateResult: formatRepo,
        templateSelection: formatRepoSelection,
        theme: 'bootstrap4',
        placeholder: 'Search for city',
        allowClear: Boolean($(this).data('allow-clear')),
    });
    return search_zipcodes;
}

$(document).on('click', '.view_address', function () {
    var id = $(this).data('id');
    var url = $(this).data('url');;

});

$(document).on('click', '.view_btn', function () {
    var id = $(this).data('id');
    var url = $(this).data('url');
    $('.modal-body').load(base_url + url + '?edit_id=' + id + ' .form-submit-event');
    $('.modal-title').html('Manage Promo code');
    $('.modal-body').addClass('view');
    $(".edit-modal-lg").modal();
});

$(document).on('hidden.bs.modal', '.edit-modal-lg', function () {
    $('.edit-modal-lg .modal-body').removeClass('view');
    $('.edit-modal-lg .modal-body').html('');
})

//form-submit-event
$(document).on('submit', '.container-fluid .form-submit-event', function (e) {
    e.preventDefault();
    var formData = new FormData(this);
    var update_id = $('#update_id').val();
    if (update_id == '1') {
        var error_box = $('.edit-modal-lg #error_box');
        var submit_btn = $('.edit-modal-lg #submit_btn');
        var btn_html = $('.edit-modal-lg #submit_btn').html();
        var btn_val = $('.edit-modal-lg #submit_btn').val();
        var button_text = (btn_html != '' || btn_html != 'undefined') ? btn_html : btn_val;

    } else {
        var error_box = $('#error_box', this);
        var submit_btn = $('#submit_btn');
        var btn_html = $('#submit_btn').html();
        var btn_val = $('#submit_btn').val();
        var button_text = (btn_html != '' || btn_html != 'undefined') ? btn_html : btn_val;
    }

    formData.append(csrfName, csrfHash);

    $.ajax({
        type: 'POST',
        url: $(this).attr('action'),
        data: formData,
        beforeSend: function () {
            submit_btn.html('Please Wait..');
            submit_btn.attr('disabled', true);
        },
        cache: false,
        contentType: false,
        processData: false,
        dataType: 'json',
        success: function (result) {
            csrfName = result['csrfName'];
            csrfHash = result['csrfHash'];

            if (result['error'] == true) {

                error_box.addClass("msg_error rounded p-3").removeClass('d-none msg_success');
                error_box.show().delay(1000).fadeOut();
                error_box.html(result['message']);
                submit_btn.html(button_text);
                submit_btn.attr('disabled', false);
                iziToast.error({
                    message: result['message'],
                });

            } else {

                error_box.addClass("msg_success rounded p-3").removeClass('d-none msg_error');
                error_box.show().delay(1000).fadeOut();
                error_box.html(result['message']);
                submit_btn.html(button_text);
                submit_btn.attr('disabled', false);
                setTimeout(function () { $('.modal').modal('hide'); }, 1000);
                $('.table-striped').bootstrapTable('refresh');
                iziToast.success({
                    message: result['message'],
                });
                $('.form-submit-event')[0].reset();
                if (window.location.href.indexOf("login") > -1) {
                    setTimeout(function () { location.reload(); }, 600);
                }
                if (window.location.href.indexOf("admin/attribute/") > -1) {
                    setTimeout(function () { location.reload(); }, 600);
                }
            }
        }
    });
});

// 1.login

//forgot_page
$(document).ready(function () {
    $('#forgot_password_page').on('submit', function (e) {
        e.preventDefault();
        var formData = new FormData(this);
        formData.append(csrfName, csrfHash);
        $.ajax({
            type: 'POST',
            url: $(this).attr('action'),
            data: formData,
            beforeSend: function () {
                $('#submit_btn').html('Please Wait..');
                $('#submit_btn').attr('disabled', true);
            },
            cache: false,
            contentType: false,
            processData: false,
            dataType: "json",
            success: function (result) {
                csrfName = result['csrfName'];
                csrfHash = result['csrfHash'];
                $('#result').html(result['message']);
                $('#result').show().delay(6000).fadeOut();
                $('#submit_btn').html('Send Email');
                $('#submit_btn').attr('disabled', false);
            }
        });
    });
});

//2.Product-Module
var edit_product_id = $('input[name=edit_product_id]').val();

if (edit_product_id) {

    create_fetched_attributes_html(from).done(function () {
        $('.no-attributes-added').hide();
        $('#save_attributes').removeClass('d-none');
        $('.no-variants-added').hide();
        save_attributes();
        create_fetched_variants_html(false, from);
    });
}

$(document).on('switchChange.bootstrapSwitch', '#is_cancelable', function (event) {
    event.preventDefault();
    var state = $(this).bootstrapSwitch('state');
    if (state) {
        $('#cancelable_till').show();
    } else {
        $('#cancelable_till').hide();
    }

});

$(document).on('change', '#category_parent', function () {
    $('#products_table').bootstrapTable('refresh');
});
$(document).on('change', '#restro_filter', function () {
    $('#products_table').bootstrapTable('refresh');
    $('#restro_wallet_table').bootstrapTable('refresh');
});
$(document).on('change', '#user_filter', function () {
    $('#payment_request_table').bootstrapTable('refresh');
});
$(document).on('change', '#status_filter', function () {
    $('#products_table').bootstrapTable('refresh');
    $('#seller_table').bootstrapTable('refresh');
});

//Summer-note
$(document).ready(function () {

    $('.textarea').summernote({
        toolbar: [
            // [groupName, [list of button]]
            ['style', ['bold', 'italic', 'underline', 'clear', 'style']],
            ['font', ['strikethrough', 'superscript', 'subscript']],
            ['fontsize', ['fontsize']],
            ['color', ['color']],
            ['para', ['ul', 'ol', 'paragraph']],
            ['height', ['height']],
            ['fontname', ['fontname']],
            ['table', ['table']],
            ['insert', ['link', 'video']],
            ['view', ['fullscreen', 'codeview', 'help']],
        ],
        height: 250, //set editable area's height
        codemirror: { // codemirror options
            theme: 'monokai'
        }
    });

});

$(document).on('click', '#variation_product_btn', function (e) {
    e.preventDefault();
    var radio = $("input[name='pro_input_type']:checked").val();
    var edit_product_id = $('input[name=edit_product_id]').val();
    var html = '';
    html = add_product_variant_html(radio);
    $('#product_variance_html').append(html);
    if (typeof edit_product_id != 'undefined') {
        $("#product_variance_html").children('div').last().append("<input type='hidden' name='edit_product_variant[]'>");
    }
});
$(document).on('click', '#remove_product_btn', function (e) {
    e.preventDefault();
    $(this).closest('.row').remove();
});
$(document).on('click', '.delete-img', function () {
    var isJson = false;
    var id = $(this).data('id');
    var path = $(this).data('path');
    var field = $(this).data('field');
    var img_name = $(this).data('img');
    var table_name = $(this).data('table');
    var t = this;
    var isjson = $(this).data('isjson');
    Swal.fire({
        title: 'Are You Sure!',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    type: 'POST',
                    url: base_url + 'admin/home/delete_image',
                    data: {
                        id: id,
                        path: path,
                        field: field,
                        img_name: img_name,
                        table_name: table_name,
                        isjson: isjson,
                        [csrfName]: csrfHash
                    },
                    dataType: 'json',
                    success: function (result) {
                        csrfName = result['csrfName'];
                        csrfHash = result['csrfHash'];
                        if (result['is_deleted'] == true) {
                            $(t).closest('div').remove();
                            Swal.fire('Success', 'Media Deleted !', 'success');
                        } else {
                            Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                        }
                    }
                });
            });
        },
        allowOutsideClick: false
    }).then((result) => {
        if (result.dismiss === Swal.DismissReason.cancel) {
            Swal.fire('Cancelled!', 'Your data is  safe.', 'error');
        }
    });
});

$(document).on('click', '.delete-media', function () {

    var id = $(this).data('id');
    Swal.fire({
        title: 'Are You Sure!',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    type: 'GET',
                    url: base_url + from + '/media/delete/' + id,
                    dataType: 'json',
                    success: function (result) {
                        csrfName = result['csrfName'];
                        csrfHash = result['csrfHash'];
                        if (result['error'] == false) {
                            $('table').bootstrapTable('refresh');
                            Swal.fire('Success', 'File Deleted !', 'success');
                        } else {
                            Swal.fire('Oops...', result['message'], 'error');
                        }
                    }
                });
            });
        },
        allowOutsideClick: false
    }).then((result) => {
        if (result.dismiss === Swal.DismissReason.cancel) {
            Swal.fire('Cancelled!', 'Your data is  safe.', 'error');
        }
    });
});



$(document).on('focusout', '.discounted_price', function () {
    var discount_amt = parseInt($(this).val());
    var price = parseInt($(this).closest('.form-group').siblings().find('.price').val());
    if (typeof price != 'undefined' && price != "") {
        if (discount_amt > price) {
            iziToast.error({
                message: "Special price can" + "'" + "t exceed price",
            });
            $(this).val('');
        }
    }
});
$(document).on('focusout', '.price', function () {
    var price = parseInt($(this).val());
    var discount_amt = parseInt($(this).closest('.form-group').siblings().find('.discounted_price').val());
    if (typeof discount_amt != 'undefined' && discount_amt != "") {
        if (discount_amt > price) {
            iziToast.error({
                message: "Special price can" + "'" + "t exceed price",
            });
            $(this).val('');
        }
    }
});
$(document).on('click', '.clear-product-variance', function () {
    var edit_product_id = $('input[name=edit_product_id]').val();
    var radio_val = $("input[name='pro_input_type']:checked").val();
    var t = this;
    Swal.fire({
        title: 'Are You Sure!',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    url: base_url + 'admin/product/delete_product',
                    type: 'GET',
                    data: {
                        'id': edit_product_id
                    },
                    dataType: 'json'
                }).done(function (response, textStatus) {
                    Swal.fire('Deleted!', response.message);
                    if (radio_val == 'packet') {
                        html = add_product_variant_html(radio_val);
                        $('#product_variance_html').html(html);
                        $('#product_loose_html').hide();
                        $('.pro_loose').hide();
                        $('.remove_pro_btn').hide();
                        $(t).hide();
                    } else {
                        $('#product_variance_html').show();
                        html = add_product_variant_html(radio_val);
                        $('#product_loose_html').show();
                        $('#product_variance_html').html(html);
                        $('.remove_pro_btn').hide();
                    }
                }).fail(function (jqXHR, textStatus, errorThrown) {
                    Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                });
            });
        },
        allowOutsideClick: false
    }).then((result) => {
        if (result.dismiss === Swal.DismissReason.cancel) {
            Swal.fire('Cancelled!', 'Your data is  safe.', 'error');
        }
    });
});
$('#sortable').sortable({
    axis: 'y',
    opacity: 0.6,
    cursor: 'grab'
});

$(document).on('click', '#save_product_order', function () {
    var data = $('#sortable').sortable('serialize');
    $.ajax({
        data: data,
        type: 'GET',
        url: base_url + 'admin/product/update_product_order',
        dataType: 'json',
        success: function (response) {
            if (response.error == false) {
                iziToast.success({
                    message: response.message,
                });
            } else {
                iziToast.error({
                    message: response.message,
                });
            }
        }
    });
});

$(document).on('click', '#save_section_order', function () {
    var data = $('#sortable').sortable('serialize');
    $.ajax({
        data: data,
        type: 'GET',
        url: base_url + 'admin/featured_sections/update_section_order',
        dataType: 'json',
        success: function (response) {
            if (response.error == false) {
                iziToast.success({
                    message: response.message,
                });
            } else {
                iziToast.error({
                    message: response.message,
                });
            }
        }
    });
});


//form-submit-event
$(document).on('submit', '#save-product', function (e) {
    e.preventDefault();
    var product_type = $('#product-type').val();
    var counter = 0;
    if (product_type != 'undefined' && product_type != ' ') {

        if ($.trim(product_type) == 'simple_product') {
            if ($('.simple_stock_management_status').is(':checked')) {
                var len = 0
            } else {
                var len = 1
            }

            if ($('.stock-simple-mustfill-field').filter(function () { return this.value === ''; }).length === len) {

                $('input[name="product_type"]').val($('#product-type').val());
                if ($('.simple_stock_management_status').is(':checked')) {
                    $('input[name="simple_product_stock_status"]').val($('#simple_product_stock_status').val());
                } else {
                    $('input[name="simple_product_stock_status"]').val('');
                }
                $('#product-type').prop('disabled', true);
                $('.product-attributes').removeClass('disabled');
                $('.product-variants').removeClass('disabled');
                $('.simple_stock_management_status').prop('disabled', true);

                save_product(this);
            } else {
                iziToast.error({
                    message: 'Please Fill All The Fields',
                });
            }
        }

        if ($.trim(product_type) == 'variable_product') {
            if ($('.variant_stock_status').is(":checked")) {
                var variant_stock_level_type = $('.variant-stock-level-type').val();
                if (variant_stock_level_type == 'product_level') {
                    if ($('.variant-stock-level-type').filter(function () { return this.value === ''; }).length === 0 && $.trim($('.variant-stock-level-type').val()) != "") {

                        if ($('.variant-stock-level-type').val() == 'product_level' && $('.variant-stock-mustfill-field').filter(function () { return this.value === ''; }).length !== 0) {
                            iziToast.error({
                                message: 'Please Fill All The Fields',
                            });
                        } else {
                            var varinat_price = $('input[name="variant_price[]"]').val();

                            if ($('input[name="variant_price[]"]').length >= 1) {

                                if ($('.varaint-must-fill-field').filter(function () { return this.value === ''; }).length == 0) {

                                    $('input[name="product_type"]').val($('#product-type').val());
                                    $('input[name="variant_stock_level_type"]').val($('#stock_level_type').val());
                                    $('input[name="varaint_stock_status"]').val("0");
                                    $('#product-type').prop('disabled', true);
                                    $('#stock_level_type').prop('disabled', true);
                                    $(this).removeClass('save-variant-general-settings');
                                    $('.product-attributes').removeClass('disabled');
                                    $('.product-variants').removeClass('disabled');
                                    $('.variant-stock-level-type').prop('readonly', true);
                                    $('#stock_status_variant_type').attr('readonly', true);
                                    $('.variant-product-level-stock-management').find('input,select').prop('readonly', true);
                                    $('#tab-for-variations').removeClass('d-none');
                                    $('.variant_stock_status').prop('disabled', true);
                                    $('#product-tab a[href="#product-attributes"]').tab('show');
                                    save_product(this);

                                } else {
                                    $('.varaint-must-fill-field').each(function () {
                                        $(this).css('border', '');
                                        if ($(this).val() == '') {
                                            $(this).css('border', '2px solid red');
                                            $(this).closest('#variant_stock_management_html').find('div:first').addClass('show');
                                            $('#product-tab a[href="#product-variants"]').tab('show');
                                            counter++;
                                        }
                                    });
                                }


                            } else {

                                Swal.fire('Variation Needed !', 'Atleast Add One Variation To Add The Product.', 'warning');
                            }
                        }
                    } else {
                        iziToast.error({
                            message: 'Please Fill All The Fields',
                        });
                    }
                } else {
                    if ($('input[name="variant_price[]"]').length >= 1) {

                        if ($('.varaint-must-fill-field').filter(function () { return this.value === ''; }).length == 0) {
                            $('input[name="product_type"]').val($('#product-type').val());
                            $('.variant_stock_status').prop('disabled', true);
                            $('#product-type').prop('disabled', true);
                            $('.product-attributes').removeClass('disabled');
                            $('.product-variants').removeClass('disabled');
                            $('#tab-for-variations').removeClass('d-none');
                            save_product(this);
                        } else {
                            $('.varaint-must-fill-field').each(function () {
                                $(this).css('border', '');
                                if ($(this).val() == '') {
                                    $(this).css('border', '2px solid red');
                                    $(this).closest('#variant_stock_management_html').find('div:first').addClass('show');
                                    $('#product-tab a[href="#product-variants"]').tab('show');
                                    counter++;
                                }
                            });
                        }

                    } else {

                        Swal.fire('Variation Needed !', 'Atleast Add One Variation To Add The Product.', 'warning');

                    }
                }
            } else {

                if ($('input[name="variant_price[]"]').length == 0) {
                    Swal.fire('Variation Needed !', 'Atleast Add One Variation To Add The Product.', 'warning');
                } else {
                    if ($('.varaint-must-fill-field').filter(function () { return this.value === ''; }).length == 0) {
                        save_product(this);
                    } else {
                        $('.varaint-must-fill-field').each(function () {
                            $(this).css('border', '');
                            if ($(this).val() == '') {
                                $(this).css('border', '2px solid red');
                                $(this).closest('#variant_stock_management_html').find('div:first').addClass('show');
                                $('#product-tab a[href="#product-variants"]').tab('show');
                                counter++;
                            }
                        });
                    }
                }
            }
        }

    } else {
        iziToast.error({
            message: 'Please Select Product Type !',
        });
    }

    if (counter > 0) {
        iziToast.error({
            message: 'Please fill all the required fields in the variation tab !',
        });
    }

});



$(document).on('click', '#delete-product', function () {
    var id = $(this).data('id');
    Swal.fire({
        title: 'Are You Sure!',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    type: 'GET',
                    url: base_url + from + '/product/delete_product',
                    data: {
                        id: id
                    },
                    dataType: 'json'
                }).done(function (response, textStatus) {
                    if (response.error == false) {

                        Swal.fire('Deleted!', response.message, 'success');
                    } else {
                        Swal.fire('Oops...', response.message, 'error');
                    }
                    $('table').bootstrapTable('refresh');
                    csrfName = response['csrfName'];
                    csrfHash = response['csrfHash'];
                }).fail(function (jqXHR, textStatus, errorThrown) {
                    Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                    csrfName = response['csrfName'];
                    csrfHash = response['csrfHash'];
                });
            });
        },
        allowOutsideClick: false
    });
});
$(document).on('click', '#delete-add-ons', function () {
    var id = $(this).data('id');
    Swal.fire({
        title: 'Are You Sure!',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    type: 'GET',
                    url: base_url + from + '/product/delete_add_on',
                    data: {
                        id: id
                    },
                    dataType: 'json'
                }).done(function (response, textStatus) {
                    if (response.error == false) {
                        Swal.fire('Deleted!', response.message, 'success');
                    } else {
                        Swal.fire('Oops...', response.message, 'error');
                    }
                    $('table').bootstrapTable('refresh');
                    csrfName = response['csrfName'];
                    csrfHash = response['csrfHash'];
                }).fail(function (jqXHR, textStatus, errorThrown) {
                    Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                    csrfName = response['csrfName'];
                    csrfHash = response['csrfHash'];
                });
            });
        },
        allowOutsideClick: false
    });
});

// multiple_values
$('.select_single , .multiple_values , #product-type').each(function () {
    $(this).select2({
        theme: 'bootstrap4',
        width: $(this).data('width') ? $(this).data('width') : $(this).hasClass('w-100') ? '100%' : 'style',
        placeholder: $(this).data('placeholder'),
        allowClear: Boolean($(this).data('allow-clear')),
    });
});

$(document).on('select2:selecting', '.select_single', function (e) {

    if ($.inArray($(this).val(), attributes_values_selected) > -1) {
        //Remove value if further selected
        attributes_values_selected.splice(attributes_values_selected.indexOf($(this).select2().find(":selected").val()), 1);
    }

});

$(document).on('select2:selecting', '.select_single .variant_attributes', function (e) {

    if ($.inArray($(this).val(), variant_values_selected) > -1) {
        //Remove value if further selected
        variant_values_selected.splice(variant_values_selected.indexOf($(this).select2().find(":selected").val()), 1);

    }

});

$(document).on('select2:select', '.select_single', function (e) {
    var text = this.className;
    var type;
    $(this).closest('.row').find(".multiple_values").text(null).trigger('change');
    var data = $(this).select2().find(":selected").data("values");
    if (text.search('attributes') != -1) {
        value_check_array = attributes_values_selected.slice();
        type = 'attributes';
    }

    if (text.search('variant_attributes') != -1) {
        value_check_array = variant_values_selected.slice();
        type = 'variant_attributes';
    }

    if ($.inArray($(this).select2().find(":selected").val(), value_check_array) > -1) {
        iziToast.error({
            message: 'Attribute Already Selected',
        });
        $(this).val('').trigger('change');
    } else {
        value_check_array.push($(this).select2().find(":selected").val());
    }
    if (text.search('attributes') != -1) {
        attributes_values_selected = value_check_array.slice();
    }

    if (text.search('variant_attributes') != -1) {
        variant_values_selected = value_check_array.slice();
    }
    $(this).closest('.row').find("." + type).select2({
        theme: 'bootstrap4',
        width: $(this).data('width') ? $(this).data('width') : $(this).hasClass('w-100') ? '100%' : 'style',
        placeholder: $(this).data('placeholder'),
        allowClear: Boolean($(this).data('allow-clear')),
    });
    $(this).closest('.row').find(".multiple_values").select2({
        theme: 'bootstrap4',
        width: $(this).data('width') ? $(this).data('width') : $(this).hasClass('w-100') ? '100%' : 'style',
        placeholder: $(this).data('placeholder'),
        allowClear: Boolean($(this).data('allow-clear')),
        data: data,
    });


});

$(document).on('click', ' #add_attributes , #tab-for-variations', function (e) {

    if (e.target.id == 'add_attributes') {

        $('.no-attributes-added').hide();
        $('#save_attributes').removeClass('d-none');
        counter++;
        var $attribute = $('#attributes_values_json_data').find('.select_single');
        var $options = $($attribute).clone().html();
        var attr_name = 'pro_attr_' + counter;
        // product-attr-selectbox
        if ($('#product-type').val() == 'simple_product') {
            var html = '<div class="form-group move row my-auto p-2 border rounded bg-gray-light product-attr-selectbox" id=' + attr_name + '><div class="col-md-1 col-sm-12 text-center my-auto"><i class="fas fa-sort"></i></div><div class="col-md-4 col-sm-12"> <select name="attribute_id[]" class="attributes select_single" data-placeholder=" Type to search and select attributes"><option value=""></option>' + $options + '</select></div><div class="col-md-4 col-sm-12 "> <select name="attribute_value_ids[]" class="multiple_values" multiple="" data-placeholder=" Type to search and select attributes values"><option value=""></option> </select></div><div class="col-md-2 col-sm-6 text-center py-1 align-self-center"> <button type="button" class="btn btn-tool remove_attributes"> <i class="text-danger far fa-times-circle fa-2x "></i> </button></div></div>';
        } else {
            $('#note').removeClass('d-none');
            var html = '<div class="form-group row move my-auto p-2 border rounded bg-gray-light product-attr-selectbox" id=' + attr_name + '><div class="col-md-1 col-sm-12 text-center my-auto"><i class="fas fa-sort"></i></div><div class="col-md-4 col-sm-12"> <select name="attribute_id[]" class="attributes select_single" data-placeholder=" Type to search and select attributes"><option value=""></option>' + $options + '</select></div><div class="col-md-4 col-sm-12 "> <select name="attribute_value_ids[]" class="multiple_values" multiple="" data-placeholder=" Type to search and select attributes values"><option value=""></option> </select></div><div class="col-md-2 col-sm-6 text-center py-1 align-self-center"><input type="checkbox" name="variations[]" class="is_attribute_checked custom-checkbox "></div><div class="col-md-1 col-sm-6 text-center py-1 align-self-center "> <button type="button" class="btn btn-tool remove_attributes"> <i class="text-danger far fa-times-circle fa-2x "></i> </button></div></div>';
        }
        $('#attributes_process').append(html);

        $("#attributes_process").last().find(".attributes").select2({
            theme: 'bootstrap4',
            width: $(this).data('width') ? $(this).data('width') : $(this).hasClass('w-100') ? '100%' : 'style',
            placeholder: $(this).data('placeholder'),
            allowClear: Boolean($(this).data('allow-clear')),
        });

        // $("#attributes_process").last().find(".attributes").trigger('change');    

        $("#attributes_process").last().find(".multiple_values").select2({
            theme: 'bootstrap4',
            width: $(this).data('width') ? $(this).data('width') : $(this).hasClass('w-100') ? '100%' : 'style',
            placeholder: $(this).data('placeholder'),
            allowClear: Boolean($(this).data('allow-clear')),
        });
    }

    if (e.target.id == 'tab-for-variations') {
        $('.additional-info').block({
            message: '<h6>Loading Variations</h6>',
            css: { border: '3px solid #E7F3FE' }
        });
        if (attributes_values.length > 0) {

            $('.no-variants-added').hide();
            create_variants(false, from);

        }
        setTimeout(function () {
            $('.additional-info').unblock();
        }, 3000);
    }

});

$(document).on('click', '#reset_variants', function () {

    Swal.fire({
        title: 'Are You Sure To Reset!',
        text: "You won't be able to revert this after update!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, Reset it!',
        showLoaderOnConfirm: true,
        allowOutsideClick: false
    }).then((result) => {
        if (result.value) {
            $('.additional-info').block({
                message: '<h6>Reseting Variations</h6>',
                css: { border: '3px solid #E7F3FE' }
            });
            if (attributes_values.length > 0) {
                $('.no-variants-added').hide();
                create_variants(false, from);
            }
            setTimeout(function () {
                $('.additional-info').unblock();
            }, 2000);
        }
    });
});

$(document).on('click', '.remove_edit_attribute', function (e) {

    $(this).closest('.row').remove();
});

$(document).on('click', '.remove_attributes , .remove_variants', function (e) {
    Swal.fire({
        title: 'Are you sure want to delete!',
        text: "You won't be able to revert this after update!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, Delete it!',
        showLoaderOnConfirm: true,
        allowOutsideClick: false
    }).then((result) => {
        if (result.value) {
            var text = this.className;
            if (text.search('remove_attributes') != -1) {
                var edit_id = $('#edit_product_id').val();

                attributes_values_selected.splice(attributes_values_selected.indexOf($(this).select2().find(":selected").val()), 1);
                $(this).closest('.row').remove();
                counter -= 1;
                var numItems = $('.product-attr-selectbox').length;
                if (numItems == 0) {
                    $('.no-attributes-added').show();
                    $('#save_attributes').addClass('d-none');
                    $('#note').addClass('d-none');

                }

            }
            if (text.search('remove_variants') != -1) {
                variant_values_selected.splice(variant_values_selected.indexOf($(this).select2().find(":selected").val()), 1);
                $(this).closest('.form-group').remove();
                variant_counter -= 1;
                var numItems = $('.product-variant-selectbox').length;
                if (numItems == 0) {
                    $('.no-variants-added').show();
                }
            }
        }
    });
});

$(document).on('select2:select', '#product-type', function () {
    var value = $(this).val();
    if ($.trim(value) != "") {
        if (value == 'simple_product') {
            $('#variant_stock_level').hide(200);
            $('#general_price_section').show(200);
            $('.simple-product-save').show(700);
            $('.product-attributes').addClass('disabled');
            $('.product-variants').addClass('disabled');

        }
        if (value == 'variable_product') {
            $('#general_price_section').hide(200);
            $('.simple-product-level-stock-management').hide(200);
            $('.simple-product-save').hide(200);
            $('.product-attributes').addClass('disabled');
            $('.product-variants').addClass('disabled');
            $('#variant_stock_level').show();
        }

    } else {
        $('.product-attributes').addClass('disabled');
        $('.product-variants').addClass('disabled');
        $('#general_price_section').hide(200);
        $('.simple-product-level-stock-management').hide(200);
        $('.simple-product-save').hide(200)
        $('#variant_stock_level').hide(200);
    }
});

$(document).on('change', '.variant_stock_status', function () {
    if ($(this).prop("checked") == true) {
        $(this).attr("checked", true);
        $('#stock_level').show(200);
    } else {
        $(this).attr("checked", false);
        $('#stock_level').hide(200);
    }
});

$(document).on('change', '.variant-stock-level-type', function () {
    if ($('.variant-stock-level-type').val() == 'product_level') {
        $('.variant-product-level-stock-management').show();
    }
    if ($.trim($('.variant-stock-level-type').val()) != 'product_level') {
        $('.variant-product-level-stock-management').hide();
    }
});

$(document).on('change', '.simple_stock_management_status', function () {
    if ($(this).prop("checked") == true) {
        $(this).attr("checked", true);
        $('.simple-product-level-stock-management').show(200);
    } else {
        $(this).attr("checked", false);
        $('.simple-product-level-stock-management').hide(200);
        $('.simple-product-level-stock-management').find('input').val('');
    }
});

$(document).on('click', '#save_attributes', function () {
    Swal.fire({
        title: 'Are you sure want to save changes!',
        text: "Do not save attributes if you made no changes! It will reset the variants if there are no changes in attributes or its values !",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, save it!',
        showLoaderOnConfirm: true,
        allowOutsideClick: false
    }).then((result) => {
        if (result.value) {
            attribute_flag = 1;
            save_attributes();
            create_fetched_variants_html(true, from);
            iziToast.success({
                message: 'Attributes Saved Succesfully',
            });
        }
    });
});

$('#attributes_process').sortable({
    axis: 'y',
    opacity: 0.6,
    cursor: 'grab'
});

$('#variants_process').sortable({
    axis: 'y',
    opacity: 0.6,
    cursor: 'grab'
});

$(document).on('click', '.reset-settings', function (e) {

    Swal.fire({
        title: 'Are You Sure To Reset!',
        text: "This will reset all attributes && variants too if added.",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, Reset it!',
        showLoaderOnConfirm: true,
        allowOutsideClick: false
    }).then((result) => {
        if (result.value) {
            attributes_values_selected = [];
            value_check_array = [];
            pre_selected_attr_values = [];
            var html = ' <input type="hidden" name="reset_settings" value="1"><div class="row mt-4 col-md-12 "> <nav class="w-100"><div class="nav nav-tabs" id="product-tab" role="tablist"> <a class="nav-item nav-link active" id="tab-for-general-price" data-toggle="tab" href="#general-settings" role="tab" aria-controls="general-price" aria-selected="true">General</a> <a class="nav-item nav-link disabled product-attributes" id="tab-for-attributes" data-toggle="tab" href="#product-attributes" role="tab" aria-controls="product-attributes" aria-selected="false">Attributes</a> <a class="nav-item nav-link disabled product-variants d-none" id="tab-for-variations" data-toggle="tab" href="#product-variants" role="tab" aria-controls="product-variants" aria-selected="false">Variations</a></div> </nav><div class="tab-content p-3 col-md-12" id="nav-tabContent"><div class="tab-pane fade active show" id="general-settings" role="tabpanel" aria-labelledby="general-settings-tab"><div class="form-group"> <label for="type" class="col-md-2">Type Of Product :</label><div class="col-md-12"> <input type="hidden" name="product_type"> <input type="hidden" name="simple_product_stock_status"> <input type="hidden" name="variant_stock_level_type"> <input type="hidden" name="variant_stock_status"> <select name="type" id="product-type" class="form-control product-type" data-placeholder=" Type to search and select type"><option value=" ">Select Type</option><option value="simple_product">Simple Product</option><option value="variable_product">Variable Product</option> </select></div></div><div id="product-general-settings"><div id="general_price_section" class="collapse"><div class="form-group"> <label for="type" class="col-md-2">Price:</label><div class="col-md-12"> <input type="number" name="simple_price" class="form-control stock-simple-mustfill-field price" min="0"></div></div><div class="form-group"> <label for="type" class="col-md-2">Special Price:</label><div class="col-md-12"> <input type="number" name="simple_special_price" class="form-control discounted_price" min="0"></div></div><div class="form-group"><div class="col"> <input type="checkbox" name="simple_stock_management_status" class="align-middle simple_stock_management_status"> <span class="align-middle">Enable Stock Management</span></div></div></div><div class="form-group simple-product-level-stock-management collapse"><div class="col col-xs-12"> <label class="control-label">SKU :</label> <input type="text" name="product_sku" class="col form-control simple-pro-sku"></div><div class="col col-xs-12"> <label class="control-label">Total Stock :</label> <input type="text" name="product_total_stock" class="col form-control stock-simple-mustfill-field"></div><div class="col col-xs-12"> <label class="control-label">Stock Status :</label> <select type="text" class="col form-control stock-simple-mustfill-field" id="simple_product_stock_status"><option value="1">In Stock</option><option value="0">Out Of Stock</option> </select></div></div><div class="form-group collapse simple-product-save"><div class="col"> <a href="javascript:void(0);" class="btn btn-primary save-settings">Save Settings</a></div></div></div><div id="variant_stock_level" class="collapse"><div class="form-group"><div class="col"> <input type="checkbox" name="variant_stock_management_status" class="align-middle variant_stock_status"> <span class="align-middle"> Enable Stock Management</span></div></div><div class="form-group collapse" id="stock_level"> <label for="type" class="col-md-2">Choose Stock Management Type:</label><div class="col-md-12"> <select id="stock_level_type" class="form-control variant-stock-level-type" data-placeholder=" Type to search and select type"><option value=" ">Select Stock Type</option><option value="product_level">Product Level ( Stock Will Be Managed Generally )</option><option value="variable_level">Variable Level ( Stock Will Be Managed Variant Wise )</option> </select><div class="form-group row variant-product-level-stock-management collapse"><div class="col col-xs-12"> <label class="control-label">SKU :</label> <input type="text" name="sku_variant_type" class="col form-control"></div><div class="col col-xs-12"> <label class="control-label">Total Stock :</label> <input type="text" name="total_stock_variant_type" class="col form-control variant-stock-mustfill-field"></div><div class="col col-xs-12"> <label class="control-label">Stock Status :</label> <select type="text" id="stock_status_variant_type" name="variant_status" class="col form-control variant-stock-mustfill-field"><option value="1">In Stock</option><option value="0">Out Of Stock</option> </select></div></div></div></div><div class="form-group"><div class="col"> <a href="javascript:void(0);" class="btn btn-primary save-variant-general-settings">Save Settings</a></div></div></div></div><div class="tab-pane fade" id="product-attributes" role="tabpanel" aria-labelledby="product-attributes-tab"><div class="info col-12 p-3 d-none" id="note"><div class=" col-12 d-flex align-center"> <strong>Note : </strong> <input type="checkbox" checked="checked" class="ml-3 my-auto custom-checkbox" disabled> <span class="ml-3">check if the attribute is to be used for variation </span></div></div><div class="col-md-12"> <a href="javascript:void(0);" id="add_attributes" class="btn btn-block btn-outline-primary col-md-2 float-right m-2 btn-sm">Add Attributes</a> <a href="javascript:void(0);" id="save_attributes" class="btn btn-block btn-outline-primary col-md-2 float-right m-2 btn-sm d-none">Save Attributes</a></div><div class="clearfix"></div><div id="attributes_process"><div class="form-group text-center row my-auto p-2 border rounded bg-gray-light col-md-12 no-attributes-added"><div class="col-md-12 text-center">No Product Attribures Are Added !</div></div></div></div><div class="tab-pane fade" id="product-variants" role="tabpanel" aria-labelledby="product-variants-tab"><div class="clearfix"></div><div class="form-group text-center row my-auto p-2 border rounded bg-gray-light col-md-12 no-variants-added"><div class="col-md-12 text-center">No Product Variations Are Added !</div></div><div id="variants_process" class="ui-sortable"></div></div></div></div>';
            $('.additional-info').html(html);
            $('.no-attributes-added').show();
            $('#product-type').each(function () {
                $(this).select2({
                    theme: 'bootstrap4',
                    width: $(this).data('width') ? $(this).data('width') : $(this).hasClass('w-100') ? '100%' : 'style',
                    placeholder: $(this).data('placeholder'),
                    allowClear: Boolean($(this).data('allow-clear')),
                });
            });
        }
    });


});
$(document).on('click', '.save-settings', function (e) {
    e.preventDefault();

    if ($('.simple_stock_management_status').is(':checked')) {
        var len = 0
    } else {
        var len = 1
    }

    if ($('.stock-simple-mustfill-field').filter(function () { return this.value === ''; }).length === len) {
        $('.additional-info').block({
            message: '<h6>Saving Settings</h6>',
            css: { border: '3px solid #E7F3FE' }
        });

        $('input[name="product_type"]').val($('#product-type').val());
        if ($('.simple_stock_management_status').is(':checked')) {
            $('input[name="simple_product_stock_status"]').val($('#simple_product_stock_status').val());
        } else {
            $('input[name="simple_product_stock_status"]').val('');
        }
        $('#product-type').prop('disabled', true);
        $('.product-attributes').removeClass('disabled');
        $('.product-variants').removeClass('disabled');
        $('.simple_stock_management_status').prop('disabled', true);
        setTimeout(function () {
            $('.additional-info').unblock();
        }, 2000);

    } else {
        iziToast.error({
            message: 'Please Fill All The Fields',
        });
    }
});

$(document).on('click', '.save-variant-general-settings', function (e) {
    e.preventDefault();
    if ($('.variant_stock_status').is(":checked")) {
        if ($('.variant-stock-level-type').filter(function () { return this.value === ''; }).length === 0 && $.trim($('.variant-stock-level-type').val()) != "") {

            if ($('.variant-stock-level-type').val() == 'product_level' && $('.variant-stock-mustfill-field').filter(function () { return this.value === ''; }).length !== 0) {
                iziToast.error({
                    message: 'Please Fill All The Fields',
                });
            } else {
                $('input[name="product_type"]').val($('#product-type').val());
                $('input[name="variant_stock_level_type"]').val($('#stock_level_type').val());
                $('input[name="variant_stock_status"]').val("0");
                $('#product-type').prop('disabled', true);
                $('#stock_level_type').prop('disabled', true);
                $(this).removeClass('save-variant-general-settings');
                $('.product-attributes').removeClass('disabled');
                $('.product-variants').removeClass('disabled');
                $('.variant-stock-level-type').prop('readonly', true);
                $('#stock_status_variant_type').attr('readonly', true);
                $('.variant-product-level-stock-management').find('input,select').prop('readonly', true);
                $('#tab-for-variations').removeClass('d-none');
                $('.variant_stock_status').prop('disabled', true);
                $('#product-tab a[href="#product-attributes"]').tab('show');
                Swal.fire('Settings Saved !', 'Attributes & Variations Can Be Added Now', 'success');
            }
        } else {
            iziToast.error({
                message: 'Please Fill All The Fields',
            });
        }

    } else {

        $('input[name="product_type"]').val($('#product-type').val());
        $('input[name="variant_stock_status"]').val("");
        $('input[name="variant_stock_level_type"]').val("");
        $('#product-tab a[href="#product-attributes"]').tab('show');
        $('.variant_stock_status').prop('disabled', true);
        $('#product-type').prop('disabled', true);
        $('.product-attributes').removeClass('disabled');
        $('.product-variants').removeClass('disabled');
        $('#tab-for-variations').removeClass('d-none');
        Swal.fire('Settings Saved !', 'Attributes & Variations Can Be Added Now', 'success');
    }

});


$(document).on('change', '.new-added-variant', function () {

    var myOpts = $(this).children().map(function () { return $(this).val(); }).get();
    var variant_id = $(this).val();
    var curr_vals = [];
    var $variant_ids = $(this).closest('.product-variant-selectbox').find('input[name="variants_ids[]"]').val();
    $.each($variant_ids.split(','), function (key, val) {
        if (val != '') {
            curr_vals[key] = $.trim(val);
        }
    });
    var newvalues = curr_vals.filter((el) => !myOpts.includes(el));
    var len = newvalues.length;
    if (variant_id != '') {
        newvalues[len] = $.trim(variant_id);
    }
    $(this).closest('.product-variant-selectbox').find('input[name="variants_ids[]"]').val(newvalues.toString());
});

$(document).on('click', '.update_active_status', function () {

    var update_id = $(this).data('id');
    var status = $(this).data('status');
    var table = $(this).data('table');
    update_status(update_id, status, table, from);

});

// 3.Category-Module
$(document).on('click', '#list_view', function () {
    $('#list_view_html').show();
    $('#tree_view_html').hide();
});

$(document).on('click', '#tree_view', function () {
    $('#tree_view_html').show();
    $('#list_view_html').hide();

    var category_url = base_url + from + '/category/get_categories';
    $.ajax({
        type: 'GET',
        url: category_url,
        dataType: 'json',
        success: function (result) {
            $('#tree_view_html').jstree({
                'core': {
                    'data': result['data']
                }
            });
        }
    });
});

function update_status(update_id, status, table, user) {
    $.ajax({
        type: 'GET',
        url: base_url + user + '/home/update_status',
        data: { id: update_id, status: status, table: table },
        dataType: 'json',
        success: function (result) {
            if (result['error'] == true) {
                iziToast.success({
                    message: '<span style="text-transform:capitalize">' + result.message + '</span> Status Updated',
                });
                $('.table').bootstrapTable('refresh');
            } else {
                iziToast.error({
                    message: '<span style="text-transform:capitalize">' + result.message + '</span> Status Not Updated',
                });
            }
        }
    });
}

$(document).on('click', '.update_default_theme', function () {
    var theme_id = $(this).data('id');
    $.ajax({
        type: 'POST',
        url: base_url + 'admin/setting/set-default-theme',
        data: { [csrfName]: csrfHash, theme_id: theme_id },
        dataType: 'json',
        success: function (result) {
            csrfName = result.csrfName;
            csrfHash = result.csrfHash;
            if (result['error'] == false) {
                iziToast.success({
                    message: result.message,
                });
                $('.table').bootstrapTable('refresh');
            } else {
                iziToast.error({
                    message: result.message,
                });
            }
        }
    });
});

$(document).on('click', '.delete-categoty', function () {
    var cat_id = $(this).data('id');
    Swal.fire({
        title: 'Are You Sure!',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    type: 'GET',
                    url: base_url + 'admin/category/delete_category',
                    data: { id: cat_id },
                    dataType: 'json'
                })
                    .done(function (response, textStatus) {
                        if (response.error == false) {
                            Swal.fire('Deleted!', response.message, 'success');
                            $('table').bootstrapTable('refresh');
                            csrfName = response['csrfName'];
                            csrfHash = response['csrfHash'];
                        } else {
                            Swal.fire('Oops...', response.message, 'warning');
                            $('table').bootstrapTable('refresh');
                            csrfName = response['csrfName'];
                            csrfHash = response['csrfHash'];
                        }

                    })
                    .fail(function (jqXHR, textStatus, errorThrown) {
                        Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                        csrfName = response['csrfName'];
                        csrfHash = response['csrfHash'];
                    });
            });
        },
        allowOutsideClick: false
    });
});

$('#category_parent').each(function () {
    $(this).select2({
        theme: 'bootstrap4',
        width: $(this).data('width') ? $(this).data('width') : $(this).hasClass('w-100') ? '100%' : 'style',
        placeholder: $(this).data('placeholder'),
        allowClear: Boolean($(this).data('allow-clear')),
        dropdownCssClass: "test",
        templateResult: function (data) {
            // We only really care if there is an element to pull classes from
            if (!data.element) {
                return data.text;
            }

            var $element = $(data.element);

            var $wrapper = $('<span></span>');
            $wrapper.addClass($element[0].className);

            $wrapper.text(data.text);

            return $wrapper;
        }
    });
});

$(document).on('click', '#save_category_order', function () {
    var data = $('#sortable').sortable('serialize');
    $.ajax({
        data: data,
        type: 'GET',
        url: base_url + 'admin/category/update_category_order',
        dataType: 'json',
        success: function (response) {
            if (response.error == false) {
                iziToast.success({
                    message: response.message,
                });
            } else {
                iziToast.error({
                    message: response.message,
                });
            }
        }
    });
});


//4.Order-Module
$('#datepicker').attr({ 'placeholder': ' Select Date Of Ranges To Filter ', 'autocomplete': 'off' });
$('#datepicker').on('cancel.daterangepicker', function (ev, picker) {
    $(this).val('');
    $('#start_date').val('');
    $('#end_date').val('');
});
$('#datepicker').on('apply.daterangepicker', function (ev, picker) {
    var drp = $('#datepicker').data('daterangepicker');
    $('#start_date').val(drp.startDate.format('YYYY-MM-DD'));
    $('#end_date').val(drp.endDate.format('YYYY-MM-DD'));
    $(this).val(picker.startDate.format('MM/DD/YYYY') + ' - ' + picker.endDate.format('MM/DD/YYYY'));
});

$('#datepicker').daterangepicker({
    showDropdowns: true,
    alwaysShowCalendars: true,
    autoUpdateInput: false,
    ranges: {
        'Today': [moment(), moment()],
        'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
        'Last 7 Days': [moment().subtract(6, 'days'), moment()],
        'Last 30 Days': [moment().subtract(29, 'days'), moment()],
        'This Month': [moment().startOf('month'), moment().endOf('month')],
        'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
    },
    startDate: moment().subtract(29, 'days'),
    endDate: moment(),
    locale: {
        "format": "DD/MM/YYYY",
        "separator": " - ",
        "cancelLabel": 'Clear',
        'label': 'Select range of dates to filter'
    }
});

$(document).on('click', '.update_order', function () {
    var field = 'status';
    var deliver_by = $('#deliver_by').val();
    var val = $('#status').val();

    var orderid = $('#status').data('orderid');
    var json = $('#status').data('isjson');
    if (typeof json == 'undefined') {
        json = false;
    }

    if (val == 'delivered' && deliver_by == '') {
        iziToast.error({
            message: 'Please Select Rider',
        });
    } else {
        Swal.fire({
            title: 'Are You Sure!',
            text: "You won't be able to revert this!",
            type: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, update it!',
            showLoaderOnConfirm: true,
            preConfirm: function () {
                return new Promise((resolve, reject) => {
                    $.ajax({
                        type: 'POST',
                        url: base_url + from + '/orders/update_orders',
                        data: { orderid: orderid, field: field, val: val, deliver_by: deliver_by, json: json, [csrfName]: csrfHash },
                        dataType: 'json',
                        success: function (result) {

                            csrfName = result['csrfName'];
                            csrfHash = result['csrfHash'];
                            if (result['error'] == false) {
                                iziToast.success({
                                    message: result['message'],
                                });
                            } else {
                                iziToast.error({
                                    message: result['message'],
                                });
                            }
                            swal.close();
                        }
                    });
                });
            },
            allowOutsideClick: false
        });
    }

});

$(document).on('click', '.update_status_rider', function (e) {
    var order_id = $(this).data('id');
    var otp_system = $(this).data('otp-system');
    var status = $(this).closest('.row').find('select').val();
    var post_otp = 0;
    if (otp_system == 1 && status == 'delivered') {
        post_otp = prompt('Enter Order OTP');
    }
    Swal.fire({
        title: 'Are You Sure!',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, update it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    type: 'POST',
                    url: base_url + 'rider/orders/update_order_status',
                    data: { order_id: order_id, status: status, otp: post_otp, [csrfName]: csrfHash },
                    dataType: 'json',
                    success: function (result) {
                        csrfName = result['csrfName'];
                        csrfHash = result['csrfHash'];
                        if (result['error'] == false) {
                            iziToast.success({
                                message: result['message'],
                            });
                        } else {
                            iziToast.error({
                                message: result['message'],
                            });
                        }
                        swal.close();
                    }
                });
            });
        },
        allowOutsideClick: false
    });

});

$(document).on('click', '.delete-orders', function () {
    var id = $(this).data('id');
    Swal.fire({
        title: 'Are You Sure!',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    type: 'GET',
                    url: base_url + 'admin/orders/delete_orders',
                    data: { id: id },
                    dataType: 'json',
                    success: function (result) {
                        if (result['error'] == false) {
                            Swal.fire('Deleted!', 'success');
                            $('table').bootstrapTable('refresh');
                        } else {
                            Swal.fire('Oops...', result['message'], 'error');
                        }
                    }
                });
            });
        },
        allowOutsideClick: false
    })
        .then((result) => {
            if (result.dismiss === Swal.DismissReason.cancel) {
                Swal.fire(
                    'Cancelled!',
                    'Your data is  safe.',
                    'error'
                );
            }
        });

});

$(document).on('click', '.remove-restro', function () {
    var id = $(this).data('id');
    var status = $(this).data('restro_status');
    var title = "";
    if (status === 7) {
        title = "restore";
    } else {
        title = "remove";
    }
    Swal.fire({
        title: `Are You Sure! Partner will be ${title} `,
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: `Yes, ${title} it!`,
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    type: 'GET',
                    url: base_url + 'admin/partners/remove_partners',
                    data: { id: id, status: status },
                    dataType: 'json',
                    success: function (result) {
                        if (result['error'] == false) {
                            Swal.fire(`${title}!`, 'success');
                            $('table').bootstrapTable('refresh');
                        } else {
                            Swal.fire('Oops...', result['message'], 'error');
                        }
                    }
                });
            });
        },
        allowOutsideClick: false
    })
        .then((result) => {
            if (result.dismiss === Swal.DismissReason.cancel) {
                Swal.fire(
                    'Cancelled!',
                    'Your data is  safe.',
                    'error'
                );
            }
        });
});
$(document).on('click', '.delete-restro', function () {
    var id = $(this).data('id');
    Swal.fire({
        title: 'Are You Sure! All data & media will be remove related to this partner',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, Remove it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    type: 'GET',
                    url: base_url + 'admin/partners/delete_partner',
                    data: { id: id },
                    dataType: 'json',
                    success: function (result) {
                        if (result['error'] == false) {
                            Swal.fire('Deleted!', result['message']);
                            $('table').bootstrapTable('refresh');
                        } else {
                            Swal.fire('Oops...', result['message'], 'error');
                        }
                    }
                });
            });
        },
        allowOutsideClick: false
    })
        .then((result) => {
            if (result.dismiss === Swal.DismissReason.cancel) {
                Swal.fire(
                    'Cancelled!',
                    'Your data is  safe.',
                    'error'
                );
            }
        });
});

//5.Featured_Section-Module
$('.select_multiple').each(function () {
    $(this).select2({
        theme: 'bootstrap4',
        width: $(this).data('width') ? $(this).data('width') : $(this).hasClass('w-100') ? '100%' : 'style',
        placeholder: $(this).data('placeholder'),
        allowClear: Boolean($(this).data('allow-clear')),
    });
});


$('.search_product').each(function () {
    $(this).select2({
        ajax: {
            url: base_url + 'admin/product/get_product_data',
            dataType: 'json',
            delay: 250,
            data: function (data) {
                return {
                    search: data.term, // search term
                    limit: 10
                };
            },
            processResults: function (response) {
                return {
                    results: response.rows
                };
            },
            cache: true
        },
        escapeMarkup: function (markup) { return markup; },
        minimumInputLength: 1,
        templateResult: formatRepo,
        templateSelection: formatRepoSelection,
        placeholder: 'Search for products',
        theme: 'bootstrap4',
        width: $(this).data('width') ? $(this).data('width') : $(this).hasClass('w-100') ? '100%' : 'style',
        placeholder: $(this).data('placeholder'),
        allowClear: Boolean($(this).data('allow-clear')),
    });
});

$(document).on('click', '#delete-featured-section', function () {
    var id = $(this).data('id');
    Swal.fire({
        title: 'Are You Sure!',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    type: 'GET',
                    url: base_url + 'admin/featured_sections/delete_featured_section',
                    data: { id: id },
                    dataType: 'json',
                    success: function (result) {
                        if (result['error'] == false) {
                            Swal.fire('Deleted!', result['message'], 'success');
                            $('table').bootstrapTable('refresh');
                        } else {
                            Swal.fire('Oops...', result['message'], 'warning');
                        }
                    }
                });
            });
        },
        allowOutsideClick: false
    })
        .then((result) => {
            if (result.dismiss === Swal.DismissReason.cancel) {
                Swal.fire(
                    'Cancelled!',
                    'Your data is  safe.',
                    'error'
                );
            }
        });
});

//6.Notifation-Module
$("#image_checkbox").on('click', function () {
    if (this.checked) {
        $(this).prop("checked", true);
        $('.include_image').removeClass('d-none');
    } else {
        $(this).prop("checked", false);
        $('.include_image').addClass('d-none');
    }
});

$(document).on('click', '.delete_notifications', function () {
    var value = $(this).data('id');
    var url = base_url + 'admin/Notification_settings/delete_notification';
    Swal.fire({
        title: 'Are You Sure !',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    url: url,
                    type: 'GET',
                    data: { 'id': value },
                    dataType: 'json',
                })
                    .done(function (result, textStatus) {
                        if (result['error'] == false) {
                            Swal.fire('Deleted!', result['message'], 'success');
                            $('table').bootstrapTable('refresh');
                        } else {
                            Swal.fire('Oops...', result['message'], 'warning');
                        }
                    })
                    .fail(function (jqXHR, textStatus, errorThrown) {
                        Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                    });
            });
        },
        allowOutsideClick: false
    });
});

//7.Faq-Module
$(document).on('click', '.edit_faq', function () {
    var faq = $(this).parent().closest('.card');
    if ($(this).hasClass('cancel')) {
        $(this).removeClass('cancel');
        $(this).html('<i class="fa fa-pen"></i>');
        $(this).closest('button').addClass('btn-primary').removeClass('btn-danger');
        $(faq).find('input').addClass('d-none');
        $(faq).find('textarea').addClass('d-none');
        $(faq).find('.faq_question').show();
        $(faq).find('.faq_answer').show();
        $(faq).find('.save').addClass('d-none');
        $(faq).find('.collapse').collapse("hide");
    } else {
        $(this).addClass('cancel');
        $(this).html('<i class="fa fa-times"></i>');
        $(this).closest('button').addClass('btn-danger').removeClass('btn-primary');
        var question = $(faq).find('.faq_question').html();
        var answer = $(faq).find('.faq_answer').html();
        $(faq).find('.faq_question').hide();
        $(faq).find('.faq_answer').hide();
        $(faq).find('.collapse').collapse("show");
        $(faq).find('input').removeClass('d-none').val($.trim(question));
        $(faq).find('.save').removeClass('d-none');
        $(faq).find('textarea').removeClass('d-none').val($.trim(answer));
    }
});

$(document).on('click', '.delete_faq', function () {
    var id = $(this).data('id');
    var t = this;
    Swal.fire({
        title: 'Are You Sure !',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    url: base_url + 'admin/faq/delete_faq',
                    type: 'GET',
                    data: { 'id': id },
                    dataType: 'json',
                })
                    .done(function (result, textStatus) {
                        if (result['error'] == false) {
                            $(t).closest('.card').remove();
                            Swal.fire('Deleted!', result['message'], 'success');
                        } else {
                            Swal.fire('Oops...', result['message'], 'warning');
                        }
                    })
                    .fail(function (jqXHR, textStatus, errorThrown) {
                        Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                    });
            });
        },
        allowOutsideClick: false
    });
});

//8.Slider-Module
$(document).on('click', '#delete-slider', function () {
    var id = $(this).data('id');
    Swal.fire({
        title: 'Are You Sure !',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    url: base_url + 'admin/Slider/delete_slider',
                    type: 'GET',
                    data: { 'id': id },
                    dataType: 'json',
                })
                    .done(function (response, textStatus) {
                        if (response.error == false) {
                            Swal.fire('Deleted!', response.message, 'success');
                            $('table').bootstrapTable('refresh');
                        } else {
                            Swal.fire('Oops...', response.message, 'warning');
                        }
                    })
                    .fail(function (jqXHR, textStatus, errorThrown) {
                        Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                    });
            });
        },
        allowOutsideClick: false
    });
});

$(document).on('change', '.product_type', function (e, data) {
    e.preventDefault();
    var sort_type_val = $(this).val();
    if (sort_type_val == 'custom_foods' && sort_type_val != ' ') {
        $('.custom_foods').removeClass('d-none');
    } else {
        $('.custom_foods').addClass('d-none');
    }
});

//9.Offer-Module
$(document).on('click', '#delete-offer', function () {
    var id = $(this).data('id');
    Swal.fire({
        title: 'Are You Sure !',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    url: base_url + 'admin/Offer/delete_offer',
                    type: 'GET',
                    data: { 'id': id },
                    dataType: 'json',
                })
                    .done(function (response, textStatus) {
                        if (response.error == false) {
                            Swal.fire('Deleted!', response.message, 'success');
                            $('table').bootstrapTable('refresh');
                        } else {
                            Swal.fire('Oops...', response.message, 'warning');
                        }
                    })
                    .fail(function (jqXHR, textStatus, errorThrown) {
                        Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                    });
            });
        },
        allowOutsideClick: false
    });
});

//10.Promo_code-Module
$(document).on('change', '#repeat_usage', function () {
    var repeat_usage = $(this).val();
    if (typeof repeat_usage != 'undefined' && repeat_usage == '1') {
        $('#repeat_usage_html').removeClass('d-none');
    } else {
        $('#repeat_usage_html').addClass('d-none');
    }

});

$(document).on('click', '#delete-promo-code', function () {
    var id = $(this).data('id');
    Swal.fire({
        title: 'Are You Sure !',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    url: base_url + 'admin/Promo_code/delete_promo_code',
                    type: 'GET',
                    data: { 'id': id },
                    dataType: 'json',
                })
                    .done(function (response, textStatus) {
                        Swal.fire('Deleted!', response.message, 'success');
                        $('.table-striped').bootstrapTable('refresh');
                    })
                    .fail(function (jqXHR, textStatus, errorThrown) {
                        Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                    });
            });
        },
        allowOutsideClick: false
    });
});

//11.Riders-Module 
$(document).on('click', '#delete-riders', function () {
    var id = $(this).data('id');
    Swal.fire({
        title: 'Are You Sure !',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    url: base_url + 'admin/riders/delete_riders',
                    type: 'GET',
                    data: { 'id': id },
                    dataType: 'json',
                })
                    .done(function (response, textStatus) {
                        if (response.error == false) {
                            Swal.fire('Deleted!', response.message, 'success');
                            $('table').bootstrapTable('refresh');
                        } else {
                            Swal.fire('Oops...', response.message, 'warning');
                        }
                    })
                    .fail(function (jqXHR, textStatus, errorThrown) {
                        Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                    });
            });
        },
        allowOutsideClick: false
    });
});

//12.Settings-Module
$(document).on('click', '#delete-time-slot', function () {
    var id = $(this).data('id');
    Swal.fire({
        title: 'Are You Sure !',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    url: base_url + 'admin/Time_slots/delete_time_slots',
                    type: 'GET',
                    data: { 'id': id },
                    dataType: 'json',
                })
                    .done(function (response, textStatus) {
                        Swal.fire('Deleted!', response.message);
                        $('.table-striped').bootstrapTable('refresh');
                    })
                    .fail(function (jqXHR, textStatus, errorThrown) {
                        Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                    });
            });
        },
        allowOutsideClick: false
    });
});

//13.City-Module
$(document).on('click', '#delete-location', function () {

    var id = $(this).data('id');
    var table = $(this).data('table');
    Swal.fire({
        title: 'Are You Sure !',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    url: base_url + 'admin/Area/delete_city',
                    type: 'GET',
                    data: { 'id': id, 'table': table },
                    dataType: 'json',
                })
                    .done(function (response, textStatus) {
                        if (response.error == false) {
                            Swal.fire('Deleted!', response.message, 'success');
                            $('table').bootstrapTable('refresh');
                        } else {
                            Swal.fire('Oops...', response.message, 'warning');
                        }
                    })
                    .fail(function (jqXHR, textStatus, errorThrown) {
                        Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                    });
            });
        },
        allowOutsideClick: false
    });
});

//14.Transaction_Module
$(document).on('change', '#transaction_type', function () {
    $('.table-striped').bootstrapTable('refresh');
});

//15.Customer-Wallet-Module  
$('#customers').on('check.bs.table', function (e, row) {
    $('#customer_dtls').val(row.name + " | " + row.email);
    $('#user_id').val(row.id);
});

//16.Fund-Transder-Module
$("#fund_transfer").on("click-cell.bs.table", function (field, value, row, $el) {
    $('#name').val($el.name);
    $('#mobile').val($el.mobile);
    $('#balance').val($el.balance);
    $('#rider_id').val($el.id);
});

//17.Return-Request-Module
$("#return_request_table").on("click-cell.bs.table", function (field, value, row, $el) {
    $('input[name="return_request_id"]').val($el.id);
    $('#user_id').val($el.user_id);
    $('#order_item_id').val($el.order_item_id);
    $('#update_remarks').html($el.remarks);

    if ($el.status_digit == 0) {
        $('.pending').prop('checked', true);
    } else if ($el.status_digit == 1) {
        $('.approved').prop('checked', true);
    } else if ($el.status_digit == 2) {
        $('.rejected').prop('rejected', true);
    }
});

//18.Tax-Module
$(document).on('click', '#delete-tax', function () {
    var tax_id = $(this).data('id');
    Swal.fire({
        title: 'Are You Sure!',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    type: 'GET',
                    url: base_url + 'admin/taxes/delete_tax',
                    data: { id: tax_id },
                    dataType: 'json'
                })
                    .done(function (response, textStatus) {
                        if (response.error == false) {
                            Swal.fire('Deleted!', response.message, 'success');
                        } else {
                            Swal.fire('Opps', response.message, 'warning');
                        }
                        $('table').bootstrapTable('refresh');
                    })
                    .fail(function (jqXHR, textStatus, errorThrown) {
                        Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                    });
            });
        },
        allowOutsideClick: false
    });
});

//19.Payment-Request-Module
$("#payment_request_table").on("click-cell.bs.table", function (field, value, row, $el) {
    $('input[name="payment_request_id"]').val($el.id);
    $('#update_remarks').html($el.remarks);

    if ($el.status_digit == 0) {
        $('.pending').prop('checked', true);
    } else if ($el.status_digit == 1) {
        $('.approved').prop('checked', true);
    } else if ($el.status_digit == 2) {
        $('.rejected').prop('rejected', true);
    }
});


$('#upload-media').on('click', function () {
    var $result = $('#media-upload-table').bootstrapTable('getSelections');

    var path = base_url + $result[0].sub_directory + $result[0].name;
    var sub_directory = $result[0].sub_directory + $result[0].name;
    var media_type = $('#media-upload-modal').find('input[name="media_type"]').val();
    var input = $('#media-upload-modal').find('input[name="current_input"]').val();
    var is_removable = $('#media-upload-modal').find('input[name="remove_state"]').val();
    var ismultipleAllowed = $('#media-upload-modal').find('input[name="multiple_images_allowed_state"]').val();
    var removable_btn = (is_removable == '1') ? '<button class="remove-image btn btn-danger btn-xs mt-3">Remove</button>' : '';

    $(current_selected_image).closest('.form-group').find('.image').removeClass('d-none');
    if (ismultipleAllowed == '1') {
        for (let index = 0; index < $result.length; index++) {
            $(current_selected_image).closest('.form-group').find('.image-upload-section').append('<div class="col-md-3 col-sm-12 shadow p-3 mb-5 bg-white rounded m-4 text-center grow image"><div class="image-upload-div"><img class="img-fluid" alt="' + $result[index].name + '" title="' + $result[index].name + '" src=' + base_url + $result[index].sub_directory + $result[index].name + ' ><input type="hidden" name=' + input + ' value=' + $result[index].sub_directory + $result[index].name + '></div>' + removable_btn + '</div>');
        }
    } else {
        path = (media_type != 'image') ? base_url + 'assets/admin/images/' + media_type + '-file.png' : path;
        $(current_selected_image).closest('.form-group').find('.image-upload-section').html('<div class="col-md-3 col-sm-12 shadow p-3 mb-5 bg-white rounded m-4 text-center grow image"><div class="image-upload-div"><img class="img-fluid" alt="' + $result[0].name + '" title="' + $result[0].name + '" src=' + path + ' ><input type="hidden" name=' + input + ' value=' + sub_directory + '></div>' + removable_btn + '</div>');
    }

    current_selected_image = '';
    $('#media-upload-modal').modal('hide');
});

$(document).on('show.bs.modal', '#media-upload-modal', function (event) {
    var triggerElement = $(event.relatedTarget);
    current_selected_image = triggerElement;
    var input = $(current_selected_image).data('input');
    var isremovable = $(current_selected_image).data('isremovable');
    var ismultipleAllowed = $(current_selected_image).data('is-multiple-uploads-allowed');
    var media_type = ($(current_selected_image).is('[data-media_type]')) ? $(current_selected_image).data('media_type') : 'image';
    $('#media_type').val(media_type);
    if (ismultipleAllowed == 1) {
        $('#media-upload-table').bootstrapTable('refreshOptions', {
            singleSelect: false,
        });
    } else {
        $('#media-upload-table').bootstrapTable('refreshOptions', {
            singleSelect: true,
        });
    }

    $(this).find('input[name="current_input"]').val(input);
    $(this).find('input[name="remove_state"]').val(isremovable);
    $(this).find('input[name="multiple_images_allowed_state"]').val(ismultipleAllowed);
});

$(document).on('change', '#video_type', function () {
    var video_type = $(this).val();
    if (video_type == 'youtube' || video_type == 'vimeo') {
        $("#video_link_container").removeClass('d-none');
        $("#video_media_container").addClass('d-none');
    } else if (video_type == 'self_hosted') {
        $("#video_link_container").addClass('d-none');
        $("#video_media_container").removeClass('d-none');
    } else {
        $("#video_link_container").addClass('d-none');
        $("#video_media_container").addClass('d-none');
    }
});
if ($('#highlights').length) {
    var tags_element = document.querySelector('input[name=highlights]');
    new Tagify(tags_element);
}
if ($('#attribute_values').length) {
    var attr_val_element = document.querySelector('input[name=attribute_values]');
    new Tagify(attr_val_element);
}

$(document).on('show.bs.modal', '#customer-address-modal', function (event) {
    var triggerElement = $(event.relatedTarget);
    current_selected_image = triggerElement;
    var id = $(current_selected_image).data('id');
    var existing_url = $(this).find('#customer-address-table').data('url');

    if (existing_url.indexOf('?') > -1) {
        var temp = $(existing_url).text().split('?');
        var new_url = temp[0] + '?user_id=' + id;
    } else {
        var new_url = existing_url + '?user_id=' + id;
    }
    $('#customer-address-table').bootstrapTable('refreshOptions', {
        url: new_url,
    });
});
$(document).on('show.bs.modal', '#product-rating-modal', function (event) {
    var triggerElement = $(event.relatedTarget);
    current_selected_image = triggerElement;
    var id = $(current_selected_image).data('id');

    var existing_url = $(this).find('#product-rating-table').data('url');
    if (existing_url.indexOf('?') > -1) {
        var temp = $(existing_url).text().split('?');
        var new_url = temp[0] + '?product_id=' + id;
    } else {
        var new_url = existing_url + '?product_id=' + id;
    }
    $('#product-rating-table').bootstrapTable('refreshOptions', {
        url: new_url,
    });
});
$(document).on('show.bs.modal', '#rider-rating-modal', function (event) {
    var triggerElement = $(event.relatedTarget);
    current_selected_image = triggerElement;
    var id = $(current_selected_image).data('id');

    var existing_url = $(this).find('#rider-rating-table').data('url');

    if (existing_url.indexOf('?') > -1) {
        var temp = $(existing_url).text().split('?');
        var new_url = temp[0] + '?rider_id=' + id;
    } else {
        var new_url = existing_url + '?rider_id=' + id;
    }
    $('#rider-rating-table').bootstrapTable('refreshOptions', {
        url: new_url,
    });
});

$(document).on('click', '.remove-image', function (e) {
    e.preventDefault();
    $(this).closest('.image').remove();
});

$(document).on('change', '#media-type', function () {
    $('table').bootstrapTable('refresh');
});

Dropzone.autoDiscover = false;

if (document.getElementById('dropzone')) {

    var myDropzone = new Dropzone("#dropzone", {
        url: base_url + from + '/media/upload',
        paramName: "documents",
        autoProcessQueue: false,
        parallelUploads: 12,
        maxFiles: 12,
        autoDiscover: false,
        addRemoveLinks: true,
        timeout: 180000,
        dictRemoveFile: 'x',
        dictMaxFilesExceeded: 'Only 12 files can be uploaded at a time ',
        dictResponseError: 'Error',
        uploadMultiple: true,
        dictDefaultMessage: '<p><input type="submit" value="Select Files" class="btn btn-info" /><br> or <br> Drag & Drop Media Files Here</p>',
    });

    myDropzone.on("addedfile", function (file) {
        var i = 0;
        if (this.files.length) {
            var _i, _len;
            for (_i = 0, _len = this.files.length; _i < _len - 1; _i++) {
                if (this.files[_i].name === file.name && this.files[_i].size === file.size && this.files[_i].lastModifiedDate.toString() === file.lastModifiedDate.toString()) {
                    this.removeFile(file);
                    i++;
                }
            }
        }
    });

    myDropzone.on("error", function (file, response) {
    });


    myDropzone.on('sending', function (file, xhr, formData) {
        formData.append(csrfName, csrfHash);
        xhr.onreadystatechange = function () {
            if (this.readyState == 4 && this.status == 200) {
                var response = JSON.parse(this.response);
                csrfName = response.csrfName;
                csrfHash = response.csrfHash;
                if (response['error'] == false) {
                    Dropzone.forElement('#dropzone').removeAllFiles(true);
                    $("#media-upload-table").bootstrapTable('refresh');
                    iziToast.success({
                        message: response['message'],
                    });
                    $('#media-table').bootstrapTable('refresh');

                } else {
                    iziToast.error({
                        title: 'Error',
                        message: response['message'],
                    });
                }
                $(file.previewElement).find('.dz-error-message').text(response.message);
            }
        };
    });
}
if (document.getElementById('system-update-dropzone')) {

    var systemDropzone = new Dropzone("#system-update-dropzone", {
        url: base_url + 'admin/updater/upload_update_file',
        paramName: "update_file",
        autoProcessQueue: false,
        parallelUploads: 1,
        maxFiles: 1,
        timeout: 360000,
        autoDiscover: false,
        addRemoveLinks: true,
        dictRemoveFile: 'x',
        dictMaxFilesExceeded: 'Only 1 file can be uploaded at a time ',
        dictResponseError: 'Error',
        uploadMultiple: true,
        dictDefaultMessage: '<p><input type="submit" value="Select Files" class="btn btn-info" /><br> or <br> Drag & Drop System Update / Installable / Plugin\'s .zip file Here</p>',
    });

    systemDropzone.on("addedfile", function (file) {
        var i = 0;
        if (this.files.length) {
            var _i, _len;
            for (_i = 0, _len = this.files.length; _i < _len - 1; _i++) {
                if (this.files[_i].name === file.name && this.files[_i].size === file.size && this.files[_i].lastModifiedDate.toString() === file.lastModifiedDate.toString()) {
                    this.removeFile(file);
                    i++;
                }
            }
        }
    });

    systemDropzone.on("error", function (file, response) {
    });


    systemDropzone.on('sending', function (file, xhr, formData) {
        formData.append(csrfName, csrfHash);
        xhr.onreadystatechange = function () {
            if (this.readyState == 4 && this.status == 200) {
                var response = JSON.parse(this.response);
                csrfName = response.csrfName;
                csrfHash = response.csrfHash;
                if (response['error'] == false) {
                    iziToast.success({
                        message: response['message'],
                    });
                } else {
                    iziToast.error({
                        title: 'Error',
                        message: response['message'],
                    });
                }
                $(file.previewElement).find('.dz-error-message').text(response.message);
            }
        };
    });
    $('#system_update_btn').on('click', function (e) {
        e.preventDefault();
        systemDropzone.processQueue();
    });
}

$('#upload-files-btn').on('click', function (e) {
    e.preventDefault();
    myDropzone.processQueue();
});




$(document).on('click', '.copy-to-clipboard', function () {

    var $element = $(this).closest('tr').find('.path');
    copyToClipboard($element);
    iziToast.success({
        message: 'Image path copied to clipboard',
    });
});
$(document).on('click', '.copy-relative-path', function () {
    var $element = $(this).closest('tr').find('.relative-path');
    copyToClipboard($element);
    iziToast.success({
        message: 'Image path copied to clipboard',
    });
});


$(document).on('click', 'button[type="reset"]', function () {
    $('.image-upload-div').remove();
    $('.image-upload-section').find('.image').addClass('d-none');
});

//20.Client Api Key Module
$(document).on('click', '#delete-client', function () {
    var id = $(this).data('id');
    Swal.fire({
        title: 'Are You Sure!',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    type: 'GET',
                    url: base_url + 'admin/client_api_keys/delete_client',
                    data: { id: id },
                    dataType: 'json'
                })
                    .done(function (response, textStatus) {
                        if (response.error == false) {
                            Swal.fire('Deleted!', response.message, 'success');
                        } else {
                            Swal.fire('Opps', response.message, 'warning');
                        }
                        $('table').bootstrapTable('refresh');
                    })
                    .fail(function (jqXHR, textStatus, errorThrown) {
                        Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                    });
            });
        },
        allowOutsideClick: false
    });
});

//21.System Users
$(document).on('click', '#delete-system-users', function () {
    var id = $(this).data('id');
    Swal.fire({
        title: 'Are You Sure!',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    type: 'GET',
                    url: base_url + 'admin/system_users/delete_system_user',
                    data: { id: id },
                    dataType: 'json'
                })
                    .done(function (response, textStatus) {
                        if (response.error == false) {
                            Swal.fire('Deleted!', response.message, 'success');
                        } else {
                            Swal.fire('Opps', response.message, 'warning');
                        }
                        $('table').bootstrapTable('refresh');
                    })
                    .fail(function (jqXHR, textStatus, errorThrown) {
                        Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                    });
            });
        },
        allowOutsideClick: false
    });
});

$(document).on('change', '.system-user-role', function () {
    var role = $(this).val();
    if (role > 0) {
        $('.permission-table').removeClass('d-none');
    } else {
        $('.permission-table').addClass('d-none');
    }
});

$(document).on('click', '.remove_individual_variants', function () {
    var variant_id = $(this).closest('.variant_col').find('input[type="hidden"]').val();
    var all_variant_ids = $(this).closest('.row').find('input[name="variants_ids[]"]').val().split(',');
    all_variant_ids.splice(all_variant_ids.indexOf(variant_id), 1);
    if ($.isEmptyObject(all_variant_ids)) {
        $(this).closest('.row').remove();
    } else {
        $(this).closest('.row').find('input[name="variants_ids[]"]').val(all_variant_ids.toString());
        $(this).closest('.variant_col').remove();
    }
});

$(document).on('change', '#system_timezone', function () {
    var gmt = $(this).find(':selected').data('gmt');
    $('#system_timezone_gmt').val(gmt);
});

$('#city').on('change', function (e) {
    e.preventDefault();
    $.ajax({
        type: 'POST',
        data: {
            'city_id': $(this).val(),
            [csrfName]: csrfHash,
        },
        url: base_url + 'my-account/get-areas',
        dataType: 'json',
        success: function (result) {
            csrfName = result.csrfName;
            csrfHash = result.csrfHash;
            if (result.error == false) {
                var html = '';
                $.each(result.data, function (i, e) {
                    html += '<option value=' + e.id + '>' + e.name + '</option>';
                });
                $('#area').html(html);
            } else {
                Toast.fire({
                    icon: 'error',
                    title: result.message
                });
                $('#area').html('');
            }
        }
    })
});

$('#add-address-form').on('submit', function (e) {
    e.preventDefault();
    var formdata = new FormData(this);
    formdata.append(csrfName, csrfHash);
    $.ajax({
        type: 'POST',
        data: formdata,
        url: $(this).attr('action'),
        dataType: 'json',
        cache: false,
        contentType: false,
        processData: false,
        beforeSend: function () {
            $('#save-address-submit-btn').val('Please Wait...').attr('disabled', true);
        },
        success: function (result) {
            csrfName = result.csrfName;
            csrfHash = result.csrfHash;
            if (result.error == false) {
                $('#save-address-result').html("<div class='alert alert-success'>" + result.message + "</div>").delay(1500).fadeOut();
                $('#add-address-form')[0].reset();
                $('#address_list_table').bootstrapTable('refresh');
            } else {
                $('#save-address-result').html("<div class='alert alert-danger'>" + result.message + "</div>").delay(1500).fadeOut();
            }
            $('#save-address-submit-btn').val('Save').attr('disabled', false);
        }
    })
})

$(document).on('click', '.delete-address', function (e) {
    e.preventDefault();
    if (confirm('Are you sure ? You want to delete this address?')) {
        $.ajax({
            type: 'POST',
            data: {
                'id': $(this).data('id'),
                [csrfName]: csrfHash,
            },
            url: base_url + 'my-account/delete-address',
            dataType: 'json',
            success: function (result) {
                csrfName = result.csrfName;
                csrfHash = result.csrfHash;
                if (result.error == false) {
                    $('#address_list_table').bootstrapTable('refresh');
                } else {
                    Toast.fire({
                        icon: 'error',
                        title: result.message
                    });
                }
            }
        })
    }
});
$('#edit_city').on('change', function (e, data) {
    e.preventDefault();
    $.ajax({
        type: 'POST',
        data: {
            'city_id': $(this).val(),
            [csrfName]: csrfHash,
        },
        url: base_url + 'my-account/get-areas',
        dataType: 'json',
        success: function (result) {
            csrfName = result.csrfName;
            csrfHash = result.csrfHash;
            if (result.error == false) {
                var html = '';
                $.each(result.data, function (i, e) {
                    html += '<option value=' + e.id + '>' + e.name + '</option>';
                });
                $('#edit_area').html(html);
            } else {
                Toast.fire({
                    icon: 'error',
                    title: result.message
                });
                $('#edit_area').html('');
            }
        }
    })
});

$('#edit-address-form').on('submit', function (e) {
    e.preventDefault();
    var formdata = new FormData(this);
    formdata.append(csrfName, csrfHash);
    $.ajax({
        type: 'POST',
        data: formdata,
        url: $(this).attr('action'),
        dataType: 'json',
        cache: false,
        contentType: false,
        processData: false,
        beforeSend: function () {
            $('#edit-address-submit-btn').val('Please Wait...').attr('disabled', true);
        },
        success: function (result) {
            csrfName = result.csrfName;
            csrfHash = result.csrfHash;
            if (result.error == false) {
                $('#edit-address-result').html("<div class='alert alert-success'>" + result.message + "</div>").delay(1500).fadeOut();
                $('#edit-address-form')[0].reset();
                $('#address_list_table').bootstrapTable('refresh');
                setTimeout(function () {
                    $('#address-modal').modal('hide');
                }, 2000)
            } else {
                $('#edit-address-result').html("<div class='alert alert-danger'>" + result.message + "</div>").delay(1500).fadeOut();
            }
            $('#edit-address-submit-btn').val('Save').attr('disabled', false);
        }
    })
})

$('#add-new-language-form').on('submit', function (e) {
    e.preventDefault();
    var formdata = new FormData(this);
    formdata.append(csrfName, csrfHash);
    $.ajax({
        type: 'POST',
        data: formdata,
        url: $(this).attr('action'),
        dataType: 'json',
        cache: false,
        contentType: false,
        processData: false,
        beforeSend: function () {
            $('#submit_btn').val('Please Wait...').attr('disabled', true);
        },
        success: function (result) {
            csrfName = result.csrfName;
            csrfHash = result.csrfHash;
            if (result.error == false) {
                $('#result').show().removeClass('msg_error').addClass('msg_success').html(result.message).delay(1500).fadeOut();
                $('#add-new-language-form')[0].reset();
                setTimeout(function () {
                    $('#language-modal').modal('hide');
                }, 2000)
            } else {
                $('#result').show().removeClass('msg_success').addClass('msg_error').html(result.message).delay(1500).fadeOut();
            }
            $('#submit_btn').val('Save').attr('disabled', false);
        }
    })
})

$('#selected_language').on('change', function () {
    var id = $(this).val();
    window.location.href = base_url + 'admin/language?id=' + id;
});
$('#distance_unit').on('change', function () {
    var unit = $(this).val();
    if (unit) {
        $("#selected_unit").text("Delivery Charge Amount per " + unit);
    } else {
        $("#selected_unit").text("Delivery Charge Amount per Unit");
    }

});
$('#update-language-form').on('submit', function (e) {
    e.preventDefault();
    var formdata = new FormData(this);
    formdata.append(csrfName, csrfHash);
    $.ajax({
        type: 'POST',
        data: formdata,
        url: $(this).attr('action'),
        dataType: 'json',
        cache: false,
        contentType: false,
        processData: false,
        beforeSend: function () {
            $('#update_btn').val('Please Wait...').attr('disabled', true);
        },
        success: function (result) {
            csrfName = result.csrfName;
            csrfHash = result.csrfHash;
            if (result.error == false) {
                $('#update-result').show().removeClass('msg_error').addClass('msg_success').html(result.message).delay(1500).fadeOut();
            } else {
                $('#update-result').show().removeClass('msg_success').addClass('msg_error').html(result.message).delay(1500).fadeOut();
            }
            $('#update_btn').val('Save').attr('disabled', false);
        }
    })
})

function product_rating_query_params(p) {
    return {
        'product_id': $('#product_id').val(),
        limit: p.limit,
        sort: p.sort,
        order: p.order,
        offset: p.offset,
        search: p.search
    };
}


$('#flat_delivery_charge').on('switchChange.bootstrapSwitch', function (event, state) {
    if (state == false) {
        $("#fixed_charges").show();
        $("#distance_charges").hide();
        $("#fixed_charges").removeClass("d-none")
    } else {
        $("#fixed_charges").hide();
        $("#distance_charges").show();
        $("#distance_charges").removeClass("d-none")
    }
});

$('#bulk_upload_form').on('submit', function (e) {
    e.preventDefault();
    var type = $('#type').val();
    if (type != '') {
        var formdata = new FormData(this);
        formdata.append(csrfName, csrfHash);
        $.ajax({
            type: 'POST',
            data: formdata,
            url: $(this).attr('action'),
            dataType: 'json',
            cache: false,
            contentType: false,
            processData: false,
            beforeSend: function () {
                $('#submit_btn').html('Please Wait...').attr('disabled', true);
            },
            success: function (result) {
                csrfName = result.csrfName;
                csrfHash = result.csrfHash;
                if (result.error == false) {
                    $('#upload_result').show().removeClass('msg_error').addClass('msg_success').html(result.message).delay(3000).fadeOut();
                } else {
                    $('#upload_result').show().removeClass('msg_success').addClass('msg_error').html(result.message).delay(3000).fadeOut();
                }
                $('#submit_btn').html('Submit').attr('disabled', false);
            }
        })
    }
    else {
        iziToast.error({
            message: 'Please select type',
        });
    }

});
$('#location_bulk_upload_form').on('submit', function (e) {
    e.preventDefault();
    var type = $('#type').val();
    var location_type = $('#location_type').val();
    if (type != '' && location_type != "" && type != "undefined" && location_type != "undefined") {
        var formdata = new FormData(this);
        formdata.append(csrfName, csrfHash);
        $.ajax({
            type: 'POST',
            data: formdata,
            url: $(this).attr('action'),
            dataType: 'json',
            cache: false,
            contentType: false,
            processData: false,
            beforeSend: function () {
                $('#submit_btn').html('Please Wait...').attr('disabled', true);
            },
            success: function (result) {
                csrfName = result.csrfName;
                csrfHash = result.csrfHash;
                if (result.error == false) {
                    $('#upload_result').show().removeClass('msg_error').addClass('msg_success').html(result.message).delay(3000).fadeOut();
                } else {
                    $('#upload_result').show().removeClass('msg_success').addClass('msg_error').html(result.message).delay(3000).fadeOut();
                }
                $('#submit_btn').html('Submit').attr('disabled', false);
            }
        });
    }
    else {
        iziToast.error({
            message: 'Please select Type and Location Type',
        });
    }

});


// swatche js

$('#swatche_color').hide();
$('#swatche_image').hide();
$(document.body).on('change', '.swatche_type', function (e) {
    e.preventDefault();
    var swatche_type = $(this).val();
    if (swatche_type == "1") {
        $('#swatche_image').hide();
        $('#swatche_color').show();
        $('#swatche_image').val('');
    } else if (swatche_type == "2") {
        $('#swatche_color').hide();
        $('#swatche_image').show();
        $('#swatche_color').val('');
    } else {
        $('#swatche_color').hide();
        $('#swatche_image').hide();
        $('#swatche_color').val('');
        $('#swatche_image').val('');
    }
});


var ticket_id = "";
var scrolled = 0;
$(document).on('click', '.view_ticket', function (e, row) {
    e.preventDefault();
    scrolled = 0;
    $(".ticket_msg").data('max-loaded', false);
    ticket_id = $(this).data("id");
    var username = $(this).data("username");
    var date_created = $(this).data("date_created");
    var subject = $(this).data("subject");
    var status = $(this).data("status");
    var ticket_type = $(this).data("ticket_type");
    $('input[name="ticket_id"]').val(ticket_id);
    $('#user_name').html(username);
    $('#date_created').html(date_created);
    $('#subject').html(subject);
    $('.change_ticket_status').data('ticket_id', ticket_id);
    if (status == 1) {
        $('#status').html('<label class="badge badge-secondary ml-2">PENDING</label>');
    } else if (status == 2) {
        $('#status').html('<label class="badge badge-info ml-2">OPENED</label>');
    } else if (status == 3) {
        $('#status').html('<label class="badge badge-success ml-2">RESOLVED</label>');
    } else if (status == 4) {
        $('#status').html('<label class="badge badge-danger ml-2">CLOSED</label>');
    } else if (status == 5) {
        $('#status').html('<label class="badge badge-warning ml-2">REOPENED</label>');
    }
    $('#ticket_type').html(ticket_type);
    $('.ticket_msg').html("");
    $('.ticket_msg').data('limit', 5);
    $('.ticket_msg').data('offset', 0);
    load_messages($('.ticket_msg'), ticket_id);
});

$(document).ready(function () {
    if ($("#element").length) {
        $("#element").scrollTop($("#element")[0].scrollHeight);
        $('#element').scroll(function () {
            if ($('#element').scrollTop() == 0) {
                load_messages($('.ticket_msg'), ticket_id);
            }
        });

        $('#element').bind('mousewheel', function (e) {
            if (e.originalEvent.wheelDelta / 120 > 0) {
                if ($(".ticket_msg")[0].scrollHeight < 370 && scrolled == 0) {
                    load_messages($('.ticket_msg'), ticket_id);
                    scrolled = 1;
                }
            }
        });
    }
});

$('#ticket_send_msg_form').on('submit', function (e) {
    e.preventDefault();
    var formdata = new FormData(this);
    formdata.append(csrfName, csrfHash);

    $.ajax({
        type: 'POST',
        url: $(this).attr('action'),
        data: formdata,
        beforeSend: function () {
            $('#submit_btn').html('Sending..').attr('disabled', true);
        },
        cache: false,
        contentType: false,
        processData: false,
        dataType: "json",
        success: function (result) {
            csrfHash = result.csrfHash;
            $('#submit_btn').html('Send').attr('disabled', false);
            if (result.error == false) {
                if (result.data.id > 0) {
                    var message = result.data;
                    var is_left = (message.user_type == 'user') ? 'left' : 'right';
                    var message_html = "";
                    var atch_html = "";
                    var i = 1;
                    if (message.attachments.length > 0) {
                        message.attachments.forEach(atch => {
                            atch_html += "<div class='container-fluid image-upload-section'>"
                                + "<a class='btn btn-danger btn-xs mr-1 mb-1' href='" + atch.media + "'  target='_blank' alt='Attachment Not Found'>Attachment " + i + "</a>" +
                                "<div class='col-md-3 col-sm-12 shadow p-3 mb-5 bg-white rounded m-4 text-center grow image d-none'></div>" +
                                "</div>";
                            i++;
                        });
                    }
                    message_html += "<div class='direct-chat-msg " + is_left + "'>" +
                        "<div class='direct-chat-infos clearfix'>" +
                        "<span class='direct-chat-name float-" + is_left + "' id='name'>" + message.name + "</span>" +
                        "<span class='direct-chat-timestamp float-" + is_left + "' id='last_updated'>" + message.last_updated + "</span>" +
                        "</div>" +
                        "<div class='direct-chat-text' id='message'>" + message.message + "</br>" + atch_html + "</div>" +
                        "</div>";

                    $('.ticket_msg').append(message_html);
                    $("#message_input").val('');

                    $("#element").scrollTop($("#element")[0].scrollHeight);
                    $('input[name="attachments[]"]').val('');
                }
            } else {
                $("#element").data('max-loaded', true);
                iziToast.error({
                    message: '<span style="text-transform:capitalize">' + result.message + '</span> ',
                });
                return false;
            }
            iziToast.success({
                message: '<span style="text-transform:capitalize">' + result.message + '</span> ',
            });
        }
    });
});

// if ($('#delete-ticket').length) {
$(document).on('click', '#delete-ticket', function () {

    var id = $(this).data('id');
    Swal.fire({
        title: 'Are You Sure !',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    url: base_url + 'admin/tickets/delete_ticket',
                    type: 'GET',
                    data: { 'id': id },
                    dataType: 'json',
                })
                    .done(function (response, textStatus) {
                        if (response.error == false) {
                            Swal.fire('Deleted!', response.message, 'success');
                            $('table').bootstrapTable('refresh');
                        } else {
                            Swal.fire('Oops...', response.message, 'warning');
                        }
                    })
                    .fail(function (jqXHR, textStatus, errorThrown) {
                        Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                    });
            });
        },
        allowOutsideClick: false
    });
});
// }

$(document).on('change', '.change_ticket_status', function () {
    var status = $(this).val();
    if (status != '') {
        if (confirm("Are you sure you want to mark the ticket as " + $(".change_ticket_status option:selected").text() + "? ")) {
            var id = $(this).data('ticket_id');
            var dataString = { ticket_id: id, status: status, [csrfName]: csrfHash };
            $.ajax({
                type: 'post',
                url: base_url + 'admin/tickets/edit-ticket-status',
                data: dataString,
                dataType: 'json',
                success: function (result) {
                    csrfHash = result.csrfHash;
                    if (result.error == false) {
                        $('#ticket_table').bootstrapTable('refresh');
                        iziToast.success({
                            message: '<span style="text-transform:capitalize">' + result.message + '</span> ',
                        });

                    } else {
                        iziToast.error({
                            message: '<span>' + result.message + '</span> ',
                        });
                    }
                }
            });
        }
    }
});

$(document).on('click', '.delete-ticket-type', function () {
    var cat_id = $(this).data('id');
    Swal.fire({
        title: 'Are You Sure!',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    type: 'GET',
                    url: base_url + 'admin/tickets/delete_ticket_type',
                    data: { id: cat_id },
                    dataType: 'json'
                })
                    .done(function (response, textStatus) {
                        if (response.error == false) {
                            Swal.fire('Deleted!', response.message, 'success');
                            $('table').bootstrapTable('refresh');
                            csrfName = response['csrfName'];
                            csrfHash = response['csrfHash'];
                        } else {
                            Swal.fire('Oops...', response.message, 'warning');
                            $('table').bootstrapTable('refresh');
                            csrfName = response['csrfName'];
                            csrfHash = response['csrfHash'];
                        }

                    })
                    .fail(function (jqXHR, textStatus, errorThrown) {
                        Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                        csrfName = response['csrfName'];
                        csrfHash = response['csrfHash'];
                    });
            });
        },
        allowOutsideClick: false
    });
});

function load_messages(element, ticket_id) {
    var limit = element.data('limit');
    var offset = element.data('offset');

    element.data('offset', limit + offset);
    var max_loaded = element.data('max-loaded');
    if (max_loaded == false) {
        var loader = '<div class="loader text-center"><img src="' + base_url + 'assets/pre-loader.gif" alt="Loading. please wait.. ." title="Loading. please wait.. ."></div>';
        $.ajax({
            type: 'get',
            data: 'ticket_id=' + ticket_id + '&limit=' + limit + '&offset=' + offset,
            url: base_url + 'admin/tickets/get_ticket_messages',
            beforeSend: function () {
                $('.ticket_msg').prepend(loader);
            },
            dataType: 'json',
            cache: false,
            contentType: false,
            processData: false,
            success: function (result) {
                if (result.error == false) {
                    if (result.error == false && result.data.length > 0) {
                        var messages_html = "";
                        var is_left = "";
                        var is_right = "";
                        var atch_html = "";
                        var i = 1;
                        result.data.reverse().forEach(messages => {
                            is_left = (messages.user_type == 'user') ? 'left' : 'right';
                            is_right = (messages.user_type == 'user') ? 'right' : 'left';
                            if (messages.attachments.length > 0) {
                                messages.attachments.forEach(atch => {
                                    atch_html += "<div class='container-fluid image-upload-section'>"
                                        + "<a class='btn btn-danger btn-xs mr-1 mb-1' href='" + atch.media + "'  target='_blank' alt='Attachment Not Found'>Attachment " + i + "</a>" +
                                        "<div class='col-md-3 col-sm-12 shadow p-3 mb-5 bg-white rounded m-4 text-center grow image d-none'></div>" +
                                        "</div>";
                                    i++;
                                });
                            }
                            messages_html += "<div class='direct-chat-msg " + is_left + "'>" +
                                "<div class='direct-chat-infos clearfix'>" +
                                "<span class='direct-chat-name float-" + is_left + "' id='name'>" + messages.name + "</span>" +
                                "<span class='direct-chat-timestamp float-" + is_left + "' id='last_updated'>" + messages.last_updated + "</span>" +
                                "</div>" +
                                "<div class='direct-chat-text' id='message'>" + messages.message + "</br>" + atch_html + "</div>" +
                                "</div>";
                        });
                        $('.ticket_msg').prepend(messages_html);
                        $('.ticket_msg').find('.loader').remove();
                        $(element).animate({
                            scrollTop: $(element).offset().top
                        });
                    }
                } else {
                    element.data('offset', offset);
                    element.data('max-loaded', true);
                    $('.ticket_msg').find('.loader').remove();
                    $('.ticket_msg').prepend('<div class="text-center"> <p>You have reached the top most message!</p></div>');
                }
                $('#element').scrollTop(20); // Scroll alittle way down, to allow user to scroll more
                $(element).animate({
                    scrollTop: $(element).offset().top
                });
                return false;
            }
        });

    }
}

$(document).on('click', '.edit_transaction', function (e, row) {
    e.preventDefault();
    var id = $(this).data("id");
    var txn_id = $(this).data("txn_id");
    var status = $(this).data("status");
    var message = $(this).data("message");

    $('#id').val(id);
    $('#txn_id').val(txn_id);
    $('#t_status').val(status);
    $('#message').val(message);

});


$('#edit_transaction_form').on('submit', function (e) {
    e.preventDefault();
    var formdata = new FormData(this);
    formdata.append(csrfName, csrfHash);

    $.ajax({
        type: 'POST',
        url: $(this).attr('action'),
        data: formdata,
        beforeSend: function () {
            $('#submit_btn').html('Please Wait..').attr('disabled', true);
        },
        cache: false,
        contentType: false,
        processData: false,
        dataType: "json",
        success: function (result) {
            csrfHash = result.csrfHash;
            $('#submit_btn').html('Update Transaction').attr('disabled', false);
            if (result.error == false) {
                $('table').bootstrapTable('refresh');
                iziToast.success({
                    message: '<span style="text-transform:capitalize">' + result.message + '</span> ',
                });
            } else {
                iziToast.error({
                    message: '<span>' + result.message + '</span> ',
                });
            }
        }
    });
});

$('#order_tracking_form').on('submit', function (e) {
    e.preventDefault();
    var formdata = new FormData(this);
    formdata.append(csrfName, csrfHash);

    $.ajax({
        type: 'POST',
        url: $(this).attr('action'),
        data: formdata,
        beforeSend: function () {
            $('#submit_btn').html('Please Wait..').attr('disabled', true);
        },
        cache: false,
        contentType: false,
        processData: false,
        dataType: "json",
        success: function (result) {
            csrfHash = result.csrfHash;
            $('#submit_btn').html('Update Transaction').attr('disabled', false);
            if (result.error == false) {
                $('table').bootstrapTable('refresh');
                iziToast.success({
                    message: '<span style="text-transform:capitalize">' + result.message + '</span> ',
                });
            } else {
                iziToast.error({
                    message: '<span>' + result.message + '</span> ',
                });
            }
        }
    });
});

$(document).on('click', '.delete-receipt', function () {
    var cat_id = $(this).data('id');
    Swal.fire({
        title: 'Are You Sure!',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    type: 'GET',
                    url: base_url + 'admin/orders/delete_receipt',
                    data: { id: cat_id },
                    dataType: 'json'
                })
                    .done(function (response, textStatus) {
                        if (response.error == false) {
                            Swal.fire('Deleted!', response.message, 'success');
                            $('table').bootstrapTable('refresh');
                            csrfName = response['csrfName'];
                            csrfHash = response['csrfHash'];
                            window.location.reload();
                        } else {
                            Swal.fire('Oops...', response.message, 'warning');
                            $('table').bootstrapTable('refresh');
                            csrfName = response['csrfName'];
                            csrfHash = response['csrfHash'];
                        }

                    })
                    .fail(function (jqXHR, textStatus, errorThrown) {
                        Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                        csrfName = response['csrfName'];
                        csrfHash = response['csrfHash'];
                    });
            });
        },
        allowOutsideClick: false
    });
});

$('#update_receipt_status').on('change', function (e) {
    e.preventDefault();
    var order_id = $(this).data('id');
    var user_id = $(this).data('user_id');
    var status = $(this).val();
    $.ajax({
        type: 'POST',
        data: {
            'order_id': order_id,
            'status': status,
            'user_id': user_id,
            [csrfName]: csrfHash,
        },
        url: base_url + 'admin/orders/update_receipt_status',
        dataType: 'json',
        success: function (result) {
            csrfName = result.csrfName;
            csrfHash = result.csrfHash;
            if (result['error'] == false) {
                iziToast.success({
                    message: result['message'],
                });
            } else {
                iziToast.error({
                    message: result['message'],
                });
            }
        }
    });
});

//13.City-Module
$(document).on('click', '#delete-zipcode', function () {

    var id = $(this).data('id');
    Swal.fire({
        title: 'Are You Sure !',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    url: base_url + 'admin/Area/delete_zipcode',
                    type: 'GET',
                    data: { 'id': id },
                    dataType: 'json',
                })
                    .done(function (response, textStatus) {
                        if (response.error == false) {
                            Swal.fire('Deleted!', response.message, 'success');
                            $('table').bootstrapTable('refresh');
                        } else {
                            Swal.fire('Oops...', response.message, 'warning');
                        }
                    })
                    .fail(function (jqXHR, textStatus, errorThrown) {
                        Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                    });
            });
        },
        allowOutsideClick: false
    });
});

var search_tags = searchable_tags();

search_tags.on('select2:select', function (e) {
    var data = e.params.data;
    if (data.link != undefined && data.link != null) {
        window.location.href = data.link;
    }
});

var search_zipcodes = searchable_zipcodes();

search_zipcodes.on('select2:select', function (e) {
    var data = e.params.data;
    if (data.link != undefined && data.link != null) {
        window.location.href = data.link;
    }
});



$(document).on('click', '.remove_category_section', function () {
    $(this).closest('.row').remove();
});

$("#seller_table").on("click-cell.bs.table", function (field, value, row, $el) {
    $('input[name="seller_status"]').val($el.id);
});

$(document).on('submit', '#verify-acount-form', function (e) {
    e.preventDefault();
    var formdata = new FormData(this);
    formdata.append(csrfName, csrfHash);

    $.ajax({
        type: 'POST',
        url: $(this).attr('action'),
        data: formdata,
        beforeSend: function () {
            $('#submit_btn1').html('Please Wait..').attr('disabled', true);
        },
        cache: false,
        contentType: false,
        processData: false,
        dataType: "json",
        success: function (result) {
            csrfHash = result.csrfHash;
            $('#submit_btn1').html('Verify Account').attr('disabled', false);
            if (result.error == false) {
                if (result.redirect == "3") {
                    window.location.replace(base_url + 'partner/auth/sign_up');
                } else if (result.redirect == "1") {
                    iziToast.success({
                        message: '<span style="text-transform:capitalize">' + result.message + '</span> ',
                    });
                }

            } else {
                if (result.redirect == '2') {
                    window.location.replace(base_url + 'partner/auth/sign_up');
                }
                iziToast.error({
                    message: '<span>' + result.message + '</span> ',
                });
            }
            $('#verify-acount-form').trigger("reset");
            setTimeout(function () {
                $('#has_account_model').modal('hide');
            }, 3000);
        }
    });
});

$(document).on('click', '.update-partner-commission', function () {
    Swal.fire({
        title: 'Are You Sure !',
        text: "You won't be able to revert this!",
        type: 'info',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, settle commission!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    url: base_url + 'admin/cron-job/settle-partner-commission',
                    type: 'GET',
                    dataType: 'json',
                })
                    .done(function (response, textStatus) {
                        csrfName = response['csrfName'];
                        csrfHash = response['csrfHash'];
                        if (response.error == false) {
                            Swal.fire('Done!', response.message, 'success');
                            $('table').bootstrapTable('refresh');
                        } else {
                            Swal.fire('Oops...', response.message, 'warning');
                        }
                    })
                    .fail(function (jqXHR, textStatus, errorThrown) {
                        Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                    });
            });
        },
        allowOutsideClick: false
    });
});

var working_hours = "";

$("input[type=checkbox][name='not_working_days[]']").on('change', function () {
    if ($(this).filter(':checked').length == 1) {
        $(this).siblings('input[type=time]').prop('disabled', false);
    } else {
        $(this).siblings('input[type=time]').prop('disabled', true);
    }
});
function checkTime(stime, etime) {
    return Date.parse('01/01/1000 ' + stime) < Date.parse('01/01/1000 ' + etime)
}
function save_hours(params) {
    var availTuesday = [];
    var success = false;
    var time_validation = false;

    if ($("input[type=checkbox][name='not_working_days[]']:checked").length) {
        $("input[type=checkbox][name='not_working_days[]']:checked").each(function () {
            var day_name_openH = $(this).val() + 'FromH';
            var open_time = $('#' + day_name_openH).val();
            console.log("open time: " + open_time);
            if (open_time.length) {
                var day_name_closeH = $(this).val() + 'ToH';
                var close_time = $('#' + day_name_closeH).val();
                if (!checkTime(open_time, close_time)) {
                    time_validation = true;
                }
                availTuesday.push({
                    "day": $(this).val(),
                    "opening_time": open_time,
                    "closing_time": close_time,
                    "is_open": 1
                });
                $('input[name="working_time"]').val(JSON.stringify(availTuesday));
                success = false;
            } else {
                success = true;
            }
        });
        if (success) {
            iziToast.error({
                message: '<span style="text-transform:capitalize">Please, Select time for working day!</span> ',
            });
        }
        if (time_validation) {
            iziToast.error({
                message: '<span style="text-transform:capitalize">Please, Close time can not laser then open time! Set proper time</span> ',
            });
        }
    } else {
        iziToast.error({
            message: '<span style="text-transform:capitalize">Please, Select atleast one day for working!</span> ',
        });
    }
}
$(".hour ").on('input', function (event) {
    save_hours();
});
$(".closed ").on('input', function (event) {
    save_hours();
});
var add_on_data = [];
$("#save_add_ons").on('click', function (event) {
    var table_data = new Object();
    event.preventDefault();
    var title = $("#add_on_title").val();
    var des = $("#add_on_description").val();
    var price = $("#add_on_price").val();
    var calories = $("#add_on_calories").val();
    if (!title) {
        iziToast.error({
            message: '<span style="text-transform:capitalize">Please, enter Title for Add Ons!</span> ',
        });
        return false;
    }
    if (!price) {
        iziToast.error({
            message: '<span style="text-transform:capitalize">Please, enter Price for Add Ons!</span> ',
        });
        return false;
    }
    var is_exist = false;
    $.each(add_on_data, function (i, e) {
        if (e.title === title) {
            iziToast.error({
                message: `<span style="text-transform:capitalize">${title} is already in list!</span> `,
            });
            is_exist = true;
            return false;
        }
    });
    if (is_exist === false) {
        add_on_data.push({
            "title": $("#add_on_title").val(),
            "description": (des) ? $("#add_on_description").val() : "",
            "price": $("#add_on_price").val(),
            "calories": (calories) ? $("#add_on_calories").val() : "0",
            "status": 1
        });
        table_data.title = $("#add_on_title").val();
        table_data.description = (des) ? $("#add_on_description").val() : "";
        table_data.price = $("#add_on_price").val();
        table_data.calories = (calories) ? $("#add_on_calories").val() : "0";

        $('#saved_add_ons_table').bootstrapTable('insertRow', {
            index: 0,
            row: table_data
        })

        $("#add_on_title").val("");
        $("#add_on_description").val("");
        $("#add_on_price").val("");
        $("#add_on_calories").val("");
        $('input[name="product_add_ons"]').val(JSON.stringify(add_on_data));
        iziToast.success({
            message: '<span style="text-transform:capitalize">Add Ons Saved Successfully!</span> ',
        });
    }
});
$(document).on('click', '.remove-add-ons', function (event) {
    event.preventDefault();
    var save_data = [];
    var titles = $.map($("#saved_add_ons_table").bootstrapTable('getSelections'), function (row) {
        return row.title
    });
    $("#saved_add_ons_table").bootstrapTable('remove', {
        field: 'title',
        values: titles
    });
    var final_data = $("#saved_add_ons_table").bootstrapTable('getData');
    $.each(final_data, function (i, e) {
        save_data.push({
            "title": e.title,
            "description": (e.description) ? e.description : "",
            "price": e.price,
            "calories": (e.calories) ? e.calories : "0",
            "status": 1
        });
    });
    $('input[name="product_add_ons"]').val(JSON.stringify(save_data));
});

$('#add_ons_table').on('check.bs.table', function (e, row) {
    $("#add_on_title").val(row.title);
    $("#add_on_description").val(row.description);
    $("#add_on_price").val(row.price);
    $("#add_on_calories").val(row.calories);
    $('input[name="add_on_id"]').val(row.id);
});

$(document).on('click', '#update_add_ons', function () {

    var add_on_id = $('input[name="add_on_id"]').val();
    var title = $("#add_on_title").val();
    var des = $("#add_on_description").val();
    var price = $("#add_on_price").val();
    var calories = $("#add_on_calories").val();
    var product_id = $(this).data('product_id');

    Swal.fire({
        title: 'Are You Sure !',
        text: "You won't be able to revert this!",
        type: 'info',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, Update it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    url: base_url + from + '/product/update_add_ons',
                    type: 'POST',
                    data: { 'add_on_id': add_on_id, 'title': title, 'product_id': product_id, "description": des, "price": price, "calories": calories, [csrfName]: csrfHash },
                    dataType: 'json',
                })
                    .done(function (response, textStatus) {
                        csrfName = response['csrfName'];
                        csrfHash = response['csrfHash'];
                        if (response.error == false) {
                            Swal.fire('Done!', response.message, 'success');
                            $('table').bootstrapTable('refresh');
                            $("#add_on_title").val("");
                            $("#add_on_description").val("");
                            $("#add_on_price").val("");
                            $("#add_on_calories").val("");
                        } else {
                            Swal.fire('Oops...', response.message, 'warning');
                        }
                    })
                    .fail(function (jqXHR, textStatus, errorThrown) {
                        Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                    });
            });
        },
        allowOutsideClick: false
    });
});
$(document).on('click', '#add_new_add_ons', function (e) {
    e.preventDefault();
    var title = $("#add_on_title").val();
    var des = $("#add_on_description").val();
    var price = $("#add_on_price").val();
    var calories = $("#add_on_calories").val();
    var product_id = $(this).data('product_id');

    Swal.fire({
        title: 'Are You Sure !',
        text: "You won't be able to revert this!",
        type: 'info',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, Insert it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    url: base_url + from + '/product/update_add_ons',
                    type: 'POST',
                    data: { 'title': title, 'product_id': product_id, "description": des, "price": price, "calories": calories, [csrfName]: csrfHash },
                    dataType: 'json',
                })
                    .done(function (response, textStatus) {
                        csrfName = response['csrfName'];
                        csrfHash = response['csrfHash'];
                        if (response.error == false) {
                            Swal.fire('Done!', response.message, 'success');
                            $('table').bootstrapTable('refresh');
                            $("#add_on_title").val("");
                            $("#add_on_description").val("");
                            $("#add_on_price").val("");
                            $("#add_on_calories").val("");
                        } else {
                            Swal.fire('Oops...', response.message, 'warning');
                        }
                    })
                    .fail(function (jqXHR, textStatus, errorThrown) {
                        Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                    });
            });
        },
        allowOutsideClick: false
    });
});

$(document).on('change', '#restro_city', function () {
    var lat = $('#restro_city option:selected').data("latitude");
    var long = $('#restro_city option:selected').data("longitude");
    $("#latitude").val(lat);
    $("#longitude").val(long);
});

// get latitude and longitude for city
var map_search_type = [];
if (window.location.href.indexOf("admin/area/manage-cities") > -1) {
    map_search_type = ["(cities)"];
}

function initMap() {
    const map = new google.maps.Map(document.getElementById("map"), {
        center: {
            lat: 23.242001,
            lng: 69.666931
        },
        zoom: 13,
        mapTypeControl: true,
    });
    const input = document.getElementById("city-input");
    const options = {
        fields: ["formatted_address", "geometry", "name"],
        strictBounds: false,
        types: map_search_type,
    };

    const autocomplete = new google.maps.places.Autocomplete(input, options);

    // Bind the map's bounds (viewport) property to the autocomplete object,
    // so that the autocomplete requests use the current map bounds for the
    // bounds option in the request.
    autocomplete.bindTo("bounds", map);

    const infowindow = new google.maps.InfoWindow();
    const infowindowContent = document.getElementById("infowindow-content");

    infowindow.setContent(infowindowContent);

    const marker = new google.maps.Marker({
        map,
        anchorPoint: new google.maps.Point(0, -29),
    });

    autocomplete.addListener("place_changed", () => {
        infowindow.close();
        marker.setVisible(false);

        const place = autocomplete.getPlace();

        if (!place.geometry || !place.geometry.location) {
            // User entered the name of a Place that was not suggested and
            // pressed the Enter key, or the Place Details request failed.
            window.alert("No details available for input: '" + place.name + "'");
            return;
        }

        // If the place has a geometry, then present it on a map.
        if (place.geometry.viewport) {
            map.fitBounds(place.geometry.viewport);
        } else {
            map.setCenter(place.geometry.location);
            map.setZoom(5);
        }

        marker.setPosition(place.geometry.location);
        marker.setVisible(true);
        $('#city_lat').val(place.geometry.location.lat);
        $('#city_long').val(place.geometry.location.lng);
        $('#city_name').val(place.name);
        infowindowContent.children["place-name"].textContent = place.name;
        infowindowContent.children["place-address"].textContent =
            place.formatted_address;
        infowindow.open(map, marker);
    });

}


// set city outlines
var map; // Global declaration of the map
var lat_longs = new Array();
var markers = new Array();
var drawingManager;
var circle;
var circle_points = [];
function initMapBoundry() {
    var myLatlng = new google.maps.LatLng(23.242001, 69.666931);
    var myOptions = {
        zoom: 13,
        center: myLatlng,
        mapTypeId: google.maps.MapTypeId.ROADMAP
    }
    map = new google.maps.Map(document.getElementById("map-canvas"), myOptions);
    drawingManager = new google.maps.drawing.DrawingManager({
        drawingMode: google.maps.drawing.OverlayType.POLYGON,
        drawingControl: true,
        drawingControlOptions: {
            position: google.maps.ControlPosition.TOP_CENTER,
            drawingModes: [google.maps.drawing.OverlayType.POLYGON,
            google.maps.drawing.OverlayType.CIRCLE,]
        },
        polygonOptions: {
            editable: true,
        },
        circleOptions: {
            fillColor: '#666666',
            fillOpacity: 0.5,
            strokeWeight: 1,
            clickable: true,
            editable: true,
            draggable: true,
            zIndex: 1
        }
    });
    drawingManager.setMap(map);

    google.maps.event.addListener(drawingManager, "overlaycomplete", function (event) {
        var newShape = event.overlay;
        newShape.type = event.type;
    });

    google.maps.event.addListener(drawingManager, "overlaycomplete", function (event) {
        if (event.type == "circle") {
            circle_points = [];
            var radius = event.overlay.getRadius();
            var lat = event.overlay.getCenter().lat();
            var long = event.overlay.getCenter().lng();
            circle_points.push({
                "type": "circle",
                "radius": radius,
                "lat": lat,
                "long": long,
            });
            $('input[name="city_outlines"]').val(JSON.stringify(circle_points));
            $('#vertices').val(JSON.stringify(circle_points));

        } else {
            overlayClickListener(event.overlay);
            $('#vertices').val(event.overlay.getPath().getArray());
        }
    });
    google.maps.event.addListener(drawingManager, "overlaycomplete", function (event) {
        overlayRemoveListener(event.overlay, false,);
    });
}

function overlayClickListener(overlay) {
    google.maps.event.addListener(overlay, "mouseup", function (event) {
        $('#vertices').val(overlay.getPath().getArray());
    });
}
function overlayRemoveListener(overlay, is_restore = false, drawed_map = "", not_remove = false) {
    if (is_restore == true) {
        document.getElementById("add-line").addEventListener("click", addLine);
    }
    document.getElementById("clear-line").addEventListener("click", clearLine);
    if (not_remove == false) {
        document.getElementById("remove-line").addEventListener("click", removeLine);
    }
    function clearLine() {
        overlay.setMap(null);
        $('#vertices').val("");
    }
    function removeLine() {
        overlay.setMap(null);
        $('#vertices').val("");
    }
    function addLine() {
        if (drawed_map != "") {
            overlay.setMap(drawed_map);
        } else {
            overlay.setMap(map);
        }
    }
}
if (window.location.href.indexOf("admin/area/manage-city-outlines") > -1) {
    google.maps.event.addDomListener(window, 'load', initMapBoundry);
}


var map, marker;
var lat_longs = new Array();
var markers = new Array();
var drawingManager;
$(document).ready(function () {
    $('.target').on('change', function () {
        var coordinate = $('select option:selected').val().split(',');
        map.setCenter(new google.maps.LatLng(coordinate[0], coordinate[1]));
        let latLong = {
            lat: coordinate[0],
            lng: coordinate[1]
        };
        marker = new google.maps.Marker({
            position: {
                lat: parseFloat(coordinate[0]),
                lng: parseFloat(coordinate[1])
            },
            map: map,
        });

        marker.setVisible(true);
        var geolocation_type = $('select option:selected').data("geolocation_type");
        var radius = $('select option:selected').data("radius");
        var boundary_points = $('select option:selected').data("boundary_points");
        var json_points = JSON.stringify(boundary_points);
        $('#vertices').val(`Boundary Points : ${json_points}  Radius: ${radius}`);
        if (geolocation_type) {
            if (geolocation_type === "polygon") {
                var bermudaTriangle = new google.maps.Polygon({
                    paths: boundary_points,
                    strokeColor: '#FF0000',
                    strokeOpacity: 0.8,
                    strokeWeight: 2,
                    fillColor: '#FF0000',
                    fillOpacity: 0.35,
                    editable: true,
                    geodesic: true
                });
                bermudaTriangle.setMap(map);
                overlayRemoveListener(bermudaTriangle, true, map, true);
            } else if (geolocation_type === "circle") {
                const cityCircle = new google.maps.Circle({
                    strokeColor: "#FF0000",
                    strokeOpacity: 0.8,
                    strokeWeight: 2,
                    fillColor: "#FF0000",
                    fillOpacity: 0.35,
                    map,
                    center: boundary_points[0],
                    radius: Math.sqrt(radius) * 100,
                });
                overlayRemoveListener(cityCircle, true, map, true);
            }
        }

    });
});

function isJSON(something) {
    if (typeof something != 'string')
        something = JSON.stringify(something);
    try {
        JSON.parse(something);
        return true;
    } catch (e) {
        return false;
    }
}

$("#save_city").on('click', function (event) {
    event.preventDefault();
    var city_id = $('#city_id').find(':selected').data('city_id');
    var vertices = $('#vertices').val();
    var final_array = [];
    var geolocation_type = "";
    var radius = "";
    if (vertices && city_id) {
        if (isJSON(vertices) === true) {
            geolocation_type = "circle";
            var parse_json = JSON.parse(vertices);
            $.each(parse_json, function (index, item) {
                radius = item.radius;
                final_array.push({
                    "lat": parseFloat(item.lat),
                    "lng": parseFloat(item.long),
                });

            });
        } else {
            geolocation_type = "polygon";
            radius = "";
            var str1 = vertices.split("),");
            $.each(str1, function (index, item) {
                var str2 = item.replace("(", "");
                var str3 = str2.replace(")", "");
                final_array.push({
                    "lat": parseFloat(str3.split(",")[0]),
                    "lng": parseFloat(str3.split(",")[1]),
                });

            });
        }
        $('input[name="city_outlines"]').val(JSON.stringify(final_array));
        Swal.fire({
            title: 'Are You Sure !',
            text: "You won't be able to revert this!",
            type: 'info',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, Update it!',
            showLoaderOnConfirm: true,
            preConfirm: function () {
                return new Promise((resolve, reject) => {
                    $.ajax({
                        url: base_url + from + '/area/add_city',
                        type: 'POST',
                        data: { 'boundary_points': $('input[name="city_outlines"]').val(), 'edit_city': city_id, "radius": radius, "geolocation_type": geolocation_type, [csrfName]: csrfHash },
                        dataType: 'json',
                    })
                        .done(function (response, textStatus) {
                            csrfName = response['csrfName'];
                            csrfHash = response['csrfHash'];
                            if (response.error == false) {
                                Swal.fire('Done!', response.message, 'success');
                                $("#vertices").val("");
                                location.reload();
                            } else {
                                Swal.fire('Oops...', response.message, 'warning');
                            }
                        })
                        .fail(function (jqXHR, textStatus, errorThrown) {
                            Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                        });
                });
            },
            allowOutsideClick: false
        });


    } else {
        iziToast.error({
            message: '<span style="text-transform:capitalize">Please, Select city or its outlines!</span> ',
        });
    }
});

$(document).on('click', '.edit_attribute', function (e, rows) {
    e.preventDefault();
    var attribute_value_ids = $(this).data("attribute_value_ids");
    var attribute_values = $(this).data("attribute_values");
    $('#name').val($(this).data("name"));
    $('input[name="edit_attribute_id"]').val($(this).data("id"));
    $('#attribute_value').val(attribute_values);
    $('input[name="attribute_value_ids"]').val(attribute_value_ids);

    if (attribute_values.search(",") > 0) {
        var attribute_values = attribute_values.split(",");
        var attribute_value_ids = attribute_value_ids.split(",");
    } else {
        var attribute_values = [attribute_values];
        var attribute_value_ids = [attribute_value_ids];
    }
    if (attribute_values.length == attribute_value_ids.length) {
        $('#attribute_values_html').html("");
        show_attribute_values(attribute_values, attribute_value_ids);
    } else {
        iziToast.error({
            message: '<span style="text-transform:capitalize">Something went wrong!</span> ',
        });
    }
});

$(document).on('click', '#add_attribute_val', function (e) {
    e.preventDefault();
    show_attribute_values();
});

function show_attribute_values(attribute_values = [], attribute_value_ids = []) {
    var html = "";

    if (attribute_values.length > 0) {
        $.each(attribute_values, function (key, val) {
            html += `<div class="form-group row">
                        <div class="col-sm-10">
                            <input type="text" class="form-control" placeholder="Values Name" name="value_name[]" value="${val}">
                            <input type="hidden" class="form-control" name="value_id[]" value="${attribute_value_ids[key]}">
                        </div>
                        <div class="col-sm-2">
                        <button type="button" class="btn btn-tool update_attribute_values_status " data-id="${attribute_value_ids[key]}" data-table="attribute_values" > <i class="text-danger far fa-times-circle fa-2x "></i> </button>
                        </div>
                    </div>`;
        });
    } else {
        html = `<div class="form-group row">
                    <div class="col-sm-10">
                        <input type="text" class="form-control" placeholder="Values Name" name="value_name[]" value="">
                        <input type="hidden" class="form-control" name="value_id[]" value="">
                    </div>
                    <div class="col-sm-2">
                    <button type="button" class="btn btn-tool " > <i class="text-danger far fa-times-circle fa-2x "></i> </button>
                    </div>
                </div>`;
    }
    $('#attribute_values_html').append(html);
}

$(document).on('click', '.update_attribute_values_status', function () {
    var cat_id = $(this).data('id');
    $(this).closest('.row').remove();
    Swal.fire({
        title: 'Are You Sure!',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, Delete it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    type: 'GET',
                    url: base_url + from + '/attribute/update_attribute_values_status',
                    data: { id: cat_id },
                    dataType: 'json'
                })
                    .done(function (response, textStatus) {
                        if (response.error == false) {
                            Swal.fire('Deleted!', response.message, 'success');
                            $('table').bootstrapTable('refresh');
                            csrfName = response['csrfName'];
                            csrfHash = response['csrfHash'];
                        } else {
                            Swal.fire('Oops...', response.message, 'warning');
                            $('table').bootstrapTable('refresh');
                            csrfName = response['csrfName'];
                            csrfHash = response['csrfHash'];
                        }

                    })
                    .fail(function (jqXHR, textStatus, errorThrown) {
                        Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                        csrfName = response['csrfName'];
                        csrfHash = response['csrfHash'];
                    });
            });
        },
        allowOutsideClick: false
    });
});


$('#edit-attributes-form').on('submit', function (e) {
    e.preventDefault();
    var formdata = new FormData(this);
    formdata.append(csrfName, csrfHash);

    $.ajax({
        type: 'POST',
        url: $(this).attr('action'),
        data: formdata,
        beforeSend: function () {
            $('#edit_attribute_val').html('Please Wait..').attr('disabled', true);
        },
        cache: false,
        contentType: false,
        processData: false,
        dataType: "json",
        success: function (result) {
            csrfHash = result.csrfHash;
            $('#edit_attribute_val').html('Update Attribute').attr('disabled', false);
            $('table').bootstrapTable('refresh');
            if (result.error == false) {
                iziToast.success({
                    message: '<span style="text-transform:capitalize">' + result.message + '</span> ',
                });
            } else {
                iziToast.error({
                    message: '<span>' + result.message + '</span> ',
                });
            }
        }
    });
});

$(document).on('click', '#delete-restro-tag', function () {
    var id = $(this).data('id');
    Swal.fire({
        title: 'Are You Sure !',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    url: base_url + from + '/tag/delete_tag',
                    type: 'GET',
                    data: { 'id': id },
                    dataType: 'json',
                })
                    .done(function (response, textStatus) {
                        if (response.error == false) {
                            Swal.fire('Deleted!', response.message, 'success');
                            $('table').bootstrapTable('refresh');
                        } else {
                            Swal.fire('Oops...', response.message, 'warning');
                        }
                    })
                    .fail(function (jqXHR, textStatus, errorThrown) {
                        Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                    });
            });
        },
        allowOutsideClick: false
    });
});

$('#sign_up_restro_form').on('submit', function (e) {
    e.preventDefault();
    var formdata = new FormData(this);
    formdata.append(csrfName, csrfHash);

    $.ajax({
        type: 'POST',
        url: $(this).attr('action'),
        data: formdata,
        beforeSend: function () {
            $('#submit_btn').html('Please Wait..').attr('disabled', true);
        },
        cache: false,
        contentType: false,
        processData: false,
        dataType: "json",
        success: function (result) {
            csrfHash = result.csrfHash;
            $('#submit_btn').html('Register').attr('disabled', false);
            if (result.error == false) {
                iziToast.success({
                    message: '<span style="text-transform:capitalize">' + result.message + '</span> ',
                });
                setTimeout(function () { window.location.replace(base_url + 'partner/login'); }, 3000);
            } else {
                iziToast.error({
                    message: '<span>' + result.message + '</span> ',
                });
                setTimeout(function () { window.location.replace(base_url + 'partner/login'); }, 3000);
            }
        }
    });
});

$('#delivery_charge_method').on('change', function (e) {
    e.preventDefault();
    if (this.value == "fixed_charge") {
        $('#submit_btn').attr('disabled', false);
        $("#fixed_charge_input").show();
        $("#per_km_charge_input").hide();
        $("#range_wise_charges_input").hide();
        $("#per_km_charge_input").removeClass("d-none");
        $("#range_wise_charges_input").removeClass("d-none");
        $("#fixed_charge_input").removeClass("d-none");
        $("#range_wise_charges_input_btn").hide();
        $("#range_wise_charges_input_btn").removeClass("d-none");
    }
    if (this.value == "per_km_charge") {
        $('#submit_btn').attr('disabled', false);
        $("#per_km_charge_input").show();
        $("#per_km_charge_input").removeClass("d-none");
        $("#fixed_charge_input").hide();
        $("#fixed_charge_input").removeClass("d-none");
        $("#range_wise_charges_input").hide();
        $("#range_wise_charges_input").removeClass("d-none");
        $("#range_wise_charges_input_btn").hide();
        $("#range_wise_charges_input_btn").removeClass("d-none");
    }
    if (this.value == "range_wise_charges") {
        $('#submit_btn').attr('disabled', true);
        $("#range_wise_charges_input").show();
        $("#range_wise_charges_input").removeClass("d-none");
        $("#range_wise_charges_input_btn").show();
        $("#range_wise_charges_input_btn").removeClass("d-none");
        $("#fixed_charge_input").hide();
        $("#fixed_charge_input").removeClass("d-none");
        $("#per_km_charge_input").hide();
        $("#per_km_charge_input").removeClass("d-none");
    }
    if (!this.value) {
        $('#submit_btn').attr('disabled', false);
        $("#fixed_charge_input").hide();
        $("#fixed_charge_input").removeClass("d-none");
        $("#per_km_charge_input").hide();
        $("#per_km_charge_input").removeClass("d-none");
        $("#range_wise_charges_input").hide();
        $("#range_wise_charges_input").removeClass("d-none");
        $("#range_wise_charges_input_btn").hide();
        $("#range_wise_charges_input_btn").removeClass("d-none");
    }
});

$(document).on('change', '#commission_method', function (e) {
    e.preventDefault();
    if (this.value == "percentage_on_delivery_charges") {
        $("#percentage_on_delivery_charges_input").show();
        $("#percentage_on_delivery_charges_input").removeClass("d-none");
        $("#fixed_commission_per_order_input").hide();
    }
    if (this.value == "fixed_commission_per_order") {
        $("#fixed_commission_per_order_input").show();
        $("#fixed_commission_per_order_input").removeClass("d-none");
        $("#percentage_on_delivery_charges_input").hide();
    }
});

$("#save_charges").on('click', function (event) {
    var charges = [];
    var is_error = false;

    // get arrays for ranges
    var to_range = $("input[name='to_range[]']").map(function () {
        return $(this).val();
    }).get();
    var from_range = $("input[name='from_range[]']").map(function () {
        return $(this).val();
    }).get();

    var price = $("input[name='price[]']").map(function () {
        return $(this).val();
    }).get();

    // filter range array for validation
    var filter = from_range.filter(function (val) {
        return val != "";
    });

    if (filter == "") {
        iziToast.error({
            message: '<span style="text-transform:capitalize">Please, YOu can not set blank for range wise delivery charge system.</span> ',
        });
        is_error = true;
        return false;
    }

    for (let i = 0; i < filter.length; i++) {
        if (to_range[i] == null || from_range[i] == null || price[i] == null || from_range[i] == "" || price[i] == "" || to_range[i] == "") {
            iziToast.error({
                message: '<span style="text-transform:capitalize">Please, Set proper ranges and prices to setup the range wise charges.</span> ',
            });
            is_error = true;
            return false;
        }
    }
    if (is_error == false) {
        $("input[name='from_range[]']").each(function (e) {
            if ($(this).val() != "") {
                charges.push({
                    "from_range": $(this).val(),
                    "to_range": to_range[e],
                    "price": price[e]
                });
            }
        });

        if (typeof (charges) != "undefined" && charges !== null) {
            $('input[name="range_wise_charges"]').val(JSON.stringify(charges));
            iziToast.success({
                message: '<span style="text-transform:capitalize">Charges Saved</span> ',
            });
            $('#submit_btn').html('Submit').attr('disabled', false);
        } else {
            iziToast.error({
                message: '<span style="text-transform:capitalize">Please, Enter Proper Range for Charges !</span> ',
            });
        }
    }
});

window.actionEvents = {
    'click .edit-city': function (e, value, row, index) {
        $("#city_name").val(row.name);
        $("#edit_city").val(row.id);
        $("#city_lat").val(row.latitude);
        $("#city_long").val(row.longitude);
        $("#time_to_travel").val(row.time_to_travel);
        $("#max_deliverable_distance").val(row.max_deliverable_distance);
        $("#delivery_charge_method").val(row.delivery_charge_method);
        $("#delivery_charge_method").trigger('change');

        if (row.delivery_charge_method == "fixed_charge") {
            $("#fixed_charge").val(row.fixed_charge);
        }
        if (row.delivery_charge_method == "per_km_charge") {
            $("#per_km_charge").val(row.per_km_charge);
        }
        if (row.delivery_charge_method == "range_wise_charges") {
            $('#submit_btn').attr('disabled', true);
            var ranges = JSON.parse(row.range_wise_charges);
            var html = "";
            var j = 1;
            for (let i = 0; i < 10; i++, j++) {
                let from_range = (ranges[i] != null) ? ranges[i]['from_range'] : "";
                let to_range = (ranges[i] != null) ? ranges[i]['to_range'] : "";
                let price = (ranges[i] != null) ? ranges[i]['price'] : "";
                html += `<div class="form-group row">
                            <div>${j}</div>
                            <div class="col-sm-2">
                                <input type="number" class="form-control" name="from_range[]" id="from_range${i}" value='${from_range}' placeholder="From Range" min="0">
                            </div>
                            <div class="btn  btn-secondary">To</div>
                            <div class="col-sm-2">
                                <input type="number" class="form-control" name="to_range[]" id="to_range${i}" value='${to_range}' placeholder="To Range" min="0">
                            </div>
                            <div class="col-sm-4">
                                <input type="number" class="form-control" name="price[]" id="price${i}" value='${price}' placeholder="Price" min="0">
                            </div>
                        </div>`;
            }
            $("#range_wise_charges_input").html(html);
        }
    }
};

var d_boy_cash = 0;
$('#riders_details').on('check.bs.table', function (e, row) {
    d_boy_cash = row.cash_received;
    $('#details').val("Id: " + row.id + " | Name:" + row.name + " | Mobile: " + row.mobile + " | Cash: " + row.cash_received);
    $('#rider_id').val(row.id);
});

function validate_amount() {
    var cash = d_boy_cash;
    var amount = $('#amount').val();
    var details_val = $('#details').val();
    if (details_val == "") {
        iziToast.error({
            message: '<span>you have to select delivery boy to collect cash.</span> ',
        });
        $('#amount').val('');
    } else {
        if (parseInt(cash) > 0) {
            if (parseInt(amount) > parseInt(cash)) {
                iziToast.error({
                    message: '<span>You Can not enter amount greater than cash</span> ',
                });
                $('#amount').val('');
            }
            if (parseInt(amount) <= 0) {
                iziToast.error({
                    message: '<span>Amount must be greater than zero</span> ',
                });
                $('#amount').val('');
            }
        } else {
            iziToast.error({
                message: '<span>Cash must be greater than zero</span> ',
            });
            $('#amount').val('');
        }
    }
}

function idFormatter() {
    return 'Total'
}

function priceFormatter(data) {
    var field = this.field
    var store_currency = $('input[name="store_currency"]').val();

    return '<span style="color:green;font-weight:bold;font-size:large;">' + store_currency + data.map(function (row) {
        return +row[field]
    })
        .reduce(function (sum, i) {
            return sum + i
        }, 0);
}

$(document).on('click', '.order_request', function () {
    var order_id = $(this).data('id');
    var req_status = $(this).data('req_status');
    Swal.fire({
        title: 'Are You Sure!',
        text: "You won't be able to revert this!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, Confirmed!',
        showLoaderOnConfirm: true,
        preConfirm: function () {
            return new Promise((resolve, reject) => {
                $.ajax({
                    type: 'GET',
                    url: base_url + 'rider/orders/update_order_request',
                    data: { order_id: order_id, req_status: req_status },
                    dataType: 'json'
                })
                    .done(function (response, textStatus) {
                        if (response.error == false) {
                            Swal.fire('Deleted!', response.message, 'success');
                            $('table').bootstrapTable('refresh');
                            csrfName = response['csrfName'];
                            csrfHash = response['csrfHash'];
                        } else {
                            Swal.fire('Oops...', response.message, 'warning');
                            $('table').bootstrapTable('refresh');
                            csrfName = response['csrfName'];
                            csrfHash = response['csrfHash'];
                        }

                    })
                    .fail(function (jqXHR, textStatus, errorThrown) {
                        Swal.fire('Oops...', 'Something went wrong with ajax !', 'error');
                        csrfName = response['csrfName'];
                        csrfHash = response['csrfHash'];
                    });
            });
        },
        allowOutsideClick: false
    });
});

$(document).on('change', '#add_on_snaps', function (e) {
    e.preventDefault();
    var price = $(this).find(':selected').data('price');
    var description = $(this).find(':selected').data('description');
    var calories = $(this).find(':selected').data('calories');
    $('#add_on_title').val(this.value);
    $('#add_on_description').val(description);
    $('#add_on_price').val(price);
    $('#add_on_calories').val(calories);
}); 
