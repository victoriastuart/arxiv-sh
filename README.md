**arxiv.sh**:  daily query for new arXiv.org articles in select subjects via RSS

I schedule the script to run daily (/etc/crontab) and mail the results to myself, which I read in Claws Mail (screenshot attached).

```
# /etc/crontab
# "At 6:00 am daily" [http://crontab.guru/]:
0    6    *    *    *    victoria    nice -n 19    /mnt/Vancouver/programming/scripts/arxiv.sh
```
