git:
	ssh jupiter -p 23231

jupiter:
	ssh jupiter

purge-mac-dns-cache:
	sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
