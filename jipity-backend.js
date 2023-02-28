const functions = require('@google-cloud/functions-framework');
const openaiLib = require("openai");

const characters = [
  {name: 'Jip'},
  {
    name: 'Rodrick', prefix: `
Rodrick is an armored guard. He is standing guard in front of the royal bedroom.
The queen has told Rodrick not to allow the king to be woken up for any reason.
To be fair, this was several hours ago. It's almost noon, and Rodrick is starting
to wonder how the king is able to sleep for so long.

Jip is the son of the royal chef. He's 9 years old and always up to mischief.

The foyer to the royal bedroom, where Rodrick stands, is richly decorated with
colorful tapestries. A few barrels have been recently stacked in the corner.
Rodrick hopes they will not become a permanent installation.

Note how short all the sentences are! They needed to fit on a small screen while still
being entertaining. The only actions the characters can take is walking somewhere
or saying something.

Here is a log of events:
- Jip walks to the foyer.
- Rodrick says "What are you looking for, Jip?"
- Jip says "Have you seen a donkey, sir?"
- Rodrick says "No donkeys here, boy."
- Jip says "You're the donkey!"
- Jip walks to the garden.
- Rodrick says "Was that supposed to be funny?"
- Two hours pass.
- Jip walks to the foyer.
    `,
  },
  {
    name: 'Zelenda', prefix: `
Zelenda is the king's daughter and princess of the castle. She spends most of her
days in the Grand Princess Tower, which was originally built for her grandmother.
She is a rebellious teenager with a nasty streak. Perhaps she is just looking for
someone who can treat her as an equal.

Jip is the son of the royal chef. He's 9 years old and always up to mischief.

The Grand Princess Tower is full of pretty things. Everything is covered in gold.
Zelenda just brought in some mud on her shoes from the garden, but the servants
have already cleaned up the mess.

Note how short all the sentences are! They needed to fit on a small screen while still
being entertaining. The only actions the characters can take is walking somewhere
or saying something.

Here is a log of events:
- Jip walks to the foyer.
- Zelenda says "What are you looking for, Jip?"
- Jip says "Have you seen a donkey, miss?"
- Zelenda says "I see one now."
- Jip says "You're the donkey!"
- Zelenda says "Why are you braying then?"
- Jip walks to the garden.
- Zelenda says "Go cry to your mom."
- Two hours pass.
- Jip walks to the foyer.
        `,
},
{ name: 'Queen' },
{ name: 'King' },
{ name: 'Chancellor' },
{
  name: 'Ducky', prefix: `
Jip is the son of the royal chef. He's 9 years old and always up to mischief.

Ducky is Jip's pet duck. Ducky likes to follow Jip around and quack a word now and then for comedic effect.

The only actions the characters can take is walking somewhere or saying something.

Here is a log of events:
- Jip walks to the stables.
- Jip says "Have you seen a donkey, Ducky?"
- Ducky says "Quack?"
- Jip says "Are you a donkey?"
- Ducky says "Duck!"
- Jip says "No luck then."
- Ducky says "Luck!"
- Jip walks to the gardens.
- Two hours pass.
- Jip walks to the stables.
      `,
},
];

for (let i = 0; i < characters.length; ++i) characters[i].id = i;

functions.http('act', async (req, res) => {
  res.set('Access-Control-Allow-Origin', "*");
  res.set('Access-Control-Allow-Methods', 'POST');
  res.set('Access-Control-Allow-Headers', 'Content-Type');
  if (req.body.id) {
    const action = await getAction(req.body);
    console.log(action);
    res.send({action});
  } else {
    res.sendStatus(200);
  }
});

const openai = new openaiLib.OpenAIApi(new openaiLib.Configuration({
  apiKey: process.env.OPENAI_API_KEY,
}));

async function getAction(c) {
  console.log(c);
  const ch = characters[c.id];
  const prompt = characters[c.id].prefix.trim() + '\n' + c.log.map(a => {
    const actor = characters[a[0]].name;
    if (a[1] === 'says') {
      return `- ${actor} says "${a[2]}"`;
    }
  }).join('\n') + '\n-';
  console.log(prompt);
  const completion = await openai.createCompletion({
    model: "text-davinci-003", prompt, stop: '\n-', max_tokens: 30 });
  const text = completion.data.choices[0].text.trim();
  console.log(text);
  return parseAction(ch, text);
}

function parseAction(ch, text) {
  const firstSpace = text.indexOf(' ');
  if (firstSpace < 0) return;
  const actor = text.slice(0, firstSpace);
  if (actor !== ch.name) return;
  const action = text.slice(firstSpace).trim();
  if (action.startsWith('says')) {
    const m = action.match(/".*?"/);
    if (!m) return;
    return [ch.id, 'says', m[0].replace(/"/g, '').replace(/\n/, ' ')];
  } else {
    return [ch.id, 'says', '*' + action.replace(/\.$/, '') + '*'];
  }
}
