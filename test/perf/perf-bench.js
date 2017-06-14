const enigma = require('enigma.js');
const WebSocket = require('ws');
const qixSchema = require('../node_modules/enigma.js/schemas/qix/3.2/schema.json');
const commandLineArgs = require('command-line-args');

const optionDefinitions = [
  { name: 'max-users', alias: 'm', type: Number },
  { name: 'avg-users', alias: 'a', type: Number },
];
const args = commandLineArgs(optionDefinitions, { partial: true });
const qixSessions = [];

function generateGUID() {
  /* eslint-disable no-bitwise */
  'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
    const r = (Math.random() * 16) | 0;
    const v = c === 'x' ? r : (r & 0x3) | 0x8;
    return v.toString(16);
  });
  /* eslint-enable no-bitwise */
}

function getEnigmaConfig(id) {
  return {
    session: {
      host: process.env.GATEWAY_IP_ADDR || 'localhost',
      route: '/doc/doc/drugcases.qvf',
      disableCache: true,
      identity: id,
    },
    schema: qixSchema,
    createSocket: url => new WebSocket(url, { rejectUnauthorized: false }),
  };
}

async function connect(numConnections, delay) {
  return new Promise((resolve) => {
    let count = 0;
    async function addSession() {
      const qix = await enigma.getService('qix', getEnigmaConfig(generateGUID()));
      qixSessions.push(qix);
      count += 1;
      if (count === numConnections) {
        resolve();
      } else {
        setTimeout(addSession, delay);
      }
    }
    setTimeout(addSession, delay);
  });
}

async function verify() {
  // eslint-disable-next-line no-restricted-syntax
  for (const qix of qixSessions) {
    /* eslint-disable no-await-in-loop */
    const app = await qix.global.getActiveDoc();
    const layout = await app.getAppLayout();
    /* eslint-enable no-await-in-loop */
    if (layout.qFileName !== '/doc/drugcases.qvf') {
      throw new Error('Unexpected filename');
    }
  }
}

async function disconnectAll() {
  // eslint-disable-next-line no-restricted-syntax
  for (const qix of qixSessions) {
    // eslint-disable-next-line no-await-in-loop
    await qix.global.session.close();
  }
}

async function sleep(delay) {
  return new Promise((resolve) => {
    setTimeout(() => { resolve(); }, delay);
  });
}

function onUnhandledError(err) {
  console.error('Process encountered an unhandled error', err);
  process.exit(1);
}

process.on('SIGTERM', () => {
  console.log('Process exiting on SIGTERM');
  process.exit(0);
});

process.on('uncaughtException', onUnhandledError);
process.on('unhandledRejection', onUnhandledError);

(async () => {
  const avgUsers = args['avg-users'];
  const maxUsers = args['max-users'];

  if (!avgUsers) {
    console.error('Error - Average number of users not provided (-a, --avg-users)');
    process.exit(1);
  }

  if (!maxUsers) {
    console.error('Error - Max number of users not provided (-a, --avg-users)');
    process.exit(1);
  }

  console.log(`Connecting ${avgUsers} users (average)`);
  await connect(avgUsers, 10);
  console.log('Sleeping for 5 seconds');
  await sleep(5000);
  console.log(`Connecting ${maxUsers} users (max)`);
  await connect(maxUsers - avgUsers, 10);
  console.log('Verifying connections');
  await verify();
  console.log('Closing all connections');
  await disconnectAll();
  console.log('Done');
})();
