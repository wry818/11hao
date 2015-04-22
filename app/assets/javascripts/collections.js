Raisy.collections = {
    init: function() {
        var _this = this;

        $('.launch-invite-modal').on('click', function(e) {
            e.preventDefault();
            var $this = $(this);
            $('#invite_collection_id').val(parseInt($this.attr('data-collection')));
            $('#invite-modal').modal('show');
        });

        $('.launch-wizard-modal').on('click', function(e) {
            e.preventDefault();
            var $this = $(this);

            $('#campaign_collection_id').val(parseInt($this.attr('data-collection')));
            $('.wizard-modal-collection-name').text($this.attr('data-name'));

            $('#wizard-modal').modal('show');
            $('#wizard-modal').on('shown.bs.modal', function (e) {
                $('#campaign_title').focus();
            })
        });

    },

    submitCampaignWizardForm: function(form) {
        $('#campaign-wizard-form-submit').prop('disabled', true).find('span.text').text('Saving').siblings('span.loader').show(200, function() {
            form.submit();
        });
    }
}
