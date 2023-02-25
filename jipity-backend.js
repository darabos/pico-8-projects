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
being entertaining.

Here is a log of events:
- Jip arrives in the foyer.
- Rodrick says "What are you looking for, Jip?"
- Jip says "Have you seen a donkey, sir?"
- Rodrick says "No donkeys here, boy."
- Jip says "You're the donkey!"
- Jip leaves the foyer.
- Rodrick says "Was that supposed to be funny?"
- Two hours pass.
- Jip arrives in the foyer.
    `,
  },
  {
    name: 'Zelenda', prefix: `
    `,
},
];

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
  const [actor, action, ...tail] = text.split(/ /);
  if (actor === ch.name && action === 'says') {
    return [c.id, 'says', tail.join(' ').replace(/"/g, '')];
  }
}
