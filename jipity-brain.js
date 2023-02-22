console.log('hello');
function think() {
	setTimeout(think, 1000);
	console.log(pico8_gpio[2], pico8_gpio[3]);
}
think();
