#=====================================================
# EPU Construction (12/10)
#=====================================================
library(htmlwidgets)
library(webshot)
library(xts)
library(tidyverse)
library(highcharter)
require(TTR)
library(magrittr)
require("stringr")
library("bindrcpp")
# 匯入函數庫
#source("EPU_Index.R")
source("EPU_Index_TiTi.R")
# 判斷個股資料(目前不需要)
#stock_list <- readRDS("tw_stock.rds")
#symbol_list <- stock_list
#name_list <- stock_list$簡稱
#=====================================================
# 經濟政策不確定性關鍵詞
#event_E <- c("兩岸","九二共識","國台辦","海協會","一國兩制")

event_U <- c("不透明","不確定性","不穩定","不穩定性","動盪","波動")
event_E <- c("經濟","生意","商業","產業","景氣")
event_P <- readLines("Policy_termset.txt", encoding = "UTF-8")
#writeLines(c(event_U,event_E,event_P), "termset.txt")
#=====================================================
# 從SQL匯入資料
library(RSQLite)
drv <- dbDriver("SQLite")
db_LT = dbConnect(drv, dbname = "Liberty_Times.db")
db_CT = dbConnect(drv, dbname = "China_Times.db")
db_AD = dbConnect(drv, dbname = "Apple_Daily.db")
# get a list of all tables (確認SQL中Tables的名稱，可不執行)
dbListTables(db_LT)
dbListTables(db_CT)
# read the table you want
#dbListFields(db_CT,"CT")
#CT <- dbGetQuery(db_CT, 'SELECT content FROM CT LIMIT 1000')
LT <- dbReadTable(db_LT, "LT")
CT <- dbReadTable(db_CT, "CT")
CTEE <- dbReadTable(db_CT, "CTEE")
AD <- dbReadTable(db_AD, "AD")
# disconnect with dbs
dbDisconnect(db_LT); dbDisconnect(db_CT); dbDisconnect(db_AD)
#=====================================================
# Merge all data
news <- list(LT = LT, CT = CT, CTEE = CTEE, AD = AD)
#=====================================================
# Execution: 近期100日作為測試
news <- readRDS("EPU_Counts_1130.rds")
last(news$LT$date)
#CTEE <- readRDS("CTEE.rds")
new <- list(LT = na.omit(LT.2017.11), CT = na.omit(CT1.2017.11),
            CTEE = na.omit(CT2.2017.11), AD = na.omit(AP.2017.11))
new <- EPU_Counts(new)
news_1209 <- list(LT = rbind(news$LT, new$LT),
                  CT = rbind(news$CT, new$CT),
                  CTEE = rbind(news$CTEE, new$CTEE),
                  AD = rbind(news$AD, new$AD))
saveRDS(news_1209, "EPU_Counts_1209.rds")
news = news_1209
Index_d <- EPU_Index(news_1209, freq = "daily")
Index_w <- EPU_Index(news_1209, freq = "weekly")
Index_m <- EPU_Index(news_1209, freq = "monthly")
saveRDS(Index_d, "Index_daily.rds")
saveRDS(Index_w, "Index_weekly.rds")
saveRDS(Index_m, "Index_monthly.rds")
#=====================================================
# Plot
#=====================================================
library(highcharter)
Index_YTD <- Index %>% filter(date >= ymd("2017-01-01"))
hchart(Index_YTD, "line", hcaes(x = date, y = Index)) %>%
  hc_title(text = list("Daily EPU Index")) %>%
  hc_subtitle(text = list("Source: China Times, Liberty Times")) %>%
  hc_tooltip(pointFormat="{series.name} : {point.y:.2f}") %>%
  hc_add_theme(hc_theme_ft())

hchart(Index_M, "line", hcaes(x = date, y = Index)) %>%
  hc_title(text = list("Monthly EPU Index")) %>%
  hc_subtitle(text = list("Source: China Times, Liberty Times")) %>%
  hc_tooltip(pointFormat="{series.name} : {point.y:.2f}") %>%
  hc_add_theme(hc_theme_ft())

#=====================================================
# Taiwan weighted index
#=====================================================
library(tidyquant)

