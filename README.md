# Fake IM
This example, by [Phil Callister](http://github.com/philcallister), is an example client/server application that demonstrates an Elixir
Instant Messenger. It makes no attempt to follow standards, such as XMPP.

## Environment

The sample was developed using the following 

- Elixir 1.2.4
- OS X El Capitan (10.11)

## Setup

Clone Repo
```bash
git clone https://github.com/philcallister/elixir-fake-im.git
```

## Run It

Start the server

```bash
mix elixir_fake_im.server
OR
iex -S mix
```

Start a telnet client

```bash
telnet localhost 10408
login:phil
group:subscribe:group1
```

Start another telnet client

```bash
telnet localhost 10408
login:amy
user:phil:HELLO
group:subscribe:group1
```

One more telnet client

```bash
telnet localhost 10408
login:nick
group:subscribe:group1
group:group1:HELLO GROUP1!!
logout
```

## License

[MIT License](http://www.opensource.org/licenses/MIT)

**Free Software, Hell Yeah!**