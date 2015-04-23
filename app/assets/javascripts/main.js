window.Raisy = {
    init: function() {
		
		var isVerticalScrollbar = window.Raisy.isVerticalScrollbar();
	
		if (isVerticalScrollbar) {
		
			$("#footer").hide();
		
		} else {
		
			$("#footer").show();
		
		}
	
		$(document).scroll(function () {

	        if ($(window).height() + $(window).scrollTop() > ($(document).height() - 100)) {
	            $("#footer").show();

	        } else {

	            $("#footer").hide();
	        }
		
	    });
		
        $('.facebook-share').on('click', function(e) {
            e.preventDefault();
            $this = $(this);
            FB.ui({
              method: 'feed',
              link: $this.attr('data-url')
            }, function(response){
            });
        });

        $('.twitter-share').click(function(e) {
            e.preventDefault();
            var width  = 550,
                height = 420,
                left   = ($(window).width()  - width)  / 2,
                top    = ($(window).height() - height) / 2,
                url    = this.href,
                opts   = 'status=1' +
                         ',width='  + width  +
                         ',height=' + height +
                         ',top='    + top    +
                         ',left='   + left;

            window.open(url, 'twitter', opts);

            return false;
        });

        tinyMCE.init({
            selector: 'textarea.tinymce',
            menubar: false,
            toolbar: "bold italic underline | bullist numlist | link",
            plugins: "link, paste",
			paste_as_text: true,
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
												
						$("<div class='tinymce-charcount' style='position:absolute; right: 32px; bottom:2px;'><span style=\"font-size:12px; font-weight:600; font-family:'Open Sans';\">"+count+"</span></div>").insertBefore($container.find(".mce-resizehandle").first());
						
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
							// Ctrl+A or C are also allowed
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
		
        tinyMCE.init({
            selector: 'textarea.tinymce-email',
            menubar: false,
            toolbar: "bold italic underline | bullist numlist | link",
            plugins: "link, paste",
			paste_as_text: true,
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
						
						$("<div style=\"text-align:center; color:gray; font-size:14px; font-family:'Open Sans'; display:inline-block; width:50%; margin-top:6px;\">You can add personalized text here</div>").appendTo($container.find(".mce-toolbar .mce-container-body").first());
												
						$("<div class='tinymce-charcount' style='position:absolute; right: 32px; bottom:2px;'><span style=\"font-size:12px; font-weight:600; font-family:'Open Sans';\">"+count+"</span></div>").insertBefore($container.find(".mce-resizehandle").first());
						
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
							// Ctrl+A or C are also allowed
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

        $('.user-modal-launch').on('click', function (e) {
            e.preventDefault();
            var $user_modal = $('#user_modal');
            var $this = $(this);
            $user_modal.find('#landing').val($this.attr('data-landing'));

            if($this.attr('data-action') === 'signup') {
                $('#user_modal .modal-title').text('Create An Account');
                $('#user_modal_signup').show();
                $('#user_modal_signin').hide();
            } else {
                $('#user_modal .modal-title').text('登录11号公益圈');
                $('#user_modal_signup').hide();
                $('#user_modal_signin').show();
            }

            $user_modal.modal('show');
            $('#user_modal').on('shown.bs.modal', function (e) {
                $('#user_fullname').focus();
            });
        });

        $('.user-modal-signin').on('click', function (e) {
            $('#user_modal .modal-title').text('Sign in to Raisy');
            $('#user_modal_signup').fadeOut(200, function() {
				$(".login-social-error").hide();
				$(".login-social-message").text("");
				$(".new-user-email").val("");
				$(".new-user-password").val("");
				$("#user_first_name").val("");
				$("#user_last_name").val("");
				$(".old-user-email").val("");
				$(".old-user-password").val("");
				
                $('#user_modal_signin').fadeIn(200);
            });
        });

        $('.user-modal-signup').on('click', function (e) {
            $('#user_modal .modal-title').text('Create An Account');
            $('#user_modal_signin').fadeOut(200, function() {
				$(".login-social-error").hide();
				$(".login-social-message").text("");
				$(".new-user-email").val("");
				$(".new-user-password").val("");
				$("#user_first_name").val("");
				$("#user_last_name").val("");
				$(".old-user-email").val("");
				$(".old-user-password").val("");
				$("#user_terms_conditions").prop("checked", false);
				$("#new_user_form").validate().resetForm();
				$("#user_modal_signup .form-group").removeClass("has-error");
				
                $('#user_modal_signup').fadeIn(200);
            });
        });

        $('.launch-invite-modal').on('click', function(e) {
            e.preventDefault();
            var $this = $(this);
            $('#invite_collection_id').val(parseInt($this.attr('data-collection')));
            $('#invite-modal').modal('show');
        });
		
		$("img").attr("alt","");
    },
	is_tw_campaign_login: false,
	tw_login_window: null,
	tw_login_timer_id: 0,
	is_tw_called_back: false,
	social_popup_base_y: 100,
	IsSafari: function () {

        var is_chrome = navigator.userAgent.indexOf('Chrome') > -1;
        //var is_explorer = navigator.userAgent.indexOf('MSIE') > -1;
        //var is_firefox = navigator.userAgent.indexOf('Firefox') > -1;
        var is_safari = navigator.userAgent.indexOf("Safari") > -1;
        //var is_Opera = navigator.userAgent.indexOf("Presto") > -1;

        if ((is_chrome) && (is_safari)) {
            is_safari = false;
        }

        return is_safari;
		
	},
	isVerticalScrollbar: function () {
		
		var root = document.compatMode == 'BackCompat'? document.body : document.documentElement;
		var isVerticalScrollbar = root.scrollHeight > root.clientHeight;
		
		return isVerticalScrollbar;
	},
	verify_user: function(is_verify,email,pwd){
		var result = true;
				
		if (is_verify)
		{
			$.ajax({
				method: "get",
				url: "/user/verify?email=" + encodeURIComponent(email) + "&password=" + encodeURIComponent(pwd),
				dataType: "json",
				cache: false,
				async: false,
				success: function(d){
					if (d && !d.verified) {
						result = false;
						
						$(".login-social-error").show();
						$(".login-social-message").text("Sorry, your email or password is incorrect.");
					}
				}
			});
		}
		else
		{
			$.ajax({
				method: "get",
				url: "/user/lookup?email=" + encodeURIComponent(email),
				dataType: "json",
				cache: false,
				async: false,
				success: function(d){
					if (d && d.user) {
						result = false;
						
						$(".login-social-error").show();
						$(".login-social-message").text("Sorry, the account has already been taken.");
					}
				}
			});
		}
		
		return result;
	},
	social_failure: function() {
		$("#campaign_social_error").hide();
		$("#campaign_social_message").text("");
		$(".login-social-error").hide();
		$(".login-social-message").text("");
		$("#seller-social-error").hide();
		$("#seller-social-message").text("");
	},
	tw_seller_login: function(is_signup){
		Raisy.is_social_seller_signup = is_signup;
		Raisy.is_social_process_seller = true;
		
		$("#seller-social-error").show();
		
		if (is_signup)
			$("#seller-social-message").text("Please wait while connecting with twitter...");
		else
			$("#seller-social-message").text("Please wait while processing your login...");
		
		var winLeft = window.screenX || window.screenLeft;
		var winTop = window.screenY || window.screenTop;
		var winWidth = $(window).width();
		var l = winLeft + (winWidth - 705)/2;
		
		if (l<winLeft) l = winLeft;
		
		var t = winTop + 100;
		
		Raisy.is_tw_called_back = false;
		Raisy.tw_login_window = window.open('/auth/twitter','Connect Twitter',
			'top=' + t.toString() + ',left=' + l.toString() + ',width=705,height=585,location=no,menubar=no,status=no,toolbar=no');
			
		Raisy.tw_login_timer_id = window.setInterval(function(){
			if (Raisy.is_tw_called_back)
			{
				window.clearInterval(Raisy.tw_login_timer_id);
				return;
			}
			
			if (Raisy.tw_login_window && Raisy.tw_login_window.closed && !Raisy.is_tw_called_back)
			{
				window.clearInterval(Raisy.tw_login_timer_id);
				
				$("#seller-social-error").hide();
				$("#seller-social-message").text("");
			}
		}, 200);
	},
	tw_seller_callback: function(auth){
		Raisy.is_tw_called_back = true;
		
		if (auth)
		{
			if (Raisy.is_social_seller_signup)
			{
				// New seller creation
				
				$("#user_email").val(auth.uid + "@twitter.com");
				// Use a fake password just for form validation
				$("#user_password").val(new Date().getTime().toString());
				$("#auth_provider").val("twitter");
				$("#auth_uid").val(auth.uid);
				$("#auth_uimage").val(auth.info.image);
			
				// Submit the form
				$("#seller_signup_submit").click();
			}
			else {
				// Seller with existing account
				
				var email = encodeURIComponent(auth.uid+"@twitter.com");
				
				// Use a fake password for the user
				var pwd = new Date().getTime().toString();
				var first_name = encodeURIComponent(auth.info.nickname);
				var last_name = encodeURIComponent(auth.info.name);
				var uid = auth.uid;
				var uimage = encodeURIComponent(auth.info.image);
				var can_go = true;
				
				$.ajax({
					method: "get",
					url: "/user/lookup?email=" + email,
					dataType: "json",
					cache: false,
					async: false,
					success: function(d){
						if (d && d.user && (d.user.uid!=uid || d.user.provider!="twitter")) {
							can_go = false;
							
							$("#seller-social-error").show();
							$("#seller-social-message").text("Sorry, the account has already been taken.");
						}
					}
				});
				
				if (!can_go) return;
				
				var referrer = "";
				
				if (document.referrer && document.referrer.indexOf("/seller/signup/")>0)
					referrer = encodeURIComponent(document.referrer);
				
				// Redirect to sign up the user
				window.location.href = "/signup_social_user/?auth_provider=twitter" +
				"&auth_uid=" + uid + "&email=" + email + 
				"&first_name=" + first_name + "&last_name="  + last_name + 
				"&referrer=" + referrer + "&auth_uimage=" + uimage;
			}
		}
		else
		{
			$("#seller-social-error").hide();
			$("#seller-social-message").text("");
		}
	},
	tw_login: function(is_campaign) {
		Raisy.is_tw_campaign_login = is_campaign;
		Raisy.is_social_process_seller = false;
		
		if (is_campaign)
		{
			$("#auth_provider").val("raisy");
			$("#auth_uid").val("");
			
			$("#campaign_social_error").show();
			$("#campaign_social_message").text("Please wait while processing your login...");
		}
		else
		{
			$(".login-social-error").show();
			$(".login-social-message").text("Please wait while processing your login...");
		}
		
		var winLeft = window.screenX || window.screenLeft;
		var winTop = window.screenY || window.screenTop;
		var winWidth = $(window).width();
		var l = winLeft + (winWidth - 705)/2;
		
		if (l<winLeft) l = winLeft;
		
		var t = winTop + 100;
		
		Raisy.is_tw_called_back = false;
		Raisy.tw_login_window = window.open('/auth/twitter','Connect Twitter',
			'top=' + t.toString() + ',left=' + l.toString() + ',width=705,height=585,location=no,menubar=no,status=no,toolbar=no');
			
		Raisy.tw_login_timer_id = window.setInterval(function(){
			if (Raisy.is_tw_called_back)
			{
				window.clearInterval(Raisy.tw_login_timer_id);
				return;
			}
			
			if (Raisy.tw_login_window && Raisy.tw_login_window.closed && !Raisy.is_tw_called_back)
			{
				window.clearInterval(Raisy.tw_login_timer_id);
				
				$("#campaign_social_error").hide();
				$("#campaign_social_message").text("");
				$(".login-social-error").hide();
				$(".login-social-message").text("");
			}
		}, 200);
	},
	tw_callback: function(auth) {
		Raisy.is_tw_called_back = true;
		
		if (auth)
		{
			if (Raisy.is_tw_campaign_login)
			{
				// Login from campaign creation

				$("#user_email").val(auth.uid + "@twitter.com");
				
				// Use a fake password just for form validation
				$("#user_password").val(new Date().getTime().toString());
				$("#user_confirm_password").val($("#user_password").val());
				$("#user_first_name").val(auth.info.nickname);
				$("#user_last_name").val(auth.info.name);
				$("#campaign_terms_conditions").prop("checked", true);

				$("#auth_provider").val("twitter");
				$("#auth_uid").val(auth.uid);

				// Submit the form
				$("#campaign_form_submit").click();
			}
			else
			{
				// System login entry
				
				var email = encodeURIComponent(auth.uid+"@twitter.com");
				
				// Use a fake password for the user
				var pwd = new Date().getTime().toString();
				var first_name = encodeURIComponent(auth.info.nickname);
				var last_name = encodeURIComponent(auth.info.name);
				var uid = auth.uid;
				var can_go = true;
				
				$.ajax({
					method: "get",
					url: "/user/lookup?email=" + email,
					dataType: "json",
					cache: false,
					async: false,
					success: function(d){
						if (d && d.user && (d.user.uid!=uid || d.user.provider!="twitter")) {
							can_go = false;
							
							$(".login-social-error").show();
							$(".login-social-message").text("Sorry, the account has already been taken.");
						}
					}
				});
				
				if (!can_go) return;
				
				// Redirect to sign up the user
				window.location.href = "/signup_social_user/?auth_provider=twitter" +
				"&auth_uid=" + uid + "&email=" + email + 
				"&first_name=" + first_name + "&last_name="  + last_name;
			}
		}
		else
		{
			$("#campaign_social_error").hide();
			$("#campaign_social_message").text("");
			$(".login-social-error").hide();
			$(".login-social-message").text("");
		}
	},
	is_social_process_seller: false,
	is_social_seller_signup: false,
	is_fb_campaign_login: false,
	is_fb_called_back: false,
	fb_login_window: null,
	fb_login_timer_id: 0,
	fb_seller_login: function(is_signup){
		Raisy.is_social_seller_signup = is_signup;
		Raisy.is_social_process_seller = true;
		
		$("#seller-social-error").show();
		
		if (is_signup)
			$("#seller-social-message").text("Please wait while connecting with facebook...");
		else
			$("#seller-social-message").text("Please wait while processing your login...");
		
		var winLeft = window.screenX || window.screenLeft;
		var winTop = window.screenY || window.screenTop;
		var winWidth = $(window).width();
		var l = winLeft + (winWidth - 705)/2;
		
		if (l<winLeft) l = winLeft;
		
		var t = winTop + 100;
		
		Raisy.is_fb_called_back = false;
		Raisy.fb_login_window = window.open('/auth/facebook','Connect Facebook',
			'top=' + t.toString() + ',left=' + l.toString() + ',width=705,height=585,location=no,menubar=no,status=no,toolbar=no');
			
		Raisy.fb_login_timer_id = window.setInterval(function(){
			if (Raisy.is_fb_called_back)
			{
				window.clearInterval(Raisy.fb_login_timer_id);
				return;
			}
			
			if (Raisy.fb_login_window && Raisy.fb_login_window.closed && !Raisy.is_fb_called_back)
			{
				window.clearInterval(Raisy.fb_login_timer_id);
				
				$("#seller-social-error").hide();
				$("#seller-social-message").text("");
			}
		}, 200);
	},
	fb_seller_callback: function(auth){
		Raisy.is_fb_called_back = true;
		
		if (auth)
		{
			if (Raisy.is_social_seller_signup)
			{
				// New seller creation
				
				if (!auth.info || auth.info.email=="")											
					$("#user_email").val(auth.uid + "@facebook.com");
				else
					$("#user_email").val(auth.info.email);
			
				// Use a fake password just for form validation
				$("#user_password").val(new Date().getTime().toString());
				$("#auth_provider").val("facebook");
				$("#auth_uid").val(auth.uid);
				$("#auth_uimage").val(auth.info.image);
			
				// Submit the form
				$("#seller_signup_submit").click();
			}
			else {
				// Seller with existing account
				
				var email = "";
			
				if (!auth.info || auth.info.email=="")											
					email = auth.uid + "@facebook.com";
				else
					email = auth.info.email;
			
				// Use a fake password for the user
				var pwd = new Date().getTime().toString();
				var first_name = encodeURIComponent(auth.info.first_name);
				var last_name = encodeURIComponent(auth.info.last_name);
				var uid = auth.uid;
				var uimage = encodeURIComponent(auth.info.image);
				var can_go = true;
				
				$.ajax({
					method: "get",
					url: "/user/lookup?email=" + encodeURIComponent(email),
					dataType: "json",
					cache: false,
					async: false,
					success: function(d){
						if (d && d.user && (d.user.uid!=uid || d.user.provider!="facebook")) {
							can_go = false;
							
							$("#seller-social-error").show();
							$("#seller-social-message").text("Sorry, the account has already been taken.");
						}
					}
				});
				
				if (!can_go) return;
				
				var referrer = "";
				
				if (document.referrer && document.referrer.indexOf("/seller/signup/")>0)
					referrer = encodeURIComponent(document.referrer);
					
				// Redirect to sign up the user
				window.location.href = "/signup_social_user/?auth_provider=facebook" +
				"&auth_uid=" + uid + "&email=" + email + 
				"&first_name=" + first_name + "&last_name="  + last_name + 
				"&referrer=" + referrer + "&auth_uimage=" + uimage;
			}
		}
		else
		{
			$("#seller-social-error").hide();
			$("#seller-social-message").text("");
		}
	},
	fb_login: function(is_campaign){
		Raisy.is_fb_campaign_login = is_campaign;
		Raisy.is_social_process_seller = false;
		
		if (is_campaign)
		{
			$("#auth_provider").val("raisy");
			$("#auth_uid").val("");
			
			$("#campaign_social_error").show();
			$("#campaign_social_message").text("Please wait while processing your login...");
		}
		else
		{
			$(".login-social-error").show();
			$(".login-social-message").text("Please wait while processing your login...");
		}
		
		var winLeft = window.screenX || window.screenLeft;
		var winTop = window.screenY || window.screenTop;
		var winWidth = $(window).width();
		var l = winLeft + (winWidth - 705)/2;
		
		if (l<winLeft) l = winLeft;
		
		var t = winTop + 100;
		
		Raisy.is_fb_called_back = false;
		Raisy.fb_login_window = window.open('/auth/facebook','Connect Facebook',
			'top=' + t.toString() + ',left=' + l.toString() + ',width=705,height=585,location=no,menubar=no,status=no,toolbar=no');
			
		Raisy.fb_login_timer_id = window.setInterval(function(){
			if (Raisy.is_fb_called_back)
			{
				window.clearInterval(Raisy.fb_login_timer_id);
				return;
			}
			
			if (Raisy.fb_login_window && Raisy.fb_login_window.closed && !Raisy.is_fb_called_back)
			{
				window.clearInterval(Raisy.fb_login_timer_id);
				
				$("#campaign_social_error").hide();
				$("#campaign_social_message").text("");
				$(".login-social-error").hide();
				$(".login-social-message").text("");
			}
		}, 200);
	},
	fb_callback: function(auth){
		Raisy.is_fb_called_back = true;
		
		if (auth)
		{
			if (Raisy.is_fb_campaign_login)
			{
				// Login from campaign creation
				
				if (!auth.info || auth.info.email=="")											
					$("#user_email").val(auth.uid + "@facebook.com");
				else
					$("#user_email").val(auth.info.email);
			
				// Use a fake password just for form validation
				$("#user_password").val(new Date().getTime().toString());
				$("#user_confirm_password").val($("#user_password").val());
				$("#user_first_name").val(auth.info.first_name);
				$("#user_last_name").val(auth.info.last_name);
				$("#campaign_terms_conditions").prop("checked", true);
		
				$("#auth_provider").val("facebook");
				$("#auth_uid").val(auth.uid);
			
				// Submit the form
				$("#campaign_form_submit").click();
			}
			else
			{
				// System login entry
				
				var email = "";
			
				if (!auth.info || auth.info.email=="")											
					email = auth.uid + "@facebook.com";
				else
					email = auth.info.email;
			
				// Use a fake password for the user
				var pwd = new Date().getTime().toString();
				var first_name = encodeURIComponent(auth.info.first_name);
				var last_name = encodeURIComponent(auth.info.last_name);
				var uid = auth.uid;
				var can_go = true;
				
				$.ajax({
					method: "get",
					url: "/user/lookup?email=" + encodeURIComponent(email),
					dataType: "json",
					cache: false,
					async: false,
					success: function(d){
						if (d && d.user && (d.user.uid!=uid || d.user.provider!="facebook")) {
							can_go = false;
							
							$(".login-social-error").show();
							$(".login-social-message").text("Sorry, the account has already been taken.");
						}
					}
				});
				
				if (!can_go) return;
				
				// Redirect to sign up the user
				window.location.href = "/signup_social_user/?auth_provider=facebook" +
				"&auth_uid=" + uid + "&email=" + email + 
				"&first_name=" + first_name + "&last_name="  + last_name;
			}
		}
		else
		{
			$("#campaign_social_error").hide();
			$("#campaign_social_message").text("");
			$(".login-social-error").hide();
			$(".login-social-message").text("");
		}
	},
	valid_email: function (email) {
        var patten = new RegExp(/^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$/i);
        return patten.test(email);
    },
	alert: function(msg, callback) {
		bootbox.alert(msg, function() {
			if ($.isFunction(callback)) callback();
		});
	},
	confirm: function(msg, callback) {
		bootbox.confirm(msg, function(result) {
			if ($.isFunction(callback)) callback(result);
		});
	}
}

$(document).ready(function() {
    Raisy.init();
    Raisy.pages.init();
    Raisy.collections.init();
    Raisy.campaigns.init();
    Raisy.shop.init();
    Raisy.seller_dashboard.init();
    Raisy.chairperson_dashboard.init();
	Raisy.users.init();
});