TAIEX <- tq_get("^TWII", from = "2009-09-01")
TAIEX <- select(TAIEX, c(date, close))
TAIEX_M <- TAIEX %>% 
  group_by(format(date, "%Y-%m")) %>%
  summarise(close = last(close))
names(TAIEX_M) <- c("date", "close")
EPU_M <- merge(Index_m, TAIEX_M, by.x = "date")

highchart() %>%
  hc_title(text = list("Monthly EPU Index and TAIEX")) %>%
  hc_subtitle(text = list("Source: China Times, Liberty Times, Apple Daliy")) %>%
  hc_yAxis_multiples(list(title = list(text = NULL)),
                     list(title = list(text = NULL), opposite = TRUE)) %>%
  hc_xAxis(categories = EPU_M$date) %>%
  hc_add_series(EPU_M$EPU, yAxis = 0, name = "EPU Index (L)", color = "#64B5F6") %>%
  hc_add_series(EPU_M$AD, yAxis = 0, name = "AD") %>%
  hc_add_series(EPU_M$CT, yAxis = 0, name = "CT") %>%
  hc_add_series(EPU_M$LT, yAxis = 0, name = "LT") %>%
  hc_add_series(EPU_M$close, yAxis = 1, name = "TAIEX (R)", color = "#E57373") %>%
  hc_add_theme(hc_theme_google())

#=====================================================
# 各個報紙單獨計算EPU
# CT
CT <- list(CT = news$CT, CTEE = news$CTEE)
names(CT$CT) = names(CT$CTEE) <- c("date", "content", "U","E","P","EPU","counts")
CT_EPU_d <- EPU_Index(CT, freq = "daily")
CT_EPU_w <- EPU_Index(CT, freq = "weekly")
CT_EPU_m <- EPU_Index(CT, freq = "monthly")
# LT
LT <- list(LT = news$LT)
names(LT$LT) <- c("date", "content", "U","E","P","EPU","counts")
LT_EPU_d <- EPU_Index(LT, freq = "daily")
LT_EPU_w <- EPU_Index(LT, freq = "weekly")
LT_EPU_m <- EPU_Index(LT, freq = "monthly")
# AD
AD <- list(AD = news$AD)
names(AD$AD) <- c("date", "content", "U","E","P","EPU","counts")
AD_EPU_d <- EPU_Index(AD, freq = "daily")
AD_EPU_w <- EPU_Index(AD, freq = "weekly")
AD_EPU_m <- EPU_Index(AD, freq = "monthly")

#=====================================================
save.hc <- function(fig, filename) {
  saveWidget(fig, file = paste0(filename, ".html"))
  webshot(paste0(filename, ".html"), file = paste0(filename, ".png"), delay = 2, zoom = 2)
  unlink(paste0(filename, ".html"))
}
Daily <- highchart() %>%
  hc_title(text = list("Daily EPU Index")) %>%
  hc_subtitle(text = list("Source: China Times, Liberty Times, Apple Daily")) %>%
  hc_yAxis(title = list(text = "EPU Indexes")) %>%
  hc_xAxis(categories = CT_EPU_d$date) %>%
  hc_add_series(CT_EPU_d$Index, type = "spline", name = "China Times") %>%
  hc_add_series(LT_EPU_d$Index, type = "spline", name = "Liberty Times") %>%
  hc_add_series(AD_EPU_d$Index, type = "spline", name = "Apple Daily") %>%
  hc_add_theme(hc_theme_ft())
save.hc(Daily, 1)

Monthly <- highchart() %>%
  hc_title(text = list("Monthly EPU Index")) %>%
  hc_subtitle(text = list("Source: China Times, Liberty Times, Apple Daily")) %>%
  hc_yAxis(title = list(text = "EPU Indexes")) %>%
  hc_xAxis(categories = CT_EPU_m$date) %>%
  hc_add_series(CT_EPU_m$Index, type = "spline", name = "China Times") %>%
  hc_add_series(LT_EPU_m$Index, type = "spline", name = "Liberty Times") %>%
  hc_add_series(AD_EPU_m$Index, type = "spline", name = "Apple Daily") %>%
  hc_add_theme(hc_theme_monokai())
Monthly
save.hc(Monthly, 2)

