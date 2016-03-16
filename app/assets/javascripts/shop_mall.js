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
        if($(".js-options-select").html()==null)
        {
            return;
        }

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
        if (cart_count < 1) {
            $cart.hide();
        }
        $cart.one("click", function () {
            window.location.href = "/checkout/checkout_weixin?id=" + $("#campaign_slug").val() + "&showwxpaytitle=1&agent_type=weixin&cart=true";
        });
        var is_add_to_cart = false;
        $("#btn_buy_next").click(function () {
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
                                window.location.href = "/checkout/checkout_weixin?id=" + $("#campaign_slug").val() + "&showwxpaytitle=1&agent_type=weixin";
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
            if (isEdit) {
                hidEdit();
                $edit.text("编辑");
            } else {
                showEdit();
                $edit.text("完成");
            }
            isEdit = !isEdit;

        });
        function showEdit() {
            $(".js-view").hide();
            $(".js-edit").show();
        }

        function hidEdit() {
            $(".js-view").show();
            $(".js-edit").hide();
        }

        hidEdit();
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
                    $("#js-btn-edit").click();
                }
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