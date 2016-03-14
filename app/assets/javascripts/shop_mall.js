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

    StarRun: function () {
        var $oDiv = $('#playBox');
        var oPre = $oDiv.find(".pre");
        var oNext = $oDiv.find(".next");
        var oUlBig = $oDiv.find(".oUlplay").get(0);
        var aBigLi = $(oUlBig).find('li');
        var oDivSmall = $oDiv.find(".smalltitle");

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
        var timer = setInterval(_click, 3000) //滚动间隔时间设置
        $oDiv.mouseover(function () {
            clearInterval(timer)
        });
        $oDiv.mouseout(function () {
            timer = setInterval(__click, 3000) //滚动间隔时间设置
        });
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

    optionSelect: function () {
        $ui = $(".js-options-select").find("li");
        $ui.click(function () {
            $ui.css("border", "1px solid rgb(229, 229, 229)");
            $(this).css("border", "1px solid rgb(255, 102, 0)");
            $("input[name='item[options][][value]']").val($(this).data("id"));
        });

        $ui[0].click();
    },

    quantitySelect: function () {
        var value = parseInt($("#item_quantity").val());

        function edit(a) {
            if(a==2)
            {
                value = value -1;
            }
            else {
                value = value +1;
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

    addOrderItem: function() {
        $cart=$("#footer_cart");
        var cart_count=parseInt($cart.data("count"));
        if(cart_count<1)
        {
            $cart.hide();
        }
        $cart.one("click",function(){
            window.location.href="/checkout/checkout_weixin?id="+$("#campaign_slug").val()+"&showwxpaytitle=1&agent_type=weixin";
        });
        var  is_add_to_cart=false;
        $("#btn_buy_next").click(function(){
            addOrderItem();
        });
        $("#btn_buy_box").click(function(){
            is_add_to_cart=true;
            addOrderItem();

        });
        function addOrderItem() {
            var errors = false;
            var $this = $(this);
            var $form = $('form.product-form');
            if (!errors) {
                $this.prop('disabled', true).find('span.text').siblings('span.loader').show();
                $.ajax('/ajax/update-cart', {
                    type: 'POST',
                    data: $form.serialize(),
                    beforeSend: function (jqXHR, settings) {
                        jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
                    },
                    success: function (data) {
                        if (data != 'fail') {
                            if(is_add_to_cart)
                            {
                                cart_count=parseInt($cart.data("count"))
                                cart_count=cart_count+parseInt($("#btn-count-value").val());
                                $cart.attr("data-count",cart_count);
                                $cart.find(".cart-count").text($cart.attr("data-count"));
                                $cart.show();
                                $('#actionsheet_cancel').click();
                            }
                            else {
                                window.location.href="/checkout/checkout_weixin?id="+$("#campaign_slug").val()+"&showwxpaytitle=1&agent_type=weixin";
                            }
                        }
                    },
                    complete: function () {
                        $this.prop('disabled', false).find('span.text').siblings('span.loader').hide();
                    }
                });
            }
        }
    }
}
$(document).ready(function () {
    window.shopmall.StarRun();
    window.shopmall.showbug();
    window.shopmall.optionSelect();
    window.shopmall.quantitySelect();
    window.shopmall.addOrderItem();
    $("#playBox").css("width", $(window).outerWidth());
    $('#playBox').find(".oUlplay").find("li").css("width", $(window).outerWidth());

    //var liwidth =getComputedStyle($('#playBox').find(".oUlplay").get(0), false)["width"] ;
    //alert(liwidth);

});