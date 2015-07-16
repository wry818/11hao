$( document ).ready(function() {
	
    //*********************************************************************************************************
    //      CAMPAIGN CREATION FORM
    //*********************************************************************************************************

    $("#campaign_form").validate({
		
        // custom handler to call named function ""
        submitHandler: function(form) {
          window.Raisy_admin_campaigns.submitCampaignForm(form);
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
		     if (element.hasClass("campaign-collection-id"))
		       error.appendTo(element.parent());
		     else  
		       error.insertAfter(element);
		},

        // validation rules
        rules: {
			"organization_name": { required: true },
            "campaign[title]": { required: true, maxlength: 100 },
            "campaign[organizer_quote]": { maxlength: 100 },
            "campaign[goal]": { number: true, min: 1 },
			"campaign[seller_goal]": { number: true, min: 1 },
            "campaign[call_to_action]": { required: true },
			"campaign[discount]": { number: true, min: 0 },
			"campaign[purchase_limit]": { number: true, min: 0 }
        },
        messages: {
          "organization_name": {
            required: "请选择组织"
          },
          "campaign[title]": {
            required: "请填写筹款标题",
            maxlength: "筹款标题最多100字"
          },
          "campaign[organizer_quote]": {
            maxlength: "宣传口号最多100字"
          },
          "campaign[goal]": {
            number: "请输入数字",
            min: "筹款目标最少是一元钱"
          },
          "campaign[goal]": {
            number: "请输入数字",
            min: "个人筹款目标最少是一元钱"
          },
          "campaign[discount]": {
            number: "请输入数字",
			min: "Minimum is 0"
          },
          "campaign[purchase_limit]": {
            number: "请输入数字",
			min: "打折商品数量最小为零"
          }
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
        messages: {
            "campaign_bulkshippinginfo[ship_to_name]": {
              required: "Please enter ship to name"
            },
            "campaign_bulkshippinginfo[address_line_1]": {
              required: "Please enter address line 1"
            },
            "campaign_bulkshippinginfo[city]": {
              required: "Please enter city"
            },
            "campaign_bulkshippinginfo[zip_code]": {
              required: "Please enter zip/postal code",
			  zipcode: "Hmm, that doesn't look valid yet"
            },
            "campaign_bulkshippinginfo[phone_number]": {
              required: "Please enter phone number"
            },
            "campaign_bulkshippinginfo[email_address]": {
              email: "Hmm, that doesn't look valid yet"
            }
        }
    });
	
	$("#option_group_form").validate({
        // custom handler to call named function ""
        submitHandler: function(form) {
          window.Raisy_admin_products.submitOptionGroupForm(form);
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
			"option_group[name]": { required: true }
        },
		// validation messages
        messages: {
            "option_group[name]": {
              required: "请输入选项组名称"
            }
        }
	});
	
	$("#organization_form").validate({
        // custom handler to call named function ""
        submitHandler: function(form) {
          window.Raisy_admin_organizations.submitOrganizationForm(form);
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
			"organization[name]": { required: true }
        },
		// validation messages
        messages: {
            "organization[name]": {
              required: "请输入组织名称"
            }
        }
	});
	
	$("#vendor_form").validate({
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
					"vendor[name]": { required: true },
					"vendor[email]": { required: true }
        },
        messages: {
            "vendor[name]": {
              required: "请输入供应商名称"
            },
            "vendor[email]": {
              required: "请输入Email"
            }
        }
	});
});