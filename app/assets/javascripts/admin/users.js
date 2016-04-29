window.adminusers={
    minilogo_data_cropper:{ischage:false,x:0,y:0,height:0,width:0, scaleX:0,scaleY:0,filename:""},
    init:function(){
        _this=this;
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
        $(".js-btn-submit").bind("click",function(){
            $(this).prop('disabled', true).find('span.text').text('保存中...').siblings('span.loader').show('fast', function () {

                var data=new Array();

                if(_this.minilogo_data_cropper!=null&&_this.minilogo_data_cropper.ischage==true)
                {
                    data[0]=_this.minilogo_data_cropper;

                }
                //alert(data.length);
                if(data.length>0)
                {
                    $.post("/upload/photo_croper", {cropperdata1:data[0]}).complete(formsubmit());
                }
                else
                {
                    formsubmit();
                }

                function formsubmit()
                {
                    _this.minilogo_data_cropper.ischage==false;
                    window.setTimeout(function () {
                        $(".user_form").submit();
                    }, 50);
                }

            });
        });
    }
}