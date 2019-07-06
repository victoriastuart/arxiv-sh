#!/bin/bash
# vim: set filetype=sh :
# vim: syntax=sh
export LANG=C.UTF-8

#          file: /mnt/Vancouver/programming/scripts/arxiv-rss.sh
#       version: 09                                                             ## added log file (v07); dates to int for datetime comparisons (v08)
# last modified: 2019-07-05
#     called by: /etc/crontab

# ARCH LINUX -- DEPENDENCIES:
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

# USAGE:
#   Runs 3 am daily via crontab:
#   m    h    dom  mon  dow  user        nice          command
#   0    3    *    *    *    victoria    nice -n 19    /mnt/Vancouver/programming/scripts/arxiv-rss.sh                                         
#   You can also manually execute (outside of: /mnt/Vancouver/tmp/arxiv/) this script.

# Open results files { .../arxiv-filtered | .../arxiv-others } in Vim/Neovim;
# with cursor on URL, "gx" keypress (or: Ctrl-click) opens that link in browser. :-D

# Aside: I program in Neovim with textwidth=220: the formatting below reflects this wide-screen display.

# ============================================================================
# DIRECTORIES, DATES:

# Set paths:

# https://stackoverflow.com/questions/793858/how-to-mkdir-only-if-a-dir-does-not-already-exist
mkdir -p /mnt/Vancouver/tmp/arxiv
mkdir -p /mnt/Vancouver/tmp/arxiv/old
mkdir -p /mnt/Vancouver/tmp/arxiv/.trash

cd /mnt/Vancouver/tmp/arxiv

cp 2>/dev/null -f .date.penultimate  .date.ante-penultimate                     ## 2>/dev/null : hide errors, warnings
cp 2>/dev/null -f .date  .date.penultimate                                      ## Not interested in seeing these files, so .hidden

# Testing:
# OLD_DATE='2019-06-12'                                                         ## for testing: ensures retrieval of latest arXiv RSS data snapshot

# First run only:
if [ -f .date ]; then : else; echo $(date +'%Y-%m-%d') > .date; fi

# https://stackoverflow.com/questions/10990949/convert-date-time-string-to-epoch-in-bash
OLD_DATE=$(cat .date)                                                           ## .hidden
echo $(date +'%Y-%m-%d') > .date                                                ## update OLD_DATE
CURR_DATE=$(date +'%Y-%m-%d')                                                   ## CURRENT datetime (YYYY-MM-DD format)

# datetime integer conversions, per my post at: https://unix.stackexchange.com/a/526087/135372
OLD_DATE_INT=$(date -d "${OLD_DATE}" +"%s")

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
# grep -m 1 : find first match; date -d ... : reformat date (-d) on STDIN (-)
# https://unix.stackexchange.com/questions/16357/usage-of-dash-in-place-of-a-filename
cs_AI_TIMESTAMP=$(grep -m 1 -E [0-9]{4}-[0-9]{2}-[0-9]{2} .arxiv-temp | date -d - +'%Y-%m-%d')
# datetime integer conversions, per my post at: https://unix.stackexchange.com/a/526087/135372
cs_AI_TIMESTAMP_INT=$(date -d "${cs_AI_TIMESTAMP}" +"%s")
printf '\n cs_AI_TIMESTAMP: %s\n' "$cs_AI_TIMESTAMP"

# comparison operators: http://tldp.org/LDP/abs/html/comparison-ops.html
if [[ "$cs_AI_TIMESTAMP_INT" -eq "$OLD_DATE_INT" ]]; then
  echo 'Retrieving new cs.AI (Artificial Intelligence) RSS feeds ...' 2>&1 | tee -a log
  cat .arxiv-temp >> .arxiv
else
  echo 'No new cs.AI (Artificial Intelligence) RSS feeds.' 2>&1 | tee -a log
fi

# ----------------------------------------
# cs.CL

curl -s http://export.arxiv.org/rss/cs.CL > .arxiv-temp
cs_CL_TIMESTAMP=$(grep -m 1 -E [0-9]{4}-[0-9]{2}-[0-9]{2} .arxiv-temp | date -d - +'%Y-%m-%d')
cs_CL_TIMESTAMP_INT=$(date -d "${cs_CL_TIMESTAMP}" +"%s")
printf '\n cs_CL_TIMESTAMP: %s\n' "$cs_CL_TIMESTAMP"

