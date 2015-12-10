window.Raisy_admin_products = {
	init: function(){
		if ($(".product_form").length>0) {
			window.Raisy_admin_products.saveCollectionCategoryIDs(
				".init-prod-collection", ".init-prod-category");
				
			$('#collection_modal').on('hide.bs.modal', function (e) {
				window.Raisy_admin_products.saveCollectionCategoryIDs(
					".prod-collection:checked", ".prod-category:checked");
			});
		}
		
		if ($("#og_property_table").length>0) {
			window.Raisy_admin_products.draw_og_property_table();
			window.Raisy_admin_products.bind_option_group_oprs();
		}
		
    $('#upload_product_more_photo').fileupload({
        forceIframeTransport: true,	// To work with IE under 10, use iframe always and do some tricks
        add: function (e, data) {
            data.submit();
        },
        start: function (e) {
					$(".product-photo-status").text("上传中，请稍候...");
        },
        progress: function (e, data) {
            
        },
        done: function (e, data) {
            $(".product-photo-status").text("");

            var txt = $(data.result[0].body).text();	// Thanks to IE, work became so ugly

            // Upload#save action returns filename+'upload.done' to indicate a successful uploading
            if (txt.indexOf("upload.done") > 0) {
                var txt = txt.replace("upload.done", "");
                var json = JSON.parse(txt);
								
                var params = {
                    angle: "exif",
										width: 97,
										height: 94,
										crop: "limit"
                };

                var url = $.cloudinary.url(json.public_id, params);
								var html="<div class=\"product-more-photo\" data-public-id=\"" + json.public_id + "\""
									+ "style=\"float:left; margin-right:20px; position:relative; width:100px;\">" 
									+ "<img src=\"" + url + "\" class=\"img-responsive\">" 
									+ "<div onclick=\"$(this).closest('.product-more-photo').remove();\""
									+ "style=\"position:absolute; top:-5px; right:1px; cursor:pointer;\">"
									+ "<span class=\"glyphicon glyphicon-remove\"></span></div>"
									+ "<input type=\"hidden\" name=\"more_photo_public_id[]\" value=\"" + json.public_id + "\"></div>";
									
								$(html).appendTo($("#product_more_photo_container"));
            }
            else {
                $(".product-photo-status").text("抱歉! 上传失败，请稍后再试");
            }
        },
        fail: function (e, data) {
            // No longer triggered when using iframe as it always get back the response, even if 404 or 500
            // which will be considered as errors when using XHR

            $(".product-photo-status").text("抱歉! 上传失败，请稍后再试");
        }
    });
	},
	submitOptionGroupForm: function(form) {
		window.Raisy_admin_products.destroy_og_property_table();
		
		// Save property values to input controls before submitting
		$("#og_property_table .og-property-row").each(function(){
			var row=$(this);
			
			row.find(".og-property-value-input").first().val(row.find(".og-property-value-text").first().text());
			row.find(".og-property-price-input").first().val(row.find(".og-property-price-text").first().text());
			row.find(".og-property-donation-input").first().val(row.find(".og-property-donation-text").first().text());
			row.find(".og-property-order-input").first().val(row.find(".og-property-order-text").first().text());
			row.find(".og-property-sku-input").first().val(row.find(".og-property-sku-text").first().text());
		});
		
		form.submit();
	},
	destroy_og_property_table: function() {
		return;
		
		$("#og_property_table").DataTable().destroy();
	},
	draw_og_property_table: function() {
		return;
		
		$("#og_property_table").dataTable({
			"ordering": false,
			"info": false,
			"searching": false,
			"bLengthChange": false,
			"pageLength": 2
		});
	},
	bind_option_group_oprs: function() {
		$("#og_property_table .og-property-edit").off("click").on("click", function(){
			window.Raisy_admin_products.edit_option_group_property(this);
		});
		
		$("#og_property_table .og-property-delete").off("click").on("click", function(){
			window.Raisy_admin_products.delete_option_group_property(this);
		});
		
		$("#og_property_table .og-property-save").off("click").on("click", function(){
			window.Raisy_admin_products.save_option_group_property(this);
		});
		
		$("#og_property_table .og-property-cancel").off("click").on("click", function(){
			window.Raisy_admin_products.cancel_option_group_property(this);
		});
		
		$("#og_property_table .og-property-arrow-up").off("click").on("click", function(){
			window.Raisy_admin_products.og_property_swap_row(this, "up");
		});
		
		$("#og_property_table .og-property-arrow-down").off("click").on("click", function(){
			window.Raisy_admin_products.og_property_swap_row(this, "down");
		});
	},
	edit_option_group_property: function(btn) {
		var row=$(btn).closest(".og-property-row");
		
		row.find(".og-property-value-input").first().val(row.find(".og-property-value-text").first().text());
		row.find(".og-property-price-input").first().val(row.find(".og-property-price-text").first().text().replace(/,/g, ""));
		row.find(".og-property-donation-input").first().val(row.find(".og-property-donation-text").first().text().replace(/,/g, ""));
		row.find(".og-property-order-input").first().val(row.find(".og-property-order-text").first().text());
		row.find(".og-property-sku-input").first().val(row.find(".og-property-sku-text").first().text());
		
		row.find(".og-property-cell").removeClass("has-error");
		
		row.find(".og-property-text").hide();
		row.find(".og-property-oprs1").hide();
		row.find(".og-property-input").show();
		row.find(".og-property-oprs2").show();
		
		window.Raisy_admin_products.hide_og_property_arrow();
	},
	add_option_group_property: function() {
		if ($("#og_property_table .og-property-new-row").length>0) return;
		
		window.Raisy_admin_products.destroy_og_property_table();
		
		var td_sku="";
		var td_qty_inventory="";
		
		if ($("#og_property_table .th-sku").length>0) {
			td_sku='<td class="og-property-cell og-property-sku-cell">' + 
				'<span class="og-property-text og-property-sku-text"></span>' + 
				'<input name="properties[][sku]" type="text" class="form-control og-property-input og-property-sku-input" value="" maxlength="50">' + 
				'</td>';
		}
		
		if ($("#og_property_table .th-qty").length>0) {
			td_qty_inventory='<td class="og-property-qty-cell"><span class="og-property-qty-text"></span></td>' + 
				'<td class="og-property-qty-cell"><span class="og-property-inv-text"></span></td>';
		}
		
		var html='<tr class="og-property-row og-property-new-row" style="display:none;">' + 
			'<td class="og-property-cell og-property-name-cell">' + 
				'<span class="og-property-text og-property-value-text"></span>' + 
				'<input name="properties[][id]" type="hidden" class="og-property-id" value="">' + 
				'<input name="properties[][value]" type="text" class="form-control og-property-input og-property-value-input" value="" maxlength="100">' + 
			'</td>' + 
			'<td class="og-property-cell og-property-price-cell">' + 
				'<span class="og-property-text">￥</span><span class="og-property-text og-property-price-text"></span>' + 
            	'<div class="og-property-input"><div class="input-group">' + 
                	'<span class="input-group-addon">￥</span>' + 
                	'<input name="properties[][price]" type="text" class="form-control og-property-price-input" value="" maxlength="10">' + 
            	'</div></div>' + 
			'</td>' + 
			'<td class="og-property-cell og-property-donation-cell">' + 
				'<span class="og-property-text">￥</span><span class="og-property-text og-property-donation-text"></span>' + 
            	'<div class="og-property-input"><div class="input-group">' + 
                	'<span class="input-group-addon">￥</span>' + 
               		'<input name="properties[][donation]" type="text" class="form-control og-property-donation-input" value="" maxlength="10">' + 
            	'</div></div>' + 
			'</td>' + 
			'<td class="og-property-cell og-property-order-cell">' + 
				'<span class="og-property-text og-property-order-text"></span>' + 
				'<input name="properties[][order]" type="text" class="form-control og-property-input og-property-order-input" value="" maxlength="10">' + 
			'</td>' + 
			td_sku + td_qty_inventory + 
			'<td class="og-property-arrow-cell"><span class="glyphicon glyphicon-arrow-up og-property-arrow og-property-arrow-up og-property-hidden-arrow"></td>' + 
			'<td class="og-property-arrow-cell"><span class="glyphicon glyphicon-arrow-down og-property-arrow og-property-arrow-down og-property-hidden-arrow"></td>' + 
			'<td class="og-property-opr-cell">' + 
				'<a class="og-property-opr og-property-oprs1 og-property-edit">编辑</a>' + 
				'<a class="og-property-opr og-property-oprs2 og-property-save">保存</a>' + 
			'</td>' + 
			'<td class="og-property-opr-cell">' + 
				'<a class="og-property-opr og-property-oprs1 og-property-delete">删除</a>' + 
				'<a class="og-property-opr og-property-oprs2 og-property-cancel">取消</a>' + 
			'</td>' +
			'</tr>';
			
		
		$("#og_property_table tbody").prepend(html);
		
		var row=$("#og_property_table").find(".og-property-new-row").first();
		
		row.find(".og-property-text").hide();
		row.find(".og-property-oprs1").hide();
		row.find(".og-property-input").show();
		row.find(".og-property-oprs2").show();
		
		row.show();
		
		window.Raisy_admin_products.bind_option_group_oprs();
		window.Raisy_admin_products.hide_og_property_arrow();
		window.Raisy_admin_products.draw_og_property_table();
	},
	save_option_group_property: function(btn) {
		window.Raisy_admin_products.destroy_og_property_table();
		
		var row=$(btn).closest(".og-property-row");
		var value=$.trim(row.find(".og-property-value-input").first().val() || "");
		var price=$.trim(row.find(".og-property-price-input").first().val() || "");
		var donation=$.trim(row.find(".og-property-donation-input").first().val() || "");
		var order=$.trim(row.find(".og-property-order-input").first().val() || "");
		var sku=$.trim(row.find(".og-property-sku-input").first().val() || "");
		var is_valid=true;
		
		row.find(".og-property-cell").removeClass("has-error");
		
		if (value=="") {
			is_valid=false;
			row.find(".og-property-name-cell").addClass("has-error");
		}
		
		if (price=="" || !$.isNumeric(price) || parseInt(price)<0) {
			is_valid=false;
			row.find(".og-property-price-cell").addClass("has-error");
		}
		
		if (donation!="" && (!$.isNumeric(donation) || parseInt(donation)<0)) {
			is_valid=false;
			row.find(".og-property-donation-cell").addClass("has-error");
		}
		
		if (order=="" || !$.isNumeric(order) || parseInt(order)<0) {
			is_valid=false;
			row.find(".og-property-order-cell").addClass("has-error");
		}
		
		if (sku=="" && row.find(".og-property-sku-input").length>0) {
			is_valid=false;
			row.find(".og-property-sku-cell").addClass("has-error");
		}
		
		if (!is_valid) return;
		
		price=parseFloat(price).toFixed(2).toString();
		order=parseInt(order).toString();
		
		if (donation=="") donation="0.00"; else donation=parseFloat(donation).toFixed(2).toString();
		
		row.find(".og-property-value-text").first().text(value);
		row.find(".og-property-price-text").first().text(price);
		row.find(".og-property-donation-text").first().text(donation);
		row.find(".og-property-order-text").first().text(order);
		row.find(".og-property-sku-text").first().text(sku);
		
		row.find(".og-property-input").hide();
		row.find(".og-property-oprs2").hide();
		row.find(".og-property-text").show();
		row.find(".og-property-oprs1").show();
		
		row.removeClass("og-property-new-row");
		
		window.Raisy_admin_products.show_og_property_arrow();
		window.Raisy_admin_products.draw_og_property_table();
	},
	delete_option_group_property: function(btn) {
		var confirmed=true;
		var row=$(btn).closest(".og-property-row");
		
		if (!row.hasClass("og-property-new-row")) {
			confirmed=confirm("Are you sure that you want to delete this property?")
		}
		
		if (!confirmed) return;
		
		window.Raisy_admin_products.destroy_og_property_table();
		
		row.hide();
		row.remove();
		
		window.Raisy_admin_products.show_og_property_arrow();
		window.Raisy_admin_products.draw_og_property_table();
	},
	cancel_option_group_property: function(btn) {
		window.Raisy_admin_products.destroy_og_property_table();
		
		var row=$(btn).closest(".og-property-row");
		
		if (row.hasClass("og-property-new-row")) {
			row.hide();
			row.remove();
		}
		else
		{
			row.find(".og-property-input").hide();
			row.find(".og-property-oprs2").hide();
			row.find(".og-property-text").show();
			row.find(".og-property-oprs1").show();
		}
		
		window.Raisy_admin_products.show_og_property_arrow();
		window.Raisy_admin_products.draw_og_property_table();
	},
	hide_og_property_arrow: function() {
		$("#og_property_table .og-property-qty-cell").hide();
		//$("#og_property_table .og-property-arrow-cell").hide();
	},
	show_og_property_arrow: function() {
		$("#og_property_table .og-property-qty-cell").show();
		
		return;
		
		var first_arrow=$("#og_property_table .og-property-row").first().find(".og-property-arrow-up");
		var last_arrow=$("#og_property_table .og-property-row").last().find(".og-property-arrow-down");
		
		$("#og_property_table .og-property-arrow").removeClass("og-property-hidden-arrow");
		$("#og_property_table .og-property-qty-cell").show();
		$("#og_property_table .og-property-arrow-cell").show();
		
		first_arrow.addClass("og-property-hidden-arrow");
		last_arrow.addClass("og-property-hidden-arrow");
	},
	og_property_swap_row: function(btn, direction) {
		var row=$(btn).closest(".og-property-row");
		var swap_row=(direction=="up" ? row.prev().first() : row.next().first());
		
		if (swap_row.length==1) {
			id=row.find(".og-property-id").first().val();
			value=row.find(".og-property-value-text").first().text();
			price=row.find(".og-property-price-text").first().text();
			donation=row.find(".og-property-donation-text").first().text();
			sku=row.find(".og-property-sku-text").first().text();
			qty=row.find(".og-property-qty-text").first().text();
			inv=row.find(".og-property-inv-text").first().text();
			
			swap_id=swap_row.find(".og-property-id").first().val();
			swap_value=swap_row.find(".og-property-value-text").first().text();
			swap_price=swap_row.find(".og-property-price-text").first().text();
			swap_donation=swap_row.find(".og-property-donation-text").first().text();
			swap_sku=swap_row.find(".og-property-sku-text").first().text();
			swap_qty=swap_row.find(".og-property-qty-text").first().text();
			swap_inv=swap_row.find(".og-property-inv-text").first().text();
			
			row.find(".og-property-id").first().val(swap_id);
			row.find(".og-property-value-text").first().text(swap_value);
			row.find(".og-property-price-text").first().text(swap_price);
			row.find(".og-property-donation-text").first().text(swap_donation);
			row.find(".og-property-sku-text").first().text(swap_sku);
			row.find(".og-property-qty-text").first().text(swap_qty);
			row.find(".og-property-inv-text").first().text(swap_inv);
			
			swap_row.find(".og-property-id").first().val(id);
			swap_row.find(".og-property-value-text").first().text(value);
			swap_row.find(".og-property-price-text").first().text(price);
			swap_row.find(".og-property-donation-text").first().text(donation);
			swap_row.find(".og-property-sku-text").first().text(sku);
			swap_row.find(".og-property-qty-text").first().text(qty);
			swap_row.find(".og-property-inv-text").first().text(inv);
		}
	},
	saveCollectionCategoryIDs: function(col_class, category_class){
		var collection_ids="";
		var category_ids="";
					
		$(col_class).each(function(){
			collection_ids+=$(this).data("value")+",";
		});
		
		$(category_class).each(function(){
			category_ids+=$(this).data("value")+",";
		});
		
		if (collection_ids!="") collection_ids=collection_ids.substring(0, collection_ids.length-1);
		if (category_ids!="") category_ids=category_ids.substring(0, category_ids.length-1);
		
		$("#product_collection_id").val(collection_ids);
		$("#product_category_id").val(category_ids);
	}
}

$(function () {
    $('select#select_product_category_id').bind('change',function(){
        ajax_load_subclass();
    })

});
function ajax_load_subclass()
{
    var id=$('select#select_product_category_id option:selected').val();
    if(id)
    {
        var url='/admin/product_categories/'+id+"/product_categories/ajax/select";
        $.get(url,function(result){
            $('select#pro_cat_subclass_id').children().remove();
            $('select#pro_cat_subclass_id').append(result);
        });
    }
    else
    {
        var op=$('select#pro_cat_subclass_id').children()[0]
        $('select#pro_cat_subclass_id').children().remove();
        $('select#pro_cat_subclass_id').append(op);
    }

}