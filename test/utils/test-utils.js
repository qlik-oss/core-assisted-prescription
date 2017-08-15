import enigmaMixin from 'halyard.js/dist/halyard-enigma-mixin';
import request from 'request';
import WebSocket from 'ws';
import fs from 'fs';
import qixSchema from '../node_modules/enigma.js/schemas/qix/3.2/schema.json';

function getSwarmManagerIP() {
  const managerName = `${process.env.USERNAME || process.env.USER}-docker-manager1`;
  const machineStoragePath = process.env.MACHINE_STORAGE_PATH || `${process.env.USERPROFILE || process.env.HOME}/.docker/machine/machines`;
  const config = JSON.parse(fs.readFileSync(`${machineStoragePath}/${managerName}/config.json`, 'utf8'));
  return config.Driver.IPAddress;
}

export function getEnigmaBaseConfig(customAnalyticsCookie) {
  const headers = customAnalyticsCookie ? { Cookie: [customAnalyticsCookie] } : undefined;
  return {
    schema: qixSchema,
    mixins: enigmaMixin,
    createSocket: url => new WebSocket(url, { rejectUnauthorized: false, headers }),
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

export async function getLoginCookie() {
  return new Promise((resolve) => {
    process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';
    const loginUrl = '/login/local/callback?username=admin&password=password';
    const fullUrl = `https://${getTestHost()}${loginUrl}`;
    request(fullUrl, { followRedirect: false },
      (error, response) => resolve(response.headers['set-cookie'][0].split(';')[0]));
  });
}
