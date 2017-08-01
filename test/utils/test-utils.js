import enigmaMixin from 'halyard.js/dist/halyard-enigma-mixin';
import WebSocket from 'ws';
import fs from 'fs';
import qixSchema from '../node_modules/enigma.js/schemas/qix/3.2/schema.json';

function getSwarmManagerIP() {
  const managerName = `${process.env.USERNAME || process.env.USER}-docker-manager1`;
  const machineStoragePath = process.env.MACHINE_STORAGE_PATH || `${process.env.USERPROFILE || process.env.HOME}/.docker/machine/machines`;
  const config = JSON.parse(fs.readFileSync(`${machineStoragePath}/${managerName}/config.json`, 'utf8'));
  return config.Driver.IPAddress;
}

export function getEnigmaBaseConfig() {
  return {
    schema: qixSchema,
    mixins: enigmaMixin,
    createSocket: url => new WebSocket(url, { rejectUnauthorized: false, headers: { 'Set-Cookie': ['custom-analytics=26a5aedb-6a15-4103-b27e-61c3b61f29e0','custom-analytics.sig=RZSz-UHrkJrP_atrP4uG_2X0wow'] } }),
    listeners: {
      'notification:OnConnected': (params) => {
        console.log('OnConnected', params);
      },
    },
    handleLog: logRow => console.log(logRow),
  };
}

export function getTestHost() {
  return process.env.SWARM ? process.env.GATEWAY_IP_ADDR || getSwarmManagerIP() : 'localhost';
}
