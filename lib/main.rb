require 'capybara/dsl'

Capybara.default_driver = :selenium_chrome
Capybara.ignore_hidden_elements = false

CuppingNotes = Struct.new(:score, keyword_init: true)
Coffee = Struct.new(:link, :name, :notes, :price, :cupping_notes, keyword_init: true)

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
      notes: extract_notes,
      price: extract_price,
      cupping_notes: extract_cupping_notes
    )
  end

  def extract_name
    find("div.product-single h1[itemprop='name']").text
  end

  def extract_notes
    find("div.product-single p.h2").text
  end

  def extract_price
    find("div.product-single span#ProductPrice").text
  end

  def extract_cupping_notes
    total = all("div#cupping-notes strong", text: /Total:.*/).first
    CuppingNotes.new(
      score: total ? total.text.scan(/Total.*\): (.*)/).last : "n/a"
    )
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
pp table
