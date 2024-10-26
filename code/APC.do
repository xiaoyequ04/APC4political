cd "D:\RESEARCH\APC"
dir
import excel "", sheet("Sheet1") firstrow clear
ssc install coefplot

*导入数据
insheet using cbs_2.csv,comma names

save cbs_2.dta,replace


//CBS数据
{
use cbs_new.dta,replace

label variable demsuit "民主适合程度"
label variable demsatisify "民主满意度"
label variable demlevel "民主程度"
label variable leader "威权领导"
save cbs_new.dta,replace

global control "female edu party interstpol frepol marriage hukourural sociallevel"

{//数据处理

**删除自变量与控制变量中值为 "NA" 的观测值
// 列出所有字符串变量
ds, has(type string)

// 强制转换所有字符串变量为数值型，使用force选项
destring `r(varlist)', replace force


*生成cohort变量
gen cohort=year-age

gen cohort10 = floor(cohort / 10) * 10

gen cohort=year-age

*生成cohorts
gen cohort_su = .

replace cohort_su = 1 if year >= 1905 & year <= 1945
replace cohort_su = 2 if year >= 1946 & year <= 1960
replace cohort_su = 3 if year >= 1961 & year <= 1970
replace cohort_su = 4 if year >= 1971 & year <= 1980
replace cohort_su = 5 if year >= 1981 & year <= 2001

* 如果你想给 cohort_su 添加标签
label define cohort_labels 1 "1905/1945" 2 "1946/1960" 3 "1961/1970" 4 "1971/1980" 5 "1981/2001"
label values cohort_su cohort_labels

*生成demview变量
**计算 demscore 的均值
summarize demscore
** 生成 demview 变量（基于均值）
gen demview1 = (demscore > r(mean))
** 计算 demscore 的中位数
summarize demscore, detail
scalar demscore_median = r(p50)
** 生成 demview 变量（基于中位数）
generate demview2 = (demscore > demscore_median)
save cbs_new.dta,replace



{//CBS
*民主得分（CBS)
	//Cohort10
**demview1
reg demview1 age $control i.cohort10  i.year
estimates store demview1_cohort10_FE
reg demview1 age $control i.cohort_su  i.year
estimates store demview1_cohortsu_FE

esttab demview1_cohort10_FE demview1_cohortsu_FE using demview1.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(demview1_cohort10_FE demview1_cohortsu_FE)
{// 画图
**cohort_10
*** 使用 coefplot 绘制Cohort系数图
coefplot  demview2_cohort10_FE, ///
    keep(*cohort10) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
	xlabel(, labsize(vsmall))
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
graph export "D:\RESEARCH\APC\Graph.jpg", as(jpg) name("demview2_cohort10_FE_cohort") quality(90)
*** 使用 coefplot 绘制Period系数图
coefplot demview2_cohort10_FE, ///
    keep(*period) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Period", size(small)) ///
    xlabel(, labsize(vsmall))
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
graph export "D:\RESEARCH\APC\Graph.jpg", as(jpg) name("demview2_cohort10_FE_period") quality(90)
**cohort_su
*** 使用 coefplot 绘制Cohort系数图
coefplot  demview2_cohortsu_FE, ///
    keep(*cohort_su) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
	xlabel(, labsize(vsmall))
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
graph export "D:\RESEARCH\APC\Graph.jpg", as(jpg) name("demview2_cohortsu_FE_cohort") quality(90)
*** 使用 coefplot 绘制Period系数图
coefplot demview2_cohortsu_FE, ///
    keep(*period) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Period", size(small)) ///
    xlabel(, labsize(vsmall))
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
graph export "D:\RESEARCH\APC\Graph.jpg", as(jpg) name("demview2_cohortsu_FE_period") quality(90)

}


**demview2
reg demview2 age $control i.cohort10  i.year
estimates store demview2_cohort10_FE
reg demview2 age $control i.cohort_su  i.year
estimates store demview2_cohortsu_FE

esttab demview2_cohort10_FE demview2_cohortsu_FE using demview2.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(demview2_cohort10_FE demview2_cohortsu_FE)

{// 画图
**cohort_10
*** 使用 coefplot 绘制Cohort系数图
coefplot  demview2_cohort10_FE, ///
    keep(*cohort10) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
	xlabel(, labsize(vsmall))
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
	
graph export "D:\RESEARCH\APC\demview2_cohort10_FE_cohort.jpg", replace

*** 使用 coefplot 绘制Period系数图
coefplot demview2_cohort10_FE, /// 
    keep(*year) /// 
    levels(90) /// 
    vertical /// 
    lcolor(black) /// 
    mcolor(black) /// 
    msymbol(circle_hollow) /// 
    ytitle("系数", size(small)) /// 
    ylabel(, labsize(small) angle(horizontal) nogrid) /// 
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) /// 
    xtitle("Period", size(small)) /// 
    xlabel(, labsize(vsmall)) /// 
    ciopts(recast(rcap)) /// 
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))

graph export "D:\RESEARCH\APC\demview2_cohort10_FE_period.jpg", replace
**cohort_su
*** 使用 coefplot 绘制Cohort系数图
coefplot  demview2_cohortsu_FE, ///
    keep(*cohort_su) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
	xlabel(, labsize(vsmall))
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))

graph export "D:\RESEARCH\APC\demview2_cohortsu_FE_cohort.jpg", replace

*** 使用 coefplot 绘制Period系数图
coefplot demview2_cohortsu_FE, ///
    keep(*year) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Period", size(small)) ///
    xlabel(, labsize(vsmall))
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))

graph export "D:\RESEARCH\APC\demview2_cohortsu_FE_period.jpg", replace

}

**demlevel
reg demlevel age $control i.cohort10  i.year
estimates store demlevel_cohort10_FE
reg demlevel age $control i.cohort_su  i.year
estimates store demlevel_cohortsu_FE

esttab demlevel_cohort10_FE demlevel_cohortsu_FE using demlevel.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(demlevel_cohort10_FE demlevel_cohortsu_FE)

**demsuit
reg demsuit age $control i.cohort10  i.year
estimates store demsuit_cohort10_FE
reg demsuit age $control i.cohort_su  i.year
estimates store demsuit_cohortsu_FE

esttab demsuit_cohort10_FE demsuit_cohortsu_FE using demsuit.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(demsuit_cohort10_FE demsuit_cohortsu_FE)

**demlevel
reg demlevel age $control i.cohort10  i.year
estimates store demlevel_cohort10_FE
reg demlevel age $control i.cohort_su  i.year
estimates store demlevel_cohortsu_FE

esttab demlevel_cohort10_FE demlevel_cohortsu_FE using demlevel.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(demlevel_cohort10_FE demlevel_cohortsu_FE)

**demsatisify
reg demsatisify age $control i.cohort10  i.year
estimates store demsatisify_cohort10_FE
reg demsatisify age $control i.cohort_su  i.year
estimates store demsatisify_cohortsu_FE

esttab demsatisify_cohort10_FE demsatisify_cohortsu_FE using demsatisify.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(demsatisify_cohort10_FE demsatisify_cohortsu_FE)

**leader
reg leader age $control i.cohort10  i.year
estimates store leader_cohort10_FE
reg leader age $control i.cohort_su  i.year
estimates store leader_cohortsu_FE

esttab leader_cohort10_FE leader_cohortsu_FE using leader.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(leader_cohort10_FE leader_cohortsu_FE)

**expert
reg expert age $control i.cohort10  i.year
estimates store expert_cohort10_FE
reg expert age $control i.cohort_su  i.year
estimates store expert_cohortsu_FE

esttab expert_cohort10_FE expert_cohortsu_FE using expert.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(expert_cohort10_FE expert_cohortsu_FE)

**army
reg army age $control i.cohort10  i.year
estimates store army_cohort10_FE
reg army age $control i.cohort_su  i.year
estimates store army_cohortsu_FE

esttab army_cohort10_FE army_cohortsu_FE using army.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(army_cohort10_FE army_cohortsu_FE)

**lifestyle
reg lifestyle age $control i.cohort10  i.year
estimates store lifestyle_cohort10_FE
reg lifestyle age $control i.cohort_su  i.year
estimates store lifestyle_cohortsu_FE

esttab lifestyle_cohort10_FE lifestyle_cohortsu_FE using lifestyle.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(lifestyle_cohort10_FE lifestyle_cohortsu_FE)

**proud
reg proud age $control i.cohort10  i.year
estimates store proud_cohort10_FE
reg proud age $control i.cohort_su  i.year
estimates store proud_cohortsu_FE

esttab proud_cohort10_FE proud_cohortsu_FE using proud.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(proud_cohort10_FE proud_cohortsu_FE)

**compete
reg compete age $control i.cohort10  i.year
estimates store compete_cohort10_FE
reg compete age $control i.cohort_su  i.year
estimates store compete_cohortsu_FE

esttab compete_cohort10_FE compete_cohortsu_FE using compete.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(compete_cohort10_FE compete_cohortsu_FE)

**systembest
reg systembest age $control i.cohort10  i.year
estimates store systembest_cohort10_FE
reg systembest age $control i.cohort_su  i.year
estimates store systembest_cohortsu_FE

esttab systembest_cohort10_FE systembest_cohortsu_FE using systembest.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(systembest_cohort10_FE systembest_cohortsu_FE)


*交互项
**dempro
reg demlevel $control i.age i.year i.age##i.year
estimates store demlevel_intersection

esttab demlevel_intersection using demlevel_intersection.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(demlevel_intersection)

**demsuit
reg demsuit $control i.age i.year i.age##i.year
estimates store demsuit_intersection

esttab demsuit_intersection using demsuit_intersection.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(demsuit_intersection)
**demsatisify
reg demsatisify $control i.age i.year i.age##i.year
estimates store demsatisify_intersection

esttab demsatisify_intersection using demsatisify_intersection.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(demsatisify_intersection)
**demsatisify
reg demsatisify $control i.age i.year i.age##i.year
estimates store demsatisify_intersection

esttab demsatisify_intersection using demsatisify_intersection.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(demsatisify_intersection)
**expert
reg expert $control i.age i.year i.age##i.year
estimates store expert_intersection

esttab expert_intersection using expert_intersection.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(expert_intersection)
**army
reg army $control i.age i.year i.age##i.year
estimates store army_intersection

esttab army_intersection using army_intersection.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(army_intersection)
**lifestyle
reg lifestyle $control i.age i.year i.age##i.year
estimates store lifestyle_intersection

esttab lifestyle_intersection using lifestyle_intersection.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(lifestyle_intersection)
**proud
reg proud $control i.age i.year i.age##i.year
estimates store proud_intersection

esttab proud_intersection using proud_intersection.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(proud_intersection)
**compete
reg compete $control i.age i.year i.age##i.year
estimates store compete_intersection

esttab compete_intersection using compete_intersection.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(compete_intersection)
**systembest
reg systembest $control i.age i.year i.age##i.year
estimates store systembest_intersection

esttab systembest_intersection using systembest_intersection.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(systembest_intersection)
**demview1
reg demview1 $control i.age i.year i.age##i.year
estimates store demview1_intersection

esttab demview1_intersection using demview1_intersection.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(demview1_intersection)
**demview2
reg demview2 $control i.age i.year i.age##i.year
estimates store demview2_intersection

esttab demview2_intersection using demview2_intersection.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(demview2_intersection)

* 使用 coefplot 绘制Cohort系数图
coefplot demview1_cohort10_FE, ///
    keep(1910.cohort10 1920.cohort10 1930.cohort10 1940.cohort10 1950.cohort10 ///
         1960.cohort10 1970.cohort10 1980.cohort10 1990.cohort10 ///
         2000.cohort10) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
* 使用 coefplot 绘制Period系数图
coefplot Cohort10_demview2_FE, ///
    keep(2014.year 2019.year) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Period", size(small)) ///
    xlabel( 1 "2014" 2 "2019"  , labsize(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
}


{
{
	//Cohort5
**demview1
mixed demview1 age $control /// 
    || cohort5_1915: /// 
    || cohort5_1920: /// 
    || cohort5_1925: /// 
    || cohort5_1930: /// 
    || cohort5_1935: /// 
    || cohort5_1940: /// 
    || cohort5_1945: /// 
    || cohort5_1950: /// 
    || cohort5_1955: /// 
    || cohort5_1960: /// 
    || cohort5_1965: /// 
    || cohort5_1970: /// 
    || cohort5_1975: /// 
    || cohort5_1980: /// 
    || cohort5_1985: /// 
    || cohort5_1990: /// 
    || cohort5_1995: /// 
    || cohort5_2000: /// 
    || period_2011: /// 
    || period_2014: /// 
    || period_2019: , mle


estimates store Cohort5_demview1_RE

reg demview1 age $control i.cohort5  i.year
estimates store Cohort5_demview1_FE


esttab Cohort5_demview1_RE Cohort5_demview1_FE using demview1.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.001) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(Cohort5_demview1_RE Cohort5_demview1_FE)


* 使用 coefplot 绘制Cohort系数图
coefplot Cohort5_demview1_FE, ///
    keep(1920.cohort5 1925.cohort5 1930.cohort5 ///
1935.cohort5 1940.cohort5 1945.cohort5 1950.cohort5 ///
1955.cohort5 1960.cohort5 1965.cohort5 1970.cohort5 ///
1975.cohort5 1980.cohort5 1985.cohort5 1990.cohort5 ///
1995.cohort5 2000.cohort5) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
    xlabel( 1 "1920" 2 "1925" 3 "1930" /// 
4 "1935" 5 "1940" 6 "1945" /// 
7 "1950" 8 "1955" 9 "1960" /// 
10 "1965" 11 "1970" 12 "1975" /// 
13 "1980" 14 "1985" 15 "1990" /// 
16 "1995" 17 "2000", labsize(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
* 使用 coefplot 绘制Period系数图
coefplot Cohort5_demview1_FE, ///
    keep(2014.year 2019.year) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Period", size(small)) ///
    xlabel( 1 "2014" 2 "2019"  , labsize(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))

**demview2
mixed demview2 age $control /// 
    || cohort5_1915: /// 
    || cohort5_1920: /// 
    || cohort5_1925: /// 
    || cohort5_1930: /// 
    || cohort5_1935: /// 
    || cohort5_1940: /// 
    || cohort5_1945: /// 
    || cohort5_1950: /// 
    || cohort5_1955: /// 
    || cohort5_1960: /// 
    || cohort5_1965: /// 
    || cohort5_1970: /// 
    || cohort5_1975: /// 
    || cohort5_1980: /// 
    || cohort5_1985: /// 
    || cohort5_1990: /// 
    || cohort5_1995: /// 
    || cohort5_2000: /// 
    || period_2011: /// 
    || period_2014: /// 
    || period_2019: , mle


estimates store Cohort5_demview1_RE

reg demview2 age $control i.cohort5  i.year
estimates store Cohort5_demview2_FE


esttab Cohort5_demview2_RE Cohort5_demview2_FE using demview1.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.001) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(Cohort5_demview2_RE Cohort5_demview2_FE)


* 使用 coefplot 绘制Cohort系数图
coefplot Cohort5_demview2_FE, ///
    keep(1920.cohort5 1925.cohort5 1930.cohort5 ///
1935.cohort5 1940.cohort5 1945.cohort5 1950.cohort5 ///
1955.cohort5 1960.cohort5 1965.cohort5 1970.cohort5 ///
1975.cohort5 1980.cohort5 1985.cohort5 1990.cohort5 ///
1995.cohort5 2000.cohort5) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
    xlabel( 1 "1920" 2 "1925" 3 "1930" /// 
4 "1935" 5 "1940" 6 "1945" /// 
7 "1950" 8 "1955" 9 "1960" /// 
10 "1965" 11 "1970" 12 "1975" /// 
13 "1980" 14 "1985" 15 "1990" /// 
16 "1995" 17 "2000", labsize(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
* 使用 coefplot 绘制Period系数图
coefplot Cohort5_demview2_FE, ///
    keep(2014.year 2019.year) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Period", size(small)) ///
    xlabel( 1 "2014" 2 "2019"  , labsize(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
}
{//Cohort_su
**demview1
mixed demview1 age $control /// 
    || cohort_su_1910: /// 
    || cohort_su_1930: /// 
    || cohort_su_1950: /// 
    || cohort_su_1958: /// 
    || cohort_su_1978: /// 
    || cohort_su_1990: /// 
    || cohort_su_1997: /// 
    || period_2011: /// 
    || period_2014: /// 
    || period_2019: , mle



estimates store Cohort_su_demview1_RE

reg demview1 age $control i.cohort_su  i.year
estimates store Cohort_su_demview1_FE


esttab Cohort_su_demview1_RE Cohort_su_demview1_FE using demview1.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.001) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(Cohort_su_demview1_RE Cohort_su_demview1_FE)


* Cohort_su_demview1_FE
coefplot Cohort_su_demview1_FE, ///
    keep(1910.cohort_su 1930.cohort_su 1950.cohort_su 1958.cohort_su /// 
1978.cohort_su 1990.cohort_su 1997.cohort_su) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
    xlabel( 1 "1930" 2 "1950" 3 "1958" ///
4 "1978" 5 "1990" 6 "1997" , labsize(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
* 使用 coefplot 绘制Period系数图
coefplot Cohort_su_demview1_FE, ///
    keep(2014.year 2019.year) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Period", size(small)) ///
    xlabel( 1 "2014" 2 "2019"  , labsize(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))

**demview2
**demview1
mixed demview2 age $control /// 
    || cohort_su_1910: /// 
    || cohort_su_1930: /// 
    || cohort_su_1950: /// 
    || cohort_su_1958: /// 
    || cohort_su_1978: /// 
    || cohort_su_1990: /// 
    || cohort_su_1997: /// 
    || period_2011: /// 
    || period_2014: /// 
    || period_2019: , mle


estimates store Cohort_su_demview1_RE

reg demview2 age $control i.cohort_su  i.year
estimates store Cohort_su_demview2_FE


esttab Cohort_su_demview2_RE Cohort_su_demview2_FE using demview1.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.001) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(Cohort_su_demview2_RE Cohort_su_demview2_FE)


* Cohort_su_demview1_FE
coefplot Cohort_su_demview2_FE, ///
    keep(1910.cohort_su 1930.cohort_su 1950.cohort_su 1958.cohort_su /// 
1978.cohort_su 1990.cohort_su 1997.cohort_su) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
    xlabel( 1 "1930" 2 "1950" 3 "1958" ///
4 "1978" 5 "1990" 6 "1997" , labsize(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
* 使用 coefplot 绘制Period系数图
coefplot Cohort_su_demview2_FE, ///
    keep(2014.year 2019.year) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Period", size(small)) ///
    xlabel( 1 "2014" 2 "2019"  , labsize(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
}
{//威权领导
*Cohort10
mixed leader age $control /// 
    || cohort10_1910: /// 
    || cohort10_1920: /// 
    || cohort10_1930: /// 
    || cohort10_1940: /// 
    || cohort10_1950: /// 
    || cohort10_1960: /// 
    || cohort10_1970: /// 
    || cohort10_1980: /// 
    || cohort10_1990: /// 
    || cohort10_2000: /// 
    || period_2011: /// 
    || period_2014: /// 
    || period_2019: ,mle

estimates store leader_Cohort10_RE

reg leader age $control i.cohort10  i.year
estimates store leader_Cohort10_FE


esttab leader_Cohort10_RE leader_Cohort10_FE using demview1.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.001) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(leader_Cohort10_RE leader_Cohort10_FE)


* 使用 coefplot 绘制Cohort系数图
coefplot leader_Cohort10_FE, ///
    keep(1920.cohort10 1930.cohort10 1940.cohort10 1950.cohort10 ///
         1960.cohort10 1970.cohort10 1980.cohort10 1990.cohort10 ///
         2000.cohort10) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
    xlabel( 1 "1920" 2 "1930" 3 "1940" ///
           4 "1950" 5 "1960" 6"1970" 7 "1980" ///
           8 "1990" 9 "2000", labsize(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
* 使用 coefplot 绘制Period系数图
coefplot leader_Cohort10_FE, ///
    keep(2014.year 2019.year) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Period", size(small)) ///
    xlabel( 1 "2014" 2 "2019"  , labsize(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))

	
*Cohort5
**demview1
mixed leader age $control /// 
    || cohort5_1915: /// 
    || cohort5_1920: /// 
    || cohort5_1925: /// 
    || cohort5_1930: /// 
    || cohort5_1935: /// 
    || cohort5_1940: /// 
    || cohort5_1945: /// 
    || cohort5_1950: /// 
    || cohort5_1955: /// 
    || cohort5_1960: /// 
    || cohort5_1965: /// 
    || cohort5_1970: /// 
    || cohort5_1975: /// 
    || cohort5_1980: /// 
    || cohort5_1985: /// 
    || cohort5_1990: /// 
    || cohort5_1995: /// 
    || cohort5_2000: /// 
    || period_2011: /// 
    || period_2014: /// 
    || period_2019: , mle


estimates store leader_Cohort5_RE

reg leader age $control i.cohort5  i.year
estimates store leader_Cohort5_FE


esttab leader_Cohort5_RE leader_Cohort5_FE using demview1.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.001) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(leader_Cohort10_RE leader_Cohort10_FE)


* 使用 coefplot 绘制Cohort系数图
coefplot leader_Cohort5_FE, ///
    keep(1920.cohort5 1925.cohort5 1930.cohort5 ///
1935.cohort5 1940.cohort5 1945.cohort5 1950.cohort5 ///
1955.cohort5 1960.cohort5 1965.cohort5 1970.cohort5 ///
1975.cohort5 1980.cohort5 1985.cohort5 1990.cohort5 ///
1995.cohort5 2000.cohort5) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
    xlabel( 1 "1920" 2 "1925" 3 "1930" /// 
4 "1935" 5 "1940" 6 "1945" /// 
7 "1950" 8 "1955" 9 "1960" /// 
10 "1965" 11 "1970" 12 "1975" /// 
13 "1980" 14 "1985" 15 "1990" /// 
16 "1995" 17 "2000", labsize(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
* 使用 coefplot 绘制Period系数图(保留期数：4期的图)
coefplot leader_Cohort5_FE, ///
    keep(2014.year 2019.year) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Period", size(small)) ///
    xlabel( 1 "2014" 2 "2019"  , labsize(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))

*Cohort_su
**demview1
mixed leader age $control /// 
    || cohort_su_1910: /// 
    || cohort_su_1930: /// 
    || cohort_su_1950: /// 
    || cohort_su_1958: /// 
    || cohort_su_1978: /// 
    || cohort_su_1990: /// 
    || cohort_su_1997: /// 
    || period_2011: /// 
    || period_2014: /// 
    || period_2019: , mle



estimates store leader_Cohort_su_RE

reg leader age $control i.cohort_su  i.year
estimates store leader_Cohort_su_FE


esttab leader_Cohort_su_RE leader_Cohort_su_FE using leader_Cohort_su.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.001) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(leader_Cohort_su_RE leader_Cohort_su_FE)


* leader_Cohort_su
coefplot leader_Cohort_su_FE, ///
    keep(1910.cohort_su 1930.cohort_su 1950.cohort_su 1958.cohort_su /// 
1978.cohort_su 1990.cohort_su 1997.cohort_su) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
    xlabel( 1 "1930" 2 "1950" 3 "1958" ///
4 "1978" 5 "1990" 6 "1997" , labsize(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
* 使用 coefplot 绘制Period系数图
coefplot leader_Cohort_su_FE, ///
    keep(2014.year 2019.year) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Period", size(small)) ///
    xlabel( 1 "2014" 2 "2019"  , labsize(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))

}}

{//WVS数据

use wvs_china.dta,replace
global control "gender edu interstpol marriage class_sub"
gen leader = 5-e114_na
gen cohort_su=.
{//变量数据处理
*cohort数据处理
tabulate cohort10, generate(cohort10_)
tabulate cohort_su, generate(cohortsu_)
tabulate year, generate(period_)
rename period_1 period_2001
rename period_2 period_2007
rename period_3 period_2013
rename period_4 period_2018
save wvs_china.dta,replace

*交互

*二次项
gen age_2=age^2
**dempro
reg dempro age $control i.cohort10  i.period
estimates store dempro_cohort10_FE
reg dempro age $control i.cohort_su  i.period
estimates store dempro_cohortsu_FE

esttab dempro_cohort10_FE dempro_cohortsu_FE using dempro.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(dempro_cohort10_FE dempro_cohortsu_FE)

**demuti
reg demuti age $control i.cohort10  i.period
estimates store demuti_cohort10_FE
reg demuti age $control i.cohort_su  i.period
estimates store demuti_cohortsu_FE

esttab demuti_cohort10_FE demuti_cohortsu_FE using demuti.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(demuti_cohort10_FE demuti_cohortsu_FE)

**demimportant
reg demimportant age $control i.cohort10  i.period
estimates store demimportant_cohort10_FE
reg demimportant age $control i.cohort_su  i.period
estimates store demimportant_cohortsu_FE

esttab demimportant_cohort10_FE demimportant_cohortsu_FE using demimportant.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(demimportant_cohort10_FE demimportant_cohortsu_FE)

**demlevel
reg demlevel age $control i.cohort10  i.period
estimates store demlevel_cohort10_FE
reg demlevel age $control i.cohort_su  i.period
estimates store demlevel_cohortsu_FE

esttab demlevel_cohort10_FE demlevel_cohortsu_FE using demlevel.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(demlevel_cohort10_FE demlevel_cohortsu_FE)

**leader
reg leader age $control i.cohort10  i.period
estimates store leader_cohort10_FE
reg leader age $control i.cohort_su  i.period
estimates store leader_cohortsu_FE

esttab leader_cohort10_FE leader_cohortsu_FE using leader.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(leader_cohort10_FE leader_cohortsu_FE)

**dempro
reg demperform age $control i.cohort10  i.period
estimates store demperform_cohort10_FE
reg demperform age $control i.cohort_su  i.period
estimates store demperform_cohortsu_FE

esttab demperform_cohort10_FE demperform_cohortsu_FE using demperform.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(demperform_cohort10_FE demperform_cohortsu_FE)

**responsibility
reg responsibility age $control i.cohort10  i.period
estimates store responsibility_cohort10_FE
reg responsibility age $control i.cohort_su  i.period
estimates store responsibility_cohortsu_FE

esttab responsibility_cohort10_FE responsibility_cohortsu_FE using responsibility.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(responsibility_cohort10_FE responsibility_cohortsu_FE)

**demuti0_dempro0 
reg demuti0_dempro0  age $control i.cohort10  i.period
estimates store demuti0_dempro0 _cohort10_FE
reg demuti0_dempro0  age $control i.cohort_su  i.period
estimates store demuti0_dempro0 _cohortsu_FE

esttab demuti0_dempro0 _cohort10_FE demuti0_dempro0 _cohortsu_FE using demuti0_dempro0 .rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(demuti0_dempro0 _cohort10_FE demuti0_dempro0 _cohortsu_FE)

**demuti0_dempro1
reg  demuti0_dempro1 age $control i.cohort10  i.period
estimates store  demuti0_dempro1_cohort10_FE
reg  demuti0_dempro1 age $control i.cohort_su  i.period
estimates store  demuti0_dempro1_cohortsu_FE

esttab  demuti0_dempro1_cohort10_FE  demuti0_dempro1_cohortsu_FE using  demuti0_dempro1.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle( demuti0_dempro1_cohort10_FE  demuti0_dempro1_cohortsu_FE)

**demuti1_dempro0
reg demuti1_dempro0 age $control i.cohort10  i.period
estimates store demuti1_dempro0_cohort10_FE
reg demuti1_dempro0 age $control i.cohort_su  i.period
estimates store demuti1_dempro0_cohortsu_FE

esttab demuti1_dempro0_cohort10_FE demuti1_dempro0_cohortsu_FE using demuti1_dempro0.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(demuti1_dempro0_cohort10_FE demuti1_dempro0_cohortsu_FE)

**demuti1_dempro1
reg demuti1_dempro1 age $control i.cohort10  i.period
estimates store demuti1_dempro1_cohort10_FE
reg demuti1_dempro1 age $control i.cohort_su  i.period
estimates store demuti1_dempro1_cohortsu_FE

esttab demuti1_dempro1_cohort10_FE demuti1_dempro1_cohortsu_FE using demuti1_dempro1.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(demuti1_dempro1_cohort10_FE demuti1_dempro1_cohortsu_FE)

}
* 创建四个新的虚拟变量
gen demuti0_dempro0 = (demuti == 0 & dempro == 0)
gen demuti0_dempro1 = (demuti == 0 & dempro == 1)
gen demuti1_dempro0 = (demuti == 1 & dempro == 0)
gen demuti1_dempro1 = (demuti == 1 & dempro == 1)


**dempro
reg dempro $control i.age i.period i.age##i.period
estimates store dempro_intersection

esttab dempro_intersection using dempro.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(dempro_intersection)

**demuti
reg demuti $control i.age i.period i.age##i.period
estimates store demuti_intersection_FE

esttab demuti_intersection_FE using demuti.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(demuti_intersection_FE)

**demimportant
reg demimportant $control i.age i.period i.age##i.period
estimates store demimportant_intersection

esttab demimportant_intersection using demimportant.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(demimportant_intersection)

**demlevel
reg demlevel $control i.age i.period i.age##i.period
estimates store demlevel_intersection_FE

esttab demlevel_intersection_FE using demlevel.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(demlevel_intersection_FE)

**leader
reg leader $control i.age i.period i.age##i.period
estimates store leader_intersection_FE

esttab leader_intersection_FE using leader.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(leader_intersection_FE)


**responsibility
reg responsibility $control i.age i.period i.age##i.period
estimates store responsibility_intersection

esttab responsibility_intersection using responsibility.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(responsibility_intersection)



{//demuti
{//Cohort10

mixed demuti age_2  age $control   || cohort10_1: || cohort10_2: || cohort10_3: || cohort10_4: || cohort10_5: || cohort10_6: || period_1: || period_2: || period_3: || period_4: , dfmethod(anova)
estimates store demuti_cohort10_FE



reg demuti age_2  age  $control  i.cohort10  i.period
estimates store demuti_cohort10_FE


 esttab demuti_cohort10_RE demuti_cohort10_FE using 政府_引入二次项_Cohort10.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.001) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(demuti_cohort10_RE demuti_cohort10_FE)

*** 使用 coefplot 绘制Cohort系数图
coefplot  demuti_cohort10_FE, ///
    keep(2.cohort10 3.cohort10 4.cohort10 ///
         5.cohort10 6.cohort10 ) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
    xlabel( 1 "1949" 2 "1959" 3 "1969" ///
           4 "1979" 5 "1989", labsize(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
*** 使用 coefplot 绘制Period系数图
coefplot demuti_cohort10_FE, ///
    keep(2007.period 2013.period 2018.period) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Period", size(small)) ///
    xlabel( 1 "2007" 2 "2013" 3 "2018"  , labsize(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))

}
{//Cohort5
mixed demuti age_2  age $control   || cohort10_1: || cohort10_2: || cohort10_3: || cohort10_4: || cohort10_5: || cohort10_6: || period_1: || period_2: || period_3: || period_4: , dfmethod(anova)
estimates store demuti_cohort5_RE



reg demuti age_2  age  $control  i.cohort5  i.period
estimates store demuti_cohort5_FE


 esttab demuti_cohort5_RE demuti_cohort5_FE using 政府_引入二次项_Cohort10.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.001) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(demuti_cohort5_RE demuti_cohort5_FE)
}

*** 使用 coefplot 绘制Cohort系数图
coefplot  demuti_cohort5_FE, ///
    keep(2.cohort5 3.cohort5 4.cohort5 ///
         5.cohort5 6.cohort5 7.cohort5 8.cohort5 9.cohort5 10.cohort5 11.cohort5) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
*** 使用 coefplot 绘制Period系数图
coefplot demuti_cohort5_FE, ///
    keep(2007.period 2013.period 2018.period) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Period", size(small)) ///
    xlabel( 1 "2007" 2 "2013" 3 "2018"  , labsize(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
}

{//dempro
{//Cohort10

mixed dempro age_2  age $control   || cohort10_1: || cohort10_2: || cohort10_3: || cohort10_4: || cohort10_5: || cohort10_6: || period_1: || period_2: || period_3: || period_4: , dfmethod(anova)
estimates store dempro_cohort10_FE



reg dempro age_2  age  $control  i.cohort10  i.period
estimates store dempro_cohort10_FE


 esttab dempro_cohort10_RE dempro_cohort10_FE using 政府_引入二次项_Cohort10.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.001) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(dempro_cohort10_RE dempro_cohort10_FE)

*** 使用 coefplot 绘制Cohort系数图
coefplot  dempro_cohort10_FE, ///
    keep(2.cohort10 3.cohort10 4.cohort10 ///
         5.cohort10 6.cohort10 ) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
    xlabel( 1 "1949" 2 "1959" 3 "1969" ///
           4 "1979" 5 "1989", labsize(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
*** 使用 coefplot 绘制Period系数图
coefplot dempro_cohort10_FE, ///
    keep(2007.period 2013.period 2018.period) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Period", size(small)) ///
    xlabel( 1 "2007" 2 "2013" 3 "2018"  , labsize(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))

}
{//Cohort5
mixed dempro age_2  age $control   || cohort10_1: || cohort10_2: || cohort10_3: || cohort10_4: || cohort10_5: || cohort10_6: || period_1: || period_2: || period_3: || period_4: , dfmethod(anova)
estimates store dempro_cohort5_RE



reg dempro age_2  age  $control  i.cohort5  i.period
estimates store dempro_cohort5_FE


 esttab dempro_cohort5_RE dempro_cohort5_FE using 政府_引入二次项_Cohort10.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.001) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(dempro_cohort5_RE dempro_cohort5_FE)
}

*** 使用 coefplot 绘制Cohort系数图
coefplot  dempro_cohort5_FE, ///
    keep(2.cohort5 3.cohort5 4.cohort5 ///
         5.cohort5 6.cohort5 7.cohort5 8.cohort5 9.cohort5 10.cohort5 11.cohort5) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
*** 使用 coefplot 绘制Period系数图
coefplot dempro_cohort5_FE, ///
    keep(2007.period 2013.period 2018.period) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Period", size(small)) ///
    xlabel( 1 "2007" 2 "2013" 3 "2018"  , labsize(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
}

{//demimportant

{//Cohort10

mixed demimportant age_2  age $control   || cohort10_1: || cohort10_2: || cohort10_3: || cohort10_4: || cohort10_5: || cohort10_6: || period_1: || period_2: || period_3: || period_4: , dfmethod(anova)
estimates store demimportant_cohort10_FE



reg demimportant age_2  age  $control  i.cohort10  i.period
estimates store demimportant_cohort10_FE


 esttab demimportant_cohort10_RE demimportant_cohort10_FE using 政府_引入二次项_Cohort10.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.001) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(demimportant_cohort10_RE demimportant_cohort10_FE)

*** 使用 coefplot 绘制Cohort系数图
coefplot demimportant_cohort10_FE, ///
    keep(2.cohort10 3.cohort10 4.cohort10 ///
         5.cohort10 6.cohort10 ) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
    xlabel( 1 "1949" 2 "1959" 3 "1969" ///
           4 "1979" 5 "1989", labsize(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
*** 使用 coefplot 绘制Period系数图
coefplot demimportant_cohort10_FE, ///
    keep(2007.period 2013.period 2018.period) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Period", size(small)) ///
    xlabel( 1 "2007" 2 "2013" 3 "2018"  , labsize(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))

}
{//Cohort5

mixed demimportant age_2  age $control   || cohort10_1: || cohort10_2: || cohort10_3: || cohort10_4: || cohort10_5: || cohort10_6: || period_1: || period_2: || period_3: || period_4: , dfmethod(anova)
estimates store demimportant_cohort5_RE



reg demimportant age_2  age  $control  i.cohort5  i.period
estimates store demimportant_cohort5_FE


 esttab demimportant_cohort5_RE demimportant_cohort5_FE using 政府_引入二次项_Cohort10.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.001) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(demimportant_cohort5_RE demimportant_cohort5_FE)


*** 使用 coefplot 绘制Cohort系数图
coefplot  demimportant_cohort5_FE, ///
    keep(2.cohort5 3.cohort5 4.cohort5 ///
         5.cohort5 6.cohort5 7.cohort5 8.cohort5 9.cohort5 10.cohort5 11.cohort5) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
*** 使用 coefplot 绘制Period系数图
coefplot demimportant_cohort5_FE, ///
    keep(2007.period 2013.period 2018.period) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Period", size(small)) ///
    xlabel( 1 "2007" 2 "2013" 3 "2018"  , labsize(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
}}

{//leader

*处理数据
drop if  e114_na == "NA"
destring e114_na,replace



{//Cohort10

mixed leader age_2  age $control   || cohort10_1: || cohort10_2: || cohort10_3: || cohort10_4: || cohort10_5: || cohort10_6: || period_1: || period_2: || period_3: || period_4: , dfmethod(anova)
estimates store leader_cohort10_FE



reg leader age_2  age  $control  i.cohort10  i.period
estimates store leader_cohort10_FE


 esttab leader_cohort10_RE leader_cohort10_FE using 政府_引入二次项_Cohort10.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.001) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(leader_cohort10_RE leader_cohort10_FE)

*** 使用 coefplot 绘制Cohort系数图
coefplot leader_cohort10_FE, ///
    keep(2.cohort10 3.cohort10 4.cohort10 ///
         5.cohort10 6.cohort10 ) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
    xlabel( 1 "1949" 2 "1959" 3 "1969" ///
           4 "1979" 5 "1989", labsize(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
*** 使用 coefplot 绘制Period系数图
coefplot leader_cohort10_FE, ///
    keep(2007.period 2013.period 2018.period) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Period", size(small)) ///
    xlabel( 1 "2007" 2 "2013" 3 "2018"  , labsize(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))

}
{//Cohort5

mixed leader age_2  age $control   || cohort10_1: || cohort10_2: || cohort10_3: || cohort10_4: || cohort10_5: || cohort10_6: || period_1: || period_2: || period_3: || period_4: , dfmethod(anova)
estimates store leader_cohort5_RE



reg leader age_2  age  $control  i.cohort5  i.period
estimates store leader_cohort5_FE


 esttab leader_cohort5_RE leader_cohort5_FE using 政府_引入二次项_Cohort10.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.001) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(leader_cohort5_RE leader_cohort5_FE)


*** 使用 coefplot 绘制Cohort系数图
coefplot  leader_cohort5_FE, ///
    keep(2.cohort5 3.cohort5 4.cohort5 ///
         5.cohort5 6.cohort5 7.cohort5 8.cohort5 9.cohort5 10.cohort5 11.cohort5) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
*** 使用 coefplot 绘制Period系数图
coefplot leader_cohort5_FE, ///
    keep(2007.period 2013.period 2018.period) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Period", size(small)) ///
    xlabel( 1 "2007" 2 "2013" 3 "2018"  , labsize(small)) ///
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
}}


}}}


{

insheet using cbs_2.csv,comma names

use cbs_2.dta,replace
**## 数据处理
	
{//
*标签
label variable demsuit "民主适合程度"
label variable demsatisify "民主满意度"
label variable demlevel "民主程度"
label variable leader "威权领导"
label variable autho "威权人格"

encode province, generate(province_num)
decode province, generate(province_str)
drop province
rename province_num province

**删除自变量与控制变量中值为 "NA" 的观测值
// 列出所有字符串变量
ds, has(type string)
// 强制转换所有字符串变量为数值型，使用force选项
destring `r(varlist)', replace force

save cbs_2.dta,replace
}

global control "female edu party interstpol frepol marriage hukourural sociallevel"


}
**# APC
gen cohort1=year-age

