window.party= {
    formvalidate:null,
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

            //var data=new Array();
            //
            //if(Raisy.campaigns.minilogo_data_cropper!=null&&Raisy.campaigns.minilogo_data_cropper.ischage==true)
            //{
            //    data[0]=_this.minilogo_data_cropper;
            //
            //}
            //if(Raisy.campaigns.logo_data_cropper!=null&&Raisy.campaigns.logo_data_cropper.ischage==true)
            //{
            //    data[1]=_this.logo_data_cropper;
            //}
            //
            ////alert(data.length);
            //if(data.length>0)
            //{
            //    $.post("/upload/photo_croper", {cropperdata1:data[0],cropperdata2:data[1]}).complete(formsubmit());
            //}
            //else
            //{
            //    formsubmit();
            //}
            formsubmit();
            function formsubmit()
            {
                //Raisy.campaigns.minilogo_data_cropper.ischage==false;
                //Raisy.campaigns.logo_data_cropper.ischage==false;
                window.setTimeout(function () {
                    form.submit();
                }, 50);
            }

        });
    }
}