This is a little toy set-up for monitoring DNS queries.

The service will tcpdump to a file watched by a path unit that activates a Go application reading and outputting it to a JSON file readable from the webroot.
