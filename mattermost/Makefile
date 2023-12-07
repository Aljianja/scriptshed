.PHONY: all mysql-setup mattermost-setup nginx-setup

all: mysql-setup mattermost-setup nginx-setup

mysql-setup:
	@echo "Setting up MySQL..."
	./mysql-setup.sh

mattermost-setup: mysql-setup
	@echo "Setting up Mattermost..."
	./mattermost-setup.sh

nginx-setup: mattermost-setup
	@echo "Setting up NGINX..."
	./nginx-setup.sh