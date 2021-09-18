const lynx = require('lynx');

// instantiate a metrics client
//  Note: the metric hostname is hardcoded here
const hostname = process.env.HOST;
const port = process.env.PORT;
const metrics = new lynx(hostname, port);
// const metrics = new lynx('localhost', 8125);

// sleep for a given number of milliseconds
function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
  // send message to the metrics server
  metrics.timing('test.core.delay', Math.random() * 1000);

  // sleep for a random number of milliseconds to avoid flooding metrics server
  return sleep(3000);
}

// infinite loop
(async () => {
  console.log("🚀🚀🚀");
  console.log(`Graphine is ${hostname}:${port}`);
  while (true) { await main() }
})()
  .then(console.log, console.error);