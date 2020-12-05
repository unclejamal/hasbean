require 'capybara/dsl'

Capybara.default_driver = :selenium_chrome

Coffee = Struct.new(:link, :name, :notes, keyword_init: true)

class HasBeanProductPage
  include Capybara::DSL

  attr_reader :link

  def initialize(link)
    @link=link
  end

  def scrape
    visit link
    Coffee.new(
      link: link,
      name: extract_name,
      notes: extract_notes
    )
  end

  def extract_name
    find("h1").text
  end

  def extract_notes
    find("p.h2").text
  end
end


class HasBeanCoffeeCollectionPage
  include Capybara::DSL

  def scrape
    visit "https://www.hasbean.co.uk/collections/coffee"

    coffees=all('.grid-link').to_a
    coffee_links=coffees.take(2).map { |c| c['href'] }  # TODO: remove take

    return coffee_links.map { |cl| HasBeanProductPage.new(cl).scrape }
  end
end


table = HasBeanCoffeeCollectionPage.new.scrape
puts table
