#!/bin/bash
# vim: set filetype=sh :
# vim: syntax=sh
export LANG=C.UTF-8

#          file: /mnt/Vancouver/programming/scripts/arxiv-rss.sh
#       version: 09
# last modified: 2019-07-27
#     called by: /etc/crontab

# Version history:
#   * v07: add log file
#   * v08: dates to INT for datetime comparisons
#   * v09: egrep from list

# Aside: I program in Neovim with textwidth=220: the formatting below reflects this wide-screen display.

# PROGRAMMATIC (ARCH LINUX) DEPENDENCIES:
#   /usr/bin/curl                                                               ## sudo pacman -S curl
# system utils:
#   /usr/bin/echo
#   /usr/bin/egrep
#   /usr/bin/grep
#   /usr/bin/printf
# optional:
#   /usr/bin/nvim
#   /usr/bin/notify-send
#   /usr/bin/vim

# SCRIPT DEPENDENCY:
#   /mnt/Vancouver/tmp/arxiv/arxiv_keywords.txt                                       ## [optional] file of key words, phrases to grep for "arxiv-filtered" results file

# USAGE:
#   Runs 3 am daily via crontab:
#   m    h    dom  mon  dow  user        nice          command
#   0    3    *    *    *    victoria    nice -n 19    /mnt/Vancouver/programming/scripts/arxiv-rss.sh                                         
#   You can also manually execute (outside of: /mnt/Vancouver/tmp/arxiv/) this script.

# Open results files { .../arxiv-filtered | .../arxiv-others } in Vim/Neovim;
# with cursor on URL, "gx" keypress (or: Ctrl-click) opens that link in browser. :-D

# ============================================================================
# DIRECTORIES, DATES:

# Set paths:

# https://stackoverflow.com/questions/793858/how-to-mkdir-only-if-a-dir-does-not-already-exist
mkdir -p /mnt/Vancouver/tmp/arxiv
mkdir -p /mnt/Vancouver/tmp/arxiv/old
mkdir -p /mnt/Vancouver/tmp/arxiv/trash

cd /mnt/Vancouver/tmp/arxiv

cp 2>/dev/null -f .date.penultimate  .date.ante-penultimate                     ## 2>/dev/null : hide errors, warnings
cp 2>/dev/null -f .date  .date.penultimate                                      ## Not interested in seeing these files, so .hidden

# ----------------------------------------------------------------------------
# DATES:

# FIRST-EVER RUN only -- set date in ".date" file to YESTERDAY's date, o/w the date
# INT equality check (see the curl statements subsections, further below) will
# be True -- so there will be no results files!
# https://www.cyberciti.biz/tips/linux-unix-get-yesterdays-tomorrows-date.html
#
# -f : file does not exist
#
if [ -f .date ]; then : else; echo $(date --date='yesterday' +'%Y-%m-%d') > .date; fi

# ----------------------------------------
# https://stackoverflow.com/questions/10990949/convert-date-time-string-to-epoch-in-bash
# datetime integer conversions, per my post at: https://unix.stackexchange.com/a/526087/135372

# Testing:
# OLD_DATE='2019-07-15'                                                         ## for testing: ensures retrieval of latest arXiv RSS data snapshot

# Get old date:
OLD_DATE=$(cat .date)                                                           ## .hidden

# Convert old date to INT:                                                      ## I convert the arXiv feed (current) dates to INT in the IF statements, further below
OLD_DATE_INT=$(date -d "${OLD_DATE}" +"%s")
# echo "$OLD_DATE_INT"

# Get current date:
echo $(date +'%Y-%m-%d') > .date                                                ## update OLD_DATE
CURR_DATE=$(date +'%Y-%m-%d')                                                   ## CURRENT datetime (YYYY-MM-DD format)

# Save last result (manually delete, as needed):
mv 2>/dev/null -f arxiv-filtered  old/"$OLD_DATE".arxiv-filtered
mv 2>/dev/null -f arxiv-others  old/"$OLD_DATE".arxiv-others

printf '\n    old datetime: %s' "$OLD_DATE"
printf '\ncurrent datetime: %s\n' "$CURR_DATE"

