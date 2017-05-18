import Halyard from 'halyard.js';
import enigma from 'enigma.js';
import getEnigmaConfig from './test-utils'

describe('QIX open doc in a swarm', () => {

  let qixGlobal;

  let enigmaConf = {
    schema: qixSchema,
    session: {
      host: process.env.SWARMMANAGER || (process.env.USERNAME || process.env.USER) + '-docker-manager1',
      secure: false,
      route: '/doc/doc/drugcases.qvf',
    },
    mixins: enigmaMixin,
    identity: generateGUID(),
    createSocket: url => new WebSocket(url),
    listeners: {
      'notification:OnConnected': (params) => {
        console.log('OnConnected', params);
      },
    },
    handleLog: logRow => console.log(logRow),
  };

  before(() => {
    return enigma.getService('qix', enigmaConf).then((qix) => {
      console.log('Connection established');
      qixGlobal = qix.global;
      return qixGlobal.getActiveDoc().then((app) => {
        sessionApp = app;
      });
    }).catch((err) => {
      console.log("error" + err);
    });
  });

  after(() => {
    qixGlobal.session.on('error', () => { });
    return qixGlobal.session.close().then(() => qixGlobal = null);
  });

  it('get engine component version', () => {
    return qixGlobal.engineVersion().then((resp) => {
      expect(resp.qComponentVersion).to.match(/^(\d+\.)?(\d+\.)?(\*|\d+)$/);
    });
  });

  it('verify that a session app is opened', () => {
    return sessionApp.getAppLayout().then((layout) => {
      expect(layout.qTitle).to.match(/SessionApp_[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i) // title should be 'SessionApp_<GUID>'
    })
  });
});


