import request from 'request';
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
      console.log("sker det här+");
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
/*  
  //fixa request-promise och gör det i starten
  it.only('http test', (done) => {
    process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';
    const loginUrl = '/login/local/callback?username=admin&password=password';
    const fullUrl = 'https://' + getTestHost() + loginUrl;
    console.log(fullUrl);
    request(fullUrl, {followRedirect: false },
      (error, response, body) => {
        console.log(response.headers['custom-analytics']);
        console.log(response.headers['custom-analytics.sig']);
        console.log(response.headers['set-cookie']);
        console.log(response.headers);
        console.log('error:', error); // Print the error if one occurred
        console.log('statusCode:', response && response.statusCode); // Print the response status code if a response was received
        console.log('body:', body); // Print the HTML for the Google homepage.
        done();
      });
  });
 */
  it('and verify that the intended doc is opened', () => qixGlobal.getActiveDoc().then(app => app.getAppLayout().then((layout) => {
    expect(layout.qFileName).to.equal('/doc/drugcases.qvf');
  })));
});
