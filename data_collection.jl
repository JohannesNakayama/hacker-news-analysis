using Feather
include(joinpath("src", "HNScraper.jl"))
data = HNScraper.scrape_topstories(n_timeslices = 60 * 48, interval_minutes = 1)
Feather.write(joinpath("data", "hacker_news_data.feather"), data)