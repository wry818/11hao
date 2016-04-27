window.party= {
    formvalidate:null,
    logo_data_cropper:{ischage:false,x:0,y:0,height:0,width:0, scaleX:0,scaleY:0,filename:""},
    init:function(){
        _this=this;
        $("#btn-submit").click(function(){
            $("#party_form").submit();
        });
        _this.formvalidate= $("#party_form").validate({

            // custom handler to call named function ""
            submitHandler: function(form) {
                _this.submitform(form);
            },

            // validate the previously selected element when the user clicks out
            onfocusout: function(element) {
                $(element).valid();
            },

            highlight: function(element) {
                $(element).closest('.form-group').addClass('has-error');
            },

            unhighlight: function(element) {
                $(element).closest('.form-group').removeClass('has-error');
            },

            ignore: ":hidden",

            errorPlacement: function(error, element) {
                if (element.hasClass("campaign-collection-id") || element.attr("type") == "checkbox")
                    error.appendTo(element.parent());
                else
                    error.insertAfter(element);
            },

            // validation rules
            rules: {
                //"organization_name": { required: true },
                //"campaign[collection_id]": { required: false },
                //"campaign[title]": { required: true, maxlength: 100 },
                //"campaign[organizer_quote]": {required: true, maxlength: 100 },
                //"campaign[goal]": { number: true, min: 1 },
                //"campaign[seller_goal]": { number: true, min: 1 },
                "max_count": { required: true,digits: true},
                "party[address]": { required: true },
                "address": { required: true},
                "party[register_end]": { required: true },
                "party[end_time]": { required: true },
                "party[begin_time]": { required: true },
                "party[name]": { required: true }
            },
            messages: {
                //"organization_name": {
                //    required: "请选择一个组织"
                //},
                //"campaign[collection_id]": {
                //    required: "请选择一件商品"
                //},
                //"campaign[title]": {
                //    required: "请输入筹款标题",
                //    maxlength: "筹款页面标题至少要100个字符"
                //},
                //"campaign[organizer_quote]": {
                //    required: "请输入筹款宣传标语",
                //    maxlength: "副筹款页面标题至少要100个字符"
                //},
                //"campaign[goal]": {
                //    number: "请只输入数字",
                //    min: "目标至少要1元"
                //},
                "max_count": {
                    digits: "请只输入整数",
                    required: "请输入活动参与上限人数"
                },
                "party[address]": {
                    required: "请输入活动详细地址"
                },
                "address": {
                    required: "请选择活动所在位置"
                },
                "party[register_end]": {
                    required: "请输入报名截止时间"
                },
                "party[end_time]": {
                    required: "请输入结束时间"
                },
                "party[begin_time]": {
                    required: "请输入开始时间"
                },
                "party[name]": {
                    required: "请输入活动主题"
                }
            }
        });
        $("#party_form").validate();
        $(".party-continue-btn").bind("click",function(e){
            var stepindex=$(this).data("currentstep");
            $(".party-step-container").hide();
            $("#party_content").val(my_editor.html());
            switch(stepindex)
            {
                case 1:
                    $("#party_form").validate().element("#party_name");
                    $("#party_form").validate().element("#party_begin_time");
                    $("#party_form").validate().element("#party_end_time");
                    $("#party_form").validate().element("#party_register_end");
                    $("#party_form").validate().element("#party_address");
                    if (!_this.formvalidate.valid())
                    {
                        $("#step_container_1").show();
                        return;
                    }
                    if ($("#party_name").val().length<1)
                    {
                        $("#step_container_1").show();
                        alert("活动主题不能为空");
                        return;
                    }
                    if ($("#party_begin_time").val().length<1)
                    {
                        $("#step_container_1").show();
                        alert("活动开始时间不能为空");
                        return;
                    }
                    if ($("#party_end_time").val().length<1)
                    {
                        $("#step_container_1").show();
                        alert("活动结束时间不能为空");
                        return;
                    }
                    if ($("#party_register_end").val().length<1)
                    {
                        $("#step_container_1").show();
                        alert("活动报名截止时间不能为空");
                        return;
                    }
                    if ($("#party_address").val().length<1)
                    {
                        $("#step_container_1").show();
                        alert("活动详细地址不能为空");
                        return;
                    }

                    $("#step_container_2").show();
                    break;
                case 2:
                    $("#step_container_3").show();
                    break;
                case 3:
                    $("#step_container_3").show();
                    $("#party_form").submit();
                    break;
            }
        });
        $(".party-back-btn").bind("click",function(){
            var stepindex=$(this).data("currentstep");
            $(".party-step-container").hide();
            switch(stepindex)
            {
                case 1:
                    history.back();
                    break;
                case 2:
                    $("#step_container_1").show();
                    break;
                case 3:
                    $("#step_container_2").show();
                    break;
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


        //$("#party_begin_time").focus();
        //$("#party_end_time").val($("#party_end_time").val());
        //$("#party_register_end").val($("#party_register_end").val());
    },
    initTicket: function () {
        var str='<tr>'
            +'<td><label class="control-label">index</label></td>'
            +'<td><input type="text" class="form-control" placeholder="收费类型" name="tickets[item[type[index]]]"/></td>'
            +'<td><input type="text" class="form-control" placeholder="金额免费请写0" name="tickets[item[fee[index]]]"/></td>'
            +'<td><input type="text" class="form-control" placeholder="人数限制" name="tickets[item[count[index]]]"/></td>'
            +'<td><button type="button" class="btn btn-default">清空</button></td>'
            +'</tr>';
        $(".js-btn-ticket-add").bind('click',function(){
            var index=$(".js-hid-ticket-count").val();

            index=parseInt(index);
            //if(index!=1){
            //    index+=1;
            //}
            if(index>=10){
                alert("最多只能添加9张电子票");
                return;
            }

            var trcontent=str.split("index").join(index);
            //alert( $(this).closest("tr").html());
            $(this).closest("tr").before(trcontent);
            index+=1;
            $(".js-hid-ticket-count").val(index);
        });
        $(".js-btn-ticket-add").click();
    },
    initFee:function(){
        $freefee=$("#optionsRadios1");
        var val=$('input:radio[name="optionsRadiosfee"]:checked').val();
        function notfee()
        {
            //$(".js-tickets-table").hide();

            $(".js-fee-count").hide();
        }
        function fee()
        {
            //$(".js-tickets-table").show();
            $(".js-fee-count").show();
            $("#fee_count").numeral(true);
        }
        if(val=="option1")// not fee
        {
            notfee();
        }else if (val=="option2")// fee
        {
            fee();
        }
        $("input:radio[name='optionsRadiosfee']").bind('change',function(){
            val=$('input:radio[name="optionsRadiosfee"]:checked').val();
            if(val=="option1")// not fee
            {
                notfee();
            }else if (val=="option2")// fee
            {
                fee();
            }
        });
    },
    submitform:function(form){
        $btn_submit=$("#btn-submit");
        $btn_submit.prop('disabled', true).find('span.text').text('发布中...').siblings('span.loader').show('fast', function () {

            var data=new Array();

            if(window.party.logo_data_cropper!=null&&window.party.logo_data_cropper.ischage==true)
            {
                data[0]=window.party.logo_data_cropper
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
                window.party.logo_data_cropper.ischage==false;
                window.setTimeout(function () {
                    form.submit();
                }, 50);
            }

        });
    },
    orders_list_pager_url_ajax:"",
    orders_list_pager_init:function(){

        $(function () {
            bind_pager_click();
//    替换默认的分页是分页变成异步发送
            function bind_pager_click()
            {
                var pagers=$("div#page_pager .pagination span a");
                pagers.each(function(){
                    var url=this.href;
                    this.href="javascript:void(0);";
                    $(this).off("click").on("click", function(){
                        $("div.all_report_loader").show();
                        $("#activity_report_content").html("");
                        load_download_pagedata(url);
                    });
                });
            }
//   绑定查询的执行方法
            $("#run_report").bind('click', function () {

                $("div.all_report_loader").show();
                $("#activity_report_content").html("");
                var url=Raisy.chairperson_dashboard.orders_list_pager_url_ajax;
                load_download_pagedata(url);
            });
            $("#run_report").click();
//    异步加载分页数据
            function  load_download_pagedata(url)
            {
                var order_type_flag= $("#all_report_order_type_flag_selector").val();
                var from_date=$("#from_date").val();
                var to_date=$("#to_date").val();
                var event_id=$("#all_report_event_selector").val();
                $.post(url,{ order_type_flag:order_type_flag, from_date:from_date, to_date:to_date,event_id:event_id }).success(function (data, textStatus, jqXHR) {
                    $("#activity_report_content").html(data);
                    bind_pager_click();
                }).error(function() {
                    alert("请求已经结束但是可能发生了错误！");
                }).complete(function() {
                    $("div.all_report_loader").hide();
                });
            }
            $("#load_data_to_xls").bind("click",function(){
                var order_type_flag= $("#all_report_order_type_flag_selector").val();
                var from_date=$("#from_date").val();
                var to_date=$("#to_date").val();
                var url= $(this).attr("href");
                url+="?order_type_flag="+order_type_flag+"&from_date="+from_date+"&to_date="+to_date;
                $(this).attr("href",url);
            });
        });

    }
}