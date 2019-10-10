#=====================================================
# Taiwan weighted index
#=====================================================
library(tidyquant)

TAIEX <- tq_get("^TWII", from = "2009-09-01", to = "2017-10-01")
TAIEX <- select(TAIEX, c(date, close))

TAIEX_M <- z %>% 
  group_by(format(date, "%Y-%m")) %>%
  summarise(close = sqrt(sum(x*100)))

names(TAIEX_M) <- c("date", "close")

EPU_M <- merge(Index_m, TAIEX_M, by.x = "date")

highchart() %>%
  hc_title(text = list("Monthly EPU Index and TAIEX")) %>%
  hc_subtitle(text = list("Source: China Times, Liberty Times, Apple Daliy")) %>%
  hc_yAxis_multiples(list(title = list(text = NULL)),
                     list(title = list(text = NULL), opposite = TRUE)) %>%
  hc_xAxis(categories = EPU_M$date) %>%
  hc_add_series(EPU_M$EPU, yAxis = 0, name = "EPU Index (L)", color = "#64B5F6") %>%
  hc_add_series(EPU_M$close*100, yAxis = 1, name = "RV of TAIEX (R)", color = "#E57373") %>%
  hc_add_theme(hc_theme_google())


z=TAIEX

x=diff(log(TAIEX$close))
x[is.na(x)]=0
x <- x^2
z %<>% mutate(x = c(0,x)) 

TAIEX$close <- TAIEX$close^2
cor(EPU_M$close,EPU_M$EPU)
cor.test(EPU_M$close,EPU_M$EPU)

