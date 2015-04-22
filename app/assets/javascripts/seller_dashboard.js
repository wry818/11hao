Raisy.seller_dashboard = {
    init: function() {
        var _this = this;
        $('.campaign-callout').on('click', function() {
            $('.campaign-dropdown').slideToggle('fast');
        });
		
		$("#seller_dashboard #navigations li").click(function(){
			$("#seller_dashboard #navigations li").removeClass("active");
			$("#seller_dashboard #navigations .nav-content").hide();
			$("#seller_dashboard #navigations " + $(this).attr("href")).show();
			
			$(this).addClass("active");
		});
		
		$("#nav-contacts .contact-edit-btn").click(function(){
			Raisy.users.editContactClick(this);
		});
		
		$("#nav-contacts .contact-save-btn").click(function(){
			Raisy.users.updateContactClick(this);
		});
		
		$("#nav-contacts .contact-cancel-btn").click(function(){
			Raisy.users.cancelContactClick(this);
		});
		
		$("#nav-contacts .contact-del-btn").click(function(){
			Raisy.users.deleteContactClick(this);
		});
    }

}
