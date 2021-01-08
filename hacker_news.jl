module HNScraper

export scrape_topstories

# libraries
using JSON
using HTTP
using DataFrames
using Dates
using Feather

# data structure for a story
struct Story 
    story_id::Int
    creator_username::String
    creation_time::Int64
    title::String
    score::Int
    comment_count::Int
end

# convenience constructor with named parameters
Story(; 
    story_id::Int, 
    creator_username::String,
    creation_time::Int64,
    title::String, 
    score::Int,
    comment_count::Int
) = Story(
    story_id, 
    creator_username,
    creation_time,
    title, 
    score,
    comment_count
)

# default constructor for convenient filtering of faulty stories
Story() = Story(
    story_id = -1,
    creator_username = "",
    creation_time = 0,
    title = "",
    score = 0,
    comment_count = 0
)

# data structure for a topstories list
struct TopStoriesList 
    itemlist::Array{Story}
    timestamp::Int
end

# get top_n top stories from hacker news
function scrape_topstories(; top_n::Int, n_timeslices::Int, interval::Int)
    if interval < 1
        interval = 1
        @info "Minimum interval is 1 minute. Setting interval = 1."
    end
    df_list = []
    for i in 1:n_timeslices
        while true 
            current_time = Dates.now()
            if ((Dates.minute(current_time) % interval) != 0) || (Dates.second(current_time) != 0)
                sleep(1)
                print(".")
            else
                print("\nRequest at $current_time", "\n")
                ts_df = log_topstories(top_n)
                push!(df_list, deepcopy(ts_df))
                break
            end
        end
        @info "Logged one time slice."
    end
    topstories = reduce(vcat, df_list)
    return topstories
end
                    
# log topstories with timestamp of extraction time
function log_topstories(n::Int)
    topstories = get_topstories(n)
    n = length(topstories)
    topstories_df = DataFrames.DataFrame(topstories.itemlist)
    topstories_df[!, :timestamp] .= topstories.timestamp
    topstories_df[!, :rank_at_timestamp] = 1:n
    return topstories_df
end

Base.length(tsl::TopStoriesList) = length(tsl.itemlist)

# get topstories 
function get_topstories(n::Int) 
    identifier = "https://hacker-news.firebaseio.com/v0/topstories.json"
    response = HTTP.get(identifier)
    response_body = String(response.body)
    topstories_id_list = JSON.parse(response_body)
    if length(topstories_id_list ) > n
        n = length(topstories_id_list)
    end
    topstories = map(get_story, topstories_id_list[1:n])
    timestamp = Int(floor(Dates.datetime2unix(Dates.now(UTC))))
    return TopStoriesList(topstories, timestamp)
end

# get story from id (factory-like)
function get_story(story_id::Int)
    identifier = "https://hacker-news.firebaseio.com/v0/item/$story_id" * ".json" 
    response = HTTP.get(identifier)
    response_body = String(response.body)
    story = JSON.parse(response_body)

    # TO DO:
    # ------ INCLUDE MECHANISM TO EXTRACT OTHER TYPES OF ITEMS
    if story["type"] != "story"
        @info "The element you requested is not a story (returned default story for convenient filtering)."
        return Story()
    end

    return Story(
        story_id = story["id"],
        creator_username = story["by"],
        creation_time = story["time"],
        title = story["title"],
        score = story["score"],
        comment_count = story["descendants"]
    )     
end

end  # end module


