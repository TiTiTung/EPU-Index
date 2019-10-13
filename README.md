## <center> EPU index 分析結果 </center>

>「經濟政策的不確定性指標  (EPU指標)  」為國外學者利用透過文字探勘的技術,  從美國10份新聞資料中萃取相關的資訊,  建構一個同時涵蓋經濟、政策與不確定性等詞庫類別的指標。 本研究案與清華大學計量財務金融學系合作,  主旨在編制屬於台灣的EPU指標,  利用網路爬蟲技術,  從蘋果日報、自由時報、中國時報的文本資料中,  進而編制指標。


## 台灣EPU指標 


<P Align=center><img src="https://i.imgur.com/ejajvPd.jpg" width="70%"></p>

##  台灣EPU指標與大盤比較 


<P Align=center><img src="https://i.imgur.com/sXPvLTV.jpg" width="70%"></p>


##  EPU Index and Realized Volatility

我將加權指數的Realized Volatility與EPU指數畫在一起，並且有跑簡單的相關性檢定，目前只用的是月資料，Realized Volatility是將每月分的日指數報酬率作平方加總而得。兩者的相關係數為0.4173，p-value = 0.000021。

<P Align=center><img src="https://i.imgur.com/6Vk51Jo.jpg" width="70%"></p>


## Politic polarization

Political Slant (2009-2017)
Baker等人的結果顯示，政治偏袒這個因素，並不會對EPU Index的編制造成太大的影響。此處我們假設，中國時報為偏藍的報紙;自由時報為偏綠的報紙。分別編制兩家報紙獨立的EPU指數，即下圖。從圖形上來看，台灣的情況並不完全符合Baker等人的研究結果，兩家報紙個別的政治傾向，確實影響了EPU指數的高低。但是從指數的走勢看起來，還算一致，並不常出現兩家報紙指數相反之情形。兩者的相關係數為0.5041。


<P Align=center><img src="https://i.imgur.com/Gw8qVBh.jpg" width="70%"></p>



## Political Slant (2014-2017)

從圖形上看來，從2014年開始，兩個指數的一致性看起來更高。因此我們擷取2014年到2017年的資料，畫小樣本的圖形。兩者的相關係數為0.8253，為高度相關。

<P Align=center><img src="https://i.imgur.com/ViMuC9Z.png" width="70%"></p>

>**兩家報紙走勢相反**
>
>在所有的時間點，中國時報與自由時報的走勢幾乎相同。唯獨在簽訂2013服務貿易協定的時點，其走勢相反，中國時報往下走，自由時報拉出了一條該區間最長的線。
>

<P Align=center><img src="https://i.imgur.com/C3OQ6JF.png" width="70%"></p>


## Politic polarization

**美國的EPU指標無政治偏坦**
美國的對於政黨傾向衡量方式為，利用media slant index of Gentzkow and Shapiro (2010)，將10家報紙區分成，民主黨5家，共和黨5家，並且個別畫出民主、共和的EPU Index。其結果顯示，不論是哪一個政黨的執政期間 (跨期將近30年)，民主黨或共和黨的EPU指標變動都相當接近，相關係數0.92。故Baker等人認為，政黨傾向這個變數，並不會造成EPU指數編製上的誤差。下圖是Baker等人在 MEASURING ECONOMIC POLICY UNCERTAINTY 中的圖形。

<P Align=center><img src="https://i.imgur.com/THo1Lld.jpg" width="70%"></p>

##  綠營 (藍營) 執政時期，中國時報 (自由時報) 的EPU Index較高

下圖我們區分為馬英九任期與蔡英文任期的EPU指標，在藍綠的不同任期中，有明顯的政治偏袒現象存在，與美國情況相當不同。不過美國在兩邊陣營，各有五家報紙，平均下來後，可能去除了很多outlier，導致指數的移動是很接近的。但目前台灣的比較基礎很小，未來增加資料量是必須的。理論上聯合報也屬泛藍的報紙，但目前還無法抓到聯合報的新聞資料，無法增加比較的基礎，做更深入的探討。由於目前的database也還不夠大，只有從2009年到2017年的資料，因此無法延伸到陳水扁執政時期的EPU指標。未來數據庫較完整後，如果依然有明顯的政治偏袒現象的話，台灣的指標編制方法可能得做些調整。

<P Align=center><img src="https://i.imgur.com/0k8OJ4N.jpg" width="70%"></p>


## 報紙對於黨派的偏袒程度

對於先前的假設，中國時報為偏藍的報紙;自由時報為偏綠的報紙。我們想要更加明確了解是
否真的有這樣的偏袒存在，或是量化其偏袒的程度，因此健嘉學長在先前的實證報告中，以代
表黨派的關鍵字，在新聞中的出現次數，用來編製新的指數，即下一頁的兩張圖。

