#!/usr/bin/env ruby
# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'uri'
require 'json'
require 'sequel'
require 'logger'
require 'optparse'

class HttpClient
  DEFAULT_HEADERS = {
    'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36',
    'Accept-Language' => 'pl-PL,pl;q=0.9,en-US;q=0.8,en;q=0.7',
    'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8'
  }.freeze

  def initialize(delay_seconds: 2.0, max_retries: 3)
    @delay = delay_seconds
    @max_retries = max_retries
  end

  def get(url)
    tries = 0
    begin
      sleep @delay if tries.positive?
      URI.open(url, DEFAULT_HEADERS.merge('Referer' => referer_for(url))) { |io| io.read }
    rescue OpenURI::HTTPError, IOError, SocketError => e
      tries += 1
      warn "[HTTP] Błąd: #{e.class} #{e.message} (próba #{tries}/#{@max_retries}) dla #{url}"
      retry if tries < @max_retries
      nil
    end
  end

  private

  def referer_for(url)
    uri = URI(url)
    "#{uri.scheme}://#{uri.host}/"
  end
end

class AmazonParser
  AMAZON_HOST = 'www.amazon.com'

  def initialize(client: HttpClient.new)
    @client = client
  end

  def crawl_search(category: nil, keyword: nil, pages: 1)
    results = []
    (2...(pages + 2)).each do |page_num|  
      url = build_search_url(category: category, keyword: keyword, page: page_num)
      html = @client.get(url)
      next unless html

      doc = Nokogiri::HTML(html)
      results.concat(
        extract_list_results(doc).map { |r| r.merge(category: category, keyword: keyword) }
      )
    end
    results
  end

  def crawl_keywords(keywords, pages: 1)
    query = URI.encode_www_form_component(keywords)
    base = "https://#{AMAZON_HOST}/s?k=#{query}"
    crawl_category(base, pages: pages).map { |r| r.merge(keywords: keywords) }
  end

  private

  def build_search_url(category: nil, keyword: nil, page: 1)
    base = "https://www.amazon.com/s?"

    params = []
    params << "i=#{category}" if category
    params << "k=#{URI.encode_www_form_component(keyword)}" if keyword
    params << "page=#{page}" if page > 1

    base + params.join("&")
  end

  def extract_list_results(doc)
    items = []
    results = doc.css("div.s-main-slot div.s-result-item[data-asin]")

    results.each do |item|
      asin = item['data-asin']&.strip
      next if asin.nil? || asin.empty?

      title_node = item.at_css('h2 span, h2 a span')

      link_node = item.at_css('h2 a')

      price_node = item.at_css('span.a-price span.a-offscreen') ||
                  item.at_css('span.a-price-whole')

      title = text_or_nil(title_node)
      href = link_node&.[]('href')
      url = href ? to_absolute(href) : nil
      price_money = text_or_nil(price_node)

      items << {
        asin: asin,
        title: title,
        url: url,
        price: price_money
      }
    end
    items
  end

  def text_or_nil(node)
    node&.text&.strip
  end

  def to_absolute(href)
    href.start_with?('http') ? href : "https://#{AMAZON_HOST}#{href}"
  end
end

class CLI
  CATEGORIES = {
    "electronics" => "electronics",
    "books"       => "stripbooks",
    "fashion"     => "fashion",
    "toys"        => "toys-and-games"
  }

  def self.run(argv)
    options = {
      pages: 1,
      category: nil,
      keywords: nil,
      delay: 2.0
    }

    OptionParser.new do |opts|
      opts.banner = "Użycie: ruby amazon_crawler.rb [opcje]"

      opts.on('-c', '--category NAME', 'Nazwa kategorii (np. electronics, books). Jeśli brak – crawler przeszuka wszystkie.') do |v|
        options[:category] = v
      end

      opts.on('-k', '--keywords TEXT', 'Słowa kluczowe (np. "wireless headphones")') do |v|
        options[:keywords] = v
      end

      opts.on('-p', '--pages N', Integer, 'Liczba stron do pobrania (domyślnie 1)') do |v|
        options[:pages] = v
      end

      opts.on('--delay SECONDS', Float, 'Opóźnienie między żądaniami (domyślnie 2.0s)') do |v|
        options[:delay] = v
      end

      opts.on('-h', '--help', 'Pomoc') do
        puts opts
        puts "Dostępne kategorie: #{CATEGORIES.keys.join(', ')}"
        exit 0
      end
    end.parse!(argv)

    logger = Logger.new($stdout)
    client = HttpClient.new(delay_seconds: options[:delay])
    parser = AmazonParser.new(client: client)

    categories_to_process = if options[:category]
                              unless CATEGORIES.key?(options[:category])
                                warn "Nieznana kategoria: #{options[:category]}"
                                warn "Dostępne: #{CATEGORIES.keys.join(', ')}"
                                exit 1
                              end
                              { options[:category] => CATEGORIES[options[:category]] }
                            else
                              CATEGORIES
                            end

    categories_to_process.each do |cat_name, cat_urlname|
      logger.info "Przetwarzam kategorię: #{cat_name} (#{cat_urlname})"
      basics = parser.crawl_search(
        category: cat_urlname,
        keyword: options[:keywords],
        pages: options[:pages]
      )

      puts "Znaleziono pozycji: #{basics.size}"
      basics.each_with_index do |rec, idx|
        puts "[#{idx + 1}/#{basics.size}] '#{rec[:title]}' || PRICE: #{rec[:price]}"
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  CLI.run(ARGV)
end