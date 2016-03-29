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

        function tab() {
            for (var i = 0; i < aLiSmall.length; i++) {
                $(aLiSmall[i]).removeClass();
            }
            $(aLiSmall[now]).addClass('thistitle');
            _this.startMove(oUlBig, 'left', -(now * aBigLi[0].offsetWidth));
        }

        var now = 0;
        for (var i = 0; i < aLiSmall.length; i++) {
            aLiSmall[i].index = i;

            $(aLiSmall[i]).click(function () {
                now = this.index;
                tab();
            });
        }
        function _click() {
            now--;
            if (now == -1) {
                now = aBigLi.length - 1;
            }
            tab();
        }

        oPre.click(function () {
            _click();
        });
        function __click() {
            now++;
            if (now == aBigLi.length) {
                now = 0;
            }
            tab();
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
                if (x - startX >10) {
                    text ="right";
                    //clearInterval(timer)
                    _click();
                    //timer = setInterval(__click, 3000)
                    return false;
                }
                if (x - startX <-10) {
                    text ="left";
                    //clearInterval(timer)
                    __click();
                    //timer = setInterval(__click, 3000)
                    return false;
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
               // alert(swipflag);
               // //evt.preventDefault(); //阻止触摸时浏览器的缩放、滚动条滚动等
               //
               //if(swipflag=="left")
               //{
               //    _click();
               //}
               // if(swipflag=="right")
               // {
               //     __click();
               // }
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
                var timer = setInterval(_click, 3000) //滚动间隔时间设置
                $oDiv.mouseover(function () {
                    clearInterval(timer)
                });
                $oDiv.mouseout(function () {
                    timer = setInterval(__click, 3000) //滚动间隔时间设置
                });
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
            mask.show().addClass('weui_fade_toggle').one('click', function () {
                hideActionSheet(weuiActionsheet, mask);
            });
            $('#actionsheet_cancel').one('click', function () {
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