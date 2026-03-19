Exploratory Analysis
================

## Become acquainted with your data sources:

- Where did you find them?

  - I sourced all of my data from <https://www.fec.gov>.

- Who collected/maintains them?

  - The Federal Elections Commission receives financial reports from
    people running of for office.

- When and why were they originally collected?

  - The data is being collected and maintained in real time. The data is
    collected to audit where people running for office are getting their
    financial support.

- What does a case represent in each data source, and how many total
  cases are available?

  - A case in the data represents a donation given by an organization or
    individual.

``` r
delaney_data %>% 
  summarise(nrows = n()) %>% 
  pull(nrows)
```

    ## [1] 3254

``` r
trone_data %>% 
  summarise(nrows = n()) %>% 
  pull(nrows)
```

    ## [1] 3402

``` r
thompson_data %>% 
  summarise(nrows = n()) %>% 
  pull(nrows)
```

    ## [1] 14228

The higher number for Thompson is because he has a much longer political
career. His donations go all the way back to 2008 where Trone and
Delaney only have data from the 2020s.

- What are some of the variables that you plan to use?
  - I plan to base most of my analysis on who is donating and the
    distribution of donations across donor types. Because of this, I’ll
    be making some summary variables to calculate total donations by
    donor type, and then the proportion to the whole of the various
    donations.

``` r
trone_fin_dist
```

    ## # A tibble: 3 × 4
    ##   entity_type_desc              total  prop candidate
    ##   <chr>                         <dbl> <dbl> <chr>    
    ## 1 INDIVIDUAL                 1183528.  44.3 Trone    
    ## 2 POLITICAL ACTION COMMITTEE  752486.  28.2 Trone    
    ## 3 ORGANIZATION                733586.  27.5 Trone

``` r
trone_donor_dist
```

    ## # A tibble: 20 × 3
    ##    contributor_name                               total candidate
    ##    <chr>                                          <dbl> <chr>    
    ##  1 ACTBLUE                                      634898. Trone    
    ##  2 CANAL PARTNERS MEDIA                         599642. Trone    
    ##  3 AMERICAN ISRAEL PUBLIC AFFAIRS COMMITTEE PAC 105600  Trone    
    ##  4 NAI THE MICHAEL COMPANIES, INC                41795. Trone    
    ##  5 GMMB                                          30435. Trone    
    ##  6 PAYCHEX                                       21920. Trone    
    ##  7 ETHOS ORGANIZING                              15000  Trone    
    ##  8 RUBIN, PAMELA                                 12800  Trone    
    ##  9 RUBIN, RONALD                                 12800  Trone    
    ## 10 ABRAMSON, ANNE                                12400  Trone    
    ## 11 ABRAMSON, RONALD                              12400  Trone    
    ## 12 AKMAN OZMEN, EREN                             12400  Trone    
    ## 13 CHAPLIN, ARLENE                               12400  Trone    
    ## 14 CHAPLIN, WAYNE                                12400  Trone    
    ## 15 EPSTEIN, ROBERT                               12400  Trone    
    ## 16 MANOCHERIAN, GREG                             12400  Trone    
    ## 17 MANOCHERIAN, JED                              12400  Trone    
    ## 18 MANOCHERIAN, JENNIFER                         12400  Trone    
    ## 19 OZMEN, FATIH                                  12400  Trone    
    ## 20 WILSON, NEAL                                  12400  Trone