if [[ "$cs_CL_TIMESTAMP_INT" -eq "$OLD_DATE_INT" ]]; then
  echo 'Retrieving new cs.CL (Computation and Language) RSS feeds ...' 2>&1 | tee -a log
  cat .arxiv-temp >> .arxiv
else
  echo 'No new cs.CL (Computation and Language) RSS feeds.' 2>&1 | tee -a log
fi

# ----------------------------------------
# cs.IR

curl -s http://export.arxiv.org/rss/cs.IR > .arxiv-temp
cs_IR_TIMESTAMP=$(grep -m 1 -E [0-9]{4}-[0-9]{2}-[0-9]{2} .arxiv-temp | date -d - +'%Y-%m-%d')
cs_IR_TIMESTAMP_INT=$(date -d "${cs_IR_TIMESTAMP}" +"%s")
printf '\n cs_IR_TIMESTAMP: %s\n' "$cs_IR_TIMESTAMP"

if [[ "$cs_IR_TIMESTAMP_INT" -eq "$OLD_DATE_INT" ]]; then
  echo 'Retrieving new cs.IR (Information Retrieval) RSS feeds ...' 2>&1 | tee -a log
  cat .arxiv-temp >> .arxiv
else
  echo 'No new cs.IR (Information Retrieval) RSS feeds.' 2>&1 | tee -a log
fi

# ----------------------------------------
# cs.LG

curl -s http://export.arxiv.org/rss/cs.LG > .arxiv-temp
cs_LG_TIMESTAMP=$(grep -m 1 -E [0-9]{4}-[0-9]{2}-[0-9]{2} .arxiv-temp | date -d - +'%Y-%m-%d')
cs_LG_TIMESTAMP_INT=$(date -d "${cs_LG_TIMESTAMP}" +"%s")
printf '\n cs_LG_TIMESTAMP: %s\n' "$cs_LG_TIMESTAMP"

if [[ "$cs_LG_TIMESTAMP_INT" -eq "$OLD_DATE_INT" ]]; then
  echo 'Retrieving new cs.LG (Machine Learning) RSS feeds ...' 2>&1 | tee -a log
  cat .arxiv-temp >> .arxiv
else
  echo 'No new cs.LG (Machine Learning) RSS feeds.' 2>&1 | tee -a log
fi

# ----------------------------------------
# stat.ML

curl -s http://export.arxiv.org/rss/stat.ML > .arxiv-temp
stat_ML_TIMESTAMP=$(grep -m 1 -E [0-9]{4}-[0-9]{2}-[0-9]{2} .arxiv-temp | date -d - +'%Y-%m-%d')
stat_ML_TIMESTAMP_INT=$(date -d "${stat_ML_TIMESTAMP}" +"%s")
printf '\n stat_ML_TIMESTAMP: %s\n' "$stat_ML_TIMESTAMP"

if [[ "$stat_ML_TIMESTAMP_INT" -eq "$OLD_DATE_INT" ]]; then
  echo 'Retrieving new stat.ML (Machine Learning) RSS feeds ...' 2>&1 | tee -a log
  cat .arxiv-temp >> .arxiv
else
  printf 'No new stat.ML (Machine Learning) RSS feeds.\n' 2>&1 | tee -a log
fi

# ----------------------------------------------------------------------------
# DEDUPLICATION; EGREP ARTICLES-OF-INTEREST

# ----------------------------------------
# Deduplication / egrep interesting titles:

# One-liner: if [[ "$(wc -c < .arxiv)" -lt 10 ]]; then : else; ,,,; fi
if [[ "$(wc -c < .arxiv)" -lt 10 ]]; then
  :
