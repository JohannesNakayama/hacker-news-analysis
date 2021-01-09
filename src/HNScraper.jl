module HNScraper

    export scrape_topstories
    export get_topstories

    # libraries
    using JSON
    using HTTP
    using DataFrames
    using Dates
    using Feather

    include("functions.jl")

end  


