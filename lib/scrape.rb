require 'capybara/dsl'

Capybara.default_driver = :selenium_chrome_headless
Capybara.ignore_hidden_elements = false

Coffee = Struct.new(:link, :name, :score, :notes, :price, :roast,
                    :process, :country, :province, :farm,
                    keyword_init: true) do
  def roast_short
    roast[0...22]
  end

  def score_as_float
    score != "n/a" ? score.to_f : -1.0
  end
end

class HasBeanProductPage
  include Capybara::DSL

  attr_reader :link

  def initialize(link)
    @link=link
  end

  def scrape
    puts "PAWEL scraping #{link}"
    visit link
    Coffee.new(
      link: link,
      name: extract_name,
      score: extract_score,
      notes: extract_notes,
      price: extract_price,
      roast: extract_roast,
      process: extract_process,
      country: extract_country,
      province: extract_province,
      farm: extract_farm,
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

  def extract_score
    total = all("div#cupping-notes p", text: /Total.*:.*/).first
    total ? total.text.scan(/Total.*\): (.*)/)[0][0] : "n/a"
  end

  def extract_roast
    roast = all("div#cupping-notes p", text: /Roast.*/).first
    roast.text.scan(/Roast.*Information(.*)/)[0][0]
  end

  def extract_country
    country = all("div#details li", text: /Country:.*/).first
    country ? country.text.scan(/Country:(.*)/)[0][0].strip : "n/a"
  end

  def extract_province
    province = all("div#details li", text: /(Province|Region):.*/).first
    province ? province.text.scan(/(Province|Region):(.*)/)[0][1].strip : "n/a"
  end

  def extract_farm
    farm = all("div#details li", text: /(Farm|Farm name):.*/).first
    farm ? farm.text.scan(/(Farm|Farm name):(.*)/)[0][1].strip : "n/a"
  end

  def extract_process
    process = all("div#details li", text: /(Process|Processing|Processing method):.*/).first
    process ? process.text.scan(/(Process|Processing|Processing method):(.*)/)[0][1].strip : "n/a"
  end
end


class HasBeanCoffeeCollectionPage
  include Capybara::DSL

  def initialize(limit)
    @limit = limit
  end

  def scrape
    puts "PAWEL Scraping Collection Page"
    visit "https://www.hasbean.co.uk/collections/coffee"

    coffees=all('.grid-link').to_a
    coffee_links=coffees.map { |c| c['href'] }.take(@limit)

    return coffee_links.map { |cl| HasBeanProductPage.new(cl).scrape }
  end
end
