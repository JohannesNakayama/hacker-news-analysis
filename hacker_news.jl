# H1: ranking has a direct influence on voting
# H2: influence of voting on ranking is not linear
# H3: distribution of votes over time is sinoidal

# libraries
using JSON
using HTTP
using DataFrames
using Dates
using Feather

# see an example story
story_endpoint = "https://hacker-news.firebaseio.com/v0/item/25623858.json"
response = HTTP.get(story_endpoint)
response_body = String(response.body)
story = JSON.parse(response_body)
for key in keys(story)
    print(key, "\t", typeof(story[key]), "\n")
end

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

# TO DO:
# ------ ACCOUNT FOR TIME DELAY FROM CALL
# ------ ADD TIMEOUT
function scrape_topstories(; top_n::Int, n_timeslices::Int, interval::Int)
    df_list = []
    for i in 1:n_timeslices
        ts_df = log_topstories(top_n)
        push!(df_list, deepcopy(ts_df))
        @info "Logged one time slice. Sleeping for $interval seconds."
        sleep(interval)
    end
    topstories = reduce(vcat, df_list)
    return topstories
end
                    
# log topstories with timestamp of extraction time
function log_topstories(n::Int)
    topstories = get_topstories(n)
    topstories_df = DataFrames.DataFrame(topstories.itemlist)
    topstories_df[!, :timestamp] .= topstories.timestamp
    topstories_df[!, :rank_at_timestamp] = 1:n
    return topstories_df
end

# get topstories 
function get_topstories(n::Int) 
    identifier = "https://hacker-news.firebaseio.com/v0/topstories.json"
    response = HTTP.get(identifier)
    response_body = String(response.body)
    topstories_id_list = JSON.parse(response_body)
    if length(topstories_id_list > n)
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


test = scrape_topstories(top_n = 10, n_timeslices = 3, interval = 10)

# scrape and write for preliminary analysis
prelim_data = scrape_topstories(top_n = 500, n_timeslices = 60, interval = 60)
if !("data" in readdir())
    mkdir("data")
end
Feather.write(joinpath("data", "prelim_data.feather"), prelim_data)