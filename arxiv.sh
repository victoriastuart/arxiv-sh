#!/bin/bash
# vim: set filetype=sh :
# vim: syntax=sh autoindent tabstop=4 shiftwidth=4 expandtab softtabstop=4 textwidth=220
export LANG=C.UTF-8

#          file:  /mnt/Vancouver/programming/scripts/arxiv.sh
#       created:  2023-06-15
#       version:  02 [2023-06-29]
# last modified:  2023-06-29 08:53:03 -0700 (PST)
# 
#      versions:  * v02 [2023-06-29] Added extra "=====..." lines to major sections for easier
#                       visual reference, and broke printf statements into individual lines
#                       for easier coding / readability / debugging / future extensions.
#                 * v01 [2023-06-15] inaugural; replaces /mnt/Vancouver/apps/arxiv/arxiv-rss.sh
#                       which appears to be deprecated (upstream) 2023-06-15?
# =============================================================================

# This first redirect > overwrites "/tmp/arxiv.txt" (if it exists):
printf '%s\n' $(date +'%Y-%m-%d') > /tmp/arxiv.txt

# ==============================================================================
# COMPUTER SCIENCE - ARTIFICIAL INTELLIGENCE

# curl https://arxiv.org/list/cs.AI/recent > /tmp/awi2eing.txt
# NOTE: with API parameters use single not double quotes:
# curl 'https://arxiv.org/list/cs.AI/pastweek?skip=0&show=100' > /tmp/awi2eing.txt

curl 'https://arxiv.org/list/cs.AI/pastweek?skip=0&show=200' > /tmp/awi2eing.txt

cat /tmp/awi2eing.txt | grep -E '<h3>|<h3>|^<span class="descriptor">Title:</span> |href="/abs/' > /tmp/ai.txt

sed -r -i '
    s/<h3>/\n\n========================================\n/
    s/<\/h3>/\n========================================/
    s/<span class="descriptor">Title:<\/span> /• /g
    s/.*"(\/abs.*)" .*$/    https:\/\/arxiv.org\1/
  ' /tmp/ai.txt

sed -i '
    s/".*$//
    s/^<.*//g
  ' /tmp/ai.txt

# These redirects >> APPEND the content to the file (> overwrites):
printf "\n===============================================================================" >> /tmp/arxiv.txt
printf "\n===============================================================================" >> /tmp/arxiv.txt
printf "\n[1/5] ARTIFICIAL INTELLIGENCE [$(date +'%Y-%m-%d')]" >> /tmp/arxiv.txt
printf "\n===============================================================================" >> /tmp/arxiv.txt
printf "\n===============================================================================\n" >> /tmp/arxiv.txt

tac /tmp/ai.txt >> /tmp/arxiv.txt

# ==============================================================================
# COMPUTER SCIENCE - COMPUTATION and LANGUAGE

curl 'https://arxiv.org/list/cs.CL/pastweek?skip=0&show=100' > /tmp/gei6sihu.txt

cat /tmp/gei6sihu.txt | grep -E '<h3>|^<span class="descriptor">Title:</span> |href="/abs/' > /tmp/cl.txt

sed -r -i '
    s/<h3>/\n========================================\n/
    s/<\/h3>/\n========================================/
    s/<span class="descriptor">Title:<\/span> /• /g
    s/.*"(\/abs.*)" .*$/    https:\/\/arxiv.org\1/
  ' /tmp/cl.txt

sed -i '
    s/".*$//
    s/^<.*//g
  ' /tmp/cl.txt

printf "\n===============================================================================" >> /tmp/arxiv.txt
printf "\n===============================================================================" >> /tmp/arxiv.txt
printf "\n[2/5] COMPUTATION and LANGUAGE [$(date +'%Y-%m-%d')]" >> /tmp/arxiv.txt
printf "\n===============================================================================" >> /tmp/arxiv.txt
printf "\n===============================================================================\n" >> /tmp/arxiv.txt

tac /tmp/cl.txt >> /tmp/arxiv.txt

# ==============================================================================
# COMPUTER SCIENCE - INFORMATION RETRIEVAL

