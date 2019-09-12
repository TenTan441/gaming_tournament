# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

# ページネーションラベルの設定
WillPaginate::ViewHelpers.pagination_options[:previous_label] = '前ページ'
WillPaginate::ViewHelpers.pagination_options[:next_label] = '次ページ'

# ChallongeのAPI使用設定
Challonge::API.username = 'TenTan441'
Challonge::API.key = 'RqayqZTRMe7TRXobnrkCGvlgh4u11gYzRpAt7i5D'