#!/usr/bin/env bash

set -exo pipefail

rm dist -rf
mkdir dist

md=(
  ./src/2025-07-28_Pre-RFC_Safety-Property-System.md
  # slides_init.md
)

site=(
  Safety-Property-System
  # demo
)

# build static pages
for i in "${!md[@]}"; do
  npm run build -- ${md[$i]} --out ../dist/${site[$i]} --base /slides/${site[$i]}/
done

# generate index.html
slides=$(
  for i in "${!md[@]}"; do
    ele=${md[$i]#./src/} # remove ./src/
    ele=${ele/_/ }       # replace the first _ by space
    ele=${ele%.md}       # remove .md
    printf '  <li>  <a href="./%s"> %s </li>\\\n' "${site[$i]}" "${ele}"
  done
)
sed -e '/^SLIDES$/c\'"${slides}" .github/index.html >dist/index.html
