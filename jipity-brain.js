let rooms, map;
function parseSource() {
	const s = jipitySource;
	rooms = Object.fromEntries(
		[...s.match(/rooms=\{(.*?)\n\}/s)[1].matchAll(/(.*)=\{(.*)\}/g)]
		.map(m => [m[1].trim(), m[2].split(/,/).map(e => parseInt(e))]));
	const gfxStr = s.match(/__gfx__(.*?)__/s)[1].trim().split(/\n/);
	map = s.match(/__map__(.*?)__/s)[1].trim().split(/\n/);
	for (let i = 64; i < gfxStr.length; i += 2) {
		map.push(gfxStr[i] + gfxStr[i+1]);
	}
}
parseSource();

function clip(text, maxLength) {
	if (text.length > maxLength) {
		const sentences = [...text.matchAll(/.*?([.?!]|$)/g)].map(m => m[0]);
		if (sentences[0].length > maxLength) {
			const words = [...text.matchAll(/.*?( |$)/g)].map(m => m[0]);
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

const GPIO_SPEECH = 50;
const GPIO_DIRECTIONS = GPIO_SPEECH - 4;

function say(c, text) {
	text = clip(text, 128-GPIO_SPEECH-2);
	for (const c2 of characters) {
		if (sees(c2, c)) {
			c2.log.push([c.id, 'says', text]);
			c2.thinking = true;
		}
	}
	text = text.toLowerCase();
	pico8_gpio[GPIO_SPEECH] = c.id + 1;
	pico8_gpio[GPIO_SPEECH + 1] = text.length;
	for (let i=0; i<text.length; ++i) {
		pico8_gpio[GPIO_SPEECH+2+i] = text.charCodeAt(i);
	}
}

const characters = [];
for (let i = 0; i < 10; ++i) {
	characters.push({
		id: i, // Backend ID. PICO-8 IDs are +1.
		log: [],
		sees: {},
  });
}
const player = characters[0];
characters[2].destination = 'kitchen';

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

function updateSight() {
	for (const a of characters) {
		for (const b of characters) {
			if (a === b) continue;
			if ([a.x, a.y, b.x, b.y].includes(undefined)) continue;
			const see = sees(a, b);
			if (see != a.sees[b.id]) {
				if (a.sees[b.id] !== undefined) {
					a.log.push([b.id, see ? 'arrives' : 'leaves']);
					a.thinking = true;
				}
				a.sees[b.id] = see;
				if (b.sees[a.id] !== undefined) {
					b.log.push([a.id, see ? 'arrives' : 'leaves']);
					b.thinking = true;
				}
				b.sees[a.id] = see;
			}
		}
	}
}

function getRoom(c) {
	for (const name in rooms) {
		const r = rooms[name];
		if (c.x < r[0] || c.y < r[1] || c.x > r[2] || c.y > r[3]) continue;
		return name;
	}
}

function getDirection(c) {
	if (!c.destination || c.destination === c.room) return 0;
	const r = rooms[c.destination]
	const rx = (r[0] + r[2]) / 2;
	const ry = (r[1] + r[3]) / 2;
	if (rx < c.x) return 1;
	if (rx > c.x) return 2;
	if (ry < c.y) return 3;
	if (ry > c.y) return 4;
}

function sendDirections(directions) {
	for (let i = 0; i < characters.length / 6; ++i) {
		let v = 0;
		for (let j = 0; j < 6; ++j) {
			v += Math.pow(5, j) * (directions[i*6+j+1] || 0);
		}
		pico8_gpio[GPIO_DIRECTIONS+i*2] = v & 0xff;
		pico8_gpio[GPIO_DIRECTIONS+i*2+1] = v >> 8;
	}
}

let request;
function think() {
	setTimeout(think, 1000);
	let directions = {};
	for (const c of characters) {
		c.x = pico8_gpio[c.id*2+2];
		c.y = pico8_gpio[c.id*2+3];
		c.room = getRoom(c)
		directions[c.id] = getDirection(c);
		if (c !== player && c.thinking && !request) {
			request = getAction(c);
			c.thinking = false;
		}
	}
	sendDirections(directions);
	updateSight();
	if (pico8_gpio[GPIO_SPEECH] == 255) {
		const text = String.fromCharCode.apply(null, pico8_gpio.slice(52, 52 + pico8_gpio[51]));
		say(player, text);
		pico8_gpio[GPIO_SPEECH] = 1;
	}
}
think();
