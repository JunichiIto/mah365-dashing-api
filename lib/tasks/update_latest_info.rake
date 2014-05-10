namespace :cron do
  desc "Update latest RSS feed."
  task update_latest_feed: :environment do
    BlogInfo.update_latest_info
  end
end