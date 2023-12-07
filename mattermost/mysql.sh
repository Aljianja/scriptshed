#!/bin/bash

source ./all-env.sh

# Install MySQL
sudo apt-get install mysql-server
sudo mysql_secure_installation

# Set up MySQL database and user
sudo mysql -u root -e "CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
sudo mysql -u root -e "CREATE DATABASE ${MYSQL_DATABASE};"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"


ssh-rsaAAAAB3NzaC1yc2EAAAADAQABAAABgQC502RHICEafS8eAfpkijiajUNK1Dfv5i/Dpd9TVOMT4YNuv+/uxpqC+NT70Vc7GfENubx+iinGcb+gncVno6rUPLEumH473DCXYEZhx+WWFPN3fundMbR/81UI/FvhqIhaionihRujsJcgJmRHXob2wyXTKtCr2gNcpjq1W89c3US1L7vCgaGPm+3SZJxrgKnIcORA1qzT9IRO5SHKLOGDJYPA65EXiEaidstKBJL+4M8vcqNUbUqsaqmQnKK4v1m+vKXiIgAg8h8+1G1TG4IjQ7qBQ3T2KPvh/f803iEtC2Li8aukahN+KOQYU4SnfgmflyqbOR/UgBT/Te87Sn1GHKSJXPMSrEOhw76sBToc9ngwM8RHJVyi1vNf4SdSCSKNKYw+mvmSbf4B1Knxa10V4iI13sVAiE2ZrJB+fLBvzJR4mhV5t8jAcXbM001EBKFB12v9A7u9LZVAOv9gfRGq5s1/bdfu8ZJXSZ313YLUy3aDHmd/11XxH212spV8F10=osboxes@osboxes