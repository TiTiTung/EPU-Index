#=====================================================
# 函數1：抓一個category所有的文章 v1.5 (10-30)
# 08-28：修正有文章的連結出現錯誤的問題(沒有標題的文章)，應該是自由網頁設計的bug
#=====================================================
lib.date.category <- function(date, category, verbose = FALSE) {
  time.start <- Sys.time()
  # 一些參數設定
  len = length
  ltn <- "http://news.ltn.com.tw"
  c <- switch(as.character(category),
              "1" = "focus", "2" = "politics",
              "3" = "society", "4" = "world", "5" = "business")
  d <- str_replace_all(date, "-", "")
  # 第一頁的連結，先取得總頁數
  doc <- read_html(paste(ltn, "list/newspaper", c, d, sep = "/"))
  # 檢視頁數 (08/28加入)
  page <- doc %>%
    html_nodes(".p_last") %>%
    html_attr("href")
  page <- ifelse(len(page) != 0, str_sub(page, str_count(page)) %>% as.numeric(), 1)
  for(p in 1:page) {
    if(p == 1) {
      doc.p = doc
    } else {
      doc.p <- read_html(paste(ltn, "list/newspaper", c, d, p, sep = "/"))
    }
    article.list <- doc.p %>%
      html_nodes("div.whitecon.boxTitle") %>%
      html_nodes("li") %>%
      html_nodes("a.tit") %>%
      html_attr("href") %>%
      str_replace_all("\r", "") %>%
      str_replace_all("\t", "") %>%
      str_replace_all("\n", "")
    article.title <- doc.p %>%
      html_nodes("div.whitecon.boxTitle") %>%
      html_nodes("li") %>%
      html_nodes("a.tit") %>%
      html_text() %>%
      str_trim() %>%
      str_replace_all("\r", "") %>%
      str_replace_all("\t", "") %>%
      str_replace_all("\n", "")
    if(len(article.list) != 0) {
      article.df <- data.frame(link = article.list, 
                               title = ifelse(article.title == "", NA, article.title)) %>%
        na.omit
      for(i in 1:nrow(article.df)) {
        doc.a <- read_html(paste(ltn, article.df$link[i], sep = "/"))
        # 本文
        content <- doc.a %>%
          html_nodes("div.text") %>%
          html_nodes("p") %>%
          html_text() %>%
          str_replace_all("\r", "") %>%
          str_replace_all("\t", "") %>%
          str_replace_all("\n", "")
        # 爬取圖片敘述，因為文章內容會誤抓要再刪除
        pic <- doc.a %>%
          html_nodes("div.text") %>%
          html_nodes("ul") %>%
          html_nodes("p") %>%
          html_text() %>%
          len
        # 合併所有段落並且刪除圖片敘述
        content <- content[1:(len(content) - pic)] %>%
          str_c(collapse = "")
        # 合併所有變數
        if(i == 1) {
          article.p <- data.frame(date = date, category = c, 
                                  title = article.df$title[i],
                                  content = content)
        } else {
          article.p <- rbind.data.frame(article.p,
                                        data.frame(date = date,
                                                   category = c, 
                                                   title = article.df$title[i],
                                                   content = content))
        }
        Sys.sleep(sample(1:3, 1)) # 休息1~3秒以免被ban
      }
      if(p == 1) {
        article.all <- article.p
      } else {
        article.all <- rbind.data.frame(article.all, article.p)
      }
    } else {
      article.all <- character(0)
    }
  }
  if(verbose) {
    time.interval <- time_length(interval(time.start, Sys.time()), unit = "min") %>% round(2)
    cat("Required articles are downloaded! Execution time: ", time.interval, "mins", "\n")
  }
  return(article.all)
}
#=====================================================
# 函數2：抓一個date所有的文章(包含所有category) v1.1 -> 最早到2005-01-01
#=====================================================
lib.date <- function(date, verbose = FALSE) {
  time.start <- Sys.time()
  len = length
  categories <- c("focus","politics","society","world","business")
  for(i in 1:len(categories)) {
    if(i == 1) {
      article.all <- lib.date.category(date, category = i)
    } else {
      article.all <- rbind.data.frame(article.all, 
                                      lib.date.category(date, category = i))
    }
  }
  if(verbose) {
    time.interval <- time_length(interval(time.start, Sys.time()), unit = "min") %>% round(2)
    cat("Required articles are downloaded! Execution time: ", time.interval, "mins", "\n")
  }
  return(article.all)
}
#=====================================================
# 函數3：抓多個date的文章 -> 最早到2005-01-01
#=====================================================
lib.seq <- function(start, end) {
  time.start <- Sys.time()
  if(exists("article.all")) rm(article.all)
  len = length
  seq.date <- as.character(seq.Date(ymd(start), ymd(end), by = "day"))
  pb <- progress_bar$new(
    format = "Date: :what [:bar] :percent ,duration: :elapsed",
    clear = FALSE, total = len(seq.date), width = 60)
  for(d in 1:len(seq.date)) {
    pb$tick(tokens = list(what = seq.date[d]))
    article <- lib.date(seq.date[d])
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
# 函數4：抓取指定年月份的文章 -> 最早到2005-01-01
#=====================================================
lib.month <- function(year, month) {
  time.start <- Sys.time()
  if(exists("article.all")) rm(article.all)
  len = length
  start <- ymd(year * 10^4 + month * 10^2 + 1)
  end <- ceiling_date(start, unit = "month") - 1
  seq.date <- as.character(seq.Date(start, end, by = "day"))
  pb <- progress_bar$new(
    format = "Date: :what [:bar] :percent ,duration: :elapsed",
    clear = FALSE, total = len(seq.date), width = 60)
  for(d in 1:len(seq.date)) {
    pb$tick(tokens = list(what = seq.date[d]))
    article <- lib.date(seq.date[d])
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