gen cohort3 = floor(cohort1 / 3) * 3

gen cohort_5 = floor(cohort1 / 5) * 5
gen cohort_10 = floor(cohort1 / 10) * 10

**## 威权人格
{
**### APC回归
reg autho age $control i.cohort5  i.year
estimates store autho_cohort5

reg autho age $control i.cohort10  i.year
estimates store autho_cohort10

reg autho age $control i.cohort_10  i.year
estimates store autho_cohort_10

reg autho age $control i.cohort_5  i.year
estimates store autho_cohort_5

reg autho age $control i.cohort3  i.year
estimates store autho_cohort3

reg autho age $control i.cohort1  i.year
estimates store autho_cohort1

esttab autho_cohort5   using autho_cohort5.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(autho_cohort5 )
esttab autho_cohort10   using autho_cohort10.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(autho_cohort10 )

esttab autho_cohort_5   using autho_cohort_5.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(autho_cohort_5 )

esttab autho_cohort3   using autho_cohort3.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(autho_cohort3 )
esttab autho_cohort1   using autho_cohort1.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(autho_cohort1 )


**### APC画图
*** 使用 coefplot 绘制Cohort系数图
coefplot  autho_cohort5, ///
    keep(*cohort5) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
	xlabel(, labsize(vsmall))
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))	
	
