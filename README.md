## Access Abuse IP DB from R

[http://www.abuseipdb.com/](http://www.abuseipdb.com/) carries information on abusive IPs, including the type of the abuse, and details of the abuse reported. 
It has a weak API that returns how often was did an IP commit each type of abuse. Reports of abuse by a particular IP can be gotten via scraping [http://www.abuseipdb.com/report-history/$IP-Address$](http://www.abuseipdb.com/report-history/). 

The [script](abuse_ip_db.R) gets the data from API as well as data from scraping the site. It takes a [list of IPs](sample_in.csv) and outputs a CSV with a few additional columns: `total` (total number of reports), `bad_isp` (is it a bad isp), `trusted_isp` (is it a trusted isp), `reports` (number of times each type of abuse has been recorder), `details` (details of each abuse). 

### License
Scripts are released under the [MIT License](https://opensource.org/licenses/MIT).
