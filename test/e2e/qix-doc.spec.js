import * as http from 'http';
import enigma from 'enigma.js';
import { getEnigmaBaseConfig, getTestHost } from '../utils/test-utils';

describe('QIX open doc in a swarm', () => {
  let qixGlobal;

  beforeEach(() => {
    const enigmaConfig = getEnigmaBaseConfig();

    enigmaConfig.session = {
      host: getTestHost(),
      route: '/doc/doc/drugcases.qvf',
    };

    return enigma.getService('qix', enigmaConfig).then((qix) => {
      qixGlobal = qix.global;
    }).catch((err) => {
      console.log(`error: ${err}`);
    });
  });

  afterEach(() => {
    qixGlobal.session.on('error', () => { });
    return qixGlobal.session.close().then(() => {
      qixGlobal = null;
    });
  });

  it('http test', () => {
    const loginUrl = '/login/local/callback?username=admin&password=passwor1d';
    http.get({
      host: getTestHost(),
      path: loginUrl,
    }, (response) => { expect(response.statusCode).to.equal(200); }).end();
  });

  it('and verify that the intended doc is opened', () => qixGlobal.getActiveDoc().then(app => app.getAppLayout().then((layout) => {
    expect(layout.qFileName).to.equal('/doc/drugcases.qvf');
  })));
});