coefplot  autho_cohort_5, ///
    keep(*cohort_5) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
	xlabel(, labsize(vsmall))
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))	

coefplot  autho_cohort10, ///
    keep(*cohort10) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
	xlabel(, labsize(vsmall))
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))	

coefplot  autho_cohort_10, ///
    keep(*cohort_10) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
	xlabel(, labsize(vsmall))
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))	


coefplot  autho_cohort1, ///
    keep(*cohort1) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
	xlabel(, labsize(vsmall))
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))	
	
coefplot  autho_cohort3, ///
    keep(*cohort3) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
	xlabel(, labsize(vsmall))
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
}



**## 威权领导
{
**### APC回归

reg leader age $control i.cohort5  i.year
estimates store leader_cohort5

reg leader age $control i.cohort10  i.year
estimates store leader_cohort10

reg leader age $control i.cohort_10  i.year
estimates store leader_cohort_10

reg leader age $control i.cohort_5  i.year
estimates store leader_cohort_5

reg leader age $control i.cohort3  i.year
estimates store leader_cohort3

reg leader age $control i.cohort1  i.year
estimates store leader_cohort1

esttab leader_cohort5   using leader_cohort5.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(leader_cohort5 )
esttab leader_cohort10   using leader_cohort10.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(leader_cohort10 )

esttab leader_cohort_5   using leader_cohort_5.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(leader_cohort_5 )

esttab leader_cohort3   using leader_cohort3.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(leader_cohort3 )
esttab leader_cohort1   using leader_cohort1.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(leader_cohort1 )


**### APC画图

*** 使用 coefplot 绘制Cohort系数图
coefplot  leader_cohort5, ///
    keep(*cohort5) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
	xlabel(, labsize(vsmall))
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))	
	
