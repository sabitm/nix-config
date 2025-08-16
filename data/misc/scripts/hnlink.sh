#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s inherit_errexit

if [[ $# -eq 0 ]]; then
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") <hn_link>

Hacker News comment link scraper

Example:

$(basename "${BASH_SOURCE[0]}") 'https://news.ycombinator.com/item?id=26499062'
EOF
fi

query() {
  curl -s "${*}" \
    -H 'Connection: keep-alive' \
    -H 'Pragma: no-cache' \
    -H 'Cache-Control: no-cache' \
    -H 'sec-ch-ua: "Google Chrome";v="89", "Chromium";v="89", ";Not A Brand";v="99"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'DNT: 1' \
    -H 'Upgrade-Insecure-Requests: 1' \
    -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36' \
    -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' \
    -H 'Sec-Fetch-Site: same-origin' \
    -H 'Sec-Fetch-Mode: navigate' \
    -H 'Sec-Fetch-User: ?1' \
    -H 'Sec-Fetch-Dest: document' \
    -H 'Referer: https://news.ycombinator.com/' \
    -H 'Accept-Language: en' \
    --compressed
}

query "${*}" \
  | rg -i -e "commtext" -e 'class="storylink">' \
  | rg -i '<a href=' \
  | sed \
      -e 's/.*<td class="title"><a href="/--0O /' \
      -e 's/" class="storylink">/ O0-- /' \
      -e 's/<\/a><span class="sitebit.*//' \
      -e 's/<a href="/\n<a href="/g' \
  | rg -i -e '<a href=' -e '--0O' \
  | sed \
      -e 's/.*<a href="//' \
      -e 's/".*//' \
  | recode html..ascii \
  | sort -u
