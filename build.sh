#!/bin/bash -xue
cd $(dirname $0)
/Users/danieldarabos/Library/Application\ Support/itch/apps/pico-8/pico-8/PICO-8.app/Contents/MacOS/pico8 jipity.p8 -export jipity.html 
echo '<script src="jipity-brain.js" type="module"></script>' >> jipity.html
echo 'export default `' > jipity-data.js
cat jipity.p8 | sed 's/\\/\\\\/g' >> jipity-data.js
echo '`;' >> jipity-data.js