coefplot  leader_cohort_5, ///
    keep(*cohort_5) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
	xlabel(, labsize(vsmall))
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))	

coefplot  leader_cohort10, ///
    keep(*cohort10) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
	xlabel(, labsize(vsmall))
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))	

coefplot  leader_cohort_10, ///
    keep(*cohort_10) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
	xlabel(, labsize(vsmall))
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))	


coefplot  leader_cohort1, ///
    keep(*cohort1) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
	xlabel(, labsize(vsmall))
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))	
	
coefplot  leader_cohort3, ///
    keep(*cohort3) ///
    levels(90) ///
    vertical ///
    lcolor(black) ///
    mcolor(black) ///
    msymbol(circle_hollow) ///
    ytitle("系数", size(small)) ///
    ylabel(, labsize(small) angle(horizontal) nogrid) ///
    yline(0, lwidth(vthin) lpattern(solid) lcolor(black)) ///
    xtitle("Cohort", size(small)) ///
	xlabel(, labsize(vsmall))
    graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
    ciopts(recast(rcap)) ///
    xline(10.5, lwidth(vthin) lpattern(solid) lcolor(black))
}
encode(province_num) 

* 假设数据集中有一个名为 "province" 的变量，表示省份，和一个名为 "cohort" 的变量，表示时间

