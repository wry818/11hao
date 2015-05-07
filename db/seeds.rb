# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = User.create email: "xyang@entertainment.com", password: "temp1234", password_confirmation: "temp1234", admin_flag: true

UserProfile.create user: user, first_name: "Xiaobing", last_name: "Yang", child_profile: false

# Create three default campaign stories
CampaignStory.create title: "模版1", created_at: Time.new
CampaignStory.create title: "模版2", created_at: Time.new
CampaignStory.create title: "模版3", created_at: Time.new
CampaignStory.create title: "模版4", created_at: Time.new

# Create the collection of direct donation
Collection.create id: 0, name: "Direct Donation", active: false, slug: "Direct-Donation", created_at: Time.now, donation_percentage: 100

# Create the default user of EPI Support
user = User.create id: -1, email: "support@epi.com", password: "temp1234", password_confirmation: "temp1234", admin_flag: false

UserProfile.create user: user, first_name: "EPI", last_name: "Support", child_profile: false

# Set default chairperson email text
admin_setting = AdminSetting.new
admin_setting.default_cp_email_message = '<p>Please help us raise even more funds by joining the online fundraiser for {{fundraiser.title}}. It is simple and fun to set up your own personal fundraising page. Then, you can reach out to your supporters through email and social media and so they can purchase directly from your page, while you get credit!</p>
<p>Click <a href="{{fundraiser.signup.url}}" target="_blank">this link</a> to get started.</p>
<p>The SOONER you join, the MORE you can sell!</p>'
admin_setting.save

AccountType.create id: 1, name: "18+"
AccountType.create id: 2, name: "14-17"
AccountType.create id: 3, name: "13"
AccountType.create id: 4, name: "Sales"
AccountType.create id: 5, name: "CSR"