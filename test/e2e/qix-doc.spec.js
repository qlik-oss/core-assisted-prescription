import enigma from 'enigma.js';
import { getEnigmaBaseConfig, getTestHost } from './test-utils';

describe('QIX open doc in a swarm', () => {
  let qixGlobal;

  beforeEach(() => {
    const enigmaConfig = getEnigmaBaseConfig();

    enigmaConfig.session = {
      host: getTestHost(),
      secure: false,
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