* 首先，创建一个 open 变量并初始化为 0
gen open = 0

* 1979年 - 开放广东省、福建省部分地区
replace open = 1 if province == "广东省" & cohort1 >= 1979
replace open = 1 if province == "福建省" & cohort1 >= 1979

* 1984年 - 扩大开放14个沿海城市
local coastal_cities "辽宁省 河北省 天津市 山东省 江苏省 上海市 浙江省 福建省 广东省 广西壮族自治区"
foreach city of local coastal_cities {
    replace open = 1 if province == "`city'" & cohort1 >= 1984
}

* 1988年4月 - 海南设立为经济特区
replace open = 1 if province == "海南省" & cohort1 >= 1988

* 1992年6月 - 沿江及内陆省会开放
    replace open = 1 if cohort1 >= 1992



* 检查 open 变量的结果
list province cohort open

encode province, generate(province_num)
//Cohort did(开放)
reg leader open age $control 
estimates store leader_cohort_did

reg autho open age $control 
estimates store autho_cohort_did


esttab leader_cohort_did   using leader_cohort_did.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(leader_cohort_did )
esttab autho_cohort_did   using autho_cohort_did.rtf, b(%8.4f) se(%8.4f) star(* 0.1 ** 0.05 *** 0.01) stats(aic bic N r2 r2_a F ll) nogap replace mtitle(autho_cohort_did )