Weekly <- highchart() %>%
  hc_title(text = list("Weekly EPU Index")) %>%
  hc_subtitle(text = list("Source: China Times, Liberty Times, Apple Daily")) %>%
  hc_yAxis(title = list(text = "EPU Indexes")) %>%
  hc_xAxis(categories = CT_EPU_w$date) %>%
  hc_add_series(CT_EPU_w$Index, type = "spline", name = "China Times") %>%
  hc_add_series(LT_EPU_w$Index, type = "spline", name = "Liberty Times") %>%
  hc_add_series(AD_EPU_w$Index, type = "spline", name = "Apple Daily") %>%
  hc_add_theme(hc_theme_ft())
Weekly
save.hc(Weekly, 3)

#=====================================================
CT_EPU_d <- mutate(CT_EPU_d, year = year(date), weekday = weekdays(date, abbreviate = F))
LT_EPU_d <- mutate(LT_EPU_d, year = year(date), weekday = weekdays(date, abbreviate = F))
AD_EPU_d <- mutate(AD_EPU_d, year = year(date), weekday = weekdays(date, abbreviate = F))
Index_d <- mutate(Index_d, year = year(date), weekday = weekdays(date, abbreviate = F))

library(ggplot2)
#library(plot3D)

x = AD_EPU_d %>% 
  group_by(year, weekday) %>% 
  summarise(Index_M = mean(Index))
hchart(x, "column", hcaes(x = year, y = Index_M, group = weekday)) %>%
  hc_title(text = list("EPU Index divided by Weekday")) %>%
  hc_subtitle(text = list(paste0("Source: ", source))) %>%
  hc_yAxis(title = list(text = "EPU Index")) %>%
  hc_add_theme(hc_theme_elementary())
Fig4 <- function(x, source, type) {
  x <- x %>% 
    group_by(year, weekday) %>% 
    summarise(Index_M = mean(Index))
  hchart(x, type, hcaes(x = year, y = Index_M, group = weekday)) %>%
    hc_title(text = list("EPU Index divided by Weekday")) %>%
    hc_subtitle(text = list(paste0("Source: ", source))) %>%
    hc_yAxis(title = list(text = "EPU Index")) %>%
    hc_xAxis(title = list(text = "year")) %>%
    hc_add_theme(hc_theme_elementary())
}
# highcharter type: area, arearange, areaspline, areasplinerange, bar,
# bellcurve, boxplot, bubble, bullet, column, columnrange, errorbar, funnel,
# gauge, heatmap, histogram, line, pareto, pie, polygon, pyramid, sankey,
# scatter, scatter3d, series, solidgauge, spline, streamgraph, sunburst, 
# tilemap, treemap, variablepie, variwide, vector, waterfall, windbarb,
# wordcloud, xrange
Fig4(CT_EPU_d, "China Times", type = "streamgraph")
Weekday_CT <- Fig4(CT_EPU_d, "China Times", type = "spline")
Weekday_LT <- Fig4(LT_EPU_d, "Liberty Times")
Weekday_AD <- Fig4(AD_EPU_d, "Apple Daily")
Weekday_ALL <- Fig4(Index_d, "China Times, Liberty Times, Apple Daily")
Weekday_CT
Weekday_LT
Weekday_AD
Weekday_ALL
save.hc(Weekday_CT, 41)
save.hc(Weekday_LT, 42)
save.hc(Weekday_AD, 43)
save.hc(Weekday_ALL, 44)


#=====================================================
library(plot3D)
detach("package:plot3D")
row.names(z) <- weeks
hist3D(x = 1:5, y = 2009:2017, z = z,
        bty = "g", phi = 20,  theta = -60,
        xlab = "", ylab = "", zlab = "", main = "Mean of EPU Index",
        col = "#0072B2", border = "black", shade = 0.4,
        ticktype = "detailed", space = 0.15, d = 2, cex.axis = 1e-9)
# Use text3D to label x axis
text3D(x = 1:5, y = rep(0.5, 5), z = rep(3, 5),
       labels = rownames(z),
       add = TRUE, adj = 0)
# Use text3D to label y axis
text3D(x = rep(1, 9), y = 2009:2017, z = rep(0, 9),
       labels  = colnames(z),
       add = TRUE, adj = 1)



