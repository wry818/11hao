class Admin::Reports::ReportsboardController < Admin::Reports::ApplicationController
  def reportindex
    @results=CampaignVisitLog.all.sort(:id)
  end
end
