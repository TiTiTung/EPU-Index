#==========================================================================
# Measuring Economic Policy Uncertainty Index
#=======================版本資訊===========================================
# 2017/10/26完成，礙於樣本不足，目前只能提供單份報紙的指數編寫。
# 2017/11/5完成多報紙的版本，需要先將新聞資料合併成list格式引入函數。
#==========================================================================
if (!is.element("dplyr", installed.packages()[,1])) {
  install.packages("dplyr", dep = TRUE)
  require("dplyr", character.only = TRUE)
} else {
  require("dplyr", character.only = TRUE)
}
if (!is.element("stringr", installed.packages()[,1])) {
  install.packages("stringr", dep = TRUE)
  require("stringr", character.only = TRUE)
} else {
  require("stringr", character.only = TRUE)
}
if (!is.element("lubridate", installed.packages()[,1])) {
  install.packages("lubridate", dep = TRUE)
  require("lubridate", character.only = TRUE)
} else {
  require("lubridate", character.only = TRUE)
}

na.replace <- function(object, replacement) {
  na.index <- is.na(object)
  object[na.index] <- replacement
  return(object)
}

#==========================================================================
# E/U/P 三大類字詞判定，顯示詞彙的內容(較少使用)，尚未支持多報紙的判斷
#==========================================================================
EPU_Identify <- function(df) {
  df[,c("Symbol","Name","Event_U","Event_E","Event_P")] <- NA
  # x: content import
  x = df$content
  pb <- progress_bar$new(
    format = "Processing i= :what [:bar] :percent ,duration: :elapsed",
    clear = FALSE, total = len(x), width = 60)
  for(i in 1:len(x)) {
    pb$tick(tokens = list(what = i))
    #article_words <- lapply(x[i], function(a) segment(a, cutter))
    match.name <- str_match_all(x[i], name_list) %>%
      unlist %>% unique %>%
      str_c(collapse = ",")
    match.symbol <- str_detect(x[i], name_list) %>% 
      which %>% unique
    match.symbol <- symbol_list[match.symbol] %>% str_c(collapse = ",")
    # Category U
    match.event.U <- str_match_all(x[i], event_U) %>% 
      unlist %>% unique %>%
      str_c(collapse = ",")
    event.U <- ifelse(len(match.event.U) == 0, NA,
                      str_c(match.event.U, collapse = ","))
    # Category E
    match.event.E <- str_match_all(x[i], event_E) %>% 
      unlist %>% unique %>%
      str_c(collapse = ",")
    event.E <- ifelse(len(match.event.E) == 0, NA,
                      str_c(match.event.E, collapse = ","))
    # Category P
    match.event.P <- str_match_all(x[i], event_P) %>% 
      unlist %>% unique %>%
      str_c(collapse = ",")
    event.P <- ifelse(len(match.event.P) == 0, NA,
                      str_c(match.event.P, collapse = ","))
    match.name <- ifelse(len(match.name) == 0, NA, match.name)
    match.symbol <- ifelse(len(match.symbol) == 0, NA, match.symbol)
    match.event.U <- ifelse(len(match.event.U) == 0, NA, match.event.U)
    match.event.E <- ifelse(len(match.event.E) == 0, NA, match.event.E)
    match.event.P <- ifelse(len(match.event.P) == 0, NA, match.event.P)
    # Output
    df$Symbol[i] <- match.symbol
    df$Name[i] <- match.name
    df$Event_U[i] <- event.U
    df$Event_E[i] <- event.E
    df$Event_P[i] <- event.P
  }
  return(df)
}
#==========================================================================
# E/U/P 三大類字詞判定，計算詞彙次數，可銜接下一個函數(EPU_Index)，常用
# 需要引入list格式檔，請先將所有新聞資料合併為同一個list再引入函數。
#==========================================================================
EPU_Counts <- function(mydat, n = NULL) {
  if(is.list(mydat)) {
    time.start <- Sys.time()
    len = length
    # 先找出重疊的樣本期間
    first_date <- c()
    for (a in 1:len(mydat)) {
      first_date <- append(first_date, first(mydat[[a]]$date))
    }
    first_date <- max(ymd(first_date))
    # 開始進行關鍵字判斷
    for (j in 1:len(mydat)) {
      mydat[[j]] <- select(mydat[[j]], date, content)
      mydat[[j]]$date <- ymd(mydat[[j]]$date)
      if(!is.null(n)) {
        pivot <- max(first_date, ymd("2017-10-31") - n)
        mydat[[j]] <- subset(mydat[[j]], date >= pivot)
      } else {
        mydat[[j]] <- subset(mydat[[j]], date >= first_date)
      }
      E = U = P = EPU = c()
      for(i in 1:nrow(mydat[[j]])) {
        # 這邊要用append來把數字疊加的很長，是因為之後要整個column放到新的database裡面(mutate)
        # 由於E、P、U每一個計算出來的數值都很長，所以在計算集合的EPU時，必須用c(U[i], E[i], P[i])
        # 用迴圈把每一個數值[i]放到EPU裡面
        
        # Category U
        U <- append(U, str_match_all(mydat[[j]]$content[i], event_U) %>% unlist %>% len)
        # Category E
        E <- append(E, str_match_all(mydat[[j]]$content[i], event_E) %>% unlist %>% len)
        # Category P
        P <- append(P, str_match_all(mydat[[j]]$content[i], event_P) %>% unlist %>% len)
        # EPU dummy variable
        EPU <- append(EPU, ifelse(any(c(U[i], E[i], P[i]) == 0), 0, 1))
      }
      mydat[[j]] <- mutate(mydat[[j]], U, E, P, EPU, counts = U + E + P)
    }
  } else
    stop("The format is wrong!")
  time.interval <- time_length(interval(time.start, Sys.time()), unit = "min") %>% round(2)
  cat("All articles are processed! Execution time: ", time.interval, "mins", "\n")
  return(mydat)
}
#==========================================================================
# 編寫EPU指數
# (2017/11/5)已完成跨報紙的指數計算，不過目前只用了3個報紙編寫，
# 未來若要加入蘋果、甚至是其他報紙，一樣只需將所有新聞data合併成同一個list，
# 先放入EPU_Counts()判定關鍵詞量之後，再將輸出的檔案引入此函數編寫出指數即可。
# 此函數主要在做標準化(standardize)的動作
#==========================================================================
EPU_Index <- function(mydat, freq = "monthly") {
  options(warn = -1)
  if(is.list(mydat)) {
    len = length
    for (i in 1:len(mydat)) {
      if(freq == "monthly") {
        Date <- data.frame(date = seq.Date(ymd(first(mydat[[i]]$date)), ymd("2017-10-31"), by = "month")) %>% format("%Y-%m")
        mydat[[i]]$date <- ymd(mydat[[i]]$date) %>% format("%Y-%m")
      } else if(freq == "daily") {
        mydat[[i]]$date <- ymd(mydat[[i]]$date)
        Date <- data.frame(date = seq.Date(first(mydat[[i]]$date), ymd("2017-10-31"), by = "day"))
      } else if(freq == "weekly") {
        Date <- data.frame(date = seq.Date(ymd(first(mydat[[i]]$date)), ymd("2017-10-31"), by = "week")) %>% format("%Y-%W")
        mydat[[i]]$date <- ymd(mydat[[i]]$date) %>% format("%Y-%W")
      }
      # 每個t的文章總數
      article_N <- mydat[[i]] %>% 
        subset(EPU == 1, select = c(date, counts)) %>%
        group_by(date) %>% 
        summarise(N = len(counts))
      # 每個月詞彙的總次數(X = total counts)
      counts <- mydat[[i]] %>%
        subset(EPU == 1, select = c(date, counts)) %>%
        group_by(date) %>%
        summarise(X = sum(counts)) %>% 
        merge(Date, by = "date", all = T) %>% 
        merge(article_N, by = "date", all.x = T) %>% 
        mutate(X = X/N)
      counts <- na.replace(counts, 0)
      # Step1: 以所有資料X來計算標準差(一個常數)
      std <- sd(counts$X)
      # Step2: 將X(Total_Counts)除以標準差計算出Y
      counts$Y <- counts$X / std
      # 整理結果
      if(i == 1) {
        output <- select(counts, date, Y)
      } else {
        output <- merge(output, select(counts, date, Y), by = "date", all = TRUE)
      }
    }
    names(output) <- append("date", names(mydat))
    # Step3: 將全報紙的Y每月平均以算出Z，目前只計算一個報紙，所以Z=Y
    output <- na.replace(output, 0)
    if(len(output) > 2) {
      output$Z <- rowMeans(output[,-1])
    } else {
      output$Z <- output[,2]
    }
    # Step4: 將時間數列中所有的Z取平均得到M(一個常數)
    M <- mean(output$Z)
    # Step5: 將Z乘以(100/M)取得EPU指數值！
    output$Index <- output$Z * (100/M)
    output <- output %>% select(date, Index)
  } else
    stop("The format is wrong!")
  options(warn = 1)
  return(output)
}



