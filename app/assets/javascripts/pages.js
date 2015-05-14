Raisy.pages = {
    init: function() {
        var _this = this;
				
				$("#search .search-result-block").on("mouseenter", function() {
	        $(this).css("border-color", "rgb(46, 157, 247)");
		    }).on("mouseleave", function() {
		        $(this).css("border-color", "#e2e2e2");
		    });
    },

    submitInviteForm: function(form) {
        var $form = $(form);
        var $button = $form.find('button');
        $('.error-message').hide();
        $button.prop('disabled', true).find('span.text').text('Submitting').siblings('span.loader').show(200, function() {
            $.ajax('/ajax/invite', {
                type: 'POST',
                data: $form.serialize(),
                beforeSend: function(jqXHR, settings) {
                    jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
                },
                success: function(data) {
                    if(data == 'success') {
                        $form.fadeOut({
                            complete: function() {
                                $form.siblings('.success-message').fadeIn();
                            }
                        });
                        ga('send', 'event', 'contact', 'submit', 'homepage');
                    } else {
                        $button.prop('disabled', false).find('span.text').text('Submit').siblings('span.loader').hide();
                        $('.error-message').fadeIn();
                    }
                }
            });
        });
    }

}
