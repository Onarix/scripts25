# Amazon Crawler

#### Prosty crawler produktów z Amazona w Ruby.

## Instalacja

* Wymagane Ruby 3.x.
  
1. Instalacja:

```bash
gem install nokogiri optparse
```

2. Użycie:

* Wszystkie kategorie (domyślnie 1 strona)
```bash
ruby amazon_crawler.rb
```

* Kilka stron
```bash
ruby amazon_crawler.rb --pages 3
```

* Konkretna kategoria
```bash
ruby amazon_crawler.rb --category electronics
```

* Keyword
```bash
ruby amazon_crawler.rb --keywords "wireless earbuds"
```

* Kategoria + keyword
```bash
ruby amazon_crawler.rb --category electronics --keywords "headphones"
```
