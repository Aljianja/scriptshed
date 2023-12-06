
#!/bin/bash
source ./.env

install_mysql() {
    # Install MySQL
    sudo apt-get update
    sudo apt-get install mysql-server


    sudo systemctl start mysql
    sudo systemctl enable mysql


    ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}


    MMUSER_PASSWORD=${MMUSER_PASSWORD}

    sudo mysql -u root -p$ROOT_PASSWORD <<EOF

    # Create Mattermost user and database
    CREATE USER 'mmuser'@'%' IDENTIFIED BY '$MMUSER_PASSWORD';
    CREATE DATABASE mattermost;

    # Grant privileges to the Mattermost user
    GRANT ALL PRIVILEGES ON mattermost.* TO 'mmuser'@'%';

    # Exit MySQL
    EXIT;
EOF
}

install_mattermost() {
    # Define the Mattermost version to install
    MATTERMOST_VERSION="9.2.3"

    # Download Mattermost Server tarball
    wget https://releases.mattermost.com/${MATTERMOST_VERSION}/mattermost-${MATTERMOST_VERSION}-linux-amd64.tar.gz

    # Extract the tarball
    tar -xvzf mattermost*.gz

    # Move Mattermost to the /opt directory
    sudo mv mattermost /opt

    # Create the storage folder for Mattermost
    sudo mkdir /opt/mattermost/data

    # Create a system user and group called 'mattermost'
    sudo useradd --system --user-group mattermost

    # Set the ownership and permissions
    sudo chown -R mattermost:mattermost /opt/mattermost
    sudo chmod -R g+w /opt/mattermost

    # Create a systemd unit file for Mattermost
    sudo bash -c 'cat <<EOF > /lib/systemd/system/mattermost.service
[Unit]
Description=Mattermost
After=network.target

[Service]
Type=notify
ExecStart=/opt/mattermost/bin/mattermost
TimeoutStartSec=3600
KillMode=mixed
Restart=always
RestartSec=10
WorkingDirectory=/opt/mattermost
User=mattermost
Group=mattermost
LimitNOFILE=49152

[Install]
WantedBy=multi-user.target
EOF'

    # Reload systemd to apply new unit file
    sudo systemctl daemon-reload

    # Start Mattermost server
    sudo systemctl start mattermost

    # Enable Mattermost server to start on boot
    sudo systemctl enable mattermost.service
}