reg autho open age $control 
outreg2 using autho_cohort_did.doc,replace tstat bdec(3) tdec(2) ctitle(y)
reg autho open age $control i.year 
outreg2 using autho_cohort_did.doc,append tstat bdec(3) tdec(2) ctitle(y)
reg autho open age $control i.province_num
outreg2 using autho_cohort_did.doc,append tstat bdec(3) tdec(2) ctitle(y)
reg autho open age $control i.year i.province_num
outreg2 using autho_cohort_did.doc,append tstat bdec(3) tdec(2) ctitle(y)


reg leader open age $control 
outreg2 using leader_cohort_did.doc,replace tstat bdec(3) tdec(2) ctitle(y)
reg leader open age $control i.year 
outreg2 using leader_cohort_did.doc,append tstat bdec(3) tdec(2) ctitle(y)
reg leader open age $control i.province_num
outreg2 using leader_cohort_did.doc,append tstat bdec(3) tdec(2) ctitle(y)
reg leader open age $control i.year i.province_num
outreg2 using leader_cohort_did.doc,append tstat bdec(3) tdec(2) ctitle(y)

reg demscore open age $control 
outreg2 using demscore_cohort_did.doc,replace tstat bdec(3) tdec(2) ctitle(y)
reg demscore open age $control i.year 
outreg2 using demscore_cohort_did.doc,append tstat bdec(3) tdec(2) ctitle(y)
reg demscore open age $control i.province_num
outreg2 using demscore_cohort_did.doc,append tstat bdec(3) tdec(2) ctitle(y)
reg demscore open age $control i.year i.province_num
outreg2 using demscore_cohort_did.doc,append tstat bdec(3) tdec(2) ctitle(y)

