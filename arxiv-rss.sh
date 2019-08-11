#!/bin/bash
# vim: set filetype=sh :
# vim: syntax=sh
export LANG=C.UTF-8

#          file: /mnt/Vancouver/programming/scripts/arxiv-rss.sh
#       version: 10
# last modified: 2019-08-06
#     called by: /etc/crontab

# Version history:
#   * v07: add log file
#   * v08: dates to INT for datetime comparisons
#   * v09: `egrep` from list
#   * v10: `sed -i` from list [replace characters: accents, etc.)

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

# SCRIPT DEPENDENCIES:
#   /mnt/Vancouver/tmp/arxiv/sed_characters                                     ## lookup file for character replacement via `sed -i` command on "arxiv-*" files
#   /mnt/Vancouver/tmp/arxiv/arxiv_keywords.txt                                 ## lookup file of key words, phrases for `grep` command on "arxiv-filtered" results file

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
  grep -i arxiv: .arxiv | sed -r 's/\(arXiv\:([0-9]{4}\.[0-9]{5}).*$/https:\/\/arxiv.org\/pdf\/\1/' | sed 's/<title>//g' | sort | uniq > .arxiv-dedupped
  
  # egrep -i -e '\bbert\b|\belmo\b|\banswer\b|\banswer[is].*|attention|biolog|biomed|cancer|carcino| [ ... snip ... ]' .arxiv-dedupped  >  arxiv-filtered
  grep -i -f arxiv_keywords.txt .arxiv-dedupped > arxiv-filtered
  
  # Results files deduplication:
  #   https://stackoverflow.com/questions/37503186/comparing-two-files-by-lines-and-removing-duplicates-from-first-file
  # Remove lines from .arxiv-dedupped that are in arxiv-filtered:
  grep -vxFf  arxiv-filtered  .arxiv-dedupped  >  arxiv-others 

  # Delete file, if empty:
  if [[ "$(wc -c < arxiv-others)" -eq 0 ]]; then rm 2>/dev/null -f arxiv-others; fi
fi

# ----------------------------------------
# Move duplicate results files to trash (failsafe check in case the dates are not processed correctly, above):

cd /mnt/Vancouver/tmp/arxiv/

# Get most recent date (embedded in file name) among previously-downloaded results in ./old/ directory:
OLD_DATE2=$(ls -lt old/ > /tmp/arxiv-old_dates; rg /tmp/arxiv-old_dates -e [0-9]\{4\}- | head -n 1 | sed -r 's/.*([0-9]{4}-[0-9]{2}-[0-9]{2}).*/\1/')

# Check for differences (diff command):
#   * On the FIRST-EVER RUN of this script, there will be no previous results -- so nothing to compare (diff command).

if [ -f arxiv-filtered ]; then
  # Only proceed if there is something to compare (present, past results files):
  if [ -f old/"$OLD_DATE2".arxiv-filtered ]; then
    # Check for differences (diff command):
    a=$(/usr/bin/diff  arxiv-filtered  old/"$OLD_DATE2".arxiv-filtered | wc -c)
    # If no differences, then move these most recent (duplicate) results to trash:
    if [[ "$a" -eq 0 ]]; then mv 2>/dev/null -f arxiv-filtered  trash/"$CURR_DATE"-arxiv-filtered-dup_results | tee -a log; fi
  fi
fi

if [ -f arxiv-others ]; then
  # Only proceed if there is something to compare (present, past results files):
  if [ -f old/"$OLD_DATE2".arxiv-others ]; then
    # Get most recent date (embedded in file name) among previously-downloaded results in ./old/ directory:
    a=$(/usr/bin/diff  arxiv-others  old/"$OLD_DATE2".arxiv-others | wc -c)
    # If no differences, then move these most recent (duplicate) results to trash:
    if [[ "$a" -eq 0 ]]; then mv 2>/dev/null -f arxiv-others  trash/"$CURR_DATE"-arxiv-others-dup_results | tee -a log; fi
  fi
fi

# ----------------------------------------
# DESKTOP NOTIFICATION OF NEW ARTICLES:

# https://stackoverflow.com/questions/40082346/how-to-check-if-a-file-exists-in-a-shell-script
# if [ -f arxiv-filtered ] || [ -f arxiv-others ]; then notify-send -i warning -t 0 "New arXiv RSS feeds at" "<span color='#57dafd' font='26px'><a href=\"file:///mnt/Vancouver/tmp/arxiv/\">/mnt/Vancouver/tmp/arxiv/</a></span>"; fi

# https://unix.stackexchange.com/questions/47584/in-a-bash-script-using-the-conditional-or-in-an-if-statement
# https://askubuntu.com/questions/598601/how-to-customize-the-font-style-in-notify-send

# One-liner:
# if [ -f arxiv-filtered ] || [ -f arxiv-others ]; then notify-send -i "/mnt/Vancouver/programming/scripts/arxiv.png" -t 0 "New arXiv RSS feeds at" "<span color='#57dafd' font='26px'><a href=\"file:///mnt/Vancouver/tmp/arxiv/\">/mnt/Vancouver/tmp/arxiv/</a></span>"; fi

if [ -f arxiv-filtered ] || [ -f arxiv-others ]; then
  # Replace HTML, non-unicode characters in titles via external "sed_characters" lookup file:
  sed -i arxiv-* -f sed_characters
  # Desktop notification, with an arXiv png logo (available at https://persagen.com/files/misc/arxiv.png):
  notify-send -i "/mnt/Vancouver/programming/scripts/arxiv.png" -t 0 "New arXiv RSS feeds at" "<span color='#57dafd' font='26px'><a href=\"file:///mnt/Vancouver/tmp/arxiv/\">/mnt/Vancouver/tmp/arxiv/</a></span>"
fi

# ----------------------------------------
# Clean up:

rm 2>/dev/null -f .arxiv*                                                       ## { .arxiv | .arxiv-dedupped | .arxiv-temp }
echo

# ============================================================================
