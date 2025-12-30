# Household Energy Consumption Time Series Forecasting

## 📊 Project Overview
Time series analysis and forecasting of household electricity consumption patterns using classical and ARIMA-based methods. Part of MSc Data Science & Analytics coursework at Munster Technological University.

## 🎯 Objectives
- Analyze 4 years of minute-level household power consumption data
- Handle missing data using interpolation
- Monthly aggregation of dataset
- Identify seasonal patterns and trends
- Build and compare forecasting models (Classical models vs ARIMA)
- Generate 12-month consumption forecasts

## 📈 Dataset
- **Source**: [UCI Machine Learning Repository]: (https://archive.ics.uci.edu/dataset/235/individual+household+electric+power+consumption)
- **Size**: 2,075,259 observations
- **Period**: December 2006 - November 2010
- **Frequency**: 1-minute sampling rate

## 🛠️ Methodology

### Data Preprocessing
- Linear interpolation for 25,979 missing values
- Aggregation to monthly averages
- Time series conversion (frequency = 12)

### Analysis Techniques
1. **Exploratory Analysis**: Summary statistics, boxplot, histogram
2. **Decomposition**: Additive vs Multiplicative models
3. **Classical Modeling**: Holt-Winters (Additive & Multiplicative)
4. **ARIMA Modeling**: SARIMA with seasonal differencing
5. **Statistical Testing**: ADF, KPSS, Ljung-Box tests
6. **Model Comparison**: RMSE, MAE, MAPE metrics, AIC Information Criterion

## 📊 Key Results

| Model | RMSE | MAE | MAPE |
|-------|------|-----|------|
| Holt-Winters Additive | 0.108 | 0.080 | 8.94% |
| SARIMA(0,0,0)(0,1,1)₁₂ | 0.128 | 0.079 | 9.87% |

**Best Model**: Holt-Winters Additive (lowest RMSE and MAPE)

## 🔍 Key Findings
- Dataset exhibits **additive seasonality** with mild trend
- Seasonal component has stronger impact than trend
- 12-month forecast shows stable seasonal patterns
- Holt-Winters Additive outperforms ARIMA on error metrics

## 💻 Technologies
- **Language**: R
- **Libraries**: dplyr, forecast, tseries, ggplot2, astsa, zoo, lubridate
- **IDE**: RStudio

## 📁 Repository Structure
```
├── household_time_series.r        # R analysis scripts
├── time-series-report.pdf         # Technical report (PDF)
├── visualizations
└── README.md
```

## 🚀 How to Run
1. Clone repository
2. Install and apply (using library()) required R packages: `dplyr`, `forecast`, `tseries`, `ggplot2`, `astsa`, `zoo`, `lubridate`
3. Run `time_series_analysis.R`

## 📚 References
- Hebrail, G., & Berard, A. (2006). Individual Household Electric Power Consumption. UCI ML Repository.
- Course: Time Series Analysis (STAT9005), MTU

## 👨‍💻 Author
Victory Odumeh | MSc Data Science & Analytics | Munster Technological University

📧 [victory.odumeh@gmail.com]  
💼 [LinkedIn](https://www.linkedin.com/in/victory-odumeh-421761223/)
