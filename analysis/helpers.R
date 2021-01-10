theme_hn <- function() {
  theme(plot.background = element_rect(color = "grey70", fill = "grey70"),
        plot.title = element_text(color = "grey20"),
        panel.background = element_rect(color = "grey50", fill = "grey50"),
        panel.grid.major.x = element_line(color = "grey70", size = 1),
        panel.grid.minor.x = element_line(color = "grey70", size = 0.7),
        panel.grid.major.y = element_line(color = "grey70", size = 1),
        panel.grid.minor.y = element_line(color = "grey70", size = 0.7),
        axis.title.x = element_text(color = "grey20"),
        axis.title.y = element_text(color = "grey20"),
        axis.text.x = element_text(color = "grey30"),
        axis.text.y = element_text(color = "grey30"))
}