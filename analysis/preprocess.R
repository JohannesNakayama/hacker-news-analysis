library(dplyr)

compute_score <- function(votes, age) {
  ((votes - 1) ^ 0.8) / ((age + 2) ^ 1.8)
}

data_raw <- read.table(file.path("..", "data", "newstories_2021-02-24_10-10-23.tsv"), sep = "\t", header = TRUE)

# this is the main preprocessing procedure ----
data_raw %>% 
  rename(rank_toppage = topRank) %>% 
  mutate(rank_toppage = as.numeric(rank_toppage)) %>% 
  mutate(age_seconds = sample_time - submission_time) %>% 
  mutate(age_hours = age_seconds / 60 / 60) %>% 
  mutate(subtime_datetime = lubridate::as_datetime(submission_time, tz = "CET"),
         samptime_datetime = lubridate::as_datetime(sample_time, tz = "CET")) %>% 
  mutate(subtime_clocktime = update(subtime_datetime, yday = 1)) %>% 
  mutate(subtime_datetime_rounded = lubridate:: floor_date(subtime_datetime, "minute"),
         subtime_clocktime_rounded = lubridate::floor_date(subtime_clocktime, "minute"),
         samptime_datetime_rounded = lubridate::round_date(samptime_datetime, "minute")) %>% 
  group_by(samptime_datetime_rounded) %>%
  arrange(desc(subtime_datetime)) %>% 
  rename(rank_newpage = newRank) %>% 
  # mutate(rank_newpage = row_number()) %>% 
  ungroup() %>% 
  arrange(samptime_datetime_rounded) %>% 
  mutate(on_toppage = !is.na(rank_toppage)) %>% 
  mutate(score_computed = compute_score(score, age_hours)) %>%
  group_by(id) %>% 
  mutate(next_score = lead(score)) %>% 
  ungroup() %>% 
  mutate(gained_votes = next_score - score) %>%  
  select(-c(submission_time, sample_time, next_score)) %>% 
  select(id, score, score_computed, gained_votes, rank_toppage, on_toppage, rank_newpage, descendants, age_seconds, age_hours,
         subtime_datetime, subtime_datetime_rounded, subtime_clocktime, subtime_clocktime_rounded,
         samptime_datetime, samptime_datetime_rounded) -> data

readr::write_rds(data, file.path("..", "data", "hn-data-processed.rds"), compress = "gz")

rm(data_raw)
