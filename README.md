# heartrate-monitor

Heart rate variabirity (HRV) analysis tool with Polar H7/H6 on MacOSX.

![image](http://narr.jp/private/miyoshi/heartrate_monitor/hrv_screen1.png)

You can analyze your heart rate variavirity to detect autonomic nerve state, with calculating parameters below.

| Parameter | Description                                                                         |
|-----------|-------------------------------------------------------------------------------------|
| AVNN      | Average of all RR intervals                                                         |
| SDNN      | Standard deviation of all RR intervals                                              |
| rMSSD     | Square root of the mean of the squares of differences between adjacent RR intervals |
| pNN50     | Percentage of differences between adjacent RR intervals that are greater than 50 ms |
| LF        | Total spectral power of all RR intervals between 0.04 and 0.15 Hz                   |
| HF        | Total spectral power of all RR intervals between 0.15 and 0.4 Hz                    |
| LF/HF     | Ratio of low to high frequency power                                                |

Power spectrum of HRV is calculated with Auto Regressive (AR) method.

For Polar H7/H6 sensor data's detail, please refer

http://developer.polar.com/wiki/H6_and_H7_Heart_rate_sensors

![image](http://narr.jp/private/miyoshi/heartrate_monitor/polar_h7.jpg)