//RDD
* 设定切断点
local threshold = 1978
rdplot autho cohort1, c(1978) p(1) graph_options(title(线性拟合)) if cohort1>=1949// 线性拟合图

rdrobust autho cohort1, c(1978) p(1) 
outreg2 using cohort_rdd.doc,append tstat bdec(3) tdec(2) ctitle(y)

//cohort did_南巡讲话
gen autho_1 = autho1 + autho2 + autho3 + autho4 + autho5 + autho6 + autho7 + autho8 + autho9

* 生成 reform 变量
gen reform = 0  // 初始化变量为0
replace reform = 1 if cohort1 >= 1992 & treat_reform == 1 // 设置处理组为1
gen treat_reform=0
replace treat_reform = 1 if province == "湖北省" | province == "湖南省" | province == "广东省" | province == "江西省" | province == "上海市" | province == "江苏省" | province == "安徽省" | province == "北京市" | province == "深圳市"

reg autho reform period treat_reform age $control 
outreg2 using autho_reform_did.doc,replace tstat bdec(3) tdec(2) ctitle(y)
reg autho reform period treat_reform age $control i.year 
outreg2 using autho_reform_did.doc,append tstat bdec(3) tdec(2) ctitle(y)
reg autho reform period treat_reform age $control i.province_num
outreg2 using autho_reform_did.doc,append tstat bdec(3) tdec(2) ctitle(y)
reg autho reform period treat_reform age $control i.year i.province_num
outreg2 using autho_reform_did.doc,append tstat bdec(3) tdec(2) ctitle(y)



