console.log('hello');
function say(tile, text) {
	pico8_gpio[50] = 3;
	pico8_gpio[51] = text.length;
	for (let i=0; i<text.length; ++i) {
		pico8_gpio[52+i] = text.charCodeAt(i);
	}
}
function think() {
	setTimeout(think, 1000);
	console.log(pico8_gpio[2], pico8_gpio[3]);
	say(2, 'howdy?');
}
think();
