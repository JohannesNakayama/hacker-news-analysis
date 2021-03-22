library(shiny)
library(magrittr)
source(file.path("..", "helpers.R"))

if (!("hn-data-processed.rds" %in% list.files(file.path("..", "..", "data")))) {
  source(file.path("..", "preprocess.R"))
}


ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      sliderInput("max_rank_new", label = "Max Rank New", min = 10, max = 100, value = 50, step = 1),
      sliderInput("max_rank_top", label = "Max Rank Top", min = 10, max = 100, value = 50, step = 1),
      sliderInput("occur_count", label = "Number of Occurrences", min = 1, max = 1000, value = 1, step = 1)
    ),
    mainPanel(
      plotOutput("rank_plot", width = 1000)
    )
  )
)




server <- function(input, output) {

  data <- readr::read_rds(file.path("..", "..", "data", "hn-data-processed.rds"))  
  data %<>% 
    mutate(rank_newpage = as.integer(rank_newpage)) %>% 
    mutate(gained_votes = as.integer(gained_votes)) %>%  
    replace_na(list(rank_toppage = 0)) %>% 
    mutate(rank_toppage = as.integer(rank_toppage)) %>% 
    select(gained_votes, rank_toppage, rank_newpage) %>% 
    group_by(rank_toppage, rank_newpage) %>% 
    summarize(gained_sum = sum(gained_votes, na.rm = TRUE),
              gained_mean = mean(gained_votes, na.rm = TRUE),
              gained_median = median(gained_votes, na.rm = TRUE),
              count = n()) %>% 
    ungroup() 
  
  output$rank_plot <- renderPlot({
    data_new %>% 
      filter(rank_newpage < input$max_rank_new) %>% 
      filter(rank_toppage < input$max_rank_top) %>% 
      filter(count > input$occur_count) %>% 
      mutate(gained_mean = log(gained_mean)) %>%
      mutate_all(function(x) ifelse(is.infinite(x), -7, x)) %>%
      ggplot(aes(x = rank_newpage, y = rank_toppage, fill = gained_mean)) +
      geom_tile() +
      labs(title = "Gained votes on new vs. top page",
           x = "newpage rank",
           y = "toppage rank",
           fill = "log gained votes") +
      scale_y_reverse() +
      coord_fixed() +
      scale_fill_viridis_c() +
      theme_hn()
  })
  
}


shinyApp(ui, server)