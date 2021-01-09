# libraries
begin
    using JSON
    using HTTP
    using DataFrames
    using Dates
    using Feather
end

# load scraper module
include(joinpath("src", "HNScraper.jl"))

# H1: There are only small changes over intervals of less than 5 minutes.
h1_data = HNScraper.scrape_topstories(n_timeslices = 30, interval_minutes = 2)
Feather.write(joinpath("data", "h1_data.feather"), h1_data)

# test data over longer period for EDA
eda_data = HNScraper.scrape_topstories(n_timeslices = 60, interval_minutes = 5)
Feather.write(joinpath("data", "eda_data.feather"), eda_data)
