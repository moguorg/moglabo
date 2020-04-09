/**
 * @fileoverview Node練習用Webアプリケーション
 */

/* eslint-env node */

const http2 = require('http2');
const express = require('express');
const cookieParser = require('cookie-parser');
const cors = require('cors');
const bodyParser = require('body-parser');

const Certs = require('../../function/certs');
const config = require('../../config');
const MyEventLoop = require('./eventloop');
const MyCookie = require('./cookie');

const app = express();
// signed cookieを使用するにはsecret指定が必須
app.use(cookieParser('secret'));

// POSTリクエストのBODYを解析するために必要
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

const port = config.port.practicenode;

const contextName = 'webxam';
const contextRoot = `/${contextName}/apps/practicenode/`;

app.get(contextRoot, (request, response) => {
  response.send('Practice Node');
});

app.get(`${contextRoot}hello`, (request, response) => {
  console.log(`Query: ${request.query}`);
  response.send('Hello Node World');
});

app.get(`${contextRoot}eventloop/redos`, (request, response) => {
  const el = new MyEventLoop;
  response.send(el.redos(request));
});

app.get(`${contextRoot}eventloop/average`, async (request, response) => {
  const el = new MyEventLoop;
  response.send(await el.average(request));
});

app.get(`${contextRoot}cookie/echo`, async (request, response) => {
  const mc = new MyCookie({ request, response });
  response.send(JSON.stringify(mc.echo()));
});

const corsCheck = (request, callback) => {
  const origin = request.get('Origin');
  if (config.cors.whitelist.indexOf(origin) >= 0 || !origin) {
    callback(null, {
      origin: true,
      credentials: true,
      methods: ['GET', 'POST', 'HEAD'],
      allowedHeaders: ['Content-Type']
    });
  } else {
    callback(new Error('Invalid origin'), {
      origin: false
    });
  }
};

app.get(`${contextRoot}cookie/sampleuser`, cors(corsCheck),
  async (request, response) => {
    const mc = new MyCookie({ request, response });
    console.log(mc.echo());
    response.send(JSON.stringify(mc.sampleUser));
  });

app.post(`${contextRoot}cspreport`, (request, response) => {
  // TODO: CSPのレポートがリクエストから得られない。
  console.log(request.body);
  response.send(JSON.stringify({ status: 200 }));
});

const main = () => {
  Certs.getOptions().then(options => {
    http2.createSecureServer(options, app).listen(port);
    console.info(`My Practice Node Application On Port ${port}`);
  });
};

main();
