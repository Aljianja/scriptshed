.PHONY: all mysql mattermost nginx

all: mysql mattermost nginx

mysql:
	@echo "Setting up MySQL..."
	./mysql.sh

mattermost: mysql
	@echo "Setting up Mattermost..."
	./mattermost.sh

nginx: mattermost
	@echo "Setting up NGINX..."
	./nginx.sh