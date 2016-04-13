window.product={
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

    }
}