# ----------------------------------------------------------------------------
# RSS FEEDS:

# https://arxiv.org/help/rss

#   FEED                            RESOLVES (BROWSER) TO
#   http://arxiv.org/rss/cs.AI      http://export.arxiv.org/rss/cs.AI           ## Artificial Intelligence
#   http://arxiv.org/rss/cs.CL      http://export.arxiv.org/rss/cs.CL           ## Computation and Language
#   http://arxiv.org/rss/cs.IR      http://export.arxiv.org/rss/cs.IR           ## Information Retrieval
#   http://arxiv.org/rss/cs.LG      http://export.arxiv.org/rss/cs.LG           ## Machine Learning
#   http://arxiv.org/rss/stat.ML    http://export.arxiv.org/rss/stat.ML         ## Machine Learning

# ----------------------------------------------------------------------------
# FETCH NEW ARTICLES

rm 2>/dev/null -f .arxiv                                                        ## start fresh, as I append (>>) new content to this file
touch .arxiv

# ----------------------------------------------------------------------------
# LOG FILE

# touch log
# https://stackoverflow.com/questions/3215742/how-to-log-output-in-bash-and-see-it-in-the-terminal-at-the-same-time
# tee -a : append; tee creates log file if it does not exist
printf '\n==============================================================================\n%s\n==============================================================================\n' "$(date +"%c")" 2>&1 | tee -a log

# ----------------------------------------------------------------------------
# ARXIV FEEDS

# Downloads once per script execution.

# ----------------------------------------
# cs.AI

curl -s http://export.arxiv.org/rss/cs.AI > .arxiv-temp                         ## -s : silent ; > : write to/overwrite existing temp file
# cs_AI_TIMESTAMP=$(grep dc:date  .arxiv-temp | sed -r 's/.*>(2019.*)<.*/\1/')
# 2019-06-17: sometime over the past week arXiv changed that line ("dc: date ..."); the following solution is ironclad.

# https://stackoverflow.com/questions/10990949/convert-date-time-string-to-epoch-in-bash
#   grep -m 1 : find first match; date -d ... : reformat date (-d) on STDIN (-)
# https://unix.stackexchange.com/questions/16357/usage-of-dash-in-place-of-a-filename
cs_AI_TIMESTAMP=$(grep -m 1 -E [0-9]{4}-[0-9]{2}-[0-9]{2} .arxiv-temp | date -d - +'%Y-%m-%d')
# datetime integer conversions, per my post at: https://unix.stackexchange.com/a/526087/135372
cs_AI_TIMESTAMP_INT=$(date -d "${cs_AI_TIMESTAMP}" +"%s")
printf '\n cs_AI_TIMESTAMP: %s\n' "$cs_AI_TIMESTAMP"

# Comparison operators: http://tldp.org/LDP/abs/html/comparison-ops.html
#   -eq : equal to | -ne : not equal to | -gt : greater than | -lt : less than | -ge : greater than or equal to | -le : less than or equal to | ...
# Testing (i.e.: -ne operator):
#   if [[ "$cs_AI_TIMESTAMP_INT" -ne "$OLD_DATE_INT" ]]; then

if [[ "$cs_AI_TIMESTAMP_INT" -eq "$OLD_DATE_INT" ]]; then
  echo 'No new cs.AI (Artificial Intelligence) RSS feeds.' 2>&1 | tee -a log
else
  echo 'Retrieving new cs.AI (Artificial Intelligence) RSS feeds ...' 2>&1 | tee -a log
  cat .arxiv-temp >> .arxiv
fi

# ----------------------------------------
# cs.CL

curl -s http://export.arxiv.org/rss/cs.CL > .arxiv-temp
cs_CL_TIMESTAMP=$(grep -m 1 -E [0-9]{4}-[0-9]{2}-[0-9]{2} .arxiv-temp | date -d - +'%Y-%m-%d')
cs_CL_TIMESTAMP_INT=$(date -d "${cs_CL_TIMESTAMP}" +"%s")
printf '\n cs_CL_TIMESTAMP: %s\n' "$cs_CL_TIMESTAMP"

