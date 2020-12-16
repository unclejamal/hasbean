$stdout.sync = true

require_relative './lib/scrape.rb'
require 'sinatra'

for i in 0 ... ARGV.length
   puts "PAWEL ARGV #{i} #{ARGV[i]}"
end

limit = 999 # effectively no limit
if (ARGV.length > 0)
  if (ARGV[0] == "only-few-coffees")
    limit = 3
  end
end
puts "PAWEL using limit of #{limit} coffees"

refreshed_coffees = []
refreshed_last_updated = nil

Thread.new do
  loop do
    puts "PAWEL Refresh Start"
    refreshed_coffees = HasBeanCoffeeCollectionPage.new(limit).scrape
    refreshed_coffees = refreshed_coffees.sort_by {|c| -c.cupping_notes.score_as_float}
    refreshed_last_updated = Time.now
    puts "PAWEL Refresh End"
    sleep 60*60 # sleep 1 hour
  end
end

get '/' do
  @table = refreshed_coffees
  @last_updated = refreshed_last_updated
  erb :index
end
