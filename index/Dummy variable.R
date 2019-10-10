#=====================================================
# Dummy Variable
#=====================================================
CT_EPU_m %<>% mutate(dummy = str_sub(date,-2,-1)) 
CT_EPU_m$dummy %<>% factor
LT_EPU_m %<>% mutate(dummy = str_sub(date,-2,-1)) 
LT_EPU_m$dummy %<>% factor
AD_EPU_m %<>% mutate(dummy = str_sub(date,-2,-1)) 
AD_EPU_m$dummy %<>% factor

EPU_m %<>% mutate(dummy = str_sub(date,-2,-1)) 
EPU_m$dummy %<>% factor


justdummy_CT <- model.matrix(~CT_EPU_m$dummy-1)
justdummy_LT <- model.matrix(~LT_EPU_m$dummy-1)
justdummy_AD <- model.matrix(~AD_EPU_m$dummy-1)

CT_EPU_m %<>% cbind(justdummy_CT)
LT_EPU_m %<>% cbind(justdummy_LT)
AD_EPU_m %<>% cbind(justdummy_AD)

names(CT_EPU_m)[-(1:3)] <-  1:12
names(LT_EPU_m)[-(1:3)] <-  1:12
names(AD_EPU_m)[-(1:3)] <-  1:12
#=====================================================
# 跑回歸
#=====================================================
mod_CT <- CT_EPU_m %>% lm(Index ~ dummy, .)
summary(mod_CT)
mod_LT <- LT_EPU_m %>% lm(Index ~ dummy, .)
summary(mod_LT)
mod_AD <- AD_EPU_m %>% lm(Index ~ dummy, .)
summary(mod_AD)
mod_EPU <- EPU_m %>% lm(Index ~ dummy, .)
summary(mod_AD)
#=====================================================
#=====================================================


