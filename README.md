# Starfi.re

## Manifesto
The goal with Starfire is to build an open community for mobile gamers. Communities exist, but they don't cater to gamers. Reddit is the best option for a forum, Discord is the best option for chat, but for the most part, they are just generic solutions. Starfire can be better with a developer-focused, transparent and open mindset.

In sticking with being as transparent as possible, I have the client-side code publicly visible.  I'll eventually put the backend code on here once I have time to verify that I  don't have any passwords or keys in the git history.

### Backstory
Starfire is an offshoot from a company I started, Clay.io. It was an HTML5 game platform I started 5 years ago. I raised half a million dollars from angel investors and moved out to Silicon Valley to try to grow it. While I loved the bay area, I got really sick of the Silicon Valley culture. There's far too much greed, hype, and arrogance.

Now I'm back in Austin, TX and set out to build something in a much different way from the typical Silicon Valley company. I want to help build something that's open, transparent and ego-less.

The first step toward that is having all of the code be public.

### Transparent, but still a business
I am still very much a believer in capitalism, so all of this 'open and transparent' doesn't mean we can go on without a business model. Money is still incredibly important for both the company's long-term growth, and for people who develop apps for the Starfire platform. The difference is, the business model will be transparent - no selling user data, etc... The current revenue source is advertisements, but this is something I'd like to change soon.

### Users
Most Starfire users couldn't care less that we are open and transparent... What they care about is having a quality community and tools for Clash Royale.

### The "team"

Starfire currently consists of just me (Austin) right now, and I'd prefer to grow through your contributions. There is a developer platform where you can build your own tools on top of our data and userbase (millions of users) and keep 100% of your ad revenue.

- Build the best community for mobile gamers
- Empower developers to build better tools and make more money
- Be transparent and fair


## Misc (mostly for me right now)
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
