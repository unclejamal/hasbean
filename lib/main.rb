require 'capybara/dsl'

Capybara.default_driver = :selenium_chrome

Coffee = Struct.new(:link)

class HasBeanProductPage
  include Capybara::DSL

  attr_reader :link

  def initialize(link)
    @link=link
  end

  def scrape
    Coffee.new(link)
  end
end


class HasBeanCoffeeCollectionPage
  include Capybara::DSL

  def scrape
    visit "https://www.hasbean.co.uk/collections/coffee"

    coffees=all('.grid-link').to_a
    coffee_links=coffees.map { |c| c['href'] }

    return coffee_links.map { |cl| HasBeanProductPage.new(cl).scrape }
  end
end


table = HasBeanCoffeeCollectionPage.new.scrape
puts table
