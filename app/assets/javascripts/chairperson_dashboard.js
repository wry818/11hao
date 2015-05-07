Raisy.chairperson_dashboard = {
    init: function() {
		  var _this = this;

			$("#chairperson_dashboard div.upload-button").on("mouseenter", function() {
			    $(this).toggleClass("upload-button-hover");
			}).on("mouseleave", function() {
			    $(this).toggleClass("upload-button-hover");
			}).on("click", function(){
				$('.cloudinary-fileupload').click();
			});

			$("#chairperson_dashboard .cloudinary-fileupload").off("cloudinarydone").on("cloudinarydone", function (e, data) {
				$(".status").text("");
				$(".progress").not(".camp-photo-progress").hide().find(".progress-bar").css("width", "0").find('span').text("");
				$("#drop-zone").css("border-color", "#ccc");
				var params = {
					// width: 400,
					// crop: "limit"
					angle: 'exif'
				};
				var html = $.cloudinary.image(data.result.public_id, params);
				_this.cropboxImage(html);
			});

			if ($(".campaign_bulkshippinginfo_form").length>0) {
				Raisy.chairperson_dashboard.bind_state_province(country_id);

				$("#country_id").change(function(){
					Raisy.chairperson_dashboard.bind_state_province($(this).val());
				});

				state_province_id=0;
			}

			$("#chairperson_dashboard #storefronts_organization_selector").select2().on("change", function(e) {
				window.location="/chairperson/storefronts" + (e.val==""? "": "?organization=" + e.val);
			});
			
			$("#chairperson_dashboard #sales_organization_selector").select2().on("change", function(e) {
				window.location="/chairperson/campaigns?cp=" + cp_param + (e.val==""? "": "&organization=" + e.val)
			});

			$("#sales_report_container #all_report_org_selector").select2().on("change", function(e) {
				$("#sales_report_container #activity_report_download_link").attr("href", 
				"/chairperson/sales_report_download?report=activity&organization=" +  e.val);

				$("#sales_report_container #sales_report_download_link").attr("href", 
					"/chairperson/sales_report_download?report=sales&organization=" + e.val);
				
				report=$("#sales_report_tabs li.active").data("report");

				if (report=="sales") Raisy.chairperson_dashboard.load_sales_report_content("sales", e.val);
				if (report=="activity") Raisy.chairperson_dashboard.load_sales_report_content("activity", e.val);
				
				$("#sales_report_tabs li a").data("loaded", "");
				$("#sales_report_tabs li.active a").data("loaded", "loaded");
			});

			$("#sales_report_container #sales_report_tabs").on('shown.bs.tab', function (e) {
				var loaded=$(e.target).data("loaded") || "";

				if (loaded=="") {
					$(e.target).data("loaded", "loaded");
					
					var report=$(e.target).data("report") || "";
					var org=$("#all_report_org_selector").select2("val");
					
					if (report=="sales") Raisy.chairperson_dashboard.load_sales_report_content("sales", org);
					if (report=="activity") Raisy.chairperson_dashboard.load_sales_report_content("activity", org);
				}
			});

			$("#sales_report_container #activity_report_download_link").attr("href", 
				"/chairperson/sales_report_download?report=activity&organization=");

			$("#sales_report_container #sales_report_download_link").attr("href", 
				"/chairperson/sales_report_download?report=sales&organization=");
				
	    $("#chairperson_dashboard div.use-button").on("mouseenter", function() {
	        $(this).toggleClass("use-button-hover");
	    }).on("mouseleave", function() {
	        $(this).toggleClass("use-button-hover");
	    }).on("click", function(){
				$("#use_ours_link").click();
	    });
			
			$("#chairperson_dashboard .default-campaign-image").click(function(){
				$("#campaign_logo").val($(this).data("image-id"));
				$("#close_use_ours").click();

				var params = {
				};

				if ($(this).data("cropped"))
				{
					params.x = $(this).data("crop-x");
					params.y = $(this).data("crop-y");
					params.width = $(this).data("crop-w");
					params.height = $(this).data("crop-h");
					params.crop = "crop";
				}

				var html = $.cloudinary.image($(this).data("public-id"), params);
				_this.cropboxImage(html);
			}).on("mouseenter", function() {
				$(this).toggleClass("default-campaign-image-hover");
			}).on("mouseleave", function() {
				$(this).toggleClass("default-campaign-image-hover");
			});
    },
	load_sales_report_content: function(report, organization) {
		$("#sales_report_container .sales_report_loader").show();
		
		if (report=="activity") {
			$("#sales_report_container #activity_report_download").hide();
			$("#sales_report_container #activity_report_conent").html("");
	 	}
		
		if (report=="sales") {
			$("#sales_report_container #sales_report_download").hide();
			$("#sales_report_container #sales_report_content").html("");
	 	}
		
		window.setTimeout(function(){
			$.ajax("/chairperson/sales_report_content", {
				type: 'GET',
				cache: false,
				data: { report: report, organization: organization },
	            beforeSend: function(jqXHR, settings) {
	                jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
	            },
	            success: function(data) {
					if (data && data.indexOf("report_content")>=0) {
						if (report=="activity") {
							$("#sales_report_container #activity_report_download").show();
							$("#sales_report_container #activity_report_conent").html(data);
					 	}
					
						if (report=="sales") {
							$("#sales_report_container #sales_report_download").show();
							$("#sales_report_container #sales_report_content").html(data);
					 	}
					}
	            },
	            error: function(XMLHttpRequest, textStatus, errorThrown) {
					msg='<div style="margin-top:40px; text-align:center;"><h4>Sorry, there was a problem while loading the report.</h4></div>';
					
					if (report=="activity") {
						$("#sales_report_container #activity_report_conent").html(msg);
				 	}
				
					if (report=="sales") {
						$("#sales_report_container #sales_report_content").html(msg);
				 	}
	            },
				complete: function () {
					$("#sales_report_container .sales_report_loader").hide();
				}
			});
		}, 50);
	},
	download_sales_report: function(report, organization) {
		
	},
	cropboxImage: function(html) {
		var crop = $("#chairperson_dashboard .preview img").data('cropbox');
		
		if (crop)
			crop.remove();
		
		var documentWidth = $(document.body).width();
		var cropWidth;
		var cropHeight;
		
		if (documentWidth > 768) {

			cropWidth = 622;
			cropHeight = 200;

		} else if (documentWidth > 468) {

			cropWidth = 400;
			cropHeight = 128;

		} else {

			cropWidth = 280;
			cropHeight = 90;

		}
		
 		$("#chairperson_dashboard .preview img").fadeOut(200, function() {
			$('#chairperson_dashboard .preview').html(html);
	
			$('#chairperson_dashboard .preview img').removeAttr("width").removeAttr("height").cropbox({
				width: cropWidth,
				height: cropHeight,
				//controls: '<div class="cropControls"><span style="width:100%;">拖拉图片调整位置</span></div>',
				showControls: 'always'
		  }).on('cropbox', function(e, data) {
				$("#logo_crop_x").val(data.cropX);
				$("#logo_crop_y").val(data.cropY);
				$("#logo_crop_w").val(data.cropW);
				$("#logo_crop_h").val(data.cropH);
		
				$("#crop_result").text(JSON.stringify(data));
		  });
	
			isuploadCampaignPhoto = true;
	
  	}).fadeIn(200);
	},
	show_order_detail: function(anchor) {
		$('#order_detail_modal .modal-body').html('<div style="text-align:center;"><h4>Loading ...</h4><span class="loader loader-black"></span></div>');
		$('#order_detail_modal').modal('show');
		
		window.setTimeout(function(){
	        $.ajax($(anchor).data("url"), {
	            type: 'GET',
	            beforeSend: function(jqXHR, settings) {
	                jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
	            },
	            success: function(data) {
					if (data && data.indexOf("order_detail")>=0) {
						$('#order_detail_modal .modal-body').html(data);
					}
					else {
						$('#order_detail_modal .modal-body').html('<div style="text-align:center;">没有找到相关记录</div>');
					}
	            },
	            error: function(XMLHttpRequest, textStatus, errorThrown) {
					$('#order_detail_modal .modal-body').html('<div style="text-align:center;">抱歉，加载订单明细的时候出了问题，请稍好再试</div>');
	            },
				complete: function () {
				}
	        });
		}, 50);
	},
	bind_state_province: function(country_id){
		$("#state_province_id").empty();

		//$('<option value="">-- Please Select --</option>').appendTo($("#product_category_id"));
		
		//var options = "";
		$(state_provinces).each(function(){
			if (this.country_id.toString()==country_id.toString())
			{
				var option="<option value='" + this.id.toString() + "'";
			
				if (this.id==state_province_id)
					option+=" selected";
			
				option+=">" + this.name + "</option>";
				//options += option;
				
				$(option).appendTo($("#state_province_id"));
			}
		});
		
		//$("#state_province_id").html(options);
	},
	submit_bulk_order: function(btn) {
		var dd=$("#campaign_bulkshippinginfo_delivery_date").val();
		var lb=$("#lb_delivery_date_error");
		var container=lb.closest(".form-group");
		var can_continue=true;
		
		if (dd=="") {
			lb.text("Please select a delivery date").show();
			container.addClass("has-error");
			can_continue=false;
		}
		
		if (new Date(dd)<minDeliveryDate) {
			lb.text("Please select a deliverable date").show();
			container.addClass("has-error");
			can_continue=false;
		}
		
		var dt=$("#campaign_bulkshippinginfo_delivery_time").val();
		var lb_dt=$("#lb_delivery_time_error");
		var container_dt=lb_dt.closest(".form-group");
		
		if (dt=="") {
			lb_dt.text("Please select a delivery time").show();
			container_dt.addClass("has-error");
			can_continue=false;
		}
		
		if (!can_continue) return;
		
		lb.hide();
		container.removeClass("has-error");
		lb_dt.hide();
		container_dt.removeClass("has-error");
		
		if (!confirm("This order can only be submitted one time. Are you sure you want to submit this order?")) return;
		
		$("#bulk_submit_order").val("1");
		$("#bulk_submit_order").closest("form").submit();
	}
}