else
  # https://arxiv.org/help/arxiv_identifier:
  # "The canonical form of identifiers from January 2015 (1501) is arXiv:YYMM.NNNNN, with 5-digits for the sequence number within the month."
  grep -i arxiv: .arxiv | sed -r 's/\(arXiv\:([0-9]{4}\.[0-9]{5}).*$/https:\/\/arxiv.org\/pdf\/\1/' | sed 's/<title>//g' | sort | uniq > .arxiv-dedupped
  #
  egrep -i -e '\bbert\b|\belmo\b|\bernie\b|\banswer\b|\banswer[is].*|attention|biolog|biomed|cancer|carcino|chemotherap|classif|clinic|comprehension|contextual|coref|corpus|data mining|dna|embedding|entity|explanat|explain|extraction|\bgpt\b|\bgene\b|genetic|genom|\bgraph\b|\bgraph[is].*|inference|interactome|knowledge|language model|medic|multi-hop|multihop|natural language|\bner\b|\bnlp\b|omic|personali|protein|relation|representation|retriev|rna|semantic|syntactic|tensor|text|topolog|transfer learn|transformer|summar|understanding|xlnet' .arxiv-dedupped  >  arxiv-filtered
  #
  # Results files deduplication:
  # https://stackoverflow.com/questions/37503186/comparing-two-files-by-lines-and-removing-duplicates-from-first-file
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
a=$(/usr/bin/diff --color=always arxiv-filtered old/"$OLD_DATE2".arxiv-filtered | wc -c)
b=$(/usr/bin/diff --color=always arxiv-others old/"$OLD_DATE2".arxiv-others | wc -c)

# If no differences, then move these most recent (duplicate) results to trash:
if [[ "$a" -eq 0 ]]; then mv 2>/dev/null -f arxiv-filtered  trash/"$CURR_DATE"-arxiv-filtered-deleted_dup_results | tee -a log; fi
if [[ "$b" -eq 0 ]]; then mv 2>/dev/null -f arxiv-others  trash/"$CURR_DATE"-arxiv-others-deleted_dup_results | tee -a log; fi

# ----------------------------------------
# DESKTOP NOTIFICATION IF NEW ARTICLES:

# https://stackoverflow.com/questions/40082346/how-to-check-if-a-file-exists-in-a-shell-script
# if [ -f arxiv-filtered ] || [ -f arxiv-others ]; then notify-send -i warning -t 0 "New arXiv RSS feeds at" "<span color='#57dafd' font='26px'><a href=\"file:///mnt/Vancouver/tmp/arxiv/\">/mnt/Vancouver/tmp/arxiv/</a></span>"; fi

# https://unix.stackexchange.com/questions/47584/in-a-bash-script-using-the-conditional-or-in-an-if-statement
# https://askubuntu.com/questions/598601/how-to-customize-the-font-style-in-notify-send

# One-liner:
# if [ -f arxiv-filtered ] || [ -f arxiv-others ]; then notify-send -i "/mnt/Vancouver/programming/scripts/arxiv.png" -t 0 "New arXiv RSS feeds at" "<span color='#57dafd' font='26px'><a href=\"file:///mnt/Vancouver/tmp/arxiv/\">/mnt/Vancouver/tmp/arxiv/</a></span>"; fi

if [ -f arxiv-filtered ] || [ -f arxiv-others ]; then
  # notify-send -i warning -t 0 "New arXiv RSS feeds at" "<span color='#57dafd' font='26px'><a href=\"file:///mnt/Vancouver/tmp/arxiv/\">/mnt/Vancouver/tmp/arxiv/</a></span>"
  # With an arXiv png logo (available at https://persagen.com/files/misc/arxiv.png)
  notify-send -i "/mnt/Vancouver/programming/scripts/arxiv.png" -t 0 "New arXiv RSS feeds at" "<span color='#57dafd' font='26px'><a href=\"file:///mnt/Vancouver/tmp/arxiv/\">/mnt/Vancouver/tmp/arxiv/</a></span>"
  # Clean up HTML, other code in titles (e.g.: &quot; to "):
  #  's/&apos;/\'\''/g' addresses &apos; --> ' | "s/\\\'//g" addresses "\'" | "s/\`//g" addresses "\`" (can't use: 's/\`//g') | ...
  sed -i 's/&quot;/"/g; s/&apos;/\'\''/g; s/&amp;/\&/g; s/\$//g; s/\\mathcal//g' arxiv-* | sed -i "s/\\\'//g; s/\`//g" arxiv-*
fi

# ----------------------------------------
# Clean up:

rm 2>/dev/null -f .arxiv*                                                       ## { .arxiv | .arxiv-dedupped | .arxiv-temp }
echo

# ============================================================================
