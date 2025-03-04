git:
	ssh jupiter -p 23231

jupiter:
	ssh jupiter

purge-mac-dns-cache:
	sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder

restart:
	sudo shutdown -r now

fatrack4:
	ssh cade.rosche@172.25.4.1

save-appsettings:
	docker cp gsw-sdk:/opt/york/ground-software/Bastion/appsettings.overrides.json /opt/york/appsettings.overrides.json

