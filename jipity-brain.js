let rooms, map;
function parseSource() {
	const s = jipitySource;
	rooms = Object.fromEntries(
		[...s.match(/rooms=\{(.*?)\n\}/s)[1].matchAll(/(.*)=\{(.*)\}/g)]
		.map(m => [m[1].trim(), m[2].split(/,/).map(e => parseInt(e))]));
	const gfxStr = s.match(/__gfx__(.*?)__/s)[1].split(/\n/);
	const mapStr = s.match(/__map__(.*?)__/s)[1].split(/\n/);
}
parseSource();

function clip(text, maxLength) {
	if (text.length > maxLength) {
		const sentences = [...text.matchAll(/.*?[.?!]/g)].map(m => m[0]);
		if (sentences[0].length > maxLength) {
			const words = [...text.matchAll(/.*? /g)].map(m => m[0]);
			if (words[0].length > maxLength) {
				text = text.substring(0, maxLength);
			} else {
				text = "";
				while (words.length && text.length + words[0].length <= maxLength) text += words.shift();
			}
		} else {
			text = "";
			while (sentences.length && text.length + sentences[0].length < maxLength) text += sentences.shift();
		}
	}
	return text;
}

function sees(a, b) {
	const dist = Math.hypot(a.x-b.x, a.y-b.y);
	return dist < 5;
}

function say(c, text) {
	const gpioOffset = 50;
	text = clip(text, 128-gpioOffset-2);
	for (const c2 of characters) {
		if (sees(c2, c)) {
			c2.log.push([c.id, 'says', text]);
			c2.thinking = true;
		}
	}
	text = text.toLowerCase();
	pico8_gpio[gpioOffset] = c.id + 1;
	pico8_gpio[gpioOffset + 1] = text.length;
	for (let i=0; i<text.length; ++i) {
		pico8_gpio[gpioOffset+2+i] = text.charCodeAt(i);
	}
}

const characters = [];
for (let i = 0; i < 10; ++i) {
	characters.push({ log: [] });
	characters[i].id = i; // Backend ID. PICO-8 IDs are +1.
}
const player = characters[0];

async function getAction(c) {
	let res;
	try {
		res = await fetch('http://localhost:8080/', {
			method: 'POST',
			headers: {'Content-Type': 'application/json'},
			body: JSON.stringify({id: c.id, log: c.log}),
		});
	} catch (e) {
		// Retry backend call.
		return await getAction(c);
	}
	const j = await res.json();
	if (j.action) {
		const a = j.action;
		if (a[1] === 'says') {
			say(characters[a[0]], a[2])
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
		if (c !== player && c.thinking && !request) {
			request = getAction(c);
			c.thinking = false;
		}
	}
	if (pico8_gpio[50] == 1) {
		const text = String.fromCharCode.apply(null, pico8_gpio.slice(52, 52 + pico8_gpio[51]));
		say(player, text);
		pico8_gpio[50] = 0;
	}
}
think();
