using Feather
include(joinpath("src", "HNScraper.jl"))
data = HNScraper.scrape_topstories(n_timeslices = 60 * 48, interval_minutes = 1)
Feather.write(joinpath("data", "hacker_news_data.feather"), data)

newstories = HNScraper.scrape_newstories(n_timeslices = 60, interval_minutes = 1)
Feather.write(joinpath("data", "hacker_news_newstories.feather"), newstories)

newstories = HNScraper.scrape_newstories(n_timeslices = 10, interval_minutes = 1)
Feather.write(joinpath("data", "hacker_news_newstories2.feather"), newstories)