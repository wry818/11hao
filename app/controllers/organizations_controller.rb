class OrganizationsController < ApplicationController

    def update_details
        @organization = Organization.friendly.find(params[:id])
        @organization.assign_attributes organization_params

        # Check if the new settings pass validations...if not, re-render form and display errors in flash msg
        if !@organization.valid?
            message = ''
            @organization.errors.each do |key, error|
                message = message + key.to_s.humanize + ' ' + error.to_s + ', '
            end
            flash.now[:danger] = message[0...-2]
            render 'chairperson_dashboard/organization_details' and return
        end

        @organization.save

        if params[:organization_logo].present?
            preloaded = Cloudinary::PreloadedFile.new(params[:organization_logo])
            if preloaded.valid?
                @organization.update_attribute(:logo, preloaded.identifier)
            end
        end

        redirect_to(dashboard_organization_details_url(@organization), flash: { success: "保存成功" }) and return
    end

    def update_deposit
        @organization = Organization.friendly.find(params[:id])
        @organization.assign_attributes organization_deposit_params

        # Check if the new settings pass validations...if not, re-render form and display errors in flash msg
        if !@organization.valid?
            message = ''
            @organization.errors.each do |key, error|
                message = message + key.to_s.humanize + ' ' + error.to_s + ', '
            end
            flash.now[:danger] = message[0...-2]
            render 'chairperson_dashboard/organization_deposit' and return
        end

        @organization.save

        redirect_to(dashboard_organization_deposit_url(@organization), flash: { success: "Deposit information updated!" }) and return
    end

    private
    # Using a private method to encapsulate the permissible parameters is
    # just a good pattern since you'll be able to reuse the same permit
    # list between create and update. Also, you can specialize this method
    # with per-user checking of permissible attributes.
    def organization_params
        params.require(:organization).permit :name, :address_line_one, :address_line_two, :address_city, :address_state, :address_postal_code, :phone,
                                                                  :email, :website
    end

    def organization_deposit_params
        params.require(:organization).permit :legal_name, :legal_tax_id, :legal_address_line_one, :legal_address_line_two, :legal_address_city,
                                                                  :legal_address_state, :legal_address_postal_code, :legal_rep_first_name, :legal_rep_last_name, :legal_rep_dob,
                                                                  :legal_rep_tax_id, :legal_rep_phone, :legal_rep_email, :account_number, :routing_number
    end

end
