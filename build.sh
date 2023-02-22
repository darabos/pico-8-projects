#!/bin/bash -xue
cd $(dirname $0)
/Users/danieldarabos/Library/Application\ Support/itch/apps/pico-8/pico-8/PICO-8.app/Contents/MacOS/pico8 jipity.p8 -export jipity.html 
echo '<script src="jipity-brain.js"></script>' >> jipity.html
