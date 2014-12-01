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
* 1 week
* 2 weeks
* 3 weeks
* 1 month
* 3 months

3 months is also the maximum that individual rep gain is kept before it is consolidated into a single, space saving value.

## Proposals
Here are some ideas for how to better handle this slider.

###
Each tick on the slider bar corresponds to "k" times longer than the previous one.

|---|---|---|---|---|---|---|---|---|
1   2   5   10  20  50  100 200 500 1000

Hitting the right side limit doubles the value.