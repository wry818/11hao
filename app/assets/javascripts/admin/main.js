window.Raisy_admin = {
    init: function() {

        tinyMCE.init({
            selector: 'textarea.tinymce',
            plugins: "link, paste, code",
			paste_as_text: true,
            menubar: "tools",
			height: 200,
			maxlength: 2000,
			relative_urls: false,
			remove_script_host: false,
			convert_urls: false,
			content_css: "/tinymce_content.css?_=" + new Date().getTime(),
			setup: function(ed) {
				ed.on('change', function(e) {
					var content=$.trim(ed.getContent({format: "text"}));
					var $container=$(ed.getContainer());

					if (!$container.hasClass("mce-tinymce")) {
						$container=$container.parents(".mce-tinymce").first();
					}

					var maxLength=parseInt(ed.getParam("maxlength"));
					var count=maxLength-content.length;

					if (count<0) {
						count=0;

						$container.find(".tinymce-charcount span").css("color", "#b94a48").text(count);
					}
					else {
						$container.find(".tinymce-charcount span").css("color", "#00aaff").text(count);
					}
				}).on("init", function(e) {
					var $container=$(ed.getContainer());

					if (!$container.hasClass("mce-tinymce")) {
						$container=$container.parents(".mce-tinymce").first();
					}

					if ($container.find(".tinymce-charcount").length==0) {
						var content=$.trim(ed.getContent({format: "text"}));
						var maxLength=parseInt(ed.getParam("maxlength"));
						var count=maxLength-content.length;
						var color="#00aaff";

						if (count<0) {
							count=0;
							color="#b94a48";
						}
						
						$("<div class='tinymce-charcount' style='position:absolute; right: 32px; bottom:2px;'><span style=\"font-size:12px; font-weight:600;\">"+count+"</span></div>").insertBefore($container.find(".mce-resizehandle").first());
					
						$container.find(".tinymce-charcount span").css("color", color);
					}
				}).on("keydown", function(e) {
					// Delete, Backspace, Tab, Enter, Home, End, Page Down/Up, Arrow Left/Right/Up/Down
					var allowedKeys=[8,9,13,33,34,35,36,37,38,39,40,46];
					
					var content=$.trim(ed.getContent({format: "text"}));
					var $container=$(ed.getContainer());

					if (!$container.hasClass("mce-tinymce")) {
						$container=$container.parents(".mce-tinymce").first();
					}
					
					var maxLength=parseInt(ed.getParam("maxlength"));
					var count=maxLength-content.length;
					
					if (count<0) {
						$container.find(".tinymce-charcount span").css("color", "#b94a48").text("0");
					}
					else {
						$container.find(".tinymce-charcount span").css("color", "#00aaff").text(count);
					}
					
					if (count<=0) {
						if ($.inArray(e.which,allowedKeys)>=0) 
						{
							return true;
						}
						else
						{
							// Ctrl+A or C are also allowed on windows, but what's key for mac os
							if ($.inArray(e.which,[65,67])>=0 && (e.ctrlKey)) {
								return true;
							}
						}
						
						e.preventDefault();
						e.stopPropagation();
						
						return false;
					}
				}).on("keyup", function(e) {
					var content=$.trim(ed.getContent({format: "text"}));
					var $container=$(ed.getContainer());

					if (!$container.hasClass("mce-tinymce")) {
						$container=$container.parents(".mce-tinymce").first();
					}
					
					var maxLength=parseInt(ed.getParam("maxlength"));
					var count=maxLength-content.length;
					
					if (count<0) {
						$container.find(".tinymce-charcount span").css("color", "#b94a48").text("0");
					}
					else {
						$container.find(".tinymce-charcount span").css("color", "#00aaff").text(count);
					}
				}).on("paste", function(e) {
					var content=$.trim(ed.getContent({format: "text"}));
					var $container=$(ed.getContainer());

					if (!$container.hasClass("mce-tinymce")) {
						$container=$container.parents(".mce-tinymce").first();
					}
					
					var maxLength=parseInt(ed.getParam("maxlength"));
					var count=maxLength-content.length;
					
					if (count<0) {
						$container.find(".tinymce-charcount span").css("color", "#b94a48").text("0");
					}
					else {
						$container.find(".tinymce-charcount span").css("color", "#00aaff").text(count);
					}
					
					if (count<=0) {
						if ($.inArray(e.which,allowedKeys)>=0) return true;
						
						e.preventDefault();
						e.stopPropagation();
						
						return false;
					}
				});
		   }
        });

        // Convert the date into a format useable by pickadate
        $('.datepicker').each(function(i) {
            var d = $(this).val();
            if(d && d.length > 0) {
                $(this).val($.datepicker.formatDate('D, M d, yy', new Date(d)));
            }
        });

        // Set up pickadate
        var min = new Date();
        $('.datepicker').not(".bulk-delivery-date").pickadate({
          min: min,
          format: 'ddd, mmm d, yyyy',
          onClose: function(event) {
			  if ($('#campaign_end_date').length > 0) {
			  	$('#campaign_end_date').valid();
			  }
          }
        });

        $('.bulkshippinginfo-timepicker').pickatime({
          	min: [9,0],
			max: [14,0]
        });
		
    }
}

$(document).ready(function() {
	Raisy_admin.init();
	Raisy_admin_campaigns.init();
	Raisy_admin_products.init();
	Raisy_admin_organizations.init();
});
