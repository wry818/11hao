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
	            required: "Please enter your email",
	            email: "Hmm, that email doesn't look valid"
	          },
	          "user[password]": {
	            required: "Please enter your password",
	            minlength: "Must be at least 8 characters"
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
			"first_name": { required: true, minlength: 2 },
			"last_name": { required: true, minlength: 2 }
        },
        messages: {
          "user[email]": {
            required: "Please enter your email",
            email: "Hmm, that email doesn't look valid"
          },
          "user[password]": {
            required: "Please enter your password",
            minlength: "Must be at least 8 characters"
          },
          "user[terms_conditions]": {
            required: "Please accept our terms and conditions before create your account"
          },
          "first_name": {
            required: "Please enter your first name",
            minlength: "Must be at least 2 characters"
          },
          "last_name": {
            required: "Please enter your last name",
            minlength: "Must be at least 2 characters"
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
					"user_profile[first_name]": { required: true, minlength: 2 },
					"user_profile[last_name]": { required: true, minlength: 2 },
					"seller[first_name]": { required: true, minlength: 2 },
					"seller[last_name]": { required: true, minlength: 2 },
					"guardian_agree": { required: true },
					"seller13[first_name]": { required: true, minlength: 2 },
					"seller13[last_name]": { required: true, minlength: 2 },
					"seller13[grade]": { required: true },
					"seller13[homeroom]": { required: true },
					"seller14[first_name]": { required: true, minlength: 2 },
					"seller14[last_name]": { required: true, minlength: 2 },
					"seller14[grade]": { required: true },
					"seller14[homeroom]": { required: true },
					"seller14[email]": { required: true, email: true },
					"seller14[password]": { required: true, minlength: 8 },
					"parent[first_name]": { required: true, minlength: 2 },
					"parent[last_name]": { required: true, minlength: 2 },
					"parent[email]": { required: true, email: true },
					"seller[grade]": { required: true },
					"seller[homeroom]": { required: true },
					"seller[email]": { required: true, email: true },
					"seller[password]": { required: true, minlength: 8 },
					"sellerexist[grade]": { required: true },
					"sellerexist[homeroom]": { required: true },
					"seller1314[first_name]": { required: true, minlength: 2 },
					"seller1314[last_name]": { required: true, minlength: 2 },
					"seller1314[grade]": { required: true },
					"seller1314[homeroom]": { required: true },
					"seller18[first_name]": { required: true, minlength: 2 },
					"seller18[last_name]": { required: true, minlength: 2 },
					"existing_seller_profile[id]": { required: true }
        },
        messages: {
          "user[fullname]": {
            required: "Please provide your first & last name",
            twowords: "Please provide your first & last name"
          },
          "user[email]": {
            required: "Please enter your email",
            email: "Hmm, that email doesn't look valid"
          },
          "user[password]": {
            required: "Please enter your password",
            minlength: "Must be at least 8 characters"
          },
          "user[confirm_password]": {
            required: "Please confirm your password",
            equalTo: "The passwords you entered do not match. Please try again"
          },
          "user[terms_conditions]": {
            required: "Please accept our terms and conditions before create your account"
          },
          "user_profile[first_name]": {
            required: "Please enter your first name",
            minlength: "Must be at least 2 characters"
          },
          "user_profile[last_name]": {
            required: "Please enter your last name",
            minlength: "Must be at least 2 characters"
          },
          "seller[first_name]": {
            required: "Please enter student first name",
            minlength: "Must be at least 2 characters"
          },
          "seller[last_name]": {
            required: "Please enter student last name",
            minlength: "Must be at least 2 characters"
          },
          "guardian_agree": {
            required: "Please check the agreement of Parent/Guardian Signup"
          },
          "seller13[first_name]": {
            required: "Please enter student first name",
            minlength: "Must be at least 2 characters"
          },
          "seller13[last_name]": {
            required: "Please enter student last name",
            minlength: "Must be at least 2 characters"
          },
          "seller13[homeroom]": {
            required: "Please enter group leader"
          },
          "seller13[grade]": {
            required: "Please enter grade"
          },
          "seller14[first_name]": {
            required: "Please enter your first name",
            minlength: "Must be at least 2 characters"
          },
          "seller14[last_name]": {
            required: "Please enter your last name",
            minlength: "Must be at least 2 characters"
          },
          "seller14[homeroom]": {
            required: "Please enter group leader"
          },
          "seller14[grade]": {
            required: "Please enter grade"
          },
          "seller14[email]": {
            required: "Please enter your email",
            email: "Hmm, that email doesn't look valid"
          },
          "seller14[password]": {
            required: "Please enter your password",
            minlength: "Must be at least 8 characters"
          },
          "parent[first_name]": {
            required: "Please enter parent first name",
            minlength: "Must be at least 2 characters"
          },
          "parent[last_name]": {
            required: "Please enter parent last name",
            minlength: "Must be at least 2 characters"
          },
          "parent[email]": {
            required: "Please enter parent email",
            email: "Hmm, that email doesn't look valid"
          },
          "seller[homeroom]": {
            required: "Please enter group leader"
          },
          "seller[grade]": {
            required: "Please enter grade"
          },
          "seller[email]": {
            required: "Please enter your email",
            email: "Hmm, that email doesn't look valid"
          },
          "seller[password]": {
            required: "Please enter your password",
            minlength: "Must be at least 8 characters"
          },
          "sellerexist[homeroom]": {
            required: "Please enter group leader"
          },
          "sellerexist[grade]": {
            required: "Please enter grade"
          },
          "seller1314[first_name]": {
            required: "Please enter student first name",
            minlength: "Must be at least 2 characters"
          },
          "seller1314[last_name]": {
            required: "Please enter student last name",
            minlength: "Must be at least 2 characters"
          },
          "seller1314[homeroom]": {
            required: "Please enter group leader"
          },
          "seller1314[grade]": {
            required: "Please enter grade"
          },
          "seller18[first_name]": {
            required: "Please enter your first name",
            minlength: "Must be at least 2 characters"
          },
          "seller18[last_name]": {
            required: "Please enter your last name",
            minlength: "Must be at least 2 characters"
          },
		  "existing_seller_profile[id]": {
			  required: "Please select an existing seller"
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
            required: "Please provide your organization's name"
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
			"user[first_name]": { required: true, minlength: 2 },
			"user[last_name]": { required: true, minlength: 2 },
			"user[terms_conditions]": { required: true }
        },
        messages: {
          "organization_name": {
            required: "Please select an organization"
          },
          "campaign[collection_id]": {
            required: "Please select a product"
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
          "user[email]": {
            required: "Please enter your email",
            email: "Hmm, that email doesn't look valid"
          },
          "user[password]": {
            required: "Please enter your password",
            minlength: "Must be at least 8 characters"
          },
          "user[confirm_password]": {
            required: "Please confirm your password",
            equalTo: "The passwords you entered do not match. Please try again"
          },
          "user[first_name]": {
            required: "Please enter your first name",
            minlength: "Must be at least 2 characters"
          },
          "user[last_name]": {
            required: "Please enter your last name",
            minlength: "Must be at least 2 characters"
          },
          "user[terms_conditions]": {
            required: "Please accept our terms and conditions before create your account"
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
          "direct_donation": "Please enter an amount"
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
          	"order[address_state]": { required: true },
          	"order[address_postal_code]": { required: true },
		  	"order[address_country]": { required: true },
			"order[phone_number]": { required: true },
			"order[address_fullname]": { required: true }
        },
        // validation messages
        messages: {
          "order[fullname]": "Please enter your full name",
          "order[email]": {
            required: "Please enter your email address",
            email: "Hmm, that doesn't look valid yet"
          },
          "card_number": {
            required: "Please enter your card number",
            minlength: "Hmm, that doesn't look valid yet",
            creditcard: "Hmm, that doesn't look valid yet"
          },
          "cvv": {
            required: "Please enter your card's CVV",
            number: "Hmm, that doesn't look valid yet",
            minlength: "Hmm, that doesn't look valid yet",
            maxlength: "Hmm, that doesn't look valid yet"
          },
          "order[billing_zip_code]": "Please enter your billing postal code",
          "order[address_line_one]": "Please enter recipient's address",
          "order[address_city]": "Please enter recipient's city",
          "order[address_state]": "Please enter recipient's state",
          "order[address_postal_code]": "Please enter recipient's postal code",
          "order[address_country]": "Please select recipient's county",
		  "order[phone_number]": "Please enter recipient's phone number",
		  "order[address_fullname]": "Please enter recipient's full name"
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
	
});
