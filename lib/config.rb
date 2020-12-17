class Config
  def self.app_mode
    ENV["APP_MODE"]
  end

  def self.is_test_mode?
    ENV["APP_MODE"]
  end

  def self.limit
    value = Config.is_test_mode? ? 3 : 999 # 999 = effectively no limit
    puts "PAWEL using limit of #{value} coffees"
    value
  end

  def self.redis_prefix
    value = Config.is_test_mode? ? "hasbeantest" : "hasbean"
    puts "PAWEL using redis prefix of #{value}"
    value
  end

  def self.redis_url
    ENV['RURL']
  end
end
