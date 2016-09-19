# Zorium Seed

[![zorium](./src/static/images/zorium_icon_256.png)](https://zorium.org)


[![Sauce Test Status](https://saucelabs.com/browser-matrix/Zolmeister.svg)](https://saucelabs.com/u/Zolmeister)

This project provides the base [Zorium](https://zorium.org) setup, following all current best practices.  

## Dev

Run live-updating webpack dev-server

  - `npm run demo-api`
  - `npm run dev`
    - `http://127.0.0.1:3000`


## Production
Environment variable are dynamically injected at runtime (for running in Docker)

  - `npm run dist`
  - `npm start`

```bash
npm run dist
docker build -t zorium-seed .

docker run \
    --restart always \
    -p 3000:3000 \
    -e PORT=3000 \
    --name zorium-seed \
    -d \
    -t zorium-seed
```

## Testing

  - `npm test`
    - real-browser karma tests
    - server/client unit tests
    - code coverage
  - `npm run test-functional`
    - see functional tests (multi-browser) below
  - `npm run watch`
    - auto-run client unit tests
  - `npm run watch -- phantom`
    - auto-run karma tests
  - `npm run watch -- server`
    - auto-run server tests
  - `npm run watch -- functional`
    - see functional tests (watch) below

#### functional tests - watch
```bash
# Before starting, make sure dev server is running and depending on public network ips
# npm run demo-api
# WEBPACK_DEV_PORT=3006 \
#   WEBPACK_DEV_URL=http://192.168.1.100:3006 \
#   PRIVATE_API_URL=http://192.168.1.100:3005 \
#   API_URL=http://192.168.1.100:3005 \
#   npm run dev
# SELENIUM_TARGET_URL (note 127.0.0.1 won't work because connections come from a Docker instance)
export SELENIUM_TARGET_URL=http://192.168.1.100:3000
npm run watch-functional
```

#### functional tests - multi-browser

```bash
# Start local sauce tunnel in order to use all sauce-hosted selenium server
export SAUCE_USERNAME=$SAUCE_USERNAME
export SAUCE_ACCESS_KEY=$SAUCE_ACCESS_KEY
npm run sauce-tunnel
```

```bash
# Before starting, make sure dev server is running and depending on public network ips
# npm run demo-api
# WEBPACK_DEV_PORT=3006 \
#   WEBPACK_DEV_URL=http://192.168.1.100:3006 \
#   PRIVATE_API_URL=http://192.168.1.100:3005 \
#   API_URL=http://192.168.1.100:3005 \
#   npm run dev
export SAUCE_USERNAME=$SAUCE_USERNAME
export SAUCE_ACCESS_KEY=$SAUCE_ACCESS_KEY
# SELENIUM_TARGET_URL (note 127.0.0.1 won't work because connections come from a remote host)
export SELENIUM_TARGET_URL=http://192.168.1.100:3000
npm run test-functional
```
