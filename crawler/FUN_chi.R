#=====================================================
# 函數1：抓一個page所有的文章 v1.1 (2017/10/31)
#=====================================================
chi.page <- function(date, doc) {
  len = length
  article.list <- doc %>%
    html_nodes("div.listRight") %>%
    html_nodes("h2") %>%
    html_nodes("a") %>%
    html_attr("href")
  article.title <- doc %>%
    html_nodes("div.listRight") %>%
    html_nodes("h2") %>%
    html_nodes("a") %>%
    html_text() %>% 
    str_trim
  article.type <- doc %>%
    html_nodes("div.listRight") %>%
    html_nodes(".kindOf") %>%
    html_text() %>% 
    str_trim
  if(len(article.list) != 0) {
    for(i in 1:len(article.list)) {
      url.a <- paste0("http://www.chinatimes.com", article.list[i])
      doc.a <- read_html(url.a)
      # 記者
      rp_name <- doc.a %>%
        html_nodes("div.rp_name") %>%
        html_text()
      reporter <- ifelse(str_detect(rp_name, "／"), 
                         str_split(rp_name, "／", simplify = T)[1],
                         rp_name) %>%
        str_replace_all("記者", "")
      # 本文
      temp <- doc.a %>%
        html_nodes("article.clear-fix") %>%
        html_nodes("p") %>%
        html_text()
      # 文章最後一段是來源
      source <- temp[length(temp)]
      # 去掉來源
      content <- temp[-length(temp)]
      article <- str_c(content, collapse = "")
      # 合併所有變數
      if(i == 1) {
        article.all <- data.frame(date = date, reporter = reporter, 
                                  category = article.type[i], title = article.title[i],
                                  content = article)
      } else {
        article.all <- rbind.data.frame(article.all,
                                        data.frame(date = date, reporter = reporter, 
                                                   category = article.type[i], 
                                                   title = article.title[i],
                                                   content = article))
      }
    }
  } else {
    article.all <- character(0)
  }
  return(article.all)
}
#=====================================================
# 函數2：抓一個date所有的文章 -> 最早到2009-09-28
#=====================================================
chi.date <- function(date, np = 1, verbose = FALSE) {
  time.start <- Sys.time()
  len = length
  url <- paste0("http://www.chinatimes.com/history-by-date/", date, "-260", np)
  doc <- read_html(url)
  # page1 first!
  article.all <- chi.page(date = date, doc = doc)
  last.page <- doc %>%
    html_nodes("div.pagination.clear-fix") %>%
    html_nodes("ul") %>%
    html_nodes("li") %>%
    html_nodes("a") %>%
    html_attr("href") %>%
    tail(1L)
  if(len(last.page) != 0) {
    last.page <- str_split(last.page, "=", simplify = T)[2] %>%
      as.numeric()
    if(len(article.all) != 0) {
      for(page in 2:last.page) {
        doc.p <- read_html(paste0(url, "?page=", page))
        article.p <- chi.page(date = date, doc = doc.p)
        # 若該頁沒有東西，則chi.page函數會回傳character(0)，迴圈就會停止
        if(len(article.p) != 0) {
          article.all <- rbind.data.frame(article.all, article.p)
        } else break
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
# 函數3：抓多個date的文章 -> 最早到2009-09-28
#=====================================================
chi.seq <- function(start, end, np = 1) {
  time.start <- Sys.time()
  len = length
  seq.date <- as.character(seq.Date(ymd(start), ymd(end), by = "day"))
  pb <- progress_bar$new(
    format = "Date: :what [:bar] :percent ,duration: :elapsed",
    clear = FALSE, total = len(seq.date), width = 60)
  for(d in 1:len(seq.date)) {
    pb$tick(tokens = list(what = seq.date[d]))
    article <- chi.date(date = seq.date[d], np = np)
    if(len(article) != 0) {
      if(d == 1) {
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
# 函數4：抓取指定年月份的文章 -> 最早到2009-09-28
#=====================================================
chi.month <- function(year, month, ...) {
  time.start <- Sys.time()
  len = length
  start <- ymd(year * 10^4 + month * 10^2 + 1)
  end <- ceiling_date(start, unit = "month") - 1
  seq.date <- as.character(seq.Date(start, end, by = "day"))
  pb <- progress_bar$new(
    format = "Downloading article on :what [:bar] :percent in :elapsed",
    clear = FALSE, total = len(seq.date), width = 60)
  for(d in 1:len(seq.date)) {
    pb$tick(tokens = list(what = seq.date[d]))
    article <- chi.date(date = seq.date[d], verbose = F, ...)
    if(len(article) != 0) {
      if(d == 1) {
        article.all <- article
      } else {
        article.all <- rbind.data.frame(article.all, article)
      }
    } else next
  }
  time.interval <- time_length(interval(time.start, Sys.time()), unit = "min") %>% round(2)
  cat("Required articles are downloaded! Execution time: ",time.interval, "mins", "\n")
  return(article.all)
}
