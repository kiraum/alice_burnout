# alice_burnout

The idea is to simulate a customer DOS/abusing the [Alice Looking Glass](https://github.com/alice-lg/alice-lg) service.

**Please, do not run it against Alice Looking Glass if you are not authorized!**

Running against all Route Servers:
```
% ./alice_burnout.sh https://lg.example.com
```

Running against specific Route Server (xpto-rs-v4 as example):
```
% ./alice_burnout.sh https://example.com xpto-rs-v4
```

This script was tested against some Alice Looking Glass, and the service crashed. **The tests were previously authorized.**

Yes, the source IP is only one, and easy to be blocked by the destination, but it's also easy to extend the script to work with multiple TOR sockets using multiple sources.

**=> We are not doing like that (and I don't plan to extend it), because the idea behind was to stress the service, and not generate DDoS against the service.**