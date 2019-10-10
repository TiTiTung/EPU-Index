#=====================================================
# 函數1：抓一天date所有的文章 v2.2 (2018/01/13 uodated) 蘋果網頁改版
#=====================================================
app.date <- function(date, verbose = FALSE) {
  time.start <- Sys.time()
  len = length
  categories <- c("headline","entertainment","international","sports","finance","home","lifestyle","forum","adcontent")
  d <- str_replace_all(date, "-", "")
  url <- paste0("https://tw.appledaily.com/appledaily/archive/", d)
  doc <- read_html(url) %>% 
    html_nodes("#coverstory") %>%
    html_nodes("div.abdominis.clearmen") %>%
    html_nodes("ul") %>%
    html_nodes("a")
  if(len(doc) == 1) {
    article.all <- character(0)
  } else {
    article.list <- doc %>% html_attr("href") %>% 
      str_replace_all("\r", "") %>%
      str_replace_all("\t", "") %>%
      str_replace_all("\n", "")
    article.title <- doc %>% html_text() %>% 
      str_replace_all("\r", "") %>%
      str_replace_all("\t", "") %>%
      str_replace_all("\n", "")
    article.type <- lapply(article.list, function(x) unlist(str_match_all(x, categories))) %>% unlist
    article.df <- data.frame(link = article.list, title = article.title, category = article.type)
    article.df <- filter(article.df, category %in% c("headline","international","finance","home"))
    if(len(article.df$link) == 0) {
      article.all <- character(0)
    } else {
      for(i in 1:len(article.df$link)) {
        url.a <- article.df$link[i]
        doc.a <- read_html(url.a)
        # 本文: 地產的新聞內容頁面較特殊，另外處理
        if(article.df$category[i] == "home") {
          content <- doc.a %>% 
            html_nodes(".articulum") %>% 
            html_nodes("p") %>% 
            html_text() %>% 
            str_extract("[\\S].*") %>% 
            str_c(collapse = "")
        } else {
          # 內容會抓到「前一頁新聞」、「其他新聞」，要另外刪除
          content <- doc.a %>%
            html_node(".ndArticle_margin") %>%
            html_nodes("p") %>%
            html_text() %>%
            str_extract("[\\S].*") %>% 
            str_c(collapse = "")
          pre_news <- doc.a %>% 
            html_nodes(".ndArticle_pagePrev") %>%
            html_nodes("p") %>%
            html_text() %>%
            str_extract("[\\S].*") %>% 
            str_c(collapse = "")
          more_news <- doc.a %>% 
            html_nodes(".ndArticle_moreNewlist") %>%
            html_nodes("p") %>%
            html_text() %>%
            str_extract("[\\S].*") %>% 
            str_c(collapse = "")
          content <- str_replace(content, more_news, "") %>% 
            str_replace(pre_news, "")
        }
        article <- ifelse(str_count(content) == 0 || len(content) == 0, NA, content)
        # 合併所有變數
        if(i == 1) {
          article.all <- data.frame(date = date, title = article.df$title[i], content = article)
        } else {
          article.all <- rbind.data.frame(article.all,
                                          data.frame(date = date, title = article.df$title[i], content = article))
        }
        Sys.sleep(sample(1:3, 1)) # 隨機休息1~3秒，避免被ban
      }
    }
  }
  if(verbose) {
    time.interval <- time_length(interval(time.start, Sys.time()), unit = "min") %>% round(2)
    cat("Required articles are downloaded! Execution time: ", time.interval, "mins", "\n")
  }
  return(article.all)
}
#=====================================================
# 函數2：抓多個date的文章 -> 最早到2003-05-02
#=====================================================
app.seq <- function(start, end) {
  time.start <- Sys.time()
  if(exists("article.all")) rm(article.all)
  len = length
  seq.date <- as.character(seq.Date(ymd(start), ymd(end), by = "day"))
  pb <- progress_bar$new(
    format = "Date: :what [:bar] :percent ,duration: :elapsed",
    clear = FALSE, total = len(seq.date), width = 60)
  for(d in seq.date) {
    pb$tick(tokens = list(what = d))
    article <- app.date(d)
    if(len(article) != 0) {
      if(!exists("article.all")) {
        article.all <- article
      } else {
        article.all <- rbind.data.frame(article.all, article)
      }
    } else next
  }
  time.interval <- time_length(interval(time.start, Sys.time()), unit = "min") %>% round(2)
  cat("Required articles are downloaded! Execution time: ", time.interval, "mins", "\n")
  return(article.all)
}
#=====================================================
# 函數3：抓取指定年月份的文章 -> 最早到2003-05-02
#=====================================================
app.month <- function(year, month) {
  time.start <- Sys.time()
  if(exists("article.all")) rm(article.all)
  len = length
  start <- ymd(year * 10^4 + month * 10^2 + 1)
  end <- ceiling_date(start, unit = "month") - 1
  seq.date <- as.character(seq.Date(start, end, by = "day"))
  pb <- progress_bar$new(
    format = "Date: :what [:bar] :percent ,duration: :elapsed",
    clear = FALSE, total = len(seq.date), width = 60)
  for(d in seq.date) {
    pb$tick(tokens = list(what = d))
    article <- app.date(d)
    if(len(article) != 0) {
      if(!exists("article.all")) {
        article.all <- article
      } else {
        article.all <- rbind.data.frame(article.all, article)
      }
    } else next
    closeAllConnections()
  }
  time.interval <- time_length(interval(time.start, Sys.time()), unit = "min") %>% round(2)
  cat("Required articles are downloaded! Execution time: ", time.interval, "mins", "\n")
  return(article.all)
}
