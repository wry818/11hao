class Admin::Reports::ApplicationController < Admin::ApplicationController
    layout 'admin/layouts/application'
    before_filter :authenticate_admin!
end
