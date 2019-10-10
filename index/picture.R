library(highcharter)
EPU_M <- read.csv("EPU and RV.csv")


#=====================================================
# 政治傾向圖
#=====================================================
highchart() %>%
  hc_title(text = list("Monthly EPU Index")) %>%
  hc_subtitle(text = list("Source: China Times, Liberty Times, Apple Daliy")) %>%
  hc_yAxis_multiples(list(title = list(text = NULL)),
                     list(title = list(text = NULL), opposite = TRUE)) %>%
  hc_xAxis(categories = EPU_M$date,
           plotBands = list(
             list(from = 3, to = 5, color = "#D3D3D3",
                  label = list(text = "ECFA簽訂議題")),
             list(from = 27, to = 29, color = "#D3D3D3",
                  label = list(text = "馬英總當選總統")),
             list(from = 53, to = 55, color = "#D3D3D3",
                  label = list(text = "太陽花學運")),
             list(from = 75, to = 77, color = "#D3D3D3",
                  label = list(text = "蔡英文當選總統"))
             )) %>%
  hc_add_series(ken$LT_Index, yAxis = 0, name = "Index",color = "#000080") %>%
  hc_add_series(EPU_M$EPU, yAxis = 0, name = "Index") %>%
  hc_add_theme(hc_theme_google())


#=====================================================
# 服務貿易協定
#=====================================================
highchart() %>%
  hc_title(text = list("Monthly EPU Index")) %>%
  hc_subtitle(text = list("Source: China Times, Liberty Times")) %>%
  hc_yAxis_multiples(list(title = list(text = NULL)),
                     list(title = list(text = NULL), opposite = TRUE)) %>%
  hc_xAxis(categories = EPU_M$date,
           plotBands = list(
             list(from = 43, to = 47, color = "#D3D3D3",
                  label = list(text = "服務貿易協定"))
           )) %>%
  hc_add_series(EPU_M$CT, yAxis = 0, name = "CT",color = "#000080") %>%
  hc_add_series(EPU_M$LT, yAxis = 0, name = "LT",color = "#32CD32") %>%
  hc_add_theme(hc_theme_google())


#=====================================================
# subset
#=====================================================
highchart() %>%
  hc_title(text = list("Monthly EPU Index, January 2014 to July 2017")) %>%
  hc_subtitle(text = list("Source: China Times, Liberty Times")) %>%
  hc_yAxis_multiples(list(title = list(text = NULL)),
                     list(title = list(text = NULL), opposite = TRUE)) %>%
  hc_xAxis(categories = EPU_M$date[53:97],
           plotBands = list(
             list(from = 19, to = 21, color = "#D3D3D3",
                  label = list(text = "希臘")),
             list(from = 23, to = 26, color = "#D3D3D3",
                  label = list(text = "蔡英文")),
             list(from = 28, to = 31, color = "#D3D3D3",
                  label = list(text = "Brexit")),
             list(from = 33, to = 35, color = "#D3D3D3",
                  label = list(text = "川普"))
           )) %>%
  hc_add_series(EPU_M$CT[53:97], yAxis = 0, name = "CT",color = "#000080") %>%
  hc_add_series(EPU_M$LT[53:97], yAxis = 0, name = "LT",color = "#32CD32") %>%
  hc_add_theme(hc_theme_google())

x=EPU_M[53:97,] %>% mutate(x=1:45)



































