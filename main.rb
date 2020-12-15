require_relative './lib/scrape.rb'
require 'sinatra'

coffees = []

Thread.new do
  loop do
    puts "PAWEL Refresh Start"
    coffees = HasBeanCoffeeCollectionPage.new.scrape
    coffees = coffees.sort_by {|c| -c.cupping_notes.score_as_int}
    puts "PAWEL Refresh End"
    sleep 60*60 # sleep 1 hour
  end
end

get '/' do
  @table = coffees
  erb :index
end
