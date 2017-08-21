const enigma = require('enigma.js');
const WebSocket = require('ws');
const qixSchema = require('../node_modules/enigma.js/schemas/qix/3.2/schema.json');
const commandLineArgs = require('command-line-args');
const request = require('request');

const optionDefinitions = [
  { name: 'gateway', alias: 'g', type: String },
  { name: 'max', alias: 'm', type: Number },
  { name: 'duration', alias: 'd', type: Number },
];
const args = commandLineArgs(optionDefinitions, { partial: true });

async function getLoginCookie() {
  return new Promise((resolve) => {
    process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';
    const loginUrl = '/login/local/callback?username=admin&password=password';
    const fullUrl = `https://${args.gateway}${loginUrl}`;
    request(fullUrl, { followRedirect: false },
      (error, response) => {
        resolve(response.headers['set-cookie'][0].split(';')[0]);
      });
  });
}

function generateGUID() {
  /* eslint-disable no-bitwise */
  'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
    const r = (Math.random() * 16) | 0;
    const v = c === 'x' ? r : (r & 0x3) | 0x8;
    return v.toString(16);
  });
  /* eslint-enable no-bitwise */
}

function getEnigmaConfig(gateway, id, cookie) {
  return {
    session: {
      host: gateway,
      route: '/doc/doc/drugcases.qvf',
      disableCache: true,
      identity: id,
    },
    schema: qixSchema,
    createSocket: url => new WebSocket(url, {
      rejectUnauthorized: false,
      headers: {
        Cookie: cookie,
      },
    }),
  };
}

async function sleep(delay) {
  return new Promise((resolve) => {
    setTimeout(() => { resolve(); }, delay);
  });
}

async function connect(gateway, numConnections, duration, cookie) {
  return new Promise((resolve, reject) => {
    const sessions = [];
    const delay = (duration * 1000) / numConnections;
    let count = 0;
    async function addSession() {
      try {
        const qix = await enigma.getService('qix', getEnigmaConfig(gateway, generateGUID(), cookie));
        sessions.push(qix);
        count += 1;
        console.log(count);
        if (count === numConnections) {
          resolve(sessions);
        } else {
          setTimeout(addSession, delay);
        }
      } catch (e) {
        reject(e);
      }
    }
    setTimeout(addSession, delay);
  });
}

async function verify(sessions) {
  // eslint-disable-next-line no-restricted-syntax
  for (const qix of sessions) {
    /* eslint-disable no-await-in-loop */
    const app = await qix.global.getActiveDoc();
    const layout = await app.getAppLayout();
    /* eslint-enable no-await-in-loop */
    if (layout.qFileName !== '/doc/drugcases.qvf') {
      throw new Error('Unexpected filename');
    }
  }
}

async function disconnect(sessions, duration) {
  const delay = (duration * 1000) / sessions.length;
  // eslint-disable-next-line no-restricted-syntax
  for (const qix of sessions) {
    /* eslint-disable no-await-in-loop */
    await qix.global.session.close();
    await sleep(delay);
    /* eslint-enable no-await-in-loop */
  }
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
  const maxNumUsers = args.max;
  let duration = args.duration;
  let gateway = args.gateway;

  if (!maxNumUsers) {
    console.error('Error - Max number of users not provided (-m, --max)');
    process.exit(1);
  }

  if (!duration) { duration = 60; }
  if (!gateway) { gateway = 'localhost'; }

  console.log('================================================================================');
  console.log(' Running performance benchmarking');
  console.log(` Gateway: ${gateway}`);
  console.log(` Max number of users: ${maxNumUsers}`);
  console.log(` Duration to peak: ${duration}`);
  console.log('================================================================================');

  // Get login cookie
  const loginCookie = await getLoginCookie().then(
    (result) => { console.log(result); return result; });

  console.log(loginCookie);

  console.log('Connecting users');
  const sessions = await connect(gateway, maxNumUsers, duration, loginCookie);
  console.log('Verifying connections');
  await verify(sessions);
  console.log('Disconnecting users');
  await disconnect(sessions, duration);
  console.log('Done');
})();
