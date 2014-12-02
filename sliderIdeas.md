# Option Slider Ideas for the TrackPeriodSlider

I want to have a slider that lets the user choose and have better control over the period that they want to track rep gain.

## Current status
Right now, the addon sets some ever increasing values that the user can choose from.

* 5 minutes
* 15 minutes
* 30 minutes
* 1 hour
* 2 hours
* 6 hours
* 12 hours
* 1 day
* 2 days
* 5 days
* 1 week
* 2 weeks
* 3 weeks
* 1 month
* 3 months

3 months is also the maximum that individual rep gain is kept before it is consolidated into a single, space saving value.

## To solve
I want to give the user the ability to have better control over the time range, with out having to guess at all of the values that someone might want to use.
Maybe showing the bars for 45 minutes is better, or maybe 5 days, or 2 months.
Also realizing that **8 hours 30 minutes** might be too fine tuned, and **8 hours** or **9 hours** is fine at that range.
And **1 month 8 hours** is also too fine tuned, but **6 weeks** might be a good range.
The jump from **3 days** to **1 week** also feels a bit rough.

While it is true that someone with some know-how could edit the code to better define the ranges, I would like to keep it as generic as possible.


## Proposals
Here are some ideas for how to better handle this slider.

### From @dwflorek
Sounds like a roughly exponential function would be useful.

Each tick on the slider bar corresponds to "k" times longer than the previous one.

A rough one for doubling is 1, 2, 5, 10, 20, 50, 100, 200, 500. ...
```
|---|---|---|---|---|---|---|---|---|
1   2   5   10  20  50  100 200 500 1000
```

Hitting the right side limit doubles the value.

k * b^n

For current max n, b determines k to get the desired max value, try different b and see how the values change.
For 'bad' choices, the values of interest will feel too close together at one end or the other ...
Sweet spot will be in the middle.

Pushing on the left side would decrease the max.

