class BlogInfo < ActiveRecord::Base
  RSS_URL = "http://blog.mah-lab.com/feed/"

  JST_OFFSET = Rational(9, 24).freeze
  BEGINNING_OF_YEAR = DateTime.new(2013, 12, 5, 0, 0, 0, JST_OFFSET).freeze
  END_OF_YEAR = BEGINNING_OF_YEAR.since(1.year).freeze

  validates :title, :published_at, :url, presence: true

  scope :by_yesterday, -> { where(published_at: span_by_yesterday) }
  scope :by_today, -> { where(published_at: span_by_today) }

  def self.info_all
    {
        everyday_updated_by_yesterday: everyday_updated_by_yesterday?,
        update_rate: update_rate,
        updated_today: updated_today?,
        updated_count_by_today: updated_dates_by_today.count,
        todays_post: todays_post.try(:title)
    }
  end

  def self.everyday_updated_by_yesterday?
    dates_by_yesterday == updated_dates_by_yesterday
  end

  def self.update_rate
    rate = (100.0 * updated_dates_by_today.count / dates_by_yesterday.count).round(2)
    rate > 100 ? 100 : rate
  end

  def self.updated_today?
    updated_dates_by_today.last == Date.current
  end

  def self.todays_post
    self.where(published_at: Date.current.beginning_of_day..Date.current.end_of_day).first if updated_today?
  end

  def self.updated_dates_by_yesterday
    updated_dates(self.by_yesterday)
  end

  def self.updated_dates_by_today
    updated_dates(self.by_today)
  end

  def self.updated_dates(relation)
    relation.order(:published_at).pluck(:published_at).map(&:to_date).uniq
  end

  def self.dates_by_yesterday
    span_by_yesterday.map(&:to_date)
  end

  def self.span_by_yesterday
    BEGINNING_OF_YEAR..DateTime.yesterday.end_of_day
  end

  def self.span_by_today
    BEGINNING_OF_YEAR..DateTime.current.end_of_day
  end

  def self.update_latest_info
    logger.info "####### Start update_latest_info"

    feed_hash = fetch_latest_feed

    if feed_hash[:published_at].to_date.in?(updated_dates_by_today)
      logger.info "[INFO] Already updated."
    else
      logger.info "[INFO] Save: #{feed_hash.inspect}"
      BlogInfo.create!(feed_hash)
    end
    logger.info "####### Complete update_latest_info"
  end

  def self.fetch_latest_feed
    logger.info "[INFO] Open: #{RSS_URL}"
    feed = FeedNormalizer::FeedNormalizer.parse(open(RSS_URL), force_parser: FeedNormalizer::SimpleRssParser).items[0]
    {
        title: feed.title,
        published_at: feed.date_published,
        url: feed.urls[0]
    }
  end

  def self.update_all
    self.transaction do
      logger.info "[INFO] Destroy all."
      self.destroy_all

      paged = 1
      while paged == 1 or BlogInfo.last.published_at.to_date > BEGINNING_OF_YEAR do
        url = "#{RSS_URL}?paged=#{paged}"

        logger.info "[INFO] Open: #{url}"
        feeds = FeedNormalizer::FeedNormalizer.parse(open(url), force_parser: FeedNormalizer::SimpleRssParser).items
        feeds.each do |feed|
          feed_hash = {
              title: feed.title,
              published_at: feed.date_published,
              url: feed.urls[0]
          }
          logger.info "[INFO] Save: #{feed_hash.inspect}"
          BlogInfo.create!(feed_hash)
        end

        logger.info "[INFO] Last info: #{BlogInfo.last.inspect}"

        paged += 1
        sleep 2
      end
    end
  end
end
