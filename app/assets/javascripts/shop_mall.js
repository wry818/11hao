window.shopmall = {
    getStyle: function (obj, name) {
        if (obj.currentStyle) {
            return obj.currentStyle[name];
        } else {
            return getComputedStyle(obj, false)[name];
        }
    },

    getByClass: function ($oParent, nClass) {
        var eLe = $oParent.find("'" + nClass + "'");
        var aRrent = [];
        for (var i = 0; i < eLe.length; i++) {
            if (eLe[i].className == nClass) {
                aRrent.push(eLe[i]);
            }
        }
        return aRrent;
    },

    startMove: function (obj, att, add) {
        var _this = this;
        clearInterval(obj.timer);
        obj.timer = setInterval(function () {
            var cutt = 0;
            if (att == 'opacity') {
                cutt = Math.round(parseFloat(_this.getStyle(obj, att)));
            }
            else {
                cutt = Math.round(parseInt(_this.getStyle(obj, att)));
            }
            var speed = (add - cutt) / 4;
            speed = speed > 0 ? Math.ceil(speed) : Math.floor(speed);
            if (cutt == add) {
                clearInterval(obj.timer);
            }
            else {
                if (att == 'opacity') {
                    obj.style.opacity = (cutt + speed) / 100;
                    obj.style.filter = 'alpha(opacity:' + (cutt + speed) + ')';
                }
                else {
                    obj.style[att] = cutt + speed + 'px';
                }
            }

        }, 30);
    },

    //product_weixin
    StarRun: function () {
        var $oDiv = $('#playBox');
        var oPre = $oDiv.find(".pre");
        var oNext = $oDiv.find(".next");
        var oUlBig = $oDiv.find(".oUlplay").get(0);
        var aBigLi = $(oUlBig).find('li');
        var oDivSmall = $oDiv.find(".smalltitle");
        var $ulpoints=oDivSmall.find("ul");
        $ulpoints.css("width",20*$ulpoints.find("li").length+"px");
        var aLiSmall = $(oDivSmall).find('li');
        var _this = this;

        var li_width=$(window).outerWidth();
        var li_arry=[];
        for(var i=0;i<aBigLi.length;i++)
        {
            li_arry.push(aBigLi[i]);
            $(aBigLi[i]).css("left",i*li_width);
        }
        function tab() {
            for (var i = 0; i < aLiSmall.length; i++) {
                $(aLiSmall[i]).removeClass();
            }
            var aLiSmall_index=now%aBigLi.length;
            if(aLiSmall_index<0)
            {
                aLiSmall_index=-aLiSmall_index;
                //aLiSmall_index-=1;
                aLiSmall_index= aLiSmall.length-aLiSmall_index;
            }
            $(aLiSmall[aLiSmall_index]).addClass('thistitle');
            _this.startMove(oUlBig, 'left', -(now * aBigLi[0].offsetWidth));
        }

        var ismove=false;
        var now = 0;
        for (var i = 0; i < aLiSmall.length; i++) {
            aLiSmall[i].index = i;

            $(aLiSmall[i]).click(function () {
                now = this.index;
                tab();
            });
        }


        function _click() {
            if(ismove)
            {
                return;
            }
            ismove=true;
            now--;
            //if (now == -1) {
            //    now = aBigLi.length - 1;
            //}
            if (now% aBigLi.length==-1) {
                //var lifirst=  aBigLi.first();
                $(li_arry[3]).nextAll().remove();
                for(var i=0;i<=aBigLi.length-1;i++)
                {
                    $(oUlBig).prepend($(li_arry[i]).clone(true).css("left",(now-((aBigLi.length-1)-i))*li_width));
                }
            }
            tab();
            ismove=false;
        }

        oPre.click(function () {
            _click();
        });
        function __click() {
            if(ismove)
            {
                return;
            }
            ismove=true;
            now++;
            if (now% aBigLi.length==0) {
                //var lifirst=  aBigLi.first();
                $(li_arry[0]).prevAll().remove();
                for(var i=0;i<aBigLi.length;i++)
                {
                    $(oUlBig).append($(li_arry[i]).clone(true).css("left",(now+i)*li_width));
                }
            }
            $(oUlBig).find('li')
            //if ( now==aBigLi.length*2) {
            //    //var lifirst=  aBigLi.first();
            //
            //    $(oUlBig).html();
            //
            //    for(var i=0;i<aBigLi.length;i++)
            //    {
            //        $(oUlBig).append($(li_arry[i]).clone(true))
            //    }
            //    for(var i=0;i<aBigLi.length;i++)
            //    {
            //        $(oUlBig).append($(li_arry[i]).clone(true))
            //    }
            //}

            tab();
            ismove=false;
        }

        oNext.click(function () {
            __click();
        });


        //$oDiv.swipe(function(){
        // alert(0);
        //});
        //全局变量，触摸开始位置
        var startX = 0, startY = 0;
        var swipflag="";
        //touchstart事件
        function touchSatrtFunc(evt) {
            try
            {
                //evt.preventDefault(); //阻止触摸时浏览器的缩放、滚动条滚动等

                var touch = evt.touches[0]; //获取第一个触点
                var x = Number(touch.pageX); //页面触点X坐标
                var y = Number(touch.pageY); //页面触点Y坐标
                //记录触点初始位置
                startX = x;
                startY = y;

            }
            catch (e) {
                alert('touchSatrtFunc：' + e.message);
            }
        }

        //touchmove事件，这个事件无法获取坐标
        function touchMoveFunc(evt) {
            try
            {

                //evt.preventDefault(); //阻止触摸时浏览器的缩放、滚动条滚动等
                var touch = evt.touches[0]; //获取第一个触点
                var x = Number(touch.pageX); //页面触点X坐标
                var y = Number(touch.pageY); //页面触点Y坐标

                var text = 'TouchMove事件触发：（' + x + ', ' + y + '）';

                //判断滑动方向
                if (x - startX >5) {
                    evt.preventDefault();
                    text ="right";
                    //clearInterval(timer)
                    //_click();
                    //timer = setInterval(__click, 3000)
                }
                if (x - startX <-5) {
                    evt.preventDefault();
                    text ="left";
                    //clearInterval(timer)
                    //__click();
                    //timer = setInterval(__click, 3000)
                }
                swipflag=text;
                //if (y - startY != 0) {
                //    text += '<br/>上下滑动';
                //}

            }
            catch (e) {
                alert('touchMoveFunc：' + e.message);
            }
        }

        //touchend事件
        function touchEndFunc(evt) {
            try {
                //alert(swipflag);
               // //evt.preventDefault(); //阻止触摸时浏览器的缩放、滚动条滚动等
               //
                if(aBigLi.length<=1)
                {
                    return;
                }
               if(swipflag=="left")
               {
                   __click();
               }
                if(swipflag=="right")
                {
                    _click();
                }
               // alert(swipflag);
            }
            catch (e) {
                alert('touchEndFunc：' + e.message);
            }
        }

        //绑定事件
        function bindEvent() {
            $oDiv.get(0).addEventListener('touchstart', touchSatrtFunc, false);
            $oDiv.get(0).addEventListener('touchmove', touchMoveFunc, false);
            $oDiv.get(0).addEventListener('touchend', touchEndFunc, false);
        }

        //判断是否支持触摸事件
        function isTouchDevice() {
            try {
                document.createEvent("TouchEvent");
                //alert("支持TouchEvent事件！");

                bindEvent(); //绑定事件
            }
            catch (e) {
                //alert("不支持TouchEvent事件！" + e.message);
                //var timer = setInterval(_click, 3000) //滚动间隔时间设置
                //$oDiv.mouseover(function () {
                //    clearInterval(timer)
                //});
                //$oDiv.mouseout(function () {
                //    timer = setInterval(__click, 3000) //滚动间隔时间设置
                //});
                if(aBigLi.length<=1)
                {
                    return;
                }
                oPre.css("z-index",100);
                oNext.css("z-index",100);
            }
        }
        isTouchDevice();

        //var timer = setInterval(_click, 3000) //滚动间隔时间设置

    },

    showbug: function () {
        $(".js-showActionBuy").click(function () {
            $this = $(this);
            var mask = $('#mask');
            var weuiActionsheet = $('#weui_actionsheet');
            weuiActionsheet.addClass('weui_actionsheet_toggle');
            $("body").css("overflow","hidden");
            var startY=0;
            $("body").bind("touchstart",function(evt){
                try
                {
                    //evt.preventDefault(); //阻止触摸时浏览器的缩放、滚动条滚动等

                    var touch = evt.originalEvent.targetTouches[0];  //获取第一个触点
                    var x = Number(touch.pageX); //页面触点X坐标
                    var y = Number(touch.pageY); //页面触点Y坐标
                    //记录触点初始位置

                    startY = y;

                }
                catch (e) {
                    alert('touchSatrtFunc：' + e.message);
                }
            })
            $("body").bind("touchmove",function(evt){
                try
                {
                    evt.preventDefault(); //阻止触摸时浏览器的缩放、滚动条滚动等
                    var touch = evt.originalEvent.targetTouches[0];  //获取第一个触点
                    var x = Number(touch.pageX); //页面触点X坐标
                    var y = Number(touch.pageY); //页面触点Y坐标
                    var scrolltoptemp=0;
                    if (y - startY != 0) {
                        var scrolltoptemp=(y - startY)/8;
                        $(".js-options-select").scrollTop($(".js-options-select").scrollTop()-scrolltoptemp);
                    }
                    //console.log(y);
                    console.log(scrolltoptemp);

                }
                catch (e) {
                    alert('touchMoveFunc：' + e.message);
                }
            });
            //alert(1);
            mask.show().addClass('weui_fade_toggle').one('click', function () {
                hideActionSheet(weuiActionsheet, mask);
                $("body").css("overflow","auto");
                $("body").unbind("touchmove");
                $("body").unbind("touchstart");
                //alert(2);
            });
            $('#actionsheet_cancel').one('click', function () {
                hideActionSheet(weuiActionsheet, mask);
                $("body").css("overflow","auto");
                $("body").unbind("touchmove");
                $("body").unbind("touchstart");
                //alert(2);
            });
            weuiActionsheet.unbind('transitionend').unbind('webkitTransitionEnd');
            function hideActionSheet(weuiActionsheet, mask) {
                weuiActionsheet.removeClass('weui_actionsheet_toggle');
                mask.removeClass('weui_fade_toggle');
                weuiActionsheet.on('transitionend', function () {
                    mask.hide();
                }).on('webkitTransitionEnd', function () {
                    mask.hide();
                })
            }

            //alert($this.prop("id"));
            if ($this.prop("id") == "showActionBuy") {
                $("#btn_buy_next").css("display", '');
                $("#btn_buy_box").css("display", 'none');
            } else {
                $("#btn_buy_next").css("display", 'none');
                $("#btn_buy_box").css("display", '');
            }
        });

    },
    donation_input_show: function () {
        $(".js-showActionDonation").click(function () {
            $this = $(this);
            var mask = $('#mask_input');
            var weuiActionsheet = $('#weui_actionsheet_input');
            weuiActionsheet.addClass('weui_actionsheet_toggle');
            mask.show().addClass('weui_fade_toggle').one('click', function () {
                hideActionSheet(weuiActionsheet, mask);
            });
            $('#actionsheet_cancel_input').one('click', function () {
                hideActionSheet(weuiActionsheet, mask);
            });
            weuiActionsheet.unbind('transitionend').unbind('webkitTransitionEnd');
            function hideActionSheet(weuiActionsheet, mask) {
                weuiActionsheet.removeClass('weui_actionsheet_toggle');
                mask.removeClass('weui_fade_toggle');
                weuiActionsheet.on('transitionend', function () {
                    mask.hide();
                }).on('webkitTransitionEnd', function () {
                    mask.hide();
                })
            }

            var $direct_donation_input=$("#direct_donation_input");
            var $direct_donation_hid_input=$("#donation_add");
            //调用文本框的id
            $direct_donation_input.numeral(true);

            $direct_donation_input.bind("blur", function () {
                if ($(this).val().length > 0) {
                    $direct_donation_hid_input.val($(this).val());

                    $("#personal_modalbody a").each(function () {
                        $(this).css('border', "1px solid #dddddd");
                    });
                }
            });
            $("#personal_modalbody a").bind('click', function () {
                $direct_donation_input.val("");
                $direct_donation_hid_input.val($(this).data("value"));
                $("#personal_modalbody a").each(function () {
                    $(this).css('border', "1px solid #dddddd");
                });

                $(this).css('border', "solid 2px red");
            });

            $("#personal_modalbody a")[0].click();

        });

    },
    optionSelect: function () {
        if($(".js-options-select").html()==null)
        {
            return;
        }

        $ui = $(".js-options-select").find("li");

        $ui.click(function () {
            $ui.css("border", "1px solid rgb(229, 229, 229)");
            $(this).css("border", "1px solid rgb(255, 102, 0)");
            var value=$(this).data("price");
            $("#product_price_span_show").html(value);
            $("input[name='item[options][][value]']").val($(this).data("id"));
        });

        $ui[0].click();
    },

    quantitySelect: function () {
        var value = parseInt($("#item_quantity").val());

        function edit(a) {
            if (a == 2) {
                value = value - 1;
            }
            else {
                value = value + 1;
            }

            if (value <= 1) {
                value = 1;
            }
            $("#item_quantity").val(value);
            $("#btn-count-value").val(value);

        }

        $("#btn-count-minus").click(function () {
            edit(2);
        });
        $("#btn-count-plus").click(function () {
            edit(1);
        });
    },

    addOrderItem: function () {
        $cart = $("#footer_cart");
        var cart_count = parseInt($cart.data("count"));
        //if (cart_count < 1) {
        //    $cart.hide();
        //}
        $cart.on("click", function () {
            cart_count = parseInt($cart.attr("data-count"));
            if (cart_count < 1) {

                return;
            }
            window.location.href = "/checkout/checkout_weixin?id=" + $("#campaign_slug").val() + "&showwxpaytitle=1&agent_type=weixin&cart=true";
        });
        var is_add_to_cart = false;
        $("#btn_buy_next").click(function () {
            is_add_to_cart = false;
            addOrderItem();
        });
        $("#btn_buy_box").click(function () {
            is_add_to_cart = true;
            addOrderItem();

        });
        function addOrderItem() {
            var errors = false;
            var $this = $(this);
            var $form = $('form.product-form');
            if (!errors) {
                $.ajax('/ajax/update-cart', {
                    type: 'POST',
                    data: $form.serialize(),
                    beforeSend: function (jqXHR, settings) {
                        jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
                    },
                    success: function (data) {
                        if (data != 'fail') {
                            if (is_add_to_cart) {
                                cart_count = parseInt($cart.attr("data-count"))
                                cart_count = cart_count + parseInt($("#btn-count-value").val());
                                $cart.attr("data-count", cart_count);
                                $cart.find(".cart-count").text($cart.attr("data-count"));
                                $cart.show();
                                $('#actionsheet_cancel').click();
                            }
                            else {
                                window.location.href = "/checkout/checkout_weixin?id=" + $("#campaign_slug").val() + "&showwxpaytitle=1&agent_type=weixin&cart=true";
                            }
                        }else
                        {
                            alert("订单更新异常请刷新后重试");
                        }

                    },
                    complete: function () {

                    }
                });
            }
        }
    },

    loadCart: function () {
        $edit = $("#js-btn-edit");
        var isEdit = false;
        $edit.bind('click', function () {
            //if (isEdit) {
            //    hidEdit();
            //} else {
            //    showEdit();
            //}
            //isEdit = !isEdit;
            var $dialog = $('#dialog1');
            $dialog.show();
            $dialog.find('.weui_btn_dialog').one('click', function () {
                $dialog.hide();
            });
            $dialog.find(".js-btn-ok").click(function(){
                $('.delete-item').click();
            });
        });
        function showEdit() {
            $(".js-view").hide();
            $(".js-edit").show();
        }

        function hidEdit() {
            $(".js-view").show();
            $(".js-edit").hide();
        }

        showEdit();
    },
    updateQuantity: function () {
        $btn_minus = $(".btn-count-minus");
        $quantity_val = new Object();
        $btn_plus = $(".btn-count-plus");

        var quantity_val = 0;
        $btn_minus.click(function () {
            $quantity_val = $(this).next("input");
            quantity_val = parseInt($quantity_val.val());
            if (quantity_val == 1) {
                return;
            }
            quantity_val = quantity_val - 1;
            quantityUpdate();
        })

        $btn_plus.click(function () {
            $quantity_val = $(this).parent().find("input");
            quantity_val = parseInt($quantity_val.val());
            quantity_val = quantity_val + 1;
            quantityUpdate();
        });

        function quantityUpdate() {
            var item_id = $quantity_val.data("itemid");
            var quantity = quantity_val;
            var order_id = $quantity_val.data("orderid");
            var parent_page = "";
            var campaign_id = $quantity_val.data("campaignid");
            $.ajax('/ajax/update-cart', {
                type: 'POST',
                data: {
                    item: {item_id: item_id, order_id: order_id, quantity: quantity, campaign_id: campaign_id},
                    parent_page: parent_page
                },
                beforeSend: function (jqXHR, settings) {
                    jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
                },
                success: function (data) {
                    if (data != 'fail') {
                        //alert(order_id);
                        refresh(order_id,$(".js-panel"));
                    }
                    else {

                    }
                }
            });
        }

        _this=this;
        function refresh(order_id,panel) {
            _this.cart_modal_weixin_refresh(order_id,panel);
        }
    },

    orderItemDelete: function () {

        $('.delete-item').on("click", function () {
            var $this = $(this);
            var $quantity_val = $this.parent().find('.btn-count-value');
            var item_id = $quantity_val.data("itemid");
            var order_id = $quantity_val.data("orderid");
            var parent_page = "";
            var campaign_id = $quantity_val.data("campaignid");
            $.ajax('/ajax/update-cart', {
                type: 'POST',
                data: {
                    item: {item_id: item_id, order_id: order_id, quantity: 0, campaign_id: campaign_id},
                    parent_page: parent_page
                },
                beforeSend: function (jqXHR, settings) {
                    jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
                },
                success: function (data) {
                    if (data != 'fail') {
                        refresh(order_id,$(".js-panel"));
                    }
                    else {

                    }
                }
            });
        });

        _this=this;
        function refresh(order_id,panel) {
            _this.cart_modal_weixin_refresh(order_id,panel);
        }
    },
    orderUpdateAddDonation:function(){
      $("#btn_submit1").click(function(){
          var $this=$(this);
          $this.prop('disabled', true);
          var $form = $('form.js-form-direct_donation_add');
          var order_id=$(".js-order-id").val();
              $.ajax('/ajax/update-order-add', {
                  type: 'POST',
                  data: $form.serialize(),
                  beforeSend: function (jqXHR, settings) {
                      jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
                  },
                  success: function (data) {
                      if (data != 'fail') {

                          refresh(order_id,$(".js-panel"));
                          $('#actionsheet_cancel_input').click();
                      }
                      else {

                      }
                  },
                  complete: function () {
                      $this.prop('disabled', false);
                  }
              });
      });
        _this=this;
        function refresh(order_id,panel) {
            _this.cart_modal_weixin_refresh(order_id,panel);
        }
    },
    cart_modal_weixin_refresh: function (order_id,panel) {
        _this=this;
        $.ajax('/ajax/order-summary', {
            type: 'POST',
            data: { order_id: order_id,cart_weixin:true },
            beforeSend: function(jqXHR, settings) {
                jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
            },
            success: function(data) {
                if(data != 'fail') {
                    panel.html(data);
                    _this.loadCart();
                    _this.orderItemDelete();
                    _this.updateQuantity();
                    _this.donation_input_show();
                    _this.orderUpdateAddDonation();
                }
            },
            complete: function () {

            }

        });
    },
    party_input_show: function () {
        $(".js-showActionPary").click(function () {
            $this = $(this);
            var mask = $('#mask_input');
            var weuiActionsheet = $('#weui_actionsheet_input');
            weuiActionsheet.addClass('weui_actionsheet_toggle');
            mask.show().addClass('weui_fade_toggle').one('click', function () {
                hideActionSheet(weuiActionsheet, mask);
            });
            $('#actionsheet_cancel_input').one('click', function () {
                hideActionSheet(weuiActionsheet, mask);
            });
            weuiActionsheet.unbind('transitionend').unbind('webkitTransitionEnd');
            function hideActionSheet(weuiActionsheet, mask) {
                weuiActionsheet.removeClass('weui_actionsheet_toggle');
                mask.removeClass('weui_fade_toggle');
                weuiActionsheet.on('transitionend', function () {
                    mask.hide();
                }).on('webkitTransitionEnd', function () {
                    mask.hide();
                })
            }

        });
        var $participent_form=$("#participant");
        var $btn_submit1=  $("#btn_submit1");
        $("#btn_submit1").bind("click",function(){
            if($(this).hasClass("js-is-show-pay"))
            {
                return;
            }else {
                $(this).addClass("js-is-show-pay");
            }
            if($("#participant_name").val().length==0)
            {
                alert("名字不能为空");
                return;
            }
            if($("#participant_tel").val().length==0)
            {
                alert("电话不能为空");
                return;
            }
            //alert($participent_form.serialize());
            $.ajax('/ajax/ajax_create_participant', {
                type: 'POST',
                data: $participent_form.serialize(),
                beforeSend: function (jqXHR, settings) {
                    jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
                },
                success: function (data) {
                    if(data!=null)
                    {
                        if(data=="error")
                        {

                        }else
                        {
                            if(data.order_id>0)
                            {
                                if (typeof WeixinJSBridge == "undefined") {
                                    if (document.addEventListener) {
                                        document.addEventListener('WeixinJSBridgeReady', onBridgeReady, false);
                                    } else if (document.attachEvent) {
                                        document.attachEvent('WeixinJSBridgeReady', onBridgeReady);
                                        document.attachEvent('onWeixinJSBridgeReady', onBridgeReady);
                                    }
                                } else {
                                    weixin_load(data.order_id);
                                }

                            }
                            else
                            {
                                $('#actionsheet_cancel_input').click();
                                $(".js-showActionPary").unbind("click");
                                $(".js-showActionPary").find("a").text("您已成功报名");
                                $btn_submit1.removeClass("js-is-show-pay");
                                location.replace(location.href);
                            }

                        }
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert("抱歉，更新订单时出了问题，请联系我们帮您解决。");
                    $btn_submit1.removeClass("js-is-show-pay");
                }
            });
        });

        function weixin_load(order_id) {
//      alert(order_id);
            $.ajax({
                method: "get",
                url: "/weixin_payment_get_req/" + order_id,
                dataType: "json",
                cache: false,
                success: function (d) {
//            alert(33333);
//            alert(d);
                    if (d) {
//              alert("  "+ d.appId+"  "+ d.timeStamp+"  "+ d.nonceStr+"  "+ d.package+"  "+ d.paySign);
                        WeixinJSBridge.invoke('getBrandWCPayRequest', {
                            "appId": d.appId,     //公众号名称，由商户传入
                            "timeStamp": d.timeStamp,         //时间戳，自1970年以来的秒数
                            "nonceStr": d.nonceStr, //随机串
                            "package": d.package,
                            "signType": "MD5",         //微信签名方式:
                            "paySign": d.paySign //微信签名
                        }, function (res) {
                //alert(res.err_msg);
                            if (res.err_msg == "get_brand_wcpay_request:ok") {
                                ComfirmOrder(order_id);
                            } else {
//              $('#wechat').prop('disabled', false);
//                                alert(22);
                                $btn_submit1.removeClass("js-is-show-pay");
                            }
                        });
                    }
                    else {
//          $('#wechat').prop('disabled', false);
//                        alert(32);
                        $btn_submit1.removeClass("js-is-show-pay");
                    }
                },
                error:function(XMLHttpRequest, textStatus, errorThrown) {
//            alert(XMLHttpRequest.status);
//            alert(XMLHttpRequest.readyState);
//            alert(textStatus);
//                    $('#wechat').prop('disabled', false);
//                    alert(42);
                    $btn_submit1.removeClass("js-is-show-pay");
                },
                complete: function () {
//            alert(1111);
                }
            });

        }

        function ComfirmOrder(order_id) {
            var order_time = new Date();
            var format_order_time = order_time.getFullYear() + "年" + (order_time.getMonth() + 1) + "月" + order_time.getDate() + "日 " + order_time.getHours() + ":" + order_time.getMinutes() + ":" + order_time.getSeconds();
            var data = {
                order_id: order_id,
                format_order_time: format_order_time,
            };
            $.ajax('/ajax/ajax_update_participant', {
                type: 'POST',
                data: data,
                beforeSend: function (jqXHR, settings) {
                    jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
                },
                success: function (data) {
                    $('#actionsheet_cancel_input').click();
                    $(".js-showActionPary").unbind("click");
                    $(".js-showActionPary").find("a").text("您已成功报名");
                    $btn_submit1.removeClass("js-is-show-pay");
                    location.replace(location.href);
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    //alert("抱歉，更新订单时出了问题，请联系我们帮您解决。");
                    $btn_submit1.removeClass("js-is-show-pay");
                }
            });

        }
    }
}
$(document).ready(function () {
    //window.shopmall.StarRun();
    //window.shopmall.showbug();
    //window.shopmall.optionSelect();
    //window.shopmall.quantitySelect();
    //window.shopmall.addOrderItem();
    //$("#playBox").css("width", $(window).outerWidth());
    //$('#playBox').find(".oUlplay").find("li").css("width", $(window).outerWidth());

    //var liwidth =getComputedStyle($('#playBox').find(".oUlplay").get(0), false)["width"] ;
    //alert(liwidth);

});