if [[ "$cs_CL_TIMESTAMP_INT" -eq "$OLD_DATE_INT" ]]; then
  echo 'No new cs.CL (Computation and Language) RSS feeds.' 2>&1 | tee -a log
else
  echo 'Retrieving new cs.CL (Computation and Language) RSS feeds ...' 2>&1 | tee -a log
  cat .arxiv-temp >> .arxiv
fi

# ----------------------------------------
# cs.IR

curl -s http://export.arxiv.org/rss/cs.IR > .arxiv-temp
cs_IR_TIMESTAMP=$(grep -m 1 -E [0-9]{4}-[0-9]{2}-[0-9]{2} .arxiv-temp | date -d - +'%Y-%m-%d')
cs_IR_TIMESTAMP_INT=$(date -d "${cs_IR_TIMESTAMP}" +"%s")
printf '\n cs_IR_TIMESTAMP: %s\n' "$cs_IR_TIMESTAMP"

if [[ "$cs_IR_TIMESTAMP_INT" -eq "$OLD_DATE_INT" ]]; then
  echo 'No new cs.IR (Information Retrieval) RSS feeds.' 2>&1 | tee -a log
else
  echo 'Retrieving new cs.IR (Information Retrieval) RSS feeds ...' 2>&1 | tee -a log
  cat .arxiv-temp >> .arxiv
fi

# ----------------------------------------
# cs.LG

curl -s http://export.arxiv.org/rss/cs.LG > .arxiv-temp
cs_LG_TIMESTAMP=$(grep -m 1 -E [0-9]{4}-[0-9]{2}-[0-9]{2} .arxiv-temp | date -d - +'%Y-%m-%d')
cs_LG_TIMESTAMP_INT=$(date -d "${cs_LG_TIMESTAMP}" +"%s")
printf '\n cs_LG_TIMESTAMP: %s\n' "$cs_LG_TIMESTAMP"

if [[ "$cs_LG_TIMESTAMP_INT" -eq "$OLD_DATE_INT" ]]; then
  echo 'No new cs.LG (Machine Learning) RSS feeds.' 2>&1 | tee -a log
else
  echo 'Retrieving new cs.LG (Machine Learning) RSS feeds ...' 2>&1 | tee -a log
  cat .arxiv-temp >> .arxiv
fi

# ----------------------------------------
# stat.ML

curl -s http://export.arxiv.org/rss/stat.ML > .arxiv-temp
stat_ML_TIMESTAMP=$(grep -m 1 -E [0-9]{4}-[0-9]{2}-[0-9]{2} .arxiv-temp | date -d - +'%Y-%m-%d')
stat_ML_TIMESTAMP_INT=$(date -d "${stat_ML_TIMESTAMP}" +"%s")
printf '\n stat_ML_TIMESTAMP: %s\n' "$stat_ML_TIMESTAMP"

if [[ "$stat_ML_TIMESTAMP_INT" -eq "$OLD_DATE_INT" ]]; then
  printf 'No new stat.ML (Machine Learning) RSS feeds.\n' 2>&1 | tee -a log
else
  echo 'Retrieving new stat.ML (Machine Learning) RSS feeds ...' 2>&1 | tee -a log
  cat .arxiv-temp >> .arxiv
fi

# ----------------------------------------------------------------------------
# DEDUPLICATION; EGREP ARTICLES-OF-INTEREST

# ----------------------------------------
# Deduplication / egrep interesting titles:

# One-liner: if [[ "$(wc -c < .arxiv)" -lt 10 ]]; then : else; ,,,; fi
if [[ "$(wc -c < .arxiv)" -lt 10 ]]; then
  :
else
  # Get article title, URL:
  #   https://arxiv.org/help/arxiv_identifier:
  #   "The canonical form of identifiers from January 2015 is arXiv:YYMM.NNNNN,
  #    with 5-digits for the sequence number within the month."
  grep -i arxiv: .arxiv | sed -r 's/\(arXiv\:([0-9]{4}\.[0-9]{5}).*$/https:\/\/arxiv.org\/pdf\/\1/' | sed 's/
