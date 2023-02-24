function say(c, text) {
	text = text.toLowerCase();
	pico8_gpio[50] = c + 1;
	pico8_gpio[51] = text.length;
	for (let i=0; i<text.length; ++i) {
		pico8_gpio[52+i] = text.charCodeAt(i);
	}
}

const characters = [
	{ log: [] },
	{ log: [] },
	{ log: [] },
];
for (let i = 0; i < characters.length; ++i) {
	characters[i].id = i;
}
const player = characters[0];

function playerSays(text) {
	for (const c of characters) {
		if (c == player) continue;
		const dist = Math.hypot(c.x-player.x, c.y-player.y);
		if (dist < 100) {
			c.log.push([0, 'says', text]);
			c.thinking = true;
		}
	}
}

async function getAction(c) {
	const res = await fetch('http://localhost:8080/', {
		method: 'POST',
		headers: {'Content-Type': 'application/json'},
		body: JSON.stringify({id: c.id, log: c.log}),
	});
	const j = await res.json();
	if (j.action) {
		const a = j.action;
		c.log.push(a);
		if (a[1] === 'says') {
			say(a[0], a[2])
		}
	}
	request = undefined;
}

let request;
function think() {
	setTimeout(think, 1000);
	for (const c of characters) {
		c.x = pico8_gpio[c.id*2+2];
		c.y = pico8_gpio[c.id*2+3];
		if (c.thinking && !request) {
			request = getAction(c);
			c.thinking = false;
		}
	}
	if (pico8_gpio[50] == 1) {
		const text = String.fromCharCode.apply(null, pico8_gpio.slice(52, 52 + pico8_gpio[51]));
		playerSays(text);
	}
}
think();