# curl 'https://arxiv.org/list/cs.IR/pastweek?skip=0&show=100' > /tmp/ahpahn4v.txt
# Fewer in this group:
curl 'https://arxiv.org/list/cs.IR/recent' > /tmp/ahpahn4v.txt

cat /tmp/ahpahn4v.txt | grep -E '<h3>|^<span class="descriptor">Title:</span> |href="/abs/' > /tmp/ir.txt

sed -r -i '
    s/<h3>/\n========================================\n/
    s/<\/h3>/\n========================================/
    s/<span class="descriptor">Title:<\/span> /• /g
    s/.*"(\/abs.*)" .*$/    https:\/\/arxiv.org\1/
  ' /tmp/ir.txt

sed -i '
    s/".*$//
    s/^<.*//g
  ' /tmp/ir.txt

printf "\n===============================================================================" >> /tmp/arxiv.txt
printf "\n===============================================================================" >> /tmp/arxiv.txt
printf "\n[3/5] COMPUTATION AND LANGUAGE [$(date +'%Y-%m-%d')]" >> /tmp/arxiv.txt
printf "\n===============================================================================" >> /tmp/arxiv.txt
printf "\n===============================================================================\n" >> /tmp/arxiv.txt

tac /tmp/ir.txt >> /tmp/arxiv.txt

# ==============================================================================
# COMPUTER SCIENCE - MACHINE LEARNING

curl 'https://arxiv.org/list/cs.LG/pastweek?skip=0&show=150' > /tmp/ohgai5ni.txt

cat /tmp/ohgai5ni.txt | grep -E '<h3>|^<span class="descriptor">Title:</span> |href="/abs/' > /tmp/ml.txt

sed -r -i '
    s/<h3>/\n========================================\n/
    s/<\/h3>/\n========================================/
    s/<span class="descriptor">Title:<\/span> /• /g
    s/.*"(\/abs.*)" .*$/    https:\/\/arxiv.org\1/
  ' /tmp/ml.txt

sed -i '
    s/".*$//
    s/^<.*//g
  ' /tmp/ml.txt

printf "\n===============================================================================" >> /tmp/arxiv.txt
printf "\n===============================================================================" >> /tmp/arxiv.txt
printf "\n[4/5] COMPUTER SCIENCE - MACHINE LEARNING [$(date +'%Y-%m-%d')]" >> /tmp/arxiv.txt
printf "\n===============================================================================" >> /tmp/arxiv.txt
printf "\n===============================================================================\n" >> /tmp/arxiv.txt

tac /tmp/ml.txt >> /tmp/arxiv.txt

# ==============================================================================
# Statistics - Machine Learning

# Fewer in this group:
curl 'https://arxiv.org/list/stat.ML/pastweek?skip=0&show=50' > /tmp/eeb8lae7.txt

cat /tmp/eeb8lae7.txt | grep -E '<h3>|^<span class="descriptor">Title:</span> |href="/abs/' > /tmp/statml.txt

sed -r -i '
    s/<h3>/\n========================================\n/
    s/<\/h3>/\n========================================/
    s/<span class="descriptor">Title:<\/span> /• /g
    s/.*"(\/abs.*)" .*$/    https:\/\/arxiv.org\1/
  ' /tmp/statml.txt

sed -i '
    s/".*$//
    s/^<.*//g
  ' /tmp/statml.txt

printf "\n===============================================================================" >> /tmp/arxiv.txt
printf "\n===============================================================================" >> /tmp/arxiv.txt
printf "\n[5/5] STATISTICS - MACHINE LEARNING [$(date +'%Y-%m-%d')]" >> /tmp/arxiv.txt
printf "\n===============================================================================" >> /tmp/arxiv.txt
printf "\n===============================================================================\n" >> /tmp/arxiv.txt

tac /tmp/statml.txt >> /tmp/arxiv.txt

# ==============================================================================


mail -s 'arxiv' mail@VictoriasJourney.com < /tmp/arxiv.txt

# ==============================================================================
# [end of file]
# ==============================================================================