```
1. Blue(代表國民黨) = "(中國國民黨|國民黨|藍黨|藍營|KMT)"
2. Green(代表民進黨) = "(民主進步黨|民進黨|綠黨|綠營|DPP)"
```

這裡期望看到的圖形為 : 在我們認知上是偏藍的報紙(中國時報)，Blue關鍵詞出現頻率應該較Green來的高，反之亦然。但以下兩張圖形並沒有看出這樣的趨勢，不論哪一家報紙的關鍵字頻率，都沒有明顯的不同。

因為從圖形上看不出明顯差異，我去實際觀察了同時出現Blue、Green關鍵詞的新聞文本。不難發現，不論是CT、LT、AD的新聞，關鍵詞出現之頻率，與該篇文章的政治傾向並無太直接關係。以下例子算是一篇偏綠的文章，先不論兩邊關鍵詞出現頻率多寡，當文章具有政治傾向時，很多情況也會提到與自身對立之黨派。如果從這個角度出發，上頁的兩張圖也就合乎道理了。
為了能夠量化報紙的政治偏袒程度，我們將導入台大情緒辭典(由tmcn套件提供)的正面、負面詞，與Blue、Green關鍵詞結合 (關鍵詞與情緒詞彙要同時出現在文章中、利用正規表示法，負面詞必須出現在黨派關鍵詞前方10 (20、50) 個字內) ，但都未能找出明顯的型態，明確區分新聞的黨派偏向。截至目前為止，尚未發現一個好的量化方法，用以衡量報紙的政治傾向。


>宇昌案解密後， <i class="fa fa-edit fa-fw"></i> 民主進步黨:總統參選人蔡英文昨天晚間首度露面；她在龍潭造勢晚會上未對宇昌案作說明，但強調 <i class="fa fa-edit fa-fw"></i> 國民黨打壓對手，濫用國家資源機器，是最不好示範。蔡英文昨晚參加在龍潭舉行的造勢晚會，她並未對宇昌案進行任何說明；她說，距離選舉日僅剩30多天，現在是台灣反轉且可以結束惡性循環的開始。她痛批政府過去3年多停滯不前且惡性循環，債務每天增加，再不改變，就會債留子孫，人民需要一個勤儉持家的客家妹來當總統。蔡英文指出，她若當選，蔡英文政府會投資未來與下一代，拿出新台幣1000億元資金鼓勵年輕人回到客家故鄉與父母打拚，同時提出400億元照顧弱勢老人及小孩，讓客家有創意特色產業發展，年輕人有機會。她表示，將會成立有效率、強有力的機構，打開國際市場，讓台灣商品走到全球各角落，讓台灣的民主及人權可以繼續前進。蔡英文最後強調， <i class="fa fa-edit fa-fw"></i> 國民黨控制政府打壓對手，濫用國家資源資產與政府機器，這是民主最不好的示範，選民要以選票改變台灣未來。


## 兩岸政治不確定性指標
 

在台灣的報紙發現政治偏袒的現象，然而台灣政治與兩岸之間的關係密切，因此我猜想，是否有可能兩岸的政治關係與台灣的EPU指標是有一定的連動關係存在的，就嘗試在現有基礎之下，編製了一個新的指數，兩岸政治不確定性指標。編制方法是將EPU指數中的"經濟辭庫 (E) "，改成 "兩岸的辭庫" ，其餘的 "政治"、"不確定性" 辭庫照舊，再來進行與計算EPU指數一模一樣的流程 (函數 : EPU_Counts_m、EPU_Index_m)。這個 "兩岸辭庫" 並沒有什麼代表性，只是我出於好奇，把目前能想到的東西拼湊後的結果。

```
兩岸辭庫  =  '( 兩岸 | 國台辦 | 海協會 | 九二共識 | 一國兩制 )'
```

兩岸政治不確定性指標的波動程度比EPU指標來的大，尤其是自由時報的EPU指標，有明顯的波動。以下圖形列出了4次兩岸不確定性指數的高點，搭配了台灣發生的大型事件。比較特別的點在於，馬英九的總統大選前後，EPU指標並沒有明顯的上升，反而有下降之情形。但在蔡英文當選總統後的一個月後，EPU指數創了近20年新高。同一時間，自由時報在2016/02時的兩岸政治不確定性指標為326，一樣是歷史新高。

<P Align=center><img src="https://i.imgur.com/RH4vtHl.png" width="70%"></p>

指標編制方法 <i class="fa fa-book"></i>
---

- [ ] 於EPU_Index_TiTi.R中, 計算月的EPU指標。
- [ ] 個國的 **[EPU Index](http://www.policyuncertainty.com)** 與編制方法:tada:


<P Align=center><img src="https://i.imgur.com/uca9Gg6.jpg" width="35%"></p>


```r =
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


```