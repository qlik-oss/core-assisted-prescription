import * as http from 'http';
import enigma from 'enigma.js';
import { getEnigmaBaseConfig, getTestHost } from '../utils/test-utils';

describe('QIX open doc in a swarm', () => {
  let qixGlobal;

  beforeEach(() => {
    let loginUrl = '/login/local/callback?username=admin&password=password';
    http.get({ host: getTestHost(), path: loginUrl }, (response) => { console.log(response.statusCode); }).end();

    loginUrl = '/login/local/callback?username=admin&password=pas1sword';
    http.get({ host: getTestHost(), path: loginUrl }, (response) => { console.log(response.statusCode); }).end();

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

  it('and verify that the intended doc is opened', () => qixGlobal.getActiveDoc().then(app => app.getAppLayout().then((layout) => {
    expect(layout.qFileName).to.equal('/doc/drugcases.qvf');
  })));
});
