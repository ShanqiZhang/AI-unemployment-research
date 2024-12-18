View(countries)
install.packages("gtrendsR")
Yes
install.packages("gtrendsR")
keyword<-"AI"
time_span<-"2017-01-01 2017-12-31"
geo<-""
trend_data <- gtrends(keyword = keyword, geo = geo, time = time_span)
library(gtrendsR)
install.packages("writexl")
library(writexl)
write_xlsx(trend_data, path = "data.xlsx")
time_span<-"2016-01-01 2016-12-31"
trend_data <- gtrends(keyword = keyword, geo = geo, time = time_span)
write_xlsx(trend_data, path = "Gtrend2016.xlsx")
print(trend_data)
trend_data <-gtrends(keyword = keyword, geo = geo, time = time_span)$interest_by_country
write_xlsx(trend_data, path = "Gtrend2016.xlsx")
time_span<-"2015-01-01 2015-12-31"
trend_data <-gtrends(keyword = keyword, geo = geo, time = time_span)$interest_by_country
write_xlsx(trend_data, path = "Gtrend2015.xlsx")
