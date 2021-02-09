include(joinpath("src", "HNScraper.jl"))
using HTTP
using JSON


# see an example story
story_endpoint = "https://hacker-news.firebaseio.com/v0/item/25623858.json"
response = HTTP.get(story_endpoint)
response_body = String(response.body)
story = JSON.parse(response_body)
for key in keys(story)
    print(key, "\t", typeof(story[key]), "\n")
end

story["descendants"]


# H1: ranking has a direct influence on voting
# H2: influence of voting on ranking is not linear
# H3: distribution of votes over time is sinoidal

test = HNScraper.scrape_topstories(top_n = 10, n_timeslices = 2, interval = 2)


tss = unique(test["timestamp"])

Dates.unix2datetime(tss[1])

# scrape and write for preliminary analysis
prelim_data = HNScraper.scrape_topstories(top_n = 500, n_timeslices = 60, interval = 5)
if !("data" in readdir())
    mkdir("data")
end
Feather.write(joinpath("data", "five_hours.feather"), prelim_data)


begin
    i = 0
    cb(timer) = (global i += 1; println(i))
    t = Timer(cb, 4, interval=0.2)
    wait(t)
    sleep(0.5)
    close(t)
end

for i in 1:5
    t = Timer(5)
    @info "Now sleeping for 3 s."
    sleep(3)
    @info "Now waiting..."
    wait(t)
    print("Finally.\n")
end


HNScraper.scrape_topstories(n_timeslices = 2, interval_minutes = 2)