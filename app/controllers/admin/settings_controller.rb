class Admin::SettingsController < Admin::ApplicationController
  def default_email_message
    @admin_setting = AdminSetting.first
    
    if !@admin_setting
      @admin_setting = AdminSetting.new
    end
  end
  
  def default_chairperson_email_message
    @admin_setting = AdminSetting.first
    
    if !@admin_setting
      @admin_setting = AdminSetting.new
    end
  end
  
  def save_default_email_message
    @admin_setting = AdminSetting.first
    
    if !@admin_setting
      @admin_setting = AdminSetting.new
    end
    
    @admin_setting.default_email_message = params[:default_email_message]
    @admin_setting.default_email_message_two = params[:default_email_message_two]
    @admin_setting.save
    
    redirect_to "/admin/default_email_message", flash: { success: "默认销售邮件已保存" } and return
  end
  
  def save_default_chairperson_email_message
      @admin_setting = AdminSetting.first
    
      if !@admin_setting
        @admin_setting = AdminSetting.new
      end
    
      @admin_setting.default_cp_email_message = params[:default_cp_email_message]
      @admin_setting.default_cp_email_message_two = params[:default_cp_email_message_two]
      @admin_setting.save
    
      redirect_to "/admin/default_chairperson_email_message", flash: { success: "默认组织者邮件已保存" } and return
  end
end