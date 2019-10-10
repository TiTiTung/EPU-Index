test <- readRDS("EPU_Counts_1209.rds")

newspaper <- c("CT","LT","AD","CTEE")
for (i in newspaper) {
  test[[i]] %<>% select(date, content, EPU) 
  test[[i]]$EPU = (str_detect(test[[i]]$content, pattern = '台灣|本土|本地|本島') & test[[i]]$EPU==1) %>% as.integer
}

Index_m <-  EPU_Index_m(test)
Index_m <- Index_m[1:97,]


EPU_M <- read.csv("EPU and RV.csv")

EPU_M$close[77]=EPU_M$close[76]

highchart() %>%
  hc_title(text = list("Monthly EPU Index and TAIEX")) %>%
  hc_subtitle(text = list("Source: China Times, Liberty Times, Apple Daliy")) %>%
  hc_yAxis_multiples(list(title = list(text = NULL)),
                     list(title = list(text = NULL), opposite = TRUE)) %>%
  hc_xAxis(categories = EPU_M$date) %>%
  hc_add_series(Index_m$Index, yAxis = 0, name = "EPU Index (L)", color = "#64B5F6") %>%
  hc_add_series(EPU_M$close, yAxis = 1, name = "TAIEX (R)", color = "#E57373") %>%
  hc_add_series(EPU_M$RV*100, yAxis = 0, name = "RV") %>%
  hc_add_theme(hc_theme_google())


#=============================================================================================
# 測試map函數的使用
#=============================================================================================
# 董帝禔是妖怪
# 假如輸入map裡面的東西不是function,必須使用‘～’讓他變成function
# map裡面可以加變數, map(str_detect, pattern = '台灣|本土|本地|本島'), 裡面加的pattern, 是str_detect的參數
# "~.$content"是把select的功能轉到map裡面來用, select會留下data.frame格式, "$"會轉成vector, 而map的輸出格式必須為vector
z <- test %>% map(~.$content) %>% map(str_detect, pattern = '台灣|本土|本地|本島')


str_detect(x[,1], pattern = '台灣|本土|本地|本島') %>% mean()
str_view_all(x[1:2,1], pattern = '中國|香港|經濟|不確定|景氣|不穩定|動盪|波動')
