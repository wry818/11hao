$( document ).ready(function() {

    $.validator.addMethod("twowords", function (value, element, param) {

        var split = value.split(' ');
        return this.optional(element) || ( split.length >=2 && split[1].length >=1 );

    }, "Must be two words");
	
	$.validator.methods.min = function (value, element) {
	    return this.optional(element) || /^-?(?:\d+|\d{1,3}(?:[\s\.,]\d{3})+)(?:[\.,]\d+)?$/.test(value);
	}
	
    //*********************************************************************************************************
    //      NEW USER FORM
    //*********************************************************************************************************
	    $("#new_user").validate({
        submitHandler: function(form) {
            login_user(form);
        },
		
	        // validate the previously selected element when the user clicks out
	        onfocusout: function(element) {
	            $(element).valid();
	        },

	        highlight: function(element) {
	            $(element).closest('.form-group').addClass('has-error');
	        },
	        unhighlight: function(element) {
	            $(element).closest('.form-group').removeClass('has-error');
	        },

			errorPlacement: function(error, element) {  
			     if (element.attr("type") == "checkbox")
			       error.appendTo(element.parent());
			     else  
			       error.insertAfter(element);
			},
		
	        // validation rules
	        rules: {
				"user[email]": { required: true, email: true },
				"user[password]": { required: true, minlength: 8 }
	        },
	        messages: {
	          "user[email]": {
	            required: "请输入您的邮箱",
	            email: "邮箱格式不正确"
	          },
	          "user[password]": {
	            required: "请输入您的密码",
	            minlength: "密码至少8位"
	          }
	        }

	    });
		
    $("#new_user_form").validate({
		
        // validate the previously selected element when the user clicks out
        onfocusout: function(element) {
            $(element).valid();
        },

        highlight: function(element) {
            $(element).closest('.form-group').addClass('has-error');
        },
        unhighlight: function(element) {
            $(element).closest('.form-group').removeClass('has-error');
        },

		errorPlacement: function(error, element) {  
		     if (element.attr("type") == "checkbox")
		       error.appendTo(element.parent());
		     else  
		       error.insertAfter(element);
		},
		
        // validation rules
        rules: {
			"user[email]": { required: true, email: true },
			"user[password]": { required: true, minlength: 8 },
			"user[terms_conditions]": { required: true },
			"first_name": { required: true },
			"last_name": { required: true }
        },
        messages: {
          "user[email]": {
            required: "请输入您的邮箱",
            email: "邮箱格式不正确"
          },
          "user[password]": {
            required: "请输入您的密码",
            minlength: "密码至少8位"
          },
          "user[terms_conditions]": {
            required: "在创建您的帐户前请先同意我们的服务协议"
          },
          "first_name": {
            required: "请输入您的姓"
          },
          "last_name": {
            required: "请输入您的名"
          }
        }

    });
	
    //*********************************************************************************************************
    //      SIGN UP FORM
    //*********************************************************************************************************
    $("#signup_form").validate({

        // custom handler to call named function ""
        submitHandler: function(form) {
            Raisy.users.submitSellerSignUpForm(form);
        },

        // validate the previously selected element when the user clicks out
        onfocusout: function(element) {
            $(element).valid();
        },

        highlight: function(element) {
            $(element).closest('.form-group').addClass('has-error');
        },
        unhighlight: function(element) {
            $(element).closest('.form-group').removeClass('has-error');
        },

		errorPlacement: function(error, element) {  
		     if (element.attr("type") == "checkbox")
		       error.appendTo(element.parent());
		     else  
		       error.insertAfter(element);
		},
		
        // validation rules
        rules: {
					"user[fullname]": { required: true, twowords: true },
					"user[email]": { required: true, email: true },
					"user[password]": { required: true, minlength: 8 },
					"user[confirm_password]": { required: true, equalTo: "#user_password" },
					"user[terms_conditions]": { required: true },
					"user_profile[first_name]": { required: true },
					"user_profile[last_name]": { required: true },
					"seller[first_name]": { required: true },
					"seller[last_name]": { required: true },
					"guardian_agree": { required: true },
					"seller13[first_name]": { required: true },
					"seller13[last_name]": { required: true },
					"seller13[grade]": { required: true },
					"seller13[homeroom]": { required: true },
					"seller14[first_name]": { required: true },
					"seller14[last_name]": { required: true },
					"seller14[grade]": { required: true },
					"seller14[homeroom]": { required: true },
					"seller14[email]": { required: true, email: true },
					"seller14[password]": { required: true, minlength: 8 },
					"parent[first_name]": { required: true },
					"parent[last_name]": { required: true },
					"parent[email]": { required: true, email: true },
					"seller[grade]": { required: true },
					"seller[homeroom]": { required: true },
					"seller[email]": { required: true, email: true },
					"seller[password]": { required: true, minlength: 8 },
					"sellerexist[grade]": { required: true },
					"sellerexist[homeroom]": { required: true },
					"seller1314[first_name]": { required: true },
					"seller1314[last_name]": { required: true },
					"seller1314[grade]": { required: true },
					"seller1314[homeroom]": { required: true },
					"seller18[first_name]": { required: true },
					"seller18[last_name]": { required: true },
					"existing_seller_profile[id]": { required: true }
        },
        messages: {
          "user[fullname]": {
            required: "请输入您的姓名",
            twowords: "请输入您的姓名"
          },
          "user[email]": {
            required: "请输入您的邮箱",
            email: "邮箱格式不正确"
          },
          "user[password]": {
            required: "请输入您的密码",
            minlength: "密码至少8位"
          },
          "user[confirm_password]": {
            required: "请确认您的密码",
            equalTo: "密码不匹配，请重新输入"
          },
          "user[terms_conditions]": {
            required: "在创建您的帐户前请先同意我们的服务协议"
          },
          "user_profile[first_name]": {
            required: "请输入您的姓"
          },
          "user_profile[last_name]": {
            required: "请输入您的名"
          },
          "seller[first_name]": {
            required: "请输入学生的姓"
          },
          "seller[last_name]": {
            required: "请输入学生的名"
          },
          "guardian_agree": {
            required: "请勾选家长／监护人注册协议"
          },
          "seller13[first_name]": {
            required: "请输入学生的姓"
          },
          "seller13[last_name]": {
            required: "请输入学生的名"
          },
          "seller13[homeroom]": {
            required: "请输入小组领队"
          },
          "seller13[grade]": {
            required: "请输入年级"
          },
          "seller14[first_name]": {
            required: "请输入您的姓"
          },
          "seller14[last_name]": {
            required: "请输入您的名"
          },
          "seller14[homeroom]": {
            required: "请输入小组领队"
          },
          "seller14[grade]": {
            required: "请输入年级"
          },
          "seller14[email]": {
            required: "请输入您的邮箱",
            email: "邮箱格式不正确"
          },
          "seller14[password]": {
            required: "请输入您的密码",
            minlength: "密码至少8位"
          },
          "parent[first_name]": {
            required: "请输入家长的姓"
          },
          "parent[last_name]": {
            required: "请输入家长的名"
          },
          "parent[email]": {
            required: "请输入家长的邮箱",
            email: "邮箱格式不正确"
          },
          "seller[homeroom]": {
            required: "请输入小组领队"
          },
          "seller[grade]": {
            required: "请输入年级"
          },
          "seller[email]": {
            required: "请输入您的邮箱",
            email: "邮箱格式不正确"
          },
          "seller[password]": {
            required: "请输入您的密码",
            minlength: "密码至少8位"
          },
          "sellerexist[homeroom]": {
            required: "请输入小组领队"
          },
          "sellerexist[grade]": {
            required: "请输入年级"
          },
          "seller1314[first_name]": {
            required: "请输入学生的姓"
          },
          "seller1314[last_name]": {
            required: "请输入学生的名"
          },
          "seller1314[homeroom]": {
            required: "请输入小组领队"
          },
          "seller1314[grade]": {
            required: "请输入年级"
          },
          "seller18[first_name]": {
            required: "请输入您的姓"
          },
          "seller18[last_name]": {
            required: "请输入您的名"
          },
		  "existing_seller_profile[id]": {
			  required: "请选择一个存在的销售"
		  }
        }

    });

    //*********************************************************************************************************
    //      INVITE FORM
    //*********************************************************************************************************

    $(".invite-form").each(function() {
            $(this).validate({

            // custom handler to call named function ""
            submitHandler: function(form) {
                Raisy.pages.submitInviteForm(form);
            },

            // validate the previously selected element when the user clicks out
            onfocusout: function(element) {
                $(element).valid();
            },

            errorPlacement: function(error, element) {
            },

            highlight: function(element) {
                $(element).closest('.form-group').addClass('has-error');
            },
            unhighlight: function(element) {
                $(element).closest('.form-group').removeClass('has-error');
            },

            // validation rules
            rules: {
                "invite[email]": { required: true, email: true }
            }

        });
    });

    //*********************************************************************************************************
    //      ORGANIZATION CREATION FORM
    //*********************************************************************************************************

    $("#organization_form").validate({

        // custom handler to call named function ""
        submitHandler: function(form) {
            form.submit();
        },

        // validate the previously selected element when the user clicks out
        onfocusout: function(element) {
            $(element).valid();
        },

        highlight: function(element) {
            $(element).closest('.form-group').addClass('has-error');
        },
        unhighlight: function(element) {
            $(element).closest('.form-group').removeClass('has-error');
        },

        // validation rules
        rules: {
            "organization[name]": { required: true },
            "organization[email]": { email: true },
            "organization[legal_name]": { required: true },
            "organization[legal_tax_id]": { required: true },
            "organization[legal_address_line_one]": { required: true },
            "organization[legal_address_city]": { required: true },
            "organization[legal_address_state]": { required: true },
            "organization[legal_address_postal_code]": { required: true },
            "organization[legal_rep_first_name]": { required: true },
            "organization[legal_rep_last_name]": { required: true },
            "organization[legal_rep_phone]": { required: true },
            "organization[legal_rep_email]": { required: true, email: true },
            "organization[legal_rep_dob]": { required: true },
            "organization[routing_number]": { required: true },
            "organization[account_number]": { required: true }
        },
        messages: {
          "organization[name]": {
            required: "请输入您组织的名称"
          }
        }
    });

    //*********************************************************************************************************
    //      CAMPAIGN CREATION FORM
    //*********************************************************************************************************

    $("#campaign_form").validate({
		
        // custom handler to call named function ""
        submitHandler: function(form) {
          Raisy.campaigns.submitCampaignForm(form);
        },

        // validate the previously selected element when the user clicks out
        onfocusout: function(element) {
          $(element).valid();
        },

        highlight: function(element) {
            $(element).closest('.form-group').addClass('has-error');
        },
		
        unhighlight: function(element) {
            $(element).closest('.form-group').removeClass('has-error');
        },
		
		ignore: ":hidden",
		
		errorPlacement: function(error, element) {  
		     if (element.hasClass("campaign-collection-id") || element.attr("type") == "checkbox")
		       error.appendTo(element.parent());
		     else  
		       error.insertAfter(element);
		},

        // validation rules
        rules: {
            "organization_name": { required: true },
			"campaign[collection_id]": { required: true },
            "campaign[title]": { required: true, maxlength: 100 },
            "campaign[organizer_quote]": { maxlength: 100 },
            "campaign[goal]": { number: true, min: 1 },
            "campaign[call_to_action]": { required: true },
            "user[email]": { required: true, email: true },
            "user[password]": { required: true, minlength: 8 },
			"user[confirm_password]": { required: true, equalTo: "#user_password" },
			"user[first_name]": { required: true },
			"user[last_name]": { required: true },
			"user[terms_conditions]": { required: true }
        },
        messages: {
          "organization_name": {
            required: "请选择一个组织"
          },
          "campaign[collection_id]": {
            required: "请选择一件商品"
          },
          "campaign[title]": {
            required: "请输入筹款页面标题",
            maxlength: "筹款页面标题至少要100个字符"
          },
          "campaign[organizer_quote]": {
            maxlength: "副筹款页面标题至少要100个字符"
          },
          "campaign[goal]": {
            number: "请只输入数字",
            min: "目标至少要1元"
          },
          "user[email]": {
            required: "请输入您的邮箱",
            email: "邮箱格式不正确"
          },
          "user[password]": {
            required: "请输入您的密码",
            minlength: "密码至少8位"
          },
          "user[confirm_password]": {
            required: "请确认您的密码",
            equalTo: "密码不匹配，请重新输入"
          },
          "user[first_name]": {
            required: "请输入您的昵称"
          },
          "user[last_name]": {
            required: "请输入您的名"
          },
          "user[terms_conditions]": {
            required: "在创建您的帐户前请先同意我们的服务协议"
          }
        }
    });

    //*********************************************************************************************************
    //      DONATION FORM
    //*********************************************************************************************************

    $("#donate_form").validate({

        // validate the previously selected element when the user clicks out
        onfocusout: function(element) {
          $(element).valid();
        },

        highlight: function(element) {
            $(element).closest('.form-group').addClass('has-error');
        },
        unhighlight: function(element) {
            $(element).closest('.form-group').removeClass('has-error');
        },

        // validation rules
        rules: {
          "direct_donation": { required: true, number: true, min: 1 }
        },
        // validation messages
        messages: {
          "direct_donation": "请输入一个数量"
        }

      });

    //*********************************************************************************************************
    //      PAYMENT FORM
    //*********************************************************************************************************

    $("#payment_form").validate({

        // custom handler to call named function ""
        submitHandler: function(form) {
            Raisy.shop.submitPaymentForm(form);
        },

        // validate the previously selected element when the user clicks out
        onfocusout: function(element) {
          $(element).valid();
        },

        highlight: function(element) {
            $(element).closest('.form-group').addClass('has-error');
        },
        unhighlight: function(element) {
            $(element).closest('.form-group').removeClass('has-error');
        },

        // hide the loader when form is not valid
        // add back in name attributes when form is not valid
        invalidHandler: function(event, validator) {
          $('#card_number').attr('name', 'card_number');
          $('#cvv').attr('name', 'cvv');
        },

        // validation rules
        rules: {
          	"order[fullname]": { required: true },
          	"order[email]": { required: true, email: true },
          	"card_number": { required: true, minlength: 12, creditcard: true},
          	"cvv": { required: true, number: true, minlength: 3, maxlength: 4 },
          	"order[billing_zip_code]": { required: true },
          	"order[address_line_one]": { required: true },
          	"order[address_city]": { required: true },
			"order[address_city_area]": { required: true },
          	"order[address_state]": { required: true },
          	"order[address_postal_code]": { required: true },
		  	"order[address_country]": { required: true },
			"order[phone_number]": { required: true },
			"order[address_fullname]": { required: true }
        },
        // validation messages
        messages: {
          "order[fullname]": "请输入您的昵称",
          "order[email]": {
            required: "请输入您的邮箱",
            email: "邮箱格式不正确"
          },
          "card_number": {
            required: "请输入您的信用卡号",
            minlength: "信用卡号格式不正确",
            creditcard: "信用卡号格式不正确"
          },
          "cvv": {
            required: "请输入您的信用卡号的CVV",
            number: "CVV格式不正确",
            minlength: "CVV格式不正确",
            maxlength: "CVV格式不正确"
          },
          "order[billing_zip_code]": "请输入记账单邮编",
          "order[address_line_one]": "请输入收货人地址",
          "order[address_city]": "请输入收货人城市",
		  "order[address_city_area]": "请输入收货人区县",
          "order[address_state]": "请输入收货人直辖市/省份",
          "order[address_postal_code]": "请输入收货人邮编",
          "order[address_country]": "请输入收货人国家",
		  "order[phone_number]": "请输入收货人联系电话",
		  "order[address_fullname]": "请输入收货人姓名"
        }
	});

    //*********************************************************************************************************
    //      Campaign_Bulkshippinginfo FORM
    //*********************************************************************************************************
	
    $("#campaign_bulkshippinginfo_form").validate({

        // validate the previously selected element when the user clicks out
        onfocusout: function(element) {
          $(element).valid();
        },

        highlight: function(element) {
            $(element).closest('.form-group').addClass('has-error');
        },
		
        unhighlight: function(element) {
            $(element).closest('.form-group').removeClass('has-error');
        },

        // validation rules
        rules: {
			"campaign_bulkshippinginfo[ship_to_name]": { required: true },
			"campaign_bulkshippinginfo[address_line_1]": { required: true },
			"campaign_bulkshippinginfo[city]": { required: true },
			"campaign_bulkshippinginfo[zip_code]": { required: true, zipcode: true },
			"campaign_bulkshippinginfo[phone_number]": { required: true },
			"campaign_bulkshippinginfo[email_address]": { email: true }
        },
		// validation messages
        messages: {
            "campaign_bulkshippinginfo[ship_to_name]": {
              required: "请输入发货名称"
            },
            "campaign_bulkshippinginfo[address_line_1]": {
              required: "请输入地址"
            },
            "campaign_bulkshippinginfo[city]": {
              required: "请输入城市"
            },
            "campaign_bulkshippinginfo[zip_code]": {
              required: "请输入邮编",
			  zipcode: "邮编格式不正确"
            },
            "campaign_bulkshippinginfo[phone_number]": {
              required: "请输入联系电话"
            },
            "campaign_bulkshippinginfo[email_address]": {
              email: "邮箱格式不正确"
            }
        }
    });
	
});
