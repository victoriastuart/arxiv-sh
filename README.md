***Note:** At various times I've updated the `arxiv-rss.sh` script, mainly to address date-related bugs interfering with the daily checks / downloads.*

* Current version (see also script header): **13**

---

# arxiv-rss
Daily query for new arXiv articles in select topics via RSS

Description: https://Persagen.com/2019/06/10/arxiv-rss.html

  * [Daily, De-Duplicated arXiv RSS Updates: Keyword Parsed, Plus Non-Parsed Content](https://persagen.com/2019/06/10/arxiv-rss.html)

**TL//DR**

* I provide a BASH script, [`arxiv-rss.sh`](https://persagen.com/files/misc/arxiv-rss.sh) [&larr; direct download link] for daily retrieval of new, de-duplicated content from preselected arXiv groups.  That content is parsed into two files: keyword-matched articles of interest, plus the remaining articles.

* The script can be scheduled to run daily via crontab, or manually executed.

* If you have desktop notification (e.g. Linux `notify-send`), then a persistent message will indicate the arrival of new content

    ![notification](https://persagen.com/files/misc/arXiv-RSS-notify-send2.png)

**Sample results (file manager)**

![sample_output](https://persagen.com/files/misc/arxiv-rss-Krusader.png)

**Sample, filtered results (Neovim)**

![neovim_filtered-results](https://persagen.com/files/misc/arxiv-rss-in_Neovim.png)
