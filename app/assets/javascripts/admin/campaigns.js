window.Raisy_admin_campaigns = {
    minilogo_data_cropper:{ischage:false,x:0,y:0,height:0,width:0, scaleX:0,scaleY:0,filename:""},
	init:function() {
		
		var _this = this;
		
	    $("#campaigns div.upload-button").on("mouseenter", function() {
	        $('div.upload-button').toggleClass("use-button-hover");	//upload-button-hover
	    }).on("mouseleave", function() {
	        $('div.upload-button').toggleClass("use-button-hover");
	    }).on("click", function(){
	    	$('.cloudinary-fileupload').click();
	    });
		
		$("#campaigns .cloudinary-fileupload").off("cloudinarydone").on("cloudinarydone", function (e, data) {
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
		
		$(document).on('dragover', function (e) { 
		    e.preventDefault();
			$("#drop-zone").css("border-color", "green");
		}).on('dragleave', function(e) {
	        $("#drop-zone").css("border-color", "#ccc");
	    }).bind("drop", function(e) {
		    e.preventDefault();
			$("#drop-zone").css("border-color", "#ccc");
	    });
		
		$(".campaign-photo-remove").click(function(){ 
			$(this).parents(".campaign-photo-instance").first().fadeOut(200,function(){
				$(this).remove();
				
				var ids = ",";
		
				$(".campaign-photo-instance").each(function(){
					ids += ($(this).data("public-id") || "") + ",";
				})
		
				$("#campaign_photo_ids").val(ids);
										
				$("#upload_camp_photo_button").fadeIn(200);
			});
		});
		
		$(".add-campaign-photo").mouseenter(function(){
			$(this).css("background-color","rgb(235,235,235)");
		}).mouseleave(function(){
			$(this).css("background-color","rgb(245,245,245)");
		});
		
		$("#upload_camp_photo_container").find("img").first().data("default-src", 
			$("#upload_camp_photo_container").find("img").first().attr("src"));
		
		$("#upload_camp_photo_button").click(function(){
			var $button=$(this);
			
			if ($button.data("uploaded")=="yes")
			{
				// Crop done 
				$button.data("uploaded","no").find("span").text("上传");
				
				$("#upload_camp_photo_container").find("img").first().fadeOut(200, function(){
					var public_id=$("#upload_camp_photo_container").data("public-id");
					
					$("#crop_result_"+public_id).val($("#upload_camp_photo_crop").val());
					
					var crop = $(this).data('cropbox');

					if (crop) crop.remove();
					
					$(this).css("margin-top","50px").attr("src", $(this).data("default-src")).fadeIn(200);
					
					// Add this photo to current
					var photo=$(".campaign-photo-template").clone();
					photo.removeClass("campaign-photo-template").addClass("campaign-photo-instance");
					photo.data("public-id", public_id);
					
					photo.insertBefore(".add-camp-photo-li").fadeIn(200, function(){
						var json=JSON.parse($("#crop_result_"+public_id).val());
			        	var params = {
							width: json.cropW,
							height: json.cropH,
							x: json.cropX,
							y: json.cropY,
							crop: "crop",
							angle: 'exif'
			        	};
						
			        	var url = $.cloudinary.url(public_id, params);
						
						photo.find("img").first().attr("src", url);
						
						if ($(".campaign-photo-instance").length>=9) $("#upload_camp_photo_button").fadeOut(200);
						
						var ids = ",";

						$(".campaign-photo-instance").each(function(){
							ids += ($(this).data("public-id") || "") + ",";
						});

						$("#campaign_photo_ids").val(ids);
						
						photo.find(".campaign-photo-remove").click(function(){
							$(this).parents(".campaign-photo-instance").first().fadeOut(200,function(){
								$(this).remove();
				
								var ids = ",";
		
								$(".campaign-photo-instance").each(function(){
									ids += ($(this).data("public-id") || "") + ",";
								});
		
								$("#campaign_photo_ids").val(ids);
				
								$("#upload_camp_photo_button").fadeIn(200);
							});
						});
					});		
				});
			}
			else
			{
				$('#add_camp_photo_upload').click();
			}
		});
		
		$('#add_camp_photo_upload').fileupload({
			forceIframeTransport: true,	// To work with IE under 10, use iframe always and do some tricks
	        add: function(e, data) {
				$('.add-campaign-photo .fa-spin').show();
				
				data.submit();
	        },
	        start: function (e) {
				$(".camp-photo-status").text("");
				$(".camp-photo-progress").hide().find(".camp-photo-progress-bar").css("width", "0").find('span').text("0%");
	            $(".camp-photo-progress").show();
	        },
	        progress: function (e, data) {
	            var prog = Math.round((data.loaded * 100.0) / data.total);
	            $(".camp-photo-status").text("上传中，请稍候...");
	            $(".camp-photo-progress-bar").css("width", prog + "%").find('span').text(prog + "%");
	        },
	        done: function (e, data) {
				$('.add-campaign-photo .fa-spin').hide();
		        $(".camp-photo-status").text("");
		        $(".camp-photo-progress").hide().find(".camp-photo-progress-bar").css("width", "0").find('span').text("");
				
				var txt=$(data.result[0].body).text();	// Thanks to IE, work became so ugly
		        
				// Upload#save action returns filename+'upload.done' to indicate a successful uploading
				if (txt.indexOf("upload.done")>0)
				{
					var txt=txt.replace("upload.done","");
					var json=JSON.parse(txt);
					
					$("<div/>").text(txt).appendTo("#more_photo_result");
					
        	var params = {
						angle: "exif"
        	};
			
        	var url = $.cloudinary.url(json.public_id, params);
					
					var $container=$("#upload_camp_photo_container");
					$container.data("public-id", json.public_id);
					$container.data("cloud-url", url);
					$container.find("img").first().css("margin-top","0px").attr("src", url);
					
					window.Raisy_admin_campaigns.cropboxPhoto($container);
					
					$("#upload_camp_photo_button").data("uploaded","yes").find("span").text("保存");
				}
				else
				{
					// txt="Internal Server Error";
					$("<div/>").text(txt).appendTo("#more_photo_result");
		            $(".camp-photo-status").text("抱歉! 上传失败，请稍后再试");
		            $(".camp-photo-progress").hide().find(".camp-photo-progress-bar").css("width", "0").find('span').text("");
				}
	        },
			fail: function(e, data) {
				// No longer triggered when using iframe as it always get back the response, even if 404 or 500
				// which will be considered as errors when using XHR

				$("<div/>").text("Internal Server Error").appendTo("#more_photo_result");
	            $(".camp-photo-status").text("抱歉! 上传失败，请稍后再试");
	            $(".camp-photo-progress").hide().find(".camp-photo-progress-bar").css("width", "0").find('span').text("");
			}
	    });

		$('#more_photo_upload').fileupload({
			forceIframeTransport: true,	// To work with IE under 10, use iframe always and do some tricks
	        add: function(e, data) {
				$('.add-campaign-photo .fa-spin').show();
				
				data.submit();
	        },
	        done: function (e, data) {
				$('.add-campaign-photo .fa-spin').hide();
				
				var txt=$(data.result[0].body).text();	// Thanks to IE, work became so ugly
		
				// Upload#save action returns filename+'upload.done' to indicate a successful uploading
				if (txt.indexOf("upload.done")>0)
				{
					var txt=txt.replace("upload.done","");
					var json=JSON.parse(txt);
					
					$("<div/>").text(txt).appendTo("#more_photo_result");
					
					var photo=$(".more-photo-template").clone();
					photo.removeClass("more-photo-template").addClass("more-photo-instance");
					photo.data("public_id", json.public_id);
					
					$(".more-photo-file").removeClass("col-md-offset-4");
					
					photo.insertBefore(".more-photo-file").fadeIn(200, function(){
						
	        	var params = {
							angle: "exif"
	        	};
				
	        	var url = $.cloudinary.url(json.public_id, params);
						
						photo.find("img").first().attr("src", url);
						
						window.Raisy_admin_campaigns.cropboxPhoto(photo);
						
						if ($(".more-photo-instance").length>=9) $(".more-photo-file").fadeOut(200);
						
						//$(".camp-back-btn-31").show();
						$(".camp-skip-btn-31").hide();
					});
					
					photo.find("button").click(function(e){
						$(this).parents(".more-photo-instance").first()
							.removeClass("more-photo-instance").fadeOut(200, function(){
								$(this).remove();
								
								if ($(".more-photo-instance").length==0) 
									$(".more-photo-file").addClass("col-md-offset-4");
						
								$(".more-photo-file").fadeIn(200);
								
								if ($(".more-photo-instance").length>0)
								{
									//$(".camp-back-btn-31").show();
									$(".camp-skip-btn-31").hide();
								}
								else
								{
									//$(".camp-back-btn-31").hide();
									$(".camp-skip-btn-31").show();
								}
							});
					});
				}
				else
				{
					// txt="Internal Server Error";
					$("<div/>").text(txt).appendTo("#more_photo_result");
				}
	        },
			fail: function(e, data) {
				// No longer triggered when using iframe as it always get back the response, even if 404 or 500
				// which will be considered as errors when using XHR

				$("<div/>").text("Internal Server Error").appendTo("#more_photo_result");
			}
	    }).bind('fileuploadprogress', function (e, data) {
		    
		});
        //$('#minilogo_upload').fileupload({
        //
        //    forceIframeTransport: true,	// To work with IE under 10, use iframe always and do some tricks
        //    add: function (e, data) {
        //        $('.add-campaign-photo .fa-spin').show();
        //        $("#minilogo_upload_view").parent().find(".loader").show();
        //        data.submit();
        //    },
        //    done: function (e, data) {
        //
        //        $('.add-campaign-photo .fa-spin').hide();
        //
        //        var txt = $(data.result[0].body).text();	// Thanks to IE, work became so ugly
        //
        //        // Upload#save action returns filename+'upload.done' to indicate a successful uploading
        //        if (txt.indexOf("upload.done") > 0) {
        //
        //            var txt = txt.replace("upload.done", "");
        //            var json = JSON.parse(txt);
        //            var params = {
        //                angle: "exif"
        //            };
        //            var url = $.cloudinary.url(json.public_id, params);
        //            $("#minilogo_upload_view").find("img").attr("src",url);
        //            $("#minilogo_upload_view").find("input").val(json.public_id);
        //            $("#minilogo_upload_view").parent().find(".loader").hide();
        //            //$("<div/>").text(txt).appendTo("#more_photo_result");
        //            //
        //            //var photo = $(".more-photo-template").clone();
        //            //photo.removeClass("more-photo-template").addClass("more-photo-instance");
        //            //photo.data("public_id", json.public_id);
        //            //
        //            //$(".more-photo-file").removeClass("col-md-offset-4");
        //            //
        //            //photo.insertBefore(".more-photo-file").fadeIn(200, function () {
        //            //
        //            //    var params = {
        //            //        angle: "exif"
        //            //    };
        //            //
        //            //    var url = $.cloudinary.url(json.public_id, params);
        //            //
        //            //    photo.find("img").first().attr("src", url);
        //            //
        //            //    Raisy.campaigns.cropboxPhoto(photo);
        //            //
        //            //    if ($(".more-photo-instance").length >= 9) $(".more-photo-file").fadeOut(200);
        //            //
        //            //    $(".web-box").find(".camp-back-btn-31").parent().removeClass("col-sm-5").addClass("col-sm-6");
        //            //    $(".camp-skip-btn-31").parent().hide();
        //            //
        //            //    if ($(".more-photo-file").hasClass("col-md-12")) {
        //            //        $(".more-photo-file").removeClass("col-md-12").addClass("col-md-4");
        //            //    }
        //            //
        //            //});
        //            //
        //            //photo.find("button").click(function (e) {
        //            //    $(this).parents(".more-photo-instance").first()
        //            //        .removeClass("more-photo-instance").fadeOut(200, function () {
        //            //            $(this).remove();
        //            //
        //            //            if ($(".more-photo-instance").length == 0)
        //            //                $(".more-photo-file").addClass("col-md-offset-4");
        //            //
        //            //            $(".more-photo-file").fadeIn(200);
        //            //
        //            //            if ($(".more-photo-instance").length > 0) {
        //            //                $(".web-box").find(".camp-back-btn-31").parent().removeClass("col-sm-5").addClass("col-sm-6");
        //            //                $(".camp-skip-btn-31").parent().hide();
        //            //            }
        //            //            else {
        //            //                $(".web-box").find(".camp-back-btn-31").parent().removeClass("col-sm-6").addClass("col-sm-5");
        //            //                $(".camp-skip-btn-31").parent().show();
        //            //            }
        //            //        });
        //            //});
        //        }
        //        else {
        //            // txt="Internal Server Error";
        //            //$("<div/>").text(txt).appendTo("#more_photo_result");
        //        }
        //    },
        //    fail: function (e, data) {
        //        // No longer triggered when using iframe as it always get back the response, even if 404 or 500
        //        // which will be considered as errors when using XHR
        //
        //        $("<div/>").text("Internal Server Error").appendTo("#more_photo_result");
        //    }
        //}).bind('fileuploadprogress', function (e, data) {
        //
        //});
		
		$("#campaign_images .delete-campaign-image").click(function(){
			if (confirm("Are you sure that you want to delete this image?"))
			{
				var $this=$(this);
				
				$.ajax({
					url: "campaign_delete_image?id=" + $(this).data("pk"),
					type: 'GET',
					dataType: "json",
					success: function(d){
						if (d.result)
						 $this.parents(".campaign-image-div").hide("slow").remove();
					},
					error:function(x,m,e){
						alert(m);
					}
				});
			}
		});
		
		$("#organization_name").not(".input-organization").select2({
			allowClear: true,
			minimumInputLength: 0,
			placeholder: "请选择组织",
			ajax: {  
			        url: "/campaigns/organizations.json",
					cache: true,
					quietMillis: 300,
					data: function(org_name, page_index){return {name: org_name, page: page_index}},
					results: function (data, page) {
						var more = (page * 10) < data.total;
  
						return {results: data.orgs, more: more};
				   	}
			    },
			initSelection: function(element, callback) {
				var id = $(element).val();
				if (id !== "") {
					$.ajax("/campaigns/organization.json/" + id, {
						dataType: "json"
					}).done(function(data) {
						if (data) {
							callback(data);
							$("#organization-name").val(data.text);
						}
					});
				}

			}
		}).on("select2-blur", function(){
			var data=$("#organization_name").select2("data");
						
			// organization-name is the real field that stores organization name
			if (data) {
				if (data.id==0)
					$("#organization-name").val(data.text);
				else
					$("#organization-name").val(data.name);
			}
			else {
				$("#organization-name").val("");
			}
			
			// Trigger validation on this field only	
			// $("form").validate().element("#organization_name");
		});
		
		if ($(".campaign_bulkshippinginfo_form").length>0) {
			window.Raisy_admin_campaigns.bind_state_province(country_id);
			
			$("#country_id").change(function(){
				window.Raisy_admin_campaigns.bind_state_province($(this).val());
			});
			
			state_province_id=0;
		}
		
		$("#default_images_modal").on("show.bs.modal", function() {
			if ($("#default_images_modal").data("img-loaded")=="no") {
				$("#default_images_modal .dynamic-image").cloudinary().removeAttr("width").removeAttr("height");
				$("#default_images_modal").data("img-loaded","yes");
			}
		});
		
    $("#campaigns div.use-button").on("mouseenter", function() {
        $(this).toggleClass("use-button-hover");
    }).on("mouseleave", function() {
        $(this).toggleClass("use-button-hover");
    }).on("click", function(){
			$("#use_ours_link").click();
    });
		
		$("#campaigns .default-campaign-image").click(function(){
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

        function upload_minilogo() {
            function getRoundedCanvas(sourceCanvas) {
                var canvas = document.createElement('canvas');
                var context = canvas.getContext('2d');
                var width = sourceCanvas.width;
                var height =sourceCanvas.height;
                canvas.width = width;
                canvas.height = height;
                context.beginPath();
                context.arc(width / 2, height / 2, Math.min(width, height) / 2, 0, 2 * Math.PI);
                context.strokeStyle = 'rgba(0,0,0,0)';
                context.stroke();
                context.clip();
                //context.scale(0.3,0.3);
                context.drawImage(sourceCanvas, 0, 0, width, height);

                return canvas;
            }

            var $img_cropper = $("#minilogo_cropper");
            var $button = $('#btn-crop-minilogo');
            var $minilogoview = $(".js-minilogo-view");
            var $result = $('#result');

            var croppable = false;
            function initcropper()
            {
                $img_cropper.cropper({
                    aspectRatio: 1,
                    viewMode: 1,
                    built: function () {
                        croppable = true;
                    },
                    crop: function (e) {
                        // Output the result data for cropping image.
                        //console.log(e.x);
                        //console.log(e.y);
                        //console.log(e.width);
                        //console.log(e.height);
                        //console.log(e.rotate);
                        //console.log(e.scaleX);
                        //console.log(e.scaleY);
                        _this.minilogo_data_cropper.x= e.x;
                        _this.minilogo_data_cropper.y= e.y;
                        _this.minilogo_data_cropper.width= e.width;
                        _this.minilogo_data_cropper.height= e.height;
                        _this.minilogo_data_cropper.scaleX= e.scaleX;
                        _this.minilogo_data_cropper.scaleY= e.scaleY;

                        _this.minilogo_data_cropper.filename=$img_cropper.attr("src");
                    }
                });
            }

            $button.on('click', function () {
                var croppedCanvas;
                var roundedCanvas;

                if (!croppable) {
                    return;
                }
                // Crop
                croppedCanvas = $img_cropper.cropper('getCroppedCanvas');
                //croppedCanvas.width=150;
                //croppedCanvas.height=150;
                // Round
                roundedCanvas = getRoundedCanvas(croppedCanvas);

                // Show
                $minilogoview.attr("src", roundedCanvas.toDataURL());
                $("#minilogo_upload_view").find("input").val(_this.minilogo_data_cropper.filename);
                _this.minilogo_data_cropper.ischage=true;
                //$result.html('<img src="' + roundedCanvas.toDataURL() + '">');
            });

            $('#minilogo_upload').fileupload({
                forceIframeTransport: true,	// To work with IE under 10, use iframe always and do some tricks
                autoUpload: true,
                add: function (e, data) {
                    //$('.add-campaign-photo .fa-spin').show();
                    //$("#minilogo_upload_view").parent().find(".loader").show();
                    $(".minilogo_cropper_box").show();
                    $(".minilogo-progress").hide().find(".progress-bar").css("width", "0").find('span').text("0%");
                    $(".minilogo-progress").show();
                    data.submit();
                },
                done: function (e, data) {
                    //$('.add-campaign-photo .fa-spin').hide();
                    var txt = $(data.result[0].body).text();	// Thanks to IE, work became so ugly
                    // Upload#save action returns filename+'upload.done' to indicate a successful uploading
                    //alert(txt);
                    if (txt.indexOf("upload.done") > 0) {
                        var txt = txt.replace("upload.done", "");
                        var json = JSON.parse(txt);
                        $img_cropper.attr("src", json.fullname);
                        initcropper();
                        $img_cropper.cropper('reset').cropper('replace', json.fullname);
                        $(".minilogo_cropper_box").show();
                        window.setTimeout(function(){
                            $(".minilogo-progress").hide().find(".progress-bar").css("width", 0 + "%").find('span').text(0 + "%");
                        },1000)


                    }
                    else if(txt=="max") {
                        alert("不能上传过大的图片");
                        // txt="Internal Server Error";
                        //$("<div/>").text(txt).appendTo("#more_photo_result");
                    }
                    else
                    {
                        alert("上传图片失败请确定你的图片格式是否正确！或刷新后重试");
                    }
                },
                progress: function (e, data) {//设置上传进度事件的回调函数

                    var progress = Math.round((data.loaded * 100.0) / data.total);
                    $(".minilogo-progress").find(".progress-bar").css("width", progress + "%").find('span').text(progress + "%");

                },
                progressall: function (e, data) {//设置上传进度事件的回调函数

                    var progress = Math.round((data.loaded * 100.0) / data.total);
                    $(".minilogo-progress").find(".progress-bar").css("width", progress + "%").find('span').text(progress + "%");

                },
                fail: function (e, data) {
                    // No longer triggered when using iframe as it always get back the response, even if 404 or 500
                    // which will be considered as errors when using XHR

                    alert("数据上传失败请刷新后重试");
                }
            })
        }
        upload_minilogo();
	},
	cropboxPhoto: function(photo) {
		var public_id=photo.data("public_id") || photo.data("public-id");
		
		public_id="crop_result_" + public_id;
		
		$("<input type='hidden'>").appendTo(photo).attr("name",public_id).attr("id",public_id);
		
		var crop = photo.find("img").first().data('cropbox');

		if (crop) crop.remove();
		
		photo.find("img").first().removeAttr("width").removeAttr("height").cropbox({
			width: 200,
	        height: 200,
			//controls: '<div class="cropControls"><span style="width:100%;">拖拉图片调整位置</span></div>',
			showControls: 'always'
	    }).on('cropbox', function(e, data) {
	        //$("#crop_result").text(JSON.stringify(data));
			$("#"+public_id).val(JSON.stringify(data));
			$("#upload_camp_photo_crop").val(JSON.stringify(data));
	    });
		
		// $('<span style="display:inline-block; margin:5px 0px 0px 20px; padding:0px;'
		// 	+ ' background-color:transparent; color:white; line-height:16px;'
		// 	+ ' font-size:12px; cursor:pointer; border:1px solid transparent;">Done</span>').insertBefore("#upload_camp_photo_container .cropZoomIn")
		// .on("mouseenter", function() {
		//         	$(this).css("border","1px solid #eee");
		// 	    }).on("mouseleave", function() {
		// 	        $(this).css("border","1px solid transparent");
		// 	    });
		
		// $("<div style='position:absolute; left:0px; bottom:30px; color:white;
		// background-color:black;padding:5px;opacity:0.55;font-size:12px;'><span>Image too small</span></div>").insertBefore($(".cropControls"));
	},
	cropboxImage: function(html) {

		var crop = $("#campaigns .preview img").data('cropbox');
		
		if (crop)
			crop.remove();
		
		var documentWidth = $(document.body).width();
		var cropWidth;
		var cropHeight;
		
		if (documentWidth > 768) {

			cropWidth = 622;
			cropHeight = 414;

		} else if (documentWidth > 468) {

			cropWidth = 400;
			cropHeight = 266;

		} else {

			cropWidth = 280;
			cropHeight = 186;

		}
		
   		$("#campaigns .preview img").fadeOut(200, function() {
        	$('#campaigns .preview').html(html);
			
			$('#campaigns .preview img').removeAttr("width").removeAttr("height").cropbox({
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
	submitCampaignForm: function (form) {
      //set the date to midnight in the user's time zone
      var $dateinput = $('#campaign_end_date');
			
			if ($dateinput.val()!="") {
	      var date = new Date($dateinput.val());
	      date.setHours(23);
	      date.setMinutes(59);
	      date.setSeconds(59);
	      $dateinput.val(date);
			}
		
		$("#campaign_goal").val($("#campaign_goal").val().replace(/,/g,""));

        $('#campaign_form_submit').prop('disabled', true).find('span.text').text('保存中...').siblings('span.loader').show('fast', function() {
            var data=new Array();

            if(window.Raisy_admin_campaigns.minilogo_data_cropper!=null&&window.Raisy_admin_campaigns.minilogo_data_cropper.ischage==true)
            {
                data[0]=window.Raisy_admin_campaigns.minilogo_data_cropper;

            }

            //alert(data.length);
            if(data.length>0)
            {
                $.post("/upload/photo_croper", {cropperdata1:data[0],cropperdata2:data[1]}).complete(formsubmit());
            }
            else
            {
                formsubmit();
            }

            function formsubmit()
            {
                window.Raisy_admin_campaigns.minilogo_data_cropper.ischage==false;
                window.setTimeout(function () {
                    form.submit();
                }, 50);
            }
        });
	},
	bind_state_province: function(country_id){
		$("#state_province_id").empty();

		//$('<option value="">-- Please Select --</option>').appendTo($("#product_category_id"));
		
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
			lb.text("请选择送货日期").show();
			container.addClass("has-error");
			can_continue=false;
		}
		
		var dt=$("#campaign_bulkshippinginfo_delivery_time").val();
		var lb_dt=$("#lb_delivery_time_error");
		var container_dt=lb_dt.closest(".form-group");
		
		if (dt=="") {
			lb_dt.text("请选择送货时间").show();
			container_dt.addClass("has-error");
			can_continue=false;
		}
		
		if (!can_continue) return;
		
		lb.hide();
		container.removeClass("has-error");
		lb_dt.hide();
		container_dt.removeClass("has-error");
		
		if (!confirm("订单只能提交一次，您确定要提交吗?")) return;
		
		$("#bulk_submit_order").val("1");
		$("#bulk_submit_order").closest("form").submit();
	}
}