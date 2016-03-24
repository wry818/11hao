Raisy.campaigns = {
    skip_add_camp_photo: false,
    minilogo_data_cropper:{ischage:false,x:0,y:0,height:0,width:0, scaleX:0,scaleY:0,filename:""},
    logo_data_cropper:{ischage:false,x:0,y:0,height:0,width:0, scaleX:0,scaleY:0,filename:""},
    init: function () {
        var _this = this;

        if ($('.admin-bar').length > 0) {
            // Clone and display the bar on the very top of the page

            var newbar = $('.admin-bar').clone();

            $('.admin-bar').remove();

            newbar.insertBefore("header").slideDown('slow');
        }

        // Set the right column min-height based on left column
        $(window).load(function () {
            $('.right-column').css('min-height', $('.left-column').outerHeight());
            $('.collection-description').css('min-height', $('.products').outerHeight());
        });

        // Convert the date into a format useable by pickadate
        $('.datepicker').each(function (i) {
            var d = $(this).val();
            if (d && d.length > 0) {
                $(this).val($.datepicker.formatDate('D, M d, yy', new Date(d)));
            }
        });

        // Set up pickadate
        var min = new Date();
        $('.datepicker').not(".bulk-delivery-date").pickadate({
            min: min,
            format: 'ddd, mmm d, yyyy',
            onClose: function (event) {
                if ($('#campaign_end_date').length > 0) {
                    $('#campaign_end_date').valid();
                }
            }
        });

        $('.bulkshippinginfo-timepicker').pickatime({
            min: [9, 0],
            max: [14, 0]
        });

        $(".camp-continue-btn").click(_this.continueBtnClick);
        $(".camp-back-btn").click(_this.backBtnClick);

        $("#campaign-edit label.upload-button").on("mouseenter", function () {
            $(this).toggleClass("upload-button-hover");
        }).on("mouseleave", function () {
            $(this).toggleClass("upload-button-hover");
        });

        $("#campaign-edit div.use-button").on("mouseenter", function () {
            $(this).toggleClass("use-button-hover");
        }).on("mouseleave", function () {
            $(this).toggleClass("use-button-hover");
        }).on("click", function () {
            $("#use_ours_link").click();
        });

        $("#campaign-edit .default-campaign-image").click(function () {
            $("#campaign_logo").val($(this).data("image-id"));
            $("#close_use_ours").click();

            var params = {};

            if ($(this).data("cropped")) {
                params.x = $(this).data("crop-x");
                params.y = $(this).data("crop-y");
                params.width = $(this).data("crop-w");
                params.height = $(this).data("crop-h");
                params.crop = "crop";
            }

            var html = $.cloudinary.image($(this).data("public-id"), params);
            _this.cropboxImage(html);
        }).on("mouseenter", function () {
            $(this).toggleClass("default-campaign-image-hover");
        }).on("mouseleave", function () {
            $(this).toggleClass("default-campaign-image-hover");
        });

        $(".example-story").on("mouseenter", function () {
            $(this).toggleClass("example-story-hover");
        }).on("mouseleave", function () {
            $(this).toggleClass("example-story-hover");
        }).on("click", function () {

            var $div = $("#" + $(this).data("story"));

            //alert(my_editor.html());
            //alert($.trim($div.html()))
            if(confirm('如果应用模板您目前的修改会丢失！'))
            {
                my_editor.html($.trim($div.html()));
            }

            //alert(1);
            $(".example-story").removeClass("example-story-selected");
            $(this).addClass("example-story-selected");
            //
            //var content = "";
            //var $div = $("#" + $(this).data("story"));
            //
            //if (!$(this).hasClass("custom-story")) {
            //    content = $.trim($div.text());
            //}
            //
            //var ed = tinymce.get("campaign_description");
            //var $container = $(ed.getContainer());
            //var maxLength = parseInt(ed.getParam("maxlength"));
            //
            //if (!$container.hasClass("mce-tinymce")) {
            //    $container = $container.parents(".mce-tinymce").first();
            //}
            //
            //var count = maxLength - content.length;
            //
            //content = "";
            //
            //if (!$(this).hasClass("custom-story")) {
            //    content = $.trim($div.html());
            //}
            //
            //if (count < 0) {
            //    $container.find(".tinymce-charcount span").css("color", "#b94a48").text("0");
            //}
            //else {
            //    $container.find(".tinymce-charcount span").css("color", "#00aaff").text(count);
            //}
            //
            //ed.setContent(content);
        });

        $("#campaign-edit .cloudinary-fileupload").off("cloudinarydone").on("cloudinarydone", function (e, data) {
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

        $("#organization_name").not(".input-organization").select2({
            allowClear: true,
            minimumInputLength: 0,
            placeholder: "选择您所属的社团或NGO",
            ajax: {
                url: "/campaigns/organizations.json",
                cache: true,
                quietMillis: 300,
                data: function (org_name, page_index) {
                    return {name: org_name, page: page_index}
                },
                results: function (data, page) {
                    var more = (page * 10) < data.total;

                    return {results: data.orgs, more: more};
                }
            }
        }).on("select2-blur", function () {
            var data = $("#organization_name").select2("data");

            // organization-name is the real field that stores organization name
            if (data) {
                if (data.id == 0)
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

        $(".collection-container").click(function () {
            $("#campaign_collection_id").val($(this).data("collection-id"));

            $(".collection-container").removeClass("collection-container-hover")
            $(this).addClass("collection-container-hover");

            // Trigger validation on this field only
            // $("form").validate().element("#campaign_collection_id");

            $(".no-collection-label").hide();
        });

        $(document).on('dragover', function (e) {
            e.preventDefault();
            $("#drop-zone").css("border-color", "green");
        }).on('dragleave', function (e) {
            $("#drop-zone").css("border-color", "#ccc");
        }).bind("drop", function (e) {
            e.preventDefault();
            $("#drop-zone").css("border-color", "#ccc");
        });

        // $("#direct_donation_collection").appendTo($("#collections_row")).show();

        $(".campaign-photo-remove").click(function () {
            $(this).parents(".campaign-photo-instance").first().fadeOut(200, function () {
                $(this).remove();

                var ids = ",";

                $(".campaign-photo-instance").each(function () {
                    ids += ($(this).data("public-id") || "") + ",";
                })

                $("#campaign_photo_ids").val(ids);

                $("#upload_camp_photo_button").fadeIn(200);
            });
        });

        $(".add-campaign-photo").mouseenter(function () {
            $(this).css("background-color", "rgb(235,235,235)");
        }).mouseleave(function () {
            $(this).css("background-color", "rgb(245,245,245)");
        });

        $("#upload_camp_photo_container").find("img").first().data("default-src",
            $("#upload_camp_photo_container").find("img").first().attr("src"));

        $("#upload_camp_photo_button").click(function () {
            var $button = $(this);

            if ($button.data("uploaded") == "yes") {
                // Crop done
                $button.data("uploaded", "no").find("span").text("上传");

                $("#upload_camp_photo_container").find("img").first().fadeOut(200, function () {
                    var public_id = $("#upload_camp_photo_container").data("public-id");

                    $("#crop_result_" + public_id).val($("#upload_camp_photo_crop").val());

                    var crop = $(this).data('cropbox');

                    if (crop) crop.remove();

                    $(this).css("margin-top", "50px").attr("src", $(this).data("default-src")).fadeIn(200);

                    // Add this photo to current
                    var photo = $(".campaign-photo-template").clone();
                    photo.removeClass("campaign-photo-template").addClass("campaign-photo-instance");
                    photo.data("public-id", public_id);

                    photo.insertBefore(".add-camp-photo-li").fadeIn(200, function () {
                        var json = JSON.parse($("#crop_result_" + public_id).val());
                        var params = {
                            width: json.cropW,
                            height: json.cropH,
                            x: json.cropX,
                            y: json.cropY,
                            crop: "crop"
                        };

                        var url = $.cloudinary.url(public_id, params);

                        photo.find("img").first().attr("src", url);

                        if ($(".campaign-photo-instance").length >= 9) $("#upload_camp_photo_button").fadeOut(200);

                        var ids = ",";

                        $(".campaign-photo-instance").each(function () {
                            ids += ($(this).data("public-id") || "") + ",";
                        });

                        $("#campaign_photo_ids").val(ids);

                        photo.find(".campaign-photo-remove").click(function () {
                            $(this).parents(".campaign-photo-instance").first().fadeOut(200, function () {
                                $(this).remove();

                                var ids = ",";

                                $(".campaign-photo-instance").each(function () {
                                    ids += ($(this).data("public-id") || "") + ",";
                                });

                                $("#campaign_photo_ids").val(ids);

                                $("#upload_camp_photo_button").fadeIn(200);
                            });
                        });
                    });
                });
            }
            else {
                $('#add_camp_photo_upload').click();
            }
        });

        $('#add_camp_photo_upload').fileupload({
            forceIframeTransport: true,	// To work with IE under 10, use iframe always and do some tricks
            add: function (e, data) {
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

                var txt = $(data.result[0].body).text();	// Thanks to IE, work became so ugly

                // Upload#save action returns filename+'upload.done' to indicate a successful uploading
                if (txt.indexOf("upload.done") > 0) {
                    var txt = txt.replace("upload.done", "");
                    var json = JSON.parse(txt);

                    $("<div/>").text(txt).appendTo("#more_photo_result");

                    var params = {
                        angle: "exif"
                    };

                    var url = $.cloudinary.url(json.public_id, params);

                    var $container = $("#upload_camp_photo_container");
                    $container.data("public-id", json.public_id);
                    $container.data("cloud-url", url);
                    $container.find("img").first().css("margin-top", "0px").attr("src", url);

                    Raisy.campaigns.cropboxPhoto($container);

                    $("#upload_camp_photo_button").data("uploaded", "yes").find("span").text("保存");
                }
                else {
                    // txt="Internal Server Error";
                    $("<div/>").text(txt).appendTo("#more_photo_result");
                    $(".camp-photo-status").text("抱歉! 上传失败，请稍后再试");
                    $(".camp-photo-progress").hide().find(".camp-photo-progress-bar").css("width", "0").find('span').text("");
                }
            },
            fail: function (e, data) {
                // No longer triggered when using iframe as it always get back the response, even if 404 or 500
                // which will be considered as errors when using XHR

                $("<div/>").text("Internal Server Error").appendTo("#more_photo_result");
                $(".camp-photo-status").text("抱歉! 上传失败，请稍后再试");
                $(".camp-photo-progress").hide().find(".camp-photo-progress-bar").css("width", "0").find('span').text("");
            }
        });



        $(".camp-step-qa-icon").click(function () {
            $("#camp_step_tips_modal").modal("show");
        });

        $("#camp_preview_modal").on("shown.bs.modal", function () {
            Raisy.campaigns.preview_border_showed = true;
            Raisy.campaigns.draw_preview_border();
        }).on("hidden.bs.modal", function () {
            Raisy.campaigns.preview_border_showed = false;
            $("#camp_preview_border").hide();
        });

        $("#default_images_modal").on("show.bs.modal", function () {
            if ($("#default_images_modal").data("img-loaded") == "no") {
                $("#default_images_modal .dynamic-image").cloudinary().removeAttr("width").removeAttr("height");
                $("#default_images_modal").data("img-loaded", "yes");
            }
        });
        function upload_logo() {
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

            var $img_cropper = $("#logo_upload_cropper");
            //var $button = $('#btn-crop-minilogo');
            //var $minilogoview = $(".js-minilogo-view");
            //var $result = $('#result');

            var croppable = false;
            function initcropper()
            {
                $img_cropper.cropper({
                    aspectRatio:9/6,
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
                        _this.logo_data_cropper.x= e.x;
                        _this.logo_data_cropper.y= e.y;
                        _this.logo_data_cropper.width= e.width;
                        _this.logo_data_cropper.height= e.height;
                        _this.logo_data_cropper.scaleX= e.scaleX;
                        _this.logo_data_cropper.scaleY= e.scaleY;


                        _this.logo_data_cropper.ischage=true;
                    }
                });
            }
            //$button.on('click', function () {
            //    var croppedCanvas;
            //    var roundedCanvas;
            //
            //    if (!croppable) {
            //        return;
            //    }
            //    // Crop
            //    croppedCanvas = $img_cropper.cropper('getCroppedCanvas');
            //    //croppedCanvas.width=150;
            //    //croppedCanvas.height=150;
            //    // Round
            //    roundedCanvas = getRoundedCanvas(croppedCanvas);
            //
            //    // Show
            //    $minilogoview.attr("src", roundedCanvas.toDataURL());
            //    $("#minilogo_upload_view").find("input").val(_this.logo_data_cropper.filename);
            //    _this.logo_data_cropper.ischage=true;
            //    //$result.html('<img src="' + roundedCanvas.toDataURL() + '">');
            //});

            var $logo_progress= $(".js-logo-progress");
            $('#logo_upload').fileupload({
                forceIframeTransport: true,	// To work with IE under 10, use iframe always and do some tricks
                autoUpload: true,
                add: function (e, data) {
                    //$('.add-campaign-photo .fa-spin').show();
                    //$("#minilogo_upload_view").parent().find(".loader").show();
                    $logo_progress.hide().find(".progress-bar").css("width", "0").find('span').text("0%");
                    $logo_progress.show();
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
                        $img_cropper.find("input").val(json.fullname);
                        _this.logo_data_cropper.filename=$img_cropper.attr("src");

                        initcropper();
                        $img_cropper.cropper('reset').cropper('replace', json.fullname);
                        window.setTimeout(function(){
                            $logo_progress.hide().find(".progress-bar").css("width", 0 + "%").find('span').text(0 + "%");
                        },1000)


                    }
                    else {
                        // txt="Internal Server Error";
                        //$("<div/>").text(txt).appendTo("#more_photo_result");
                    }
                },
                progress: function (e, data) {//设置上传进度事件的回调函数

                    var progress = Math.round((data.loaded * 100.0) / data.total);
                    $logo_progress.find(".progress-bar").css("width", progress + "%").find('span').text(progress + "%");

                },
                progressall: function (e, data) {//设置上传进度事件的回调函数

                    var progress = Math.round((data.loaded * 100.0) / data.total);
                    $logo_progress.find(".progress-bar").css("width", progress + "%").find('span').text(progress + "%");

                },
                fail: function (e, data) {
                    // No longer triggered when using iframe as it always get back the response, even if 404 or 500
                    // which will be considered as errors when using XHR

                    alert("数据上传失败请刷新后重试");
                }
            })
        }
        upload_logo();
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
                    else {
                        // txt="Internal Server Error";
                        //$("<div/>").text(txt).appendTo("#more_photo_result");
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
    cropboxPhoto: function (photo) {
        var public_id = photo.data("public_id") || photo.data("public-id");

        public_id = "crop_result_" + public_id;

        $("<input type='hidden'>").appendTo(photo).attr("name", public_id).attr("id", public_id);

        var crop = photo.find("img").first().data('cropbox');

        if (crop) crop.remove();

        photo.find("img").first().removeAttr("width").removeAttr("height").cropbox({
            width: 200,
            height: 200,
            //controls: '<div class="cropControls"><span style="width:100%;">拖拉图片调整位置</span></div>',
            showControls: 'always'
        }).on('cropbox', function (e, data) {
            //$("#crop_result").text(JSON.stringify(data));
            $("#" + public_id).val(JSON.stringify(data));
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
    cropboxImage: function (html) {
        var crop = $("#campaign-edit .preview img").data('cropbox');

        if (crop) crop.remove();

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

        $("#campaign-edit .preview img").fadeOut(200, function () {
            $('#campaign-edit .preview').html(html);

            $('#campaign-edit .preview img').removeAttr("width").removeAttr("height").cropbox({
                width: cropWidth,
                height: cropHeight,
                //controls: '<div class="cropControls"><span style="width:100%;">拖拉图片调整位置</span></div>',
                showControls: 'always'
            }).on('cropbox', function (e, data) {
                $("#logo_crop_x").val(data.cropX);
                $("#logo_crop_y").val(data.cropY);
                $("#logo_crop_w").val(data.cropW);
                $("#logo_crop_h").val(data.cropH);

                //$("#crop_result").text(JSON.stringify(data));
            });

            isuploadCampaignPhoto = true;

        }).fadeIn(200);
    },
    submitCampaignForm: function (form) {
        _this=this;
        if ($("#campaign_collection_id").val() == "") {
            $(".no-collection-label").show();
            return false;
        }

        var can_continue = true;

        if ($("#campaign_new_user").val() == "1") {
            // Lookup to see if new user can be created or connected

            if ($("#auth_provider").val() == "raisy") {
                can_continue = Raisy.verify_user(false, $("#user_email").val(), '');
            }
            else {
                $.ajax({
                    method: "get",
                    url: "/user/lookup?email=" + encodeURIComponent($("#user_email").val()),
                    dataType: "json",
                    cache: false,
                    async: false,
                    success: function (d) {
                        if (d && d.user && (d.user.uid != uid || d.user.provider != $("#auth_provider").val())) {
                            can_continue = false;
                        }
                    }
                });
            }

            if (!can_continue) {
                $("#campaign_social_error").show();
                $("#campaign_social_message").text("抱歉，这个帐户已被注册。");
            }
        }
        else {
            // Check existing user credential
            if ($("#auth_provider").val() == "raisy") {
                can_continue = Raisy.verify_user(true, $("#user_email").val(), $("#user_password").val());

                if (!can_continue) {
                    $("#campaign_social_error").show();
                    $("#campaign_social_message").text("抱歉，您的邮箱或密码不正确。");
                }
            }
        }

        if (!can_continue) {
            $("#auth_provider").val("raisy");
            $("#auth_uid").val("");

            return false;
        }

        $("#campaign_social_error").show();
        $("#campaign_social_message").text("登录中，请稍候...");

        //set the date to midnight in the user's time zone
        var $dateinput = $('#campaign_end_date');

        if ($dateinput.val() != "") {
            var date = new Date($dateinput.val());
            date.setHours(23);
            date.setMinutes(59);
            date.setSeconds(59);
            $dateinput.val(date);
        }

        $("#campaign_goal").val($("#campaign_goal").val().replace(/,/g, ""));

        $('#campaign_form_submit').prop('disabled', true).find('span.text').text('保存中...').siblings('span.loader').show('fast', function () {

            var data=new Array();

            if(Raisy.campaigns.minilogo_data_cropper!=null&&Raisy.campaigns.minilogo_data_cropper.ischage==true)
            {
                data[0]=_this.minilogo_data_cropper;

            }
            if(Raisy.campaigns.logo_data_cropper!=null&&Raisy.campaigns.logo_data_cropper.ischage==true)
            {
                data[1]=_this.logo_data_cropper;
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
                window.setTimeout(function () {
                    form.submit();
                }, 50);
            }

        });
    },
    skipMorePhoto: function (btn) {
        Raisy.campaigns.skip_add_camp_photo = true;

        if ($("#campaign_collection_id").val() == "0") {
            $("#campaign_call_to_action").attr("placeholder", "做一次捐赠");
            $("#campaign_call_to_action").val("Make a Donation");
        }
        else {
            $("#campaign_call_to_action").attr("placeholder", "立刻购买");
            $("#campaign_call_to_action").val("立刻购买");
        }

        var nextStep = $(btn).data("nextstep");

        if (nextStep == 5) {
            Raisy.campaigns.campaign_current_step = 5;
						Raisy.campaigns.campaign_ajax_create(btn, 5);
        }
        else {
            Raisy.campaigns.campaign_ajax_create(btn, 6);
        }
    },
    backBtnClick: function () {
        var step = $(this).data("currentstep");

        // Sign In/Up now acts as the first step and
        // Who Are You Raising Funds For is combined into Fundraiser Details.
        // Number of steps is not changed and currentstep still starts from 1 (Fundraiser Details).
        // But it may affect the display of step icon and navigation.

        if (step != 1) {

            $(".camp-step-container").hide();
            $(".step-nav-icon").removeClass("step-nav-icon-gray");

        }

        switch (step) {
            case 5:
                if (Raisy.campaigns.skip_add_camp_photo) {
                    Raisy.campaigns.campaign_current_step = 3;

                    $("#step_container_3").show();
                    $("#step_nav_icon_4").addClass("step-nav-icon-gray");

                    $("#camp_step_tips_modal .modal-body").html($("#camp_step_tips_3_1").html());
                    $("#hide_camp_step_tips").off("click").on("click", function () {
                        Raisy.campaigns.step_tips_show_status.step3_1 = false;
                        Raisy.campaigns.donot_show_step_tips();
                    });

                    if (Raisy.campaigns.step_tips_show_status.step3_1) {
                        $("#camp_step_tips_modal").modal("show");
                    }
                }
                else {
                    if ($(".more-photo-instance").length > 0) {
                        Raisy.campaigns.campaign_current_step = 3.1;

                        $(".camp-skip-btn-31").parent().hide();

                        $("#step_container_3_1").show();
                        $("#step_nav_icon_4").addClass("step-nav-icon-gray");

                        $("#camp_step_tips_modal .modal-body").html($("#camp_step_tips_3_2").html());
                        $("#hide_camp_step_tips").off("click").on("click", function () {
                            Raisy.campaigns.step_tips_show_status.step3_2 = false;
                            Raisy.campaigns.donot_show_step_tips();
                        });

                        if (Raisy.campaigns.step_tips_show_status.step3_2) {
                            $("#camp_step_tips_modal").modal("show");
                        }
                    }
                    else {
                        Raisy.campaigns.campaign_current_step = 3;

                        $(".camp-skip-btn-31").parent().show();

                        $("#step_container_3").show();
                        $("#step_nav_icon_4").addClass("step-nav-icon-gray");

                        $("#camp_step_tips_modal .modal-body").html($("#camp_step_tips_3_1").html());
                        $("#hide_camp_step_tips").off("click").on("click", function () {
                            Raisy.campaigns.step_tips_show_status.step3_1 = false;
                            Raisy.campaigns.donot_show_step_tips();
                        });

                        if (Raisy.campaigns.step_tips_show_status.step3_1) {
                            $("#camp_step_tips_modal").modal("show");
                        }
                    }
                }

                break;
            case 4:
                // Who Are You Raising Funds For is combined into Fundraiser Details,
                // just leave it alone

                if (Raisy.campaigns.skip_add_camp_photo) {
                    Raisy.campaigns.campaign_current_step = 3;

                    $("#step_container_3").show();
                    $("#step_nav_icon_3").addClass("step-nav-icon-gray");

                    $("#camp_step_tips_modal .modal-body").html($("#camp_step_tips_3_1").html());
                    $("#hide_camp_step_tips").off("click").on("click", function () {
                        Raisy.campaigns.step_tips_show_status.step3_1 = false;
                        Raisy.campaigns.donot_show_step_tips();
                    });

                    if (Raisy.campaigns.step_tips_show_status.step3_1) {
                        $("#camp_step_tips_modal").modal("show");
                    }
                }
                else {
                    if ($(".more-photo-instance").length > 0) {
                        Raisy.campaigns.campaign_current_step = 3.1;

                        $(".camp-skip-btn-31").parent().hide();

                        $("#step_container_3_1").show();
                        $("#step_nav_icon_3").addClass("step-nav-icon-gray");

                        $("#camp_step_tips_modal .modal-body").html($("#camp_step_tips_3_2").html());
                        $("#hide_camp_step_tips").off("click").on("click", function () {
                            Raisy.campaigns.step_tips_show_status.step3_2 = false;
                            Raisy.campaigns.donot_show_step_tips();
                        });

                        if (Raisy.campaigns.step_tips_show_status.step3_2) {
                            $("#camp_step_tips_modal").modal("show");
                        }
                    }
                    else {
                        Raisy.campaigns.campaign_current_step = 3;

                        $(".camp-skip-btn-31").show();

                        $("#step_container_3").show();
                        $("#step_nav_icon_3").addClass("step-nav-icon-gray");

                        $("#camp_step_tips_modal .modal-body").html($("#camp_step_tips_3_1").html());
                        $("#hide_camp_step_tips").off("click").on("click", function () {
                            Raisy.campaigns.step_tips_show_status.step3_1 = false;
                            Raisy.campaigns.donot_show_step_tips();
                        });

                        if (Raisy.campaigns.step_tips_show_status.step3_1) {
                            $("#camp_step_tips_modal").modal("show");
                        }
                    }
                }

                break;
            case 3.1:
                Raisy.campaigns.campaign_current_step = 3;

                $("#step_container_3").show();
                $("#step_nav_icon_4").addClass("step-nav-icon-gray");

                $("#camp_step_tips_modal .modal-body").html($("#camp_step_tips_3_1").html());
                $("#hide_camp_step_tips").off("click").on("click", function () {
                    Raisy.campaigns.step_tips_show_status.step3_1 = false;
                    Raisy.campaigns.donot_show_step_tips();
                });

                if (Raisy.campaigns.step_tips_show_status.step3_1) {
                    $("#camp_step_tips_modal").modal("show");
                }

                break;
            case 3:
                Raisy.campaigns.campaign_current_step = 2;

                $("#step_container_2").show();
                $("#step_nav_icon_3").addClass("step-nav-icon-gray");

                $("#camp_step_tips_modal .modal-body").html($("#camp_step_tips_2").html());
                $("#hide_camp_step_tips").off("click").on("click", function () {
                    Raisy.campaigns.step_tips_show_status.step2 = false;
                    Raisy.campaigns.donot_show_step_tips();
                });

                if (Raisy.campaigns.step_tips_show_status.step2) {
                    $("#camp_step_tips_modal").modal("show");
                }

                break;
            case 2:
                Raisy.campaigns.campaign_current_step = 1;

                $("#step_container_1").show();
                $("#step_nav_icon_2").addClass("step-nav-icon-gray");

                $("#camp_step_tips_modal .modal-body").html($("#camp_step_tips_1").html());
                $("#hide_camp_step_tips").off("click").on("click", function () {
                    Raisy.campaigns.step_tips_show_status.step1 = false;
                    Raisy.campaigns.donot_show_step_tips();
                });

                if (Raisy.campaigns.step_tips_show_status.step1) {
                    $("#camp_step_tips_modal").modal("show");
                }

                break;
            case 1:
                history.back();
                break;
            default:
                break;
        }
    },
    continueBtnClick: function () {
        _this=this;
        var step = $(this).data("currentstep");
        var story_too_long = false;
        // Sign In/Up now acts as the first step and
        // Who Are You Raising Funds For is combined into Fundraiser Details.
        // Number of steps is not changed and currentstep still starts from 1 (Fundraiser Details).
        // But it may affect the display of step icon and navigation.
				
        if (step == 2) {
            //var ed = tinymce.get("campaign_description");
            //var $container = $(ed.getContainer());
            //
            //if (!$container.hasClass("mce-tinymce")) {
            //    $container = $container.parents(".mce-tinymce").first();
            //}
            //
            //var content = $.trim(ed.getContent({format: "text"}));
            //var maxLength = parseInt(ed.getParam("maxlength"));
            //var count = maxLength - content.length;
            //
            //if (count < 0) {
            //    story_too_long = true;
            //
            //    $container.find(".tinymce-charcount span").css("color", "#b94a48").text("Up to " + maxLength + " characters");
            //}
            //else {
            //    $container.find(".tinymce-charcount span").css("color", "#00aaff").text(count);
				//
				//				content=$.trim(ed.getContent());
				//
				//				$("#campaign_description").val(content);
            //}
        }

        if (story_too_long) {
            return;
        }

        //var noCollection = false;
        //
        //if (step == 5 && $("#campaign_collection_id").val() == "") {
        //    noCollection = true;
        //}
        //
        //if (!$("#campaign_form").valid() || noCollection) {
        //    if (noCollection) {
        //        $(".no-collection-label").show();
        //    }
        //
        //    return;
        //}

        switch (step) {
            case 1:

                Raisy.campaigns.campaign_current_step = 2;
								Raisy.campaigns.campaign_ajax_create(this, 2);

                break;
            case 2:

                Raisy.campaigns.campaign_current_step = 3;
								Raisy.campaigns.campaign_ajax_create(this, 3);
								
                break;
            case 3:
                if ($(".more-photo-instance").length > 0) {
                    $(".camp-skip-btn-31").parent().hide();
                }
                else {
                    $(".camp-skip-btn-31").parent().show();
                }

                Raisy.campaigns.campaign_current_step = 3.1;

                var data=new Array();

                if(Raisy.campaigns.minilogo_data_cropper!=null&&Raisy.campaigns.minilogo_data_cropper.ischage==true)
                {
                    data[0]=Raisy.campaigns.minilogo_data_cropper;

                }
                if(Raisy.campaigns.logo_data_cropper!=null&&Raisy.campaigns.logo_data_cropper.ischage==true)
                {
                    data[1]=Raisy.campaigns.logo_data_cropper;
                }

                //alert(data.length);
                if(data.length>0)
                {
                    $.post("/upload/photo_croper", {cropperdata1:data[0],cropperdata2:data[1]}).complete(campaignformsubmit());
                }
                else
                {
                    campaignformsubmit();
                }
                //var btncontaion=$(".camp-continue-btn");
                function  campaignformsubmit()
                { 
                    Raisy.campaigns.campaign_ajax_create(_this, 3.1);
                }


                break;
            case 3.1:

                var ids = ",";

                $(".more-photo-instance").each(function () {
                    ids += ($(this).data("public_id") || "") + ",";
                })

                $("#campaign_photo_ids").val(ids);

                if ($("#campaign_collection_id").val() == "0") {
                    $("#campaign_call_to_action").attr("placeholder", "Make a Donation");
                    $("#campaign_call_to_action").val("Make a Donation");
                }
                else {
                    $("#campaign_call_to_action").attr("placeholder", "立刻购买");
                    $("#campaign_call_to_action").val("立刻购买");
                }

                //var nextStep = $(this).data("nextstep");
                //
                //if (nextStep == 5) {
                //    Raisy.campaigns.campaign_current_step = 5;
					//					Raisy.campaigns.campaign_ajax_create(this, 5);
                //}
                //else {
                //    Raisy.campaigns.campaign_ajax_create(this, 6);
                //}
                var data=new Array();

                if(Raisy.campaigns.minilogo_data_cropper!=null&&Raisy.campaigns.minilogo_data_cropper.ischage==true)
                {
                    data[0]=Raisy.campaigns.minilogo_data_cropper;

                }
                if(Raisy.campaigns.logo_data_cropper!=null&&Raisy.campaigns.logo_data_cropper.ischage==true)
                {
                    data[1]=Raisy.campaigns.logo_data_cropper;
                }

                //alert(data.length);
                if(data.length>0)
                {
                    $.post("/upload/photo_croper", {cropperdata1:data[0],cropperdata2:data[1]}).complete(campaignminilogoformsubmit());
                }
                else
                {
                    campaignminilogoformsubmit();
                }
                function  campaignminilogoformsubmit()
                {
                    Raisy.campaigns.campaign_ajax_create(_this, 6);
                }

                break;
            case 4:
                // Who Are You Raising Funds For is combined into Fundraiser Details,
                // just leave it alone

                if ($("#campaign_collection_id").val() == "0") {
                    $("#campaign_call_to_action").attr("placeholder", "Make a Donation");
                    $("#campaign_call_to_action").val("Make a Donation");
                }
                else {
                    $("#campaign_call_to_action").attr("placeholder", "立刻购买");
                    $("#campaign_call_to_action").val("立刻购买");
                }

                //var nextStep = $(this).data("nextstep");
                //
                //if (nextStep == 5) {
                //    Raisy.campaigns.campaign_current_step = 5;
					//					Raisy.campaigns.campaign_ajax_create(this, 5);
                //}
                //else {
                //    Raisy.campaigns.campaign_ajax_create(this, 6);
                //}

                Raisy.campaigns.campaign_ajax_create(this, 6);
                break;
            case 5:
                Raisy.campaigns.campaign_ajax_create(this, 6);
                break;
            default:
                break;
        }
    },
    campaign_ajax_create: function (btn, nextStep) {

        var ids = ",";

        $(".more-photo-instance").each(function () {
            ids += ($(this).data("public_id") || "") + ",";
        })

        $("#campaign_photo_ids").val(ids);

        var $dateinput = $('#campaign_end_date');

        if ($dateinput.val() != "") {
            var date = new Date($dateinput.val());
            date.setHours(23);
            date.setMinutes(59);
            date.setSeconds(59);
            $dateinput.val(date);
        }

        $("#campaign_goal").val($("#campaign_goal").val().replace(/,/g, ""));
				
				var $button=$(btn);
				
        $button.prop('disabled', true).find('span.text').siblings('span.loader').show(200, function() {
            $("#campaign_description").val(my_editor.html());
	        $.ajax({
	            method: "POST",
	            url: "/campaigns/ajax_create",
	            data: $("#campaign_form").serialize(),
	            dataType: "json",
	            cache: false,
	            success: function (d) {
	                if (d && d.id && d.slug) {
	                    var campaign_id = parseInt(d.id);

	                    if (isNaN(campaign_id)) {
												window.Raisy.alert("抱歉，创建这个筹款团队时出了问题，请稍后再试。");
	                    }
	                    else {
							$("#campaign_id").val(d.id);
                            var campaign_id = parseInt($("#campaign_id").val());
                            //alert(campaign_id);
                            if (!isNaN(campaign_id)) {
                                $("#camp_preview_modal").find("img").hide();
                                $ifra=$("#camp_preview_modal").find("iframe");
                                $ifra.attr("src",'/checkout/campaign_'+campaign_id);
                                $ifra.show();
                            }

	                        switch (nextStep) {
	                            case 1:
																// Next step could not be 1
	                                break;

	                            case 2:
								                $(".camp-step-container").hide();
								                $(".step-nav-icon").removeClass("step-nav-icon-gray");

								                $("#step_container_2").show();
								                $("#step_nav_icon_3").addClass("step-nav-icon-gray");

								                $("#camp_step_tips_modal .modal-body").html($("#camp_step_tips_2").html());
								                $("#hide_camp_step_tips").off("click").on("click", function () {
								                    Raisy.campaigns.step_tips_show_status.step2 = false;
								                    Raisy.campaigns.donot_show_step_tips();
								                });

								                if (Raisy.campaigns.step_tips_show_status.step2) {
								                    $("#camp_step_tips_modal").modal("show");
								                }
															
	                                break;

	                            case 3:
								                $(".camp-step-container").hide();
								                $(".step-nav-icon").removeClass("step-nav-icon-gray");

								                $("#step_container_3").show();
								                $("#step_nav_icon_4").addClass("step-nav-icon-gray");

								                $("#camp_step_tips_modal .modal-body").html($("#camp_step_tips_3_1").html());
								                $("#hide_camp_step_tips").off("click").on("click", function () {
								                    Raisy.campaigns.step_tips_show_status.step3_1 = false;
								                    Raisy.campaigns.donot_show_step_tips();
								                });

								                if (Raisy.campaigns.step_tips_show_status.step3_1) {
								                    $("#camp_step_tips_modal").modal("show");
								                }
															
	                                break;

	                            case 3.1:
								                $(".camp-step-container").hide();
								                $(".step-nav-icon").removeClass("step-nav-icon-gray");

								                $("#step_container_3_1").show();
								                $("#step_nav_icon_4").addClass("step-nav-icon-gray");

								                Raisy.campaigns.skip_add_camp_photo = false;

								                $("#camp_step_tips_modal .modal-body").html($("#camp_step_tips_3_2").html());
								                $("#hide_camp_step_tips").off("click").on("click", function () {
								                    Raisy.campaigns.step_tips_show_status.step3_2 = false;
								                    Raisy.campaigns.donot_show_step_tips();
								                });

								                if (Raisy.campaigns.step_tips_show_status.step3_2) {
								                    $("#camp_step_tips_modal").modal("show");
								                }
															
	                                break;

	                            case 4:
																// This step Who are you raising for is combined to Fundraiser Details
	                                break;

	                            case 5:
						                    $(".camp-step-container").hide();
						                    $(".step-nav-icon").removeClass("step-nav-icon-gray");

						                    $("#step_container_5").show();
						                    $("#step_nav_icon_5").addClass("step-nav-icon-gray");

						                    $("#camp_step_tips_modal .modal-body").html($("#camp_step_tips_5").html());
						                    $("#hide_camp_step_tips").off("click").on("click", function () {
						                        Raisy.campaigns.step_tips_show_status.step5 = false;
						                        Raisy.campaigns.donot_show_step_tips();
						                    });

						                    if (Raisy.campaigns.step_tips_show_status.step5) {
						                        $("#camp_step_tips_modal").modal("show");
						                    }
															
	                                break;

	                            case 6:
	                                window.location.href = "/campaigns/" + d.slug + "/preview";
	                                break;
	                        }
	                    }
	                }
	            },
	            error: function () {
								window.Raisy.alert("抱歉，保存这个筹款团队时出了问题，请稍后再试。");
	            },
	            complete: function () {
								$button.prop('disabled', false).find('span.text').siblings('span.loader').hide();
							
                $('.datepicker').each(function (i) {
                    var d = $(this).val();
                    if (d && d.length > 0) {
                        $(this).val($.datepicker.formatDate('D, M d, yy', new Date(d)));
                    }
                });
	            }
	        });
       });
    },
    campaign_signup_account: function () {
        $("#campaign_signup_user").fadeOut(200, function () {
            $("#campaign_user_forget_pwd").hide();
            $("#user_email").val("");
            $("#user_password").val("");
            $("#user_first_name").val("");
            $("#user_last_name").val("");
            $("#campaign_terms_conditions").prop("checked", false);
            $("#campaign_form").validate().resetForm();
            $("#campaign_signup_user .form-group").removeClass("has-error");
            $(".welcome-back").hide();
            $(".campaign_user_alt_row").show();
            $("#campaign_signup_account_link").hide();
            $("#campaign_login_account_link").show();
            $("#campaign_form_submit span.text").text("创建我的帐户");
            $("#campaign_user_modal .modal-title").text("创建帐户");
            $("#campaign_new_user").val("1");
            $("#auth_provider").val("raisy");
            $("#auth_uid").val("");
            $("#campaign_social_links").css("margin-top", "35px");
            $("#campaign_social_error").hide();
            $("#campaign_social_message").text("");
            $(".campaign_form_submit span.text").text("继续");

            $("#campaign_signup_user").fadeIn(200);
        });
    },
    campaign_login_account: function () {
        $("#campaign_signup_user").fadeOut(200, function () {
            $("#campaign_user_forget_pwd").show();
            $("#user_email").val("");
            $("#user_password").val("");
            $("#user_first_name").val("");
            $("#user_last_name").val("");
            $("#campaign_terms_conditions").prop("checked", false);
            $("#campaign_form").validate().resetForm();
            $("#campaign_signup_user .form-group").removeClass("has-error");
            $(".welcome-back").show();
            $(".campaign_user_alt_row").hide();
            $("#campaign_login_account_link").hide();
            $("#campaign_signup_account_link").show();
            $("#campaign_form_submit span.text").text("登录");
            $("#campaign_user_modal .modal-title").text("登录到11号公益圈");
            $("#campaign_new_user").val("0");
            $("#auth_provider").val("raisy");
            $("#auth_uid").val("");
            $("#campaign_social_links").css("margin-top", "35px");
            $("#campaign_social_error").hide();
            $("#campaign_social_message").text("");
            $(".campaign_form_submit span.text").text("继续");

            $("#campaign_signup_user").fadeIn(200);
        });
    },
    step_tips_show_status: {step1: true, step2: true, step3_1: true, step3_2: true, step4: true, step5: true},
    donot_show_step_tips: function () {
        Raisy.campaigns.step_tips_show_status.step1 = false;
        Raisy.campaigns.step_tips_show_status.step2 = false;
        Raisy.campaigns.step_tips_show_status.step3_1 = false;
        Raisy.campaigns.step_tips_show_status.step3_2 = false;
        Raisy.campaigns.step_tips_show_status.step4 = false;
        Raisy.campaigns.step_tips_show_status.step5 = false;

        $.ajax('/ajax/campsteppopup', {
            type: 'GET',
            cache: false,
            data: {popup: "disable"},
            beforeSend: function (jqXHR, settings) {
                jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
            },
            success: function (data) {
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
            },
            complete: function () {
                $("#camp_step_tips_modal").modal("hide");
            }
        });
    },
    campaign_current_step: 1,
    preview_border_showed: false,
    draw_preview_border: function () {
        if (!Raisy.campaigns.preview_border_showed) false;

        $("#camp_preview_border").hide();

        var img = $("#camp_preview_img");
        var img_top = img.position().top;
        var img_left = img.position().left;
        var img_height = img.height();
        var img_width = img.width();
        var img_natural_height = 800;
        var img_natural_width = 705;
        var y_ratio = img_height / img_natural_height;
        var x_ratio = img_width / img_natural_width;
        var border_top, border_left, border_width, border_height;

        switch (Raisy.campaigns.campaign_current_step) {
            case 1:
                border_left = (img_left + Math.floor(8 * x_ratio)).toString() + "px";
                border_top = (img_top + Math.floor(256 * y_ratio)).toString() + "px";
                border_width = Math.ceil(389 * x_ratio).toString() + "px";
                border_height = Math.ceil(45 * y_ratio).toString() + "px";

                break;

            case 2:
                border_left = (img_left + Math.floor(8 * x_ratio)).toString() + "px";
                border_top = (img_top + Math.floor(340 * y_ratio)).toString() + "px";
                border_width = Math.ceil(690 * x_ratio).toString() + "px";
                border_height = Math.ceil(121 * y_ratio).toString() + "px";

                break;

            case 3:
                border_left = img_left.toString() + "px";
                border_top = img_top.toString() + "px";
                border_width = img_width.toString() + "px";
                border_height = Math.ceil(257 * y_ratio).toString() + "px";

                break;

            case 3.1:
                border_left = (img_left + Math.floor(8 * x_ratio)).toString() + "px";
                border_top = (img_top + Math.floor(337 * y_ratio)).toString() + "px";
                border_width = Math.ceil(226 * x_ratio).toString() + "px";
                border_height = Math.ceil(55 * y_ratio).toString() + "px";

                break;

            case 4:
                border_left = (img_left + Math.floor(467 * x_ratio)).toString() + "px";
                border_top = (img_top + Math.floor(445 * y_ratio)).toString() + "px";
                border_width = Math.ceil(213 * x_ratio).toString() + "px";
                border_height = Math.ceil(49 * y_ratio).toString() + "px";

                break;

            case 5:
                border_left = (img_left + Math.floor(259 * x_ratio)).toString() + "px";
                border_top = (img_top + Math.floor(526 * y_ratio)).toString() + "px";
                border_width = Math.ceil(412 * x_ratio).toString() + "px";
                border_height = Math.ceil(166 * y_ratio).toString() + "px";

                break;

            default:
                return;
        }



        $("#camp_preview_border").css({
            "left": border_left,
            "top": border_top,
            "width": border_width,
            "height": border_height,
        }).show();
    }
}
