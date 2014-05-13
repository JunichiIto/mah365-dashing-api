class BlogInfo < ActiveRecord::Base
  RSS_URL = "http://blog.mah-lab.com/feed/"

  JST_OFFSET = Rational(9, 24).freeze
  BEGINNING_OF_YEAR = DateTime.new(2013, 12, 5, 0, 0, 0, JST_OFFSET).freeze
  END_OF_YEAR = BEGINNING_OF_YEAR.since(1.year).ago(1.day).end_of_day.freeze

  validates :title, :published_at, :url, presence: true

  scope :by_yesterday, -> { where(published_at: span_by_yesterday) }
  scope :by_today, -> { where(published_at: span_by_today) }

  class << self
    def info_all
      {
          update_rate: update_rate,
          updated_count_by_today: updated_dates_by_today.count,
          todays_post: todays_post.try(:title),
          dates_to_go: dates_to_go
      }
    end

    def update_rate
      rate = (100.0 * updated_dates_by_today.count / dates_by_yesterday.count).round(2)
      rate > 100 ? 100 : rate
    end

    def todays_post
      self.where(published_at: Date.current.beginning_of_day..Date.current.end_of_day).first
    end

    def dates_to_go
      count = (Date.current..END_OF_YEAR.to_date).count
      count < 0 ? 0 : count
    end

    def updated_dates_by_yesterday
      updated_dates by_yesterday
    end

    def updated_dates_by_today
      updated_dates by_today
    end

    def updated_dates(relation)
      relation.order(:published_at).pluck(:published_at).map(&:to_date).uniq
    end

    def dates_by_yesterday
      span_by_yesterday.map(&:to_date)
    end

    def span_by_yesterday
      BEGINNING_OF_YEAR..DateTime.yesterday.end_of_day
    end

    def span_by_today
      BEGINNING_OF_YEAR..DateTime.current.end_of_day
    end

    def update_latest_info
      logger.info "####### Start update_latest_info"

      feed = fetch_feeds(RSS_URL).first

      if feed[:published_at].to_date.in?(updated_dates_by_today)
        logger.info "[INFO] Already updated."
      else
        logger.info "[INFO] Save: #{feed.inspect}"
        BlogInfo.create!(feed)
      end
      logger.info "####### Complete update_latest_info"
    end

    def update_all
      self.transaction do
        logger.info "[INFO] Destroy all."
        self.destroy_all

        create_feed_history
      end
    end

    def create_feed_history
      paged = 1
      while paged == 1 or BlogInfo.last.published_at.to_date > BEGINNING_OF_YEAR do
        url = "#{RSS_URL}?paged=#{paged}"

        fetch_feeds(url).each do |feed|
          logger.info "[INFO] Save: #{feed.inspect}"
          BlogInfo.create!(feed)
        end

        paged += 1
        sleep 2
      end
    end

    def fetch_feeds(url)
      logger.info "[INFO] Open: #{url}"
      feeds = FeedNormalizer::FeedNormalizer.parse(open(url), force_parser: FeedNormalizer::SimpleRssParser).items
      feeds.map{|feed|
        {
            title: feed.title,
            published_at: feed.date_published,
            url: feed.urls[0]
        }
      }
    end
  end
end
