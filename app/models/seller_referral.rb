class SellerReferral < ActiveRecord::Base
  belongs_to :seller
  has_many :sellerreferrals
  belongs_to :sellerreferral
end