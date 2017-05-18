import Halyard from 'halyard.js';
import enigma from 'enigma.js';
import { getEnigmaBaseConfig, getSwarmHost } from './test-utils'

describe('QIX open doc in a swarm', () => {

  let qixGlobal;

  let enigmaConfig = getEnigmaBaseConfig();

  enigmaConfig.session = {
    host: getSwarmHost(),
    secure: false,
    route: '/doc/doc/drugcases.qvf',
  }

  before(() => {
    return enigma.getService('qix', enigmaConfig).then((qix) => {
      qixGlobal = qix.global;
    }).catch((err) => {
      console.log("error" + err);
    });
  });

  after(() => {
    qixGlobal.session.on('error', () => { });
    return qixGlobal.session.close().then(() => qixGlobal = null);
  });

  it('and verify that the intended doc is opened', () => {
    return qixGlobal.getActiveDoc().then((app) => {
      return app.getAppLayout().then((layout) => {
        expect(layout.qFileName).to.equal('/doc/drugcases.qvf');
      })
    });
  });
});
