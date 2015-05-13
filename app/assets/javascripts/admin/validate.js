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
            "campaign[call_to_action]": { required: true },
			"campaign[discount]": { number: true, min: 0 },
			"campaign[purchase_limit]": { number: true, min: 0 }
        },
        messages: {
          "organization_name": {
            required: "Please select an organization"
          },
          "campaign[title]": {
            required: "Please provide a title",
            maxlength: "Title must be less than 100 characters"
          },
          "campaign[organizer_quote]": {
            maxlength: "Sub-title must be less than 100 characters"
          },
          "campaign[goal]": {
            number: "Only numbers, please",
            min: "Goal minimum is 1"
          },
          "campaign[discount]": {
            number: "Only numbers, please",
			min: "Minimum is 0"
          },
          "campaign[purchase_limit]": {
            number: "Only numbers, please",
			min: "Minimum is 0"
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
              required: "Please enter option group name"
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
              required: "Please enter organization name"
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
					"vendor[email]": { required: true, email: true }
        },
        messages: {
            "vendor[name]": {
              required: "Please enter name"
            },
            "vendor[email]": {
              required: "Please enter email",
							email: "Hmm, that doesn't look valid yet"
            }
        }
	});
});