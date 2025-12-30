install.packages("zoo")
install.packages("lubridate")
install.packages("psych")
install.packages("ggfortify")


library(dplyr)
library(astsa)
library(tseries)
library(forecast)
library(zoo)
library(lubridate)
library(psych)
library(ggfortify)
library(ggplot2)



house_data <- read.table("Household Power Consumption Dataset (1).txt", 
                         header = TRUE, 
                         stringsAsFactors = FALSE,
                         sep = ";",
                         na.strings = "?")

names(house_data)
g_data <- house_data$Global_active_power


# Checking for missing data

paste("Missing data count for global active power variable:", sum(is.na(g_data)))


# Linear Interpolation. Reference: https://www.geeksforgeeks.org/data-analysis/what-is-data-interpolation/

g_data_interpolated <- na.approx(g_data, rule=2)



paste("Missing data count after interpolation:", sum(is.na(g_data_interpolated)))

house_data$Global_active_power <- g_data_interpolated


# Aggregation

house_data$DateTime <- dmy_hms(paste(house_data$Date, house_data$Time))
house_data$Months <- format(house_data$DateTime, "%Y/%m")


# Calculate monthly averages
monthly_avg <- house_data %>% 
  group_by(Months) %>% 
  summarise(
    mon_g_data = mean(Global_active_power, na.rm=TRUE)
  ) %>% 
  arrange(Months)

# Convert to time series
ts_data <- ts(monthly_avg$mon_g_data, start = c(2006, 12), frequency = 12)
class(ts_data)

# Summary statistics

describe(ts_data)

# The mean of the dataset is 1.1, which is less than the median, 1.12. This indicate
# that the distribution is slightly skewed to the left. The skew value is -0.11
# which also show that the data is negatively skewed. The maximum monthly global active
# power is 1.9 and the minimum is 0.28 with a range, 1.63. The standard deviation is 0.3
# indicating that the spread of the dataset is not too far from the mean.

boxplot(ts_data, main="Boxplot for Monthly Global Active Power")

# The boxplot also shows that there are outliers above the upper fence and below the lower 
# fence. The body of the boxplot also show that the distribution may follow a normal distribution.

hist(ts_data, main="Histogram for Monthly Global Active Power")

# The histogram appears approximately symmetric, indicating that the dataset maybe normally distributed.


# Time series plot

autoplot(ts_data, main="Monthly Global Active Power Consumption") +
  ylab("Global Active Power") + xlab("Year")

# No clear trend, but fairly constant seasonality over time, indicating a homogeneous or additive
# behaviour


# ACF and PACF
acf2(ts_data, main="Correlograms for Monthly Global Active Power")

# The slow decay in ACF at low lags does indicate non-stationarity and seasonality.




# Decomposition

# Additive


da = decompose(ts_data, type = c("additive"))
autoplot(da)

# multiplicative

dm = decompose(ts_data, type = c("multiplicative"))
autoplot(dm)





mstl(ts_data)

# mstl function also says additive seasonality, with no trend.

autoplot(mstl(ts_data))


ets(ts_data) # ETS(A,N,A)



# classical

# Holt-winters classical model was selected because of the seasonal component in the dataset.
# SES works only when there's no trend or seasonality, while the holts works with only trend


par(mfrow=c(1,2))

# Additive with trend
forecast_add <- hw(ts_data, h=frequency(ts_data), seasonal = c("additive")) 
plot(forecast_add, main = "Holt-Winter's Additive Model Forecast")
accuracy(forecast_add)



# Multiplicative with trend

forecast_mul <- hw(ts_data, h=frequency(ts_data), seasonal = c("multiplicative"))
plot(forecast_mul, main = "Holt-Winter's Multiplicative Model Forecast")
accuracy(forecast_mul)


# Holt-winter's Multiplicative does not describe the dataset because it does not account for the variability of the dataset
# from the past data, therefore Holt winter's Additive is prefered


# Summary for classical model forecast

summary(forecast_add) # - smaller RMSE,  than multiplicative


summary(forecast_mul)

# Overall, additive has lesser RMSE and MAPE  than multilicative.


# ARIMA

# A time series is stationary if:

# 1. Constant mean: E(yt) = E(yt+k) = μ
# 2. Constant variance: Var(yt) = Var(Yt+k) = 𝝈^2
# 3. Constant autocorrelation, depends only in the lag k: 
# 𝜸(k) = cov(yt), y(t+k) = E(yt) - 𝝁E[y(t+k) - 𝝁 


