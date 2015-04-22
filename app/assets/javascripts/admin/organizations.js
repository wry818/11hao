window.Raisy_admin_organizations = {
	init: function() {
		if ($(".organization_form").length>0) {
			window.Raisy_admin_organizations.bind_state_province(country_id);
			
			$("#organization_address_country").change(function(){
				window.Raisy_admin_organizations.bind_state_province($(this).val());
			});
			
			state_province_id=0;
		}
	},
	bind_state_province: function(country_id) {
		$("#organization_address_state").empty();
		
		$(state_provinces).each(function(){
			if (this.country_id.toString()==country_id.toString())
			{
				var option="<option value='" + this.id.toString() + "'";
			
				if (this.id==state_province_id)
					option+=" selected";
			
				option+=">" + this.name + "</option>";
				
				$(option).appendTo($("#organization_address_state"));
			}
		});
	},
	submitOrganizationForm: function(form) {
		form.submit();
	}
}