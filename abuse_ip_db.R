'''
Gaurav Sood
Get data from abuseipdb.com
API + Scraping where abuseipdb says reports have been submitted

'''

# Load the libs
library(httr)
library(XML)
library(rvest)
library(magrittr)
library(stringr)

# Get ID and Key from the website
# Set User ID and Key
uid  <- 'ENTER UID HERE'
skey <- "ENTER KEY HERE"

# Category ID/Category Name translation table from AbuseIPDB
cats <- read.csv("abuseipdb_cat_catid.csv")

# Categories requested are comma separated character vectors
# We want to get data on all categories
catids <- paste(cats$catid, collapse=",")

# Take a list of IPS and gets data from the API

# Sample IPs 
sample_in <- read.csv("sample_in.csv")
ips <- sample_in$IP 

results <- list()

for (i in 1:nrow(ips)) {
	
	querylist <- list(ip=ips[i], uid=uid, skey=skey, cids=catids, o="xml")
	res <- GET("http://api.abuseipdb.com/check/", query=querylist)
	
	results[[i]] <- xmlToList(content(res))
	}
}

# 
# List to data.frame
final_res <- data.frame(ip=ips, total=NA, bad_isp=NA, trusted_isp=NA, reports=NA)
final_res$total   <- sapply(results, "[[", "total")
final_res$bad_isp <- sapply(results, "[[", "bad_isp")
final_res$trusted_isp <- sapply(results, "[[", "trusted_isp")

# Reports processing
reports <- sapply(results, "[[", "reports")
reports_unlist <- lapply(reports, unlist)
fin_reports <-  sapply(reports_unlist, function(x) data.frame(report.cid=cats$category[match(x[names(x)=="report.cid"], cats$catid)], report.total=x[names(x)=="report.total"]))
fin_reports2 <- sapply(fin_reports, function(x) apply(as.matrix(x), 1 , paste, collapse=" ") )
final_res$reports <- fin_reports2
final_res$reports <- vapply(final_res$reports, paste, collapse = ", ", character(1L))

# You could return here
# write.csv(final_res, file="sample_out.csv", row.names=F)

# The Abuse IP DB doesn't return data on reports filed
# You have to scrape that
# get_extras does that for you. For IPs on which reports are filed, get the reports

# For IPs for which abuseIP has reports, we get data on the reports
# Who submitted etc. 
res <- as.list(rep(NA, nrow(final_res)))
for (i in 1:nrow(final_res)) {
	if (final_res$reports[i]!="") {
		req <- GET(paste0("http://www.abuseipdb.com/report-history/", final_res$ip[i]))
			if (req$status == 200) {		
				html <- read_html(req)
				res[[i]] <- html %>% html_nodes(xpath='//*/table[1]') %>% html_table()
			}
		}
	}

# Nested list so
res1 <- sapply(res, "[[", 1)
res2 <- sapply(res1, function(x) if(!identical(x, NA)) paste(apply(as.matrix(x), 1, paste, collapse=" "), collapse="; "))

final_res$details <- res2
final_res$details <- vapply(final_res$details, paste, collapse = ", ", character(1L))

write.csv(final_res, file="sample_out.csv", row.names=F)
