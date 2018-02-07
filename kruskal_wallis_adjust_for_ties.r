# Example from Deborah Rumsey (2009), ch. 19

# Kruskal-Wallis test statistic, without adjusting for ties
# There were 27 scores altogether, 9 each from 3 groups
kw = 12/(27*28)*(159^2/9+149.5^2/9+69.5^2/9)-3*28

# Adjust for ties
# There were 7 twos, 12 threes, and 7 fours
adj_factor = 1 - sum(7^3-7, 12^3-12, 7^3-7)/(27^3-27)

# Kruskal-Wallis test statistic, after adjusting for ties
kw /adj_factor


# References:
# http://support.minitab.com/en-us/minitab-express/1/help-and-how-to/modeling-statistics/anova/how-to/kruskal-wallis-test/methods-and-formulas/methods-and-formulas/
