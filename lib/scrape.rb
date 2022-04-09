require 'capybara/dsl'
require 'selenium-webdriver'

Capybara.register_driver :selenium_chrome_headless do |app|
  options = ::Selenium::WebDriver::Chrome::Options.new

  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end
Capybara.default_driver = :selenium_chrome_headless
Capybara.ignore_hidden_elements = false

Coffee = Struct.new(:link, :name, :score, :notes, :price, :roast,
                    :process, :country, :province, :farm, :varietal,
                    keyword_init: true) do
  def roast_short
    roast[0...22]
  end

  def score_as_float
    score != "n/a" ? score.to_f : -1.0
  end

  def alternative_name
    [
      country,
      farm[0...18],
      !!varietal ? varietal[0...18] : "n/a", # remove when update feed has varietals (mid April 2022)
      process.split(/ |-/).map { |s| s[0] }.join.upcase
    ].join(" | ")
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
      varietal: extract_varietal,
    )
  end

  def extract_name
    content = page.html
    begin
      find("div.product-container h1").text
    rescue Exception => e
      # unexpected but it does happen in prod sometimes... why?
      puts "Original content"
      puts content
      visit link
      puts "another visit content for #{link}"
      the_name = find("div.product-container h1").text
      puts "found #{the_name}"
      return the_name if !!the_name
      puts page.html
      puts "Reraise"
      raise e
    end
  end

  def extract_notes
    notes = all("div.product-container ul.metafield-list li", text: /.*Flavour profile.*/).first
    notes ? notes.text.scan(/.*Flavour profile (.*)/)[0][0] : "n/a"
  end

  def extract_price
    price = all("div.product-container span.price-item").first
    price ? price.text.strip : "n/a"
  end

  def extract_score
    total = all("div.product-container div#product_accordion_1 li", text: /Total.*\(max.? 100\).*:.*/).first
    return total.text.scan(/Total.*\(max.? 100\).*: (.*)/)[0][0] if total

    return "n/a"
  end

  def extract_roast
    roast = all("div.product-container div#product_accordion_1 p", text: /Roast.*/).first
    roast ? roast.text.scan(/Roast.*Information(.*)/)[0][0] : "n/a"
  end

  def extract_country
    country = all("div.product-container li.accordion li", text: /Country:.*/).first
    country ? country.text.scan(/Country:(.*)/)[0][0].strip : "n/a"
  end

  def extract_province
    province = all("div.product-container li.accordion li", text: /(Province|Region):.*/).first
    province ? province.text.scan(/(Province|Region):(.*)/)[0][1].strip : "n/a"
  end

  def extract_farm
    farm = all("div.product-container li.accordion li", text: /(Farm|Farm name|Estate|Washing station):.*/).first
    farm ? farm.text.scan(/(Farm|Farm name|Estate|Washing station):(.*)/)[0][1].strip : "n/a"
  end

  def extract_varietal
    varietal = all("div.product-container li.accordion li", text: /(Varietal|Varietals|Variety):.*/).first
    varietal ? varietal.text.scan(/(Varietal|Varietals|Variety):(.*)/)[0][1].strip : "n/a"
  end

  def extract_process
    process = all("div.product-container li.accordion li", text: /(Processing system|Processing method|Processing|Process):.*/).first
    process ? process.text.scan(/(Processing system|Processing method|Processing|Process):(.*)/)[0][1].strip : "n/a"
  end
end


class HasBeanCoffeeCollectionPage
  require 'open-uri'

  def initialize(limit)
    @limit = limit
  end

  def scrape
    puts "PAWEL Scraping Collection Page"
    atom = open("http://www.hasbean.co.uk/collections/coffee.atom", {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE})
    doc = Nokogiri::XML(atom)

    coffees = doc.search('entry link')
    coffee_links=coffees.map { |c| c['href'] }.take(@limit)
    return coffee_links.map { |cl| HasBeanProductPage.new(cl).scrape }
  end
end
