**arxiv.sh**:  automated daily query for new arXiv.org articles in select subjects via RSS

I schedule the script to run daily and email the results to myself, which I read in Claws Mail (screenshot attached; links open in web browser).

```
# /etc/crontab
# "At 6:00 am daily" [http://crontab.guru/]:
0    6    *    *    *    victoria    nice -n 19    /mnt/Vancouver/programming/scripts/arxiv.sh
```

Due to the way arXiv.org presents the data, some older results are retained on each day but they are clearly delineated in the script output and can be ignored (scroll past them) or used for reference to older results.
