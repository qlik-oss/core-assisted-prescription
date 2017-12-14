const enigmaMixin = require('halyard.js/dist/halyard-enigma-mixin');
const request = require('request');
const WebSocket = require('ws');
const fs = require('fs');
const qixSchema = require('enigma.js/schemas/12.20.0.json');

function getSwarmManagerIP() {
  const managerName = `${process.env.USERNAME || process.env.USER}-docker-manager1`;
  const machineStoragePath = process.env.MACHINE_STORAGE_PATH || `${process.env.USERPROFILE || process.env.HOME}/.docker/machine/machines`;
  const config = JSON.parse(fs.readFileSync(`${machineStoragePath}/${managerName}/config.json`, 'utf8'));
  return config.Driver.IPAddress;
}

function getTestHost() {
  return process.env.SWARM ? process.env.GATEWAY_IP_ADDR || getSwarmManagerIP() : 'localhost';
}

export function getEnigmaBaseConfig(customAnalyticsCookie, route) {
  const headers = customAnalyticsCookie ? {
    Cookie: [customAnalyticsCookie],
  } : undefined;
  return {
    schema: qixSchema,
    mixins: enigmaMixin,
    url: `https://${getTestHost()}${route}`,
    createSocket(url) {
      return new WebSocket(url, {
        rejectUnauthorized: false,
        headers,
      });
    },
    listeners: {
      'notification:OnConnected': (params) => {
        console.log('OnConnected', params);
      },
    },

    handleLog: logRow => console.log(logRow),
  };
}

export async function getLoginCookie() {
  return new Promise((resolve) => {
    process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';
    const loginUrl = '/login/local/callback?username=admin&password=password';
    const fullUrl = `https://${getTestHost()}${loginUrl}`;
    request(fullUrl, { followRedirect: false }, (error, response) => resolve(response.headers['set-cookie'][0].split(';')[0]));
  });
}
