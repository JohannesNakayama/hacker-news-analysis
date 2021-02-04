theme_hn <- function() {
  theme(plot.background = element_rect(color = "white", fill = "white"),
        plot.margin = margin(15, 15, 15, 15),
        plot.title = element_text(color = "black"),
        panel.background = element_rect(color = "grey50", fill = "white"),
        panel.grid.major.x = element_line(color = "grey70", size = 1),
        panel.grid.minor.x = element_line(color = "grey70", size = 0.7),
        panel.grid.major.y = element_line(color = "grey70", size = 1),
        panel.grid.minor.y = element_line(color = "grey70", size = 0.7),
        axis.title.x = element_text(color = "black"),
        axis.title.y = element_text(color = "black"),
        axis.text.x = element_text(color = "black"),
        axis.text.y = element_text(color = "black"))
}