#==========================================================================
# 編寫月的EPU指數
# TI-TI TUNG 
#==========================================================================
EPU_Index_m <- function(mydat) {
  options(warn = -1)
  if(is.list(mydat)) {
    len = length
    for (i in 1:len(mydat)) {
# 將日期改成月份
Date <- data.frame(date = seq.Date(ymd(first(mydat[[i]]$date)), ymd("2017-10-31"), by = "month")) %>% format("%Y-%m")
mydat[[i]]$date <- ymd(mydat[[i]]$date) %>% format("%Y-%m")

      # 每個月詞彙的總次數(X = EPU / 該月總文章數)
      counts <- mydat[[i]] %>% 
        select(date, EPU) %>% 
        group_by(date) %>% 
        summarise(N = len(date), EPU = sum(EPU)) %>% 
        mutate(X = (EPU/N)) 
      
      counts %<>% na.replace(0)
      
      # Step1: 以所有資料X來計算標準差(一個常數)
      std <- sd(counts$X)
      # Step2: 將X(Total_Counts)除以標準差計算出Y
      counts %<>% mutate(Y = X / std)
      
        # 整理結果
        if(i == 1) {
          output <- select(counts, date, Y)
        } else {
          output <- merge(output, select(counts, date, Y), by = "date", all = TRUE)
        }
      
    } # 計算各報紙的Y Loop 結束

      # 產生一個data.frame，有日期與不同報紙的Y，此處把各報紙的名子標上
      names(output) <- append("date", names(mydat))
      
      output %<>% na.replace(0)
      
      # Step3: 將全報紙的Y每月平均以算出Z，目前只計算一個報紙，所以Z=Y
        if(len(output) > 2) {
          output %<>% mutate(Z = rowMeans(.[,-1]))
        } else {
          colnames(output)[-1] <- "Z"
        }
      
      # Step4: 將時間數列中所有的Z取平均得到M(一個常數)
      M <- mean(output$Z)
      # Step5: 將Z乘以(100/M)取得EPU指數值！
      output %<>% mutate(Index = Z * (100/M)) %>% 
        select(date, Index)
      
  } else
    stop("The format is wrong!")
    options(warn = 1)
  return(output)
}