autoplot(ts_data, main="Monthly Global Active Power Consumption") +
  ylab("Global Active Power") + xlab("Year")



# Stationarity test

# For Adf
# Ho: The timeseries is not stationary
# Ha: The timeseries is stationary

adf.test(ts_data, alternative = "stationary",k = 0)

# Assuming that the significance level is 5% = 0.05
# p-value = 0.05808

# since p-value > 0.05, we fail to reject Ho at 5% level. There is insignificant evidence to
# suggest that the timeseries is stationary


# For kpss test:
  
# Ho: The timeseries is stationary (level stationarity) 
# Ha: The timeseries is not stationary

kpss.test(ts_data)

# p-value = 0.1 > 0.05, so we fail to reject Ho.

# Combination of test and visualisation, i assume the time series is not stationary.



# For mean, the mild trend so, i assume it was constant. For variance, 
# since the data portrays a homogeneous behaviour, i assumed it was constant



season_diff <- diff(ts_data, differences = 1, lag = 12)

autoplot(season_diff)
autoplot(decompose(season_diff))


acf2(season_diff)

# Model:

# All autocorrelation bars lie within the blue bounds. No slow decay on either ACF and PACF
# No seasonal spikes after differencing on lags. Therefore, AR(p) = AR(0), MA(q) = MA(0), d=0,
# s=12,D=1, P=0, Q=0:

# SARIMA(p=0, d=0, q=0),(P=0, D=1, Q=0)s=12


## Test for seasonal stationarity

adf.test(season_diff)

# For Adf:

# Ho: The dataset is not stationary
# Ha: The dataset is stationary

# p-value = 0.03746

# Since p-value < 0.05, we reject Ho


kpss.test(season_diff)

# For kpss test:

# Ho: The dataset is stationary with level or trend
# Ha: The dataset is not stationary with level or trend

# p-value = 0.1

# Since p-value > 0.05, we fail to reject Ho




# Residuals for derived models: # SARIMA(p=0, d=0, q=0),(P=0, D=1, Q=0)s=12
fit_model = arima(ts_data, order = c(0,0,0), seasonal = list(order = c(0,1,0)))
fit_model


# Other models


fit_model_011 = arima(ts_data, order = c(0,0,0), seasonal = list(order = c(0,1,1)))
fit_model_011


fit_model_11 = arima(ts_data, order = c(0,0,1), seasonal = list(order = c(0,1,1)))
fit_model_11


#  Residual for auto arima
fit_auto = auto.arima(ts_data)
fit_auto




# Best model is SARIMA(0,0,0)(0,1,1)12 because the AIC is lower.


# Ljung-Box: Testing the independece of the residuals of the dataset

# Ho: Residuals are independent
# Ha: Residuals are not independent

checkresiduals(fit_model_011)

# p-value = 0.5909 > 0.05, so we fail to reject Ho.


# standardization of the residuals for the best model SARIMA(0,0,0)(0,1,1)12
fit_model_plot_011 = sarima(ts_data, 0,0,0,0,1,1,12)





# prediction of auto arima
prediction_auto <- predict(fit_auto, n.ahead=12)
prediction_auto


# # prediction of derived model SARIMA(0,0,0)(0,1,1)12
prediction_model = predict(fit_model_011, n.ahead = 12)
prediction_model


# Prediction plot for auto arima 
ts.plot(ts_data, prediction_auto$pred, lty=c(1,3), main="Prediction for Auto ARIMA")
# ts.plot(ts_data, prediction_auto, lty=c(1,3) )


# Prediction plot for derived model SARIMA(0,0,0)(0,1,1)12
ts.plot(ts_data, prediction_model$pred, lty=c(1,3), main="Prediction for Derived Model")




# forecast for auto arima
forecast_auto = forecast(fit_auto, h = 12)
forecast_auto



# forecast for derived model SARIMA(0,0,0)(0,1,1)12
forecast_model = forecast(fit_model_011, h = 12)
forecast_model
# fore_log; fore_2



dev.off()

# plot a forecast for auto arima
plot(forecast_auto,
     main = "12-Month ARIMA Forecast",
     ylab = "Global Active Power",
     xlab = "Year")


# plot a forecast for derived model SARIMA(0,0,0)(0,1,1)12
plot(forecast_model,
     main = "12-Month Derived Model Forecast",
     ylab = "Global Active Power",
     xlab = "Year")




# Model Comparison

# Holt-winters Additive model
accuracy(forecast_add)

# Derived Sarima Model
accuracy(fit_model_011)
