.PHONY: all set-env mysql mattermost nginx

all: set-env mysql mattermost nginx

set-env:
	@echo "Setting enviroment variables..."
	./env.sh

mysql:
	@echo "Setting up MySQL..."
	./mysql.sh

mattermost: mysql
	@echo "Setting up Mattermost..."
	./mattermost.sh

nginx: mattermost
	@echo "Setting up NGINX..."
	./nginx.sh