
window.shopmall = {
    getStyle: function (obj, name) {
        if (obj.currentStyle) {
            return obj.currentStyle[name];
        } else {
            return getComputedStyle(obj, false)[name];
        }
    },

    getByClass: function ($oParent, nClass) {
        var eLe = $oParent.find("'"+nClass+"'");
        var aRrent = [];
        for (var i = 0; i < eLe.length; i++) {
            if (eLe[i].className == nClass) {
                aRrent.push(eLe[i]);
            }
        }
        return aRrent;
    },

    startMove: function (obj, att, add) {
        var _this=this;
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
        var oNext =$oDiv.find(".next");
        var oUlBig = $oDiv.find(".oUlplay").get(0);
        var aBigLi = $(oUlBig).find('li');
        var oDivSmall = $oDiv.find(".smalltitle");

        var aLiSmall = $(oDivSmall).find('li');
        var _this=this;
        function tab() {
            for (var i = 0; i < aLiSmall.length; i++) {
                aLiSmall[i].className = '';
            }
            aLiSmall[now].className = 'thistitle'
            _this.startMove(oUlBig, 'left', -(now * aBigLi[0].offsetWidth));
        }

        var now = 0;
        for (var i = 0; i < aLiSmall.length; i++) {
            aLiSmall[i].index = i;
            aLiSmall[i].onclick = function () {
                now = this.index;
                tab();
            }
        }
        oPre.onclick = function () {
            now--
            if (now == -1) {
                now = aBigLi.length;
            }
            tab();
        }
        oNext.onclick = function () {
            now++
            if (now == aBigLi.length) {
                now = 0;
            }
            tab();
        }
        var timer = setInterval(oNext.onclick, 3000) //滚动间隔时间设置
        $oDiv.onmouseover = function () {
            clearInterval(timer)
        }
        $oDiv.onmouseout = function () {
            timer = setInterval(oNext.onclick, 3000) //滚动间隔时间设置
        }
    },

    showbug:function () {
        $("#showActionSheet").click(function(){
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
        });

    }
}
$(document).ready(function() {
    window.shopmall.StarRun();
    window.shopmall.showbug();
    $("#playBox").css("width",$(window).outerWidth());
    $('#playBox').find(".oUlplay").find("li").css("width",$(window).outerWidth());


    //var liwidth =getComputedStyle($('#playBox').find(".oUlplay").get(0), false)["width"] ;
    //alert(liwidth);

});