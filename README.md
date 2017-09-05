# Starfi.re

## Manifesto
The goal with Starfire is to build an open community for mobile games, starting with Clash Royale. There are plenty of tools and websites out there trying to build something like this, but where I think this can be better is in that  developer-focused, transparent and open mindset. In sticking with being as transparent as possible, I have the client-side code publicly visible.  I'll eventually put the backend code on here once I have time to verify that I  don't have any passwords or keys in the git history.

### Backstory


### The "team"

Starfire currently consists of just me (Austin) right now, and I'd prefer to grow through your contributions. There is a developer platform where you can build your own tools on top of our data and userbase (millions of users) and keep 100% of your ad revenue.

---


#### Misc (mostly for me right now)
#### Dev SSL

Note that you need to specify full xip host (multi-level wildcards are not allowed)

```
sudo openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout ~/dev/starfire/bin/starfire-dev.key -out ~/dev/starfire/bin/starfire-dev.crt -reqexts v3_req -extensions v3_ca
```
```
Generating a 4096 bit RSA private key
...............................................................................................................................++
......................................++
writing new private key to '/home/austin/dev/starfire/bin/starfire-dev.key'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:US
State or Province Name (full name) [Some-State]:California
Locality Name (eg, city) []:San Francisco
Organization Name (eg, company) [Internet Widgits Pty Ltd]:Clay.io LLC
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []:192.168.0.109.xip.io
Email Address []:austin@clay.io
```

http://stackoverflow.com/questions/7580508/getting-chrome-to-accept-self-signed-localhost-certificate

For Android:
```
sudo openssl x509 -in ~/dev/starfire/bin/starfire-dev.crt -outform der -out ~/dev/starfire/bin/starfire-dev.der.crt
```

Copy starfire.der.crt to your phone, settings -> security -> install from storage -> select key

`USE_HTTPS=1 npm run dev`
