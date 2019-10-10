library(DBI)
library(RSQLite)

mydb <- dbConnect(RSQLite::SQLite(), "")
dbDisconnect(mydb)
#Loading data
#You can easily copy an R data frame into a SQLite database with dbWriteTable():

db <- dbConnect(RSQLite::SQLite(), "")


iris2 <- dbReadTable(db, "iris")



## append = TRUE時，R 會把我們要寫入的資料，接在撞名的表格之下。 這等介紹完dbReadTable之後，我們再試試。
dbWriteTable(mydb, "x", mtcars[1,], append = T)
dbReadTable(mydb, "x") 
dbGetQuery(mydb, 'SELECT * FROM x LIMIT 5')

#    mpg cyl  disp  hp drat    wt  qsec vs am gear carb
#1  21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
#2  21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
#3  22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1
#4  21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1
#5  18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2






mydat <- readRDS("EPU_Counts.rds")


CT <- dbGetQuery(db_CT, 'SELECT * FROM CT LIMIT 10')
LT <- dbGetQuery(db_LT, "SELECT * FROM LT LIMIT 10000")
CTEE <- dbGetQuery(db_CT, "SELECT * FROM CTEE LIMIT 1000")
AD <- dbGetQuery(db_AD, "SELECT * FROM AD LIMIT 10000")
CTEE=na.omit(CTEE)
news <- list(LT = AD, CT = AD, CTEE = AD, AD = AD)

new <- EPU_Counts_m(mydat)
mydat=new
x <-  EPU_Index_m(new)

new <- EPU_Counts(news)
is.list(news)

CT = CT %>% filter(date > "2009-12-31"|date < "2010-02-01")
  mutate(counts = Event_U + Event_E + Event_P)%>% filter(date > "2008-12-31")
  

Date <- data.frame(date = seq.Date(ymd(first(mydat$date)), ymd("2017-10-31"), by = "month")) %>% format("%Y-%m")
mydat$date %<>% ymd %>% format("%Y-%m")



#=====================================================
# Plot
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


AD <- readRDS("Counts_AD.rds")
CT <- readRDS("Counts_CT.rds")
LT <- readRDS("Counts_LT.rds")
ALL <- readRDS("Counts_ALL.rds")
mydat <- readRDS("Counts_ALL(2009).rds")

# read index
Index_m <- read.csv("EPU Index.csv")
EPU_M <- Index_m[1:98,]
EPU_M <- read.csv("EPU and RV.csv")
ken$date = Index_m$date[1:97]
EPU_M=Index_m
table <- data.frame(date = CT_EPU_m$date, EPU = ALL_EPU_m$Index,
                    CT = CT_EPU_m$Index, LT = LT_EPU_m$Index, AD = AD_EPU_m$Index)

write.csv(ken, "EPU_china.csv")
