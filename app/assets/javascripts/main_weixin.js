/**
 * Created by Administrator on 2016/3/14.
 */

var sessionStorageManager = {
    CurrentShippingAddress: "CurrentShippingAddress11hao"
};
window._11hao={
    SetCurrentShippingAddress: function (receiveName, addressLine, provinceName, cityName, cityAreaName, phoneNumber, zipCode) {

        var currentShippingAddress = new Object();
        currentShippingAddress.ReceiveName = receiveName;
        currentShippingAddress.AddressLine = addressLine;
        currentShippingAddress.ProvinceName = provinceName;
        currentShippingAddress.CityName = cityName;
        currentShippingAddress.CityAreaName = cityAreaName;
        currentShippingAddress.PhoneNumber = phoneNumber;
        currentShippingAddress.ZipCode = zipCode;

        sessionStorage.setItem(sessionStorageManager.CurrentShippingAddress, JSON.stringify(currentShippingAddress));
    },
    GetCurrentShippingAddress: function () {
        var currentShippingAddress = $.parseJSON(sessionStorage.getItem(sessionStorageManager.CurrentShippingAddress));
        return currentShippingAddress;

    },
    clearCurrentShippingAddress:function(){
        sessionStorage.removeItem(sessionStorageManager.CurrentShippingAddress);
    },
    formatAddress: function (province, city, cityArea, addressLine, receiveName, cellPhone) {
        var address = "";
        address = province + " " + city + " " + cityArea + " " + addressLine + " (" + receiveName + "收 手机：" + cellPhone + ") "
        return address;
    },
    formatAddressNew:function()
    {
        var ca=this.GetCurrentShippingAddress();
        if(ca!=null) {
            var address = "<h4 class=\"weui_media_title\">收货人：" + ca.ReceiveName + " <span>" + ca.PhoneNumber + "</span></h4>";
            address = address + "<p class=\"weui_media_desc\">收货地址：" + ca.ProvinceName + " " + ca.CityName + " " + ca.CityAreaName + " " + ca.AddressLine +" "+ ca.ZipCode+"</p>";
        }else
        {
            var address = "<h4 class=\"weui_media_title\"> <span></span></h4>";
            address = address + "<p class=\"weui_media_desc\">点击选择收货地址 </p>";

        }

        return address;

    },
    loadingShow:function() {
        var $loadingToast = $('#loadingToast');
        if ($loadingToast.css('display') != 'none') {
            return;
        }
        $loadingToast.show();
    },
    loadingShowTimeOut:function(){
        var $loadingToast = $('#loadingToast');
        if ($loadingToast.css('display') != 'none') {
            return;
        }
        $loadingToast.show();
        setTimeout(function () {
            $loadingToast.hide();
        }, 2000);
    },
    loadingHid:function(){
        var $loadingToast = $('#loadingToast');
        setTimeout(function () {
            $loadingToast.hide();
        }, 500);
    },
    loadingHidNNow:function(){
        var $loadingToast = $('#loadingToast');
        $loadingToast.hide();
    },
    shareDialogShow:function(){
        var $Toast = $('.share-dialog-show');
        $Toast.show();

        $Toast.click(function(){
            $Toast.hide();
        });
    },
    shareDialogHid:function(){
        var $Toast = $('.share-dialog-show');
        $Toast.hide();

    }
}

function _onStart(event) {
    //.....
   window._11hao.loadingShow();
}

function _onComplete(event, xhr, settings) {
    //.....
    window._11hao.loadingHid();
}
$(document).ajaxStart(_onStart).ajaxSuccess(_onComplete).ajaxError(function(event,xhr,options,exc){
    alert("数据执行发生了异常请刷新后重试！");
});


$.fn.numeral = function (bl) {//限制金额输入、兼容浏览器、屏蔽粘贴拖拽等
    $(this).keypress(function (e) {
        var keyCode = e.keyCode ? e.keyCode : e.which;
        if (bl) {//浮点数
            if ((this.value.length == 0 || this.value.indexOf(".") != -1) && keyCode == 46) return false;
            return keyCode >= 48 && keyCode <= 57 || keyCode == 46 || keyCode == 8;
        } else {//整数
            return keyCode >= 48 && keyCode <= 57 || keyCode == 8;
        }
    });
    $(this).bind("copy cut paste", function (e) { // 通过空格连续添加复制、剪切、粘贴事件
        if (window.clipboardData)//clipboardData.setData('text', clipboardData.getData('text').replace(/\D/g, ''));
            return !clipboardData.getData('text').match(/\D/);
        else
            event.preventDefault();
    });
    $(this).bind("dragenter", function () {
        return false;
    });
    $(this).css("ime-mode", "disabled");
    $(this).bind("focus", function () {
        if (this.value.lastIndexOf(".") == (this.value.length - 1)) {
            this.value = this.value.substr(0, this.value.length - 1);
        } else if (isNaN(this.value)) {
            this.value = "";
        }
    });
    $(this).bind("focusout", function () {
        if (this.value=="0") {
            this.value = "";
        } else if (isNaN(this.value)) {
            this.value = "";
        }
        if(parseFloat(this.value)==0)
        {
            this.value = "";
        }
    });
}