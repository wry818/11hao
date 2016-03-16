/**
 * Created by Administrator on 2016/3/14.
 */

var sessionStorageManager = {
    CurrentShippingAddress: "CurrentShippingAddress"
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
        sessionStorage.setItem(sessionStorageManager.CurrentShippingAddress,null);
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
        }, 1000);
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
$(document).ajaxStart(_onStart).ajaxComplete(_onComplete);