reg leader reform period treat_reform age $control 
outreg2 using leader_reform_did.doc,replace tstat bdec(3) tdec(2) ctitle(y)
reg leader reform period treat_reform age $control i.year 
outreg2 using leader_reform_did.doc,append tstat bdec(3) tdec(2) ctitle(y)
reg leader reform period treat_reform age $control i.province_num
outreg2 using leader_reform_did.doc,append tstat bdec(3) tdec(2) ctitle(y)
reg leader reform period treat_reform age $control i.year i.province_num
outreg2 using leader_reform_did.doc,append tstat bdec(3) tdec(2) ctitle(y)

reg demscore reform period treat_reform age $control 
outreg2 using demscore_reform_did.doc,replace tstat bdec(3) tdec(2) ctitle(y)
reg demscore reform period treat_reform age $control i.year 
outreg2 using demscore_reform_did.doc,append tstat bdec(3) tdec(2) ctitle(y)
reg demscore reform period treat_reform age $control i.province_num
outreg2 using demscore_reform_did.doc,append tstat bdec(3) tdec(2) ctitle(y)
reg demscore reform period treat_reform age $control i.year i.province_num
outreg2 using demscore_reform_did.doc,append tstat bdec(3) tdec(2) ctitle(y)

save cbs_2.dta,replace
// 市场化水平（1997做代理）
use 市场化.dta,replace
drop if year !=1997
replace province = "上海市" in 1
replace province = "内蒙古自治区" in 3
replace province = "云南省" in 2
replace province = "吉林省" in 5
replace province = "四川省" in 6
replace province = "天津市" in 7
replace province = "宁夏回族自治区" in 8
replace province = "安徽省" in 9
replace province = "山东省" in 10
replace province = "山西省" in 11
replace province = "广东省" in 12
replace province = "广西壮族自治区" in 13
replace province = "北京市" in 4
replace province = "新疆维吾尔自治区" in 14
replace province = "江苏省" in 15
replace province = "江西省" in 16
replace province = "河南省" in 18
replace province = "河北省" in 17
replace province = "浙江省" in 19
replace province = "海南省" in 20
replace province = "湖北省" in 21
replace province = "湖南省" in 22
replace province = "甘肃省" in 23
replace province = "福建省" in 24
replace province = "西藏自治区" in 25
replace province = "贵州省" in 26
replace province = "辽宁" in 27
replace province = "重庆市" in 28
replace province = "陕西省" in 29
replace province = "青海省" in 30
replace province = "黑龙江省" in 31
drop year
merge 1:n province using cbs_2.dta

summarize market
gen market_mean = r(mean)

* 生成 Nanxun 变量
gen period=0
replace period = 1 if cohort1 >= 1992  // 根据条件替换值
gen treat_Nanxun=0
replace treat_Nanxun=1 if market > market_mean   // 根据条件替换值

gen Nanxun = 0  // 初始化变量为0
replace Nanxun = 1 if cohort1 >= 1992 & market > market_mean  // 根据条件替换值

reg autho Nanxun period treat_Nanxun age $control 
outreg2 using autho_Nanxun_did.doc,replace tstat bdec(3) tdec(2) ctitle(y)
reg autho Nanxun period treat_Nanxun age $control i.year 
outreg2 using autho_Nanxun_did.doc,append tstat bdec(3) tdec(2) ctitle(y)
reg autho Nanxun period treat_Nanxun age $control i.province_num
outreg2 using autho_Nanxun_did.doc,append tstat bdec(3) tdec(2) ctitle(y)
reg autho Nanxun period treat_Nanxun age $control i.year i.province_num
outreg2 using autho_Nanxun_did.doc,append tstat bdec(3) tdec(2) ctitle(y)


reg autho_1 Nanxun period treat_Nanxun age $control 
outreg2 using autho_1_Nanxun_did.doc,replace tstat bdec(3) tdec(2) ctitle(y)
reg autho_1 Nanxun period treat_Nanxun age $control i.year 
outreg2 using autho_1_Nanxun_did.doc,append tstat bdec(3) tdec(2) ctitle(y)
reg autho_1 Nanxun period treat_Nanxun age $control i.province_num
outreg2 using autho_1_Nanxun_did.doc,append tstat bdec(3) tdec(2) ctitle(y)
reg autho_1 Nanxun period treat_Nanxun age $control i.year i.province_num
outreg2 using autho_1_Nanxun_did.doc,append tstat bdec(3) tdec(2) ctitle(y)


reg leader Nanxun period treat_Nanxun age $control 
outreg2 using leader_Nanxun_did.doc,replace tstat bdec(3) tdec(2) ctitle(y)
reg leader Nanxun period treat_Nanxun age $control i.year 
outreg2 using leader_Nanxun_did.doc,append tstat bdec(3) tdec(2) ctitle(y)
reg leader Nanxun period treat_Nanxun age $control i.province_num
outreg2 using leader_Nanxun_did.doc,append tstat bdec(3) tdec(2) ctitle(y)
reg leader Nanxun period treat_Nanxun age $control i.year i.province_num
outreg2 using leader_Nanxun_did.doc,append tstat bdec(3) tdec(2) ctitle(y)

reg demscore Nanxun period treat_Nanxun age $control 
outreg2 using demscore_Nanxun_did.doc,replace tstat bdec(3) tdec(2) ctitle(y)
reg demscore Nanxun period treat_Nanxun age $control i.year 
outreg2 using demscore_Nanxun_did.doc,append tstat bdec(3) tdec(2) ctitle(y)
reg demscore Nanxun period treat_Nanxun age $control i.province_num
outreg2 using demscore_Nanxun_did.doc,append tstat bdec(3) tdec(2) ctitle(y)
reg demscore Nanxun period treat_Nanxun age $control i.year i.province_num
outreg2 using demscore_Nanxun_did.doc,append tstat bdec(3) tdec(2) ctitle(y)
