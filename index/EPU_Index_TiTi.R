#==========================================================================
# Measuring Economic Policy Uncertainty Index
#=======================版本資訊===========================================
# 2017/11/5完成多報紙的版本，需要先將新聞資料合併成list格式引入函數。
# 目前該一版本只計算月的EPU Index。
#==========================================================================
if (!is.element("dplyr", installed.packages()[,1])) {
  install.packages("dplyr", dep = TRUE)
  require("dplyr", character.only = TRUE)
} else {
  require("dplyr", character.only = TRUE)
}
if (!is.element("magrittr", installed.packages()[,1])) {
  install.packages("magrittr", dep = TRUE)
  require("magrittr", character.only = TRUE)
} else {
  require("magrittr", character.only = TRUE)
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
# E/U/P 三大類字詞判定，計算詞彙次數，可銜接下一個函數(EPU_Index)，常用
# 需要引入list格式檔，請先將所有新聞資料合併為同一個list再引入函數。
#==========================================================================
EPU_Counts_m <- function(mydat, n = NULL) {
  if(is.list(mydat)) {
    time.start <- Sys.time()
    len = length
    # 先找出重疊的樣本期間
    first_date <- c()
    for (a in seq_along(mydat)) {
      first_date %<>% append(first(mydat[[a]]$date))
    }
    first_date %<>% ymd %>% max
    # 開始進行關鍵字判斷
    for (j in seq_along(mydat)) {
      mydat[[j]] %<>% select(date, content)
      mydat[[j]]$date %<>% ymd()
      
        if(!is.null(n)) {
          pivot <- max(first_date, ymd("2017-10-31") - n)
          mydat[[j]] %<>% subset(date >= pivot)
        } else {
          mydat[[j]] %<>% subset(date >= first_date)
        }
      
      # 這裡為了增加速度，我們先把需要的空間建立好，再用[i]放進去，理論上會比用append快
      E = U = P = EPU <- vector("double", nrow(mydat[[j]]))
      for(i in 1:nrow(mydat[[j]])) {

        # Category U
        U[i] <- str_count(mydat[[j]]$content[i], event_U) %>% sum
        # Category E
        E[i] <- str_count(mydat[[j]]$content[i], event_E) %>% sum
        # Category P
        P[i] <- str_count(mydat[[j]]$content[i], event_P) %>% sum
        # EPU dummy variable
        EPU[i] <- ifelse(any(c(U[i], E[i], P[i]) == 0), 0, 1)
      }
      # mydat[[j]] %<>% mutate(U, E, P, EPU, counts = U + E + P)
      # 但為了節省空間，增加速度，我們只留下計算EPU需要的資料，即"date"、"EPU"。
      mydat[[j]] %<>% select(date) %>% mutate(U, E, P, EPU)
    }
  } else 
    stop("The format is wrong!")
  time.interval <- time_length(interval(time.start, Sys.time()), unit = "min") %>% round(2)
  cat("All articles are processed! Execution time: ", time.interval, "mins", "\n")
  
  return(mydat)
}
#==========================================================================
# 編寫月的EPU指數 # TI-TI TUNG 
# (2017/11/5)已完成跨報紙的指數計算，不過目前只用了3個報紙編寫，
# 未來若要加入蘋果、甚至是其他報紙，一樣只需將所有新聞data合併成同一個list，
# 先放入EPU_Counts()判定關鍵詞量之後，再將輸出的檔案引入此函數編寫出指數即可。
# 此函數主要在做標準化(standardize)的動作
#==========================================================================
EPU_Index_m <- function(mydat) {
  options(warn = -1)
  if(is.list(mydat)) {
    len = length
    for (i in 1:len(mydat)) {
    # 將日期改成月份
    mydat[[i]]$date %<>% ymd %>% format("%Y-%m")
    # 每個月詞彙的總次數(X = EPU / 該月總文章數)
    counts <- mydat[[i]] %>% 
      select(date, EPU) %>% 
      group_by(date) %>% 
      summarise(N = len(date), EPU = sum(EPU)) %>% 
      mutate(X = (EPU/N)) %>% 
      na.replace(0)
      
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
    
    output %<>% na.replace(0)
    # 產生一個data.frame，有日期與不同報紙的Y，此處把各報紙的名子標上
    names(output) <- append("date", names(mydat))
    
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
