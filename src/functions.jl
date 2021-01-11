# data structure for a story
struct Story 
    id::Int64
    creator_username::String
    creation_time::Int64
    title::String
    score::Int64
    comment_count::Int64
    scrape_timestamp::Float64
end

# convenience constructor with named parameters
Story(; 
    id::Int64, creator_username::String, creation_time::Int64, title::String, score::Int64, comment_count::Int64, scrape_timestamp::Float64
) = Story(
    id, creator_username, creation_time, title, score, comment_count, scrape_timestamp
)

# default constructor for convenient filtering of faulty stories
Story() = Story(id = -1, creator_username = "NA", creation_time = -1, title = "NA", score = -1, comment_count = -1, scrape_timestamp = -1)

# data structure for a topstories list
struct TopStoriesList 
    itemlist::Array{Story}
    slice_timestamp::Float64
end

# get top stories from hacker news (every `interval_minutes` for a total of `n_timeslices` iterations)
function scrape_topstories(; n_timeslices::Int, interval_minutes::Int)
    (interval_minutes >= 1) || throw(DomainError(interval_minutes, "sampling rate cannot be less than 1 minute"))
    df_list = []
    for i in 1:n_timeslices
        t = Timer(interval_minutes * 60)
        current_time = Dates.now()
        @info "Request at $current_time"
        ts_df = log_topstories()
        push!(df_list, deepcopy(ts_df))
        @info "Logged time slice. Waiting for next request."
        wait(t)
    end
    topstories = reduce(vcat, df_list)
    return topstories
end
                    
# log topstories with timestamp of extraction time
function log_topstories()
    topstories = get_topstories()
    topstories_df = DataFrames.DataFrame(topstories.itemlist)
    topstories_df[!, :slice_timestamp] .= topstories.slice_timestamp
    topstories_df[!, :rank_at_timestamp] = 1:length(topstories)
    return topstories_df
end

Base.length(tsl::TopStoriesList) = length(tsl.itemlist)

# get topstories 
function get_topstories() 
    identifier = "https://hacker-news.firebaseio.com/v0/topstories.json"
    slice_timestamp = Dates.datetime2unix(Dates.now(UTC))
    response = HTTP.get(identifier)
    response_body = String(response.body)
    topstories_id_list = JSON.parse(response_body)
    topstories = asyncmap(get_story, topstories_id_list, ntasks = 20)
    return TopStoriesList(topstories, slice_timestamp)
end

# get story from id (factory-like)
function get_story(story_id::Int)
    identifier = "https://hacker-news.firebaseio.com/v0/item/$story_id" * ".json" 
    scrape_timestamp = Dates.datetime2unix(Dates.now(UTC))
    response = HTTP.get(identifier)
    response_body = String(response.body)
    story = JSON.parse(response_body)
    element_keys = keys(story)
    return Story(
        id = "id" in element_keys ? story["id"] : -1,
        creator_username = "by" in element_keys ? story["by"] : "NA",
        creation_time = "time" in element_keys ? story["time"] : -1,
        title = "title" in element_keys ? story["title"] : "NA",
        score = "score" in element_keys ? story["score"] : -1,
        comment_count = "descendants" in element_keys ? story["descendants"] : -1,
        scrape_timestamp = scrape_timestamp
    )
end

# POTENTIAL TO DO: subscribe to updates