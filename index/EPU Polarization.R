#=====================================================
# EPU Index: Politic polarization (12/10)
#=====================================================
library(htmlwidgets)
library(webshot)
library(reshape2)
setwd("~/Google Drive/R/EPU_TW")
# ????摨?
source("EPU_Index.R")

Blue <- c("中國國民黨","國民黨","藍黨","KMT")
Green <- c("民主進步黨","民進黨","綠黨","DPP")

EPU_Polarization <- function(mydat, n = NULL) {
  if(is.list(mydat)) {
    time.start <- Sys.time()
    len = length
    # ???????見?????
    first_date <- c()
    for (a in 1:len(mydat)) {
      first_date <- append(first_date, first(mydat[[a]]$date))
    }
    first_date <- max(ymd(first_date))
    # ???脰??摮?
    for (j in 1:len(mydat)) {
      mydat[[j]] <- select(mydat[[j]], date, content)
      mydat[[j]]$date <- ymd(mydat[[j]]$date)
      if(!is.null(n)) {
        pivot <- max(first_date, ymd("2017-10-31") - n)
        mydat[[j]] <- subset(mydat[[j]], date >= pivot)
      } else {
        mydat[[j]] <- subset(mydat[[j]], date >= first_date)
      }
      B = G = EPU = c()
      for(i in 1:nrow(mydat[[j]])) {
        # Category B
        B <- append(B, str_match_all(mydat[[j]]$content[i], Blue) %>% unlist %>% len)
        # Category G
        G <- append(G, str_match_all(mydat[[j]]$content[i], Green) %>% unlist %>% len)
        # EPU dummy variable
        EPU <- append(EPU, ifelse(any(c(B[i], G[i]) == 0), 0, 1))
      }
      mydat[[j]] <- mutate(mydat[[j]], B, G, EPU, counts = B + G)
    }
  } else
    stop("The format is wrong!")
  time.interval <- time_length(interval(time.start, Sys.time()), unit = "min") %>% round(2)
  cat("All articles are processed! Execution time: ", time.interval, "mins", "\n")
  return(mydat)
}



news_p$LT
news_p = news
for (i in 1:4) {
  news_p[[i]] <- news_p[[i]] %>% 
    select(date, content)
}

test <- EPU_Polarization(news_p, n = 10000)
news_p <- test
EPU_Index(test, "daily")

# 瑼Ｘ??蝝????活?瘥??
save.hc <- function(fig, filename) {
  saveWidget(fig, file = paste0(filename, ".html"))
  webshot(paste0(filename, ".html"), file = paste0(filename, ".png"), delay = 2, zoom = 2)
  unlink(paste0(filename, ".html"))
}

LT_p <- news_p$LT %>% 
  group_by(date = format(ymd(date), "%Y-%m")) %>% 
  summarise(KMT = sum(B), DKK = sum(G)) %>% 
  melt(id = "date") %>% 
  mutate(colors = ifelse(variable == "KMT", "#2980b9", "#2ecc71"))

LT_p_m <- hchart(LT_p, "line", hcaes(x = date, y = value, group = variable)) %>% 
  hc_colors(colors = c("#2980b9", "#2ecc71")) %>% 
  hc_title(text = list("Monthly Counts of Liberty times")) %>% 
  hc_xAxis(title = list(text = "Date")) %>% 
  hc_yAxis(title = list(text = "Counts"))
save.hc(LT_p_m, "LT_p monthly counts")

CT_p <- news_p$CT %>% 
  group_by(date = format(ymd(date), "%Y-%m")) %>% 
  summarise(KMT = sum(B), DKK = sum(G)) %>% 
  melt(id = "date") %>% 
  mutate(colors = ifelse(variable == "KMT", "#2980b9", "#2ecc71"))

CT_p_m <- hchart(CT_p, "line", hcaes(x = date, y = value, group = variable)) %>% 
  hc_colors(colors = c("#2980b9", "#2ecc71")) %>% 
  hc_title(text = list("Monthly Counts of China times")) %>% 
  hc_xAxis(title = list(text = "Date")) %>% 
  hc_yAxis(title = list(text = "Counts"))
save.hc(CT_p_m, "CT_p monthly counts")

CTEE_p <- news_p$CTEE %>% 
  group_by(date = format(ymd(date), "%Y-%m")) %>% 
  summarise(KMT = sum(B), DKK = sum(G)) %>% 
  melt(id = "date") %>% 
  mutate(colors = ifelse(variable == "KMT", "#2980b9", "#2ecc71"))

CTEE_p_m <- hchart(CTEE_p, "line", hcaes(x = date, y = value, group = variable)) %>% 
  hc_colors(colors = c("#2980b9", "#2ecc71")) %>% 
  hc_title(text = list("Monthly Counts of Commercial times")) %>% 
  hc_xAxis(title = list(text = "Date")) %>% 
  hc_yAxis(title = list(text = "Counts"))
save.hc(CTEE_p_m, "CTEE_p monthly counts")

AD_p <- news_p$AD %>% 
  group_by(date = format(ymd(date), "%Y-%m")) %>% 
  summarise(KMT = sum(B), DKK = sum(G)) %>% 
  melt(id = "date") %>% 
  mutate(colors = ifelse(variable == "KMT", "#2980b9", "#2ecc71"))

AD_p_m <- hchart(AD_p, "line", hcaes(x = date, y = value, group = variable)) %>% 
  hc_colors(colors = c("#2980b9", "#2ecc71")) %>% 
  hc_title(text = list("Monthly Counts of Apple daily")) %>% 
  hc_xAxis(title = list(text = "Date")) %>% 
  hc_yAxis(title = list(text = "Counts"))
save.hc(AD_p_m, "AD_p monthly counts")


