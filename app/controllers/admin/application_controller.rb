class Admin::ApplicationController < ApplicationController
    layout 'admin/layouts/application'
    before_filter :authenticate_admin!
end
