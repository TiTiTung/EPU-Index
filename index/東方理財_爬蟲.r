library(xml2)
library(rvest)
library(dplyr)
library(stringr)
library(magrittr)

# ****************************************************
#   Case 0. 东方财富网
# ****************************************************

NURL <- "http://finance.eastmoney.com/news/ccjdd.html"
pg0 <- read_html(NURL)

stitle <- pg0 %>% 
  html_nodes(".title") %>%
  html_text(trim=TRUE)

sdate <- pg0 %>% 
  html_nodes(".time") %>%
  html_text(trim=TRUE)

stitle <- pg0 %>% 
  html_nodes(".repeatList .title") %>%
  html_text(trim=TRUE)

surl <- pg0 %>% 
  html_nodes(".repeatList .title a") %>%
  html_attr("href")

i <- 1 
pg1 <- read_html(surl[i])

# 新闻摘要
areview <- pg1 %>%
  html_nodes(".b-review") %>%
  html_text(trim=TRUE)
# 新闻本文
abody <- pg1 %>%
  html_nodes(".Body") %>%
  html_text(trim=TRUE) 
# 评论人数
acnum <- pg1 %>%
  html_nodes(".cNumShow.num") %>%
  html_text(trim=TRUE) 
# 讨论人数
adnum <- pg1 %>%
  html_nodes(".num.ml5") %>%
  html_text(trim=TRUE) 

# ****************************************************
#   Case 1. 豆瓣电影
# ****************************************************
DURL <- "https://movie.douban.com/subject/10741834/"
# 评分
allsdat <- read_html(DURL)

sdat <- allsdat %>% 
  html_nodes(".ll.rating_num") %>%
  html_text()
sdat <- as.numeric(sdat)

# 评价人数
sdat1 <- allsdat %>% 
  html_nodes(".rating_people span") %>%
  html_text()
sdat1 <- as.numeric(sdat1)

# 星级比率
sdat2 <- allsdat %>% 
  html_nodes(".rating_per") %>%
  html_text()
sdat2 <- as.numeric(gsub("\\%","",sdat2))/100

# imdb连结
sdat3 <- allsdat %>% 
  html_nodes(".subject.clearfix a") %>%
  html_attr("href") 
IURL <- grep("http\\:\\/\\/www.imdb.com\\/title\\/",sdat3, value = TRUE)
imdb <- gsub("http://www.imdb.com/title/","",IURL,fixed = TRUE)
