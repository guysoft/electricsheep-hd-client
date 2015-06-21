# electricsheep-hd-client
[Wikipedia](https://en.wikipedia.org/wiki/Electric_sheep): 
`Electric Sheep is a distributed computing project for animating and evolving fractal flames, which are in turn distributed to the networked computers`

Originaly designed by http://www.electricsheep.org/ but rendered at low resolutions i am trying to bring the sheeps to the next generation of computer displays.
This is the early alpha of a client for an electric sheep ecosystem which renders frames in HD ( e.g. 720p, 1080p, 4k, 8k).
For a good example of what electric sheeps are see [this youtube vid](https://www.youtube.com/watch?v=vo8IC8sMXwQ)

## Roadmap
- System is fully operational but in an alpha state. So expect [bugs](https://github.com/kochd/electricsheep-hd-client/issues).
- Currently there is no frontend where you can you can see the overall rendering process by the community.
- GPU rendering with CUDA is planned but this need more investigation

## Getting started 
Theres might so be something more to get it running. If anything goes wrong let me know

### Debian / Ubuntu / ...
<pre>
git clone https://github.com/kochd/electricsheep-hd-client.git && cd electricsheep-hd-client
apt-get install flam3 ruby bundler
bundle install
./daemon
</pre>

If this results in `./daemon.rb:29:in <main>': You will need an api key. Please register at https://sheeps.triple6.org:9999/register (RuntimeError)` continue with [registration](https://github.com/kochd/electricsheep-hd-client#registration).

### Other Linux / Unix / Posix systems
Currently i dont know. Adept from [Debian / Ubuntu](https://github.com/kochd/electricsheep-hd-client/blob/master/README.md#debian--ubuntu--) and contribute back so others can learn from your wisdom.

### Windows 
My heard bleeds for you. Propably it can be done. If you want to get the client running on windows feel free to contact me.

## Registration
Register [here](https://sheeps.triple6.org:9999/register) and follow the instructions in the email.
The certificated is self-signed. You should be fine ignoring the warning and process to the page.  

## Usage
<pre>
Usage: daemon [OPTIONS]
        --server SERVER              Control server to connect to
        --apikey APIKEY              Your api key
        --debug                      Debug-mode
        --nice NICENESS              Niceness (Higher values result in lower process priority (default: 19, max: 19))
</pre>
