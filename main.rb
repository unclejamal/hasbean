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

coffees = []

Thread.new do
  loop do
    puts "PAWEL Refresh Start"
    coffees = HasBeanCoffeeCollectionPage.new(limit).scrape
    coffees = coffees.sort_by {|c| -c.cupping_notes.score_as_int}
    puts "PAWEL Refresh End"
    sleep 60*60 # sleep 1 hour
  end
end

get '/' do
  @table = coffees
  erb :index
end
