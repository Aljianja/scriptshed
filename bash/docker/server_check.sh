#!/bin/bash

# Detect Linux distribution
OS=$(awk -F= '/^NAME/{print $2}' /etc/os-release)

echo "Server Information Summary"
echo "========================="
echo ""

# List specific installed packages related to web development
echo "Installed Packages (Web Development Related):"
web_packages=("apache2" "httpd" "nginx" "mysql-server" "postgresql" "php" "python" "nodejs" "ruby" "java-1.8.0-openjdk" "java-11-openjdk" "tomcat" "php-fpm" "perl" "django" "flask" "rails" "express" "spring")

if [[ "$OS" =~ "Ubuntu" || "$OS" =~ "Debian" ]]; then
    for package in "${web_packages[@]}"; do
        dpkg -l | grep "$package"
    done
elif [[ "$OS" =~ "CentOS" || "$OS" =~ "Red Hat" || "$OS" =~ "Fedora" || "$OS" =~ "Amazon Linux" ]]; then
    for package in "${web_packages[@]}"; do
        rpm -qa | grep "$package"
    done
else
    echo "Unsupported OS for package listing"
fi
echo ""

# List running processes related to web development
echo "Running Processes (Web Development Related):"
web_processes=("apache2" "httpd" "nginx" "mysqld" "postgres" "php-fpm" "python" "node" "ruby" "java" "tomcat" "perl" "django" "flask" "rails" "express" "spring")
ps aux | grep -E "${web_processes[*]}" | grep -v grep
echo ""

# List active services related to web development
echo "Active Services (Web Development Related):"
systemctl list-units --type=service --state=running | grep -E "${web_processes[*]}"
echo ""

# Check open ports
echo "Open Ports:"
netstat -tuln
echo ""

# Check for available web servers and list websites
echo "Web Servers and Websites:"
web_servers=("apache2" "httpd" "nginx")
for server in "${web_servers[@]}"; do
    if command -v $server &> /dev/null; then
        echo "$server is installed."
        
        if [[ "$server" == "apache2" || "$server" == "httpd" ]]; then
            echo "Apache HTTPD Virtual Hosts:"
            apachectl -S 2>/dev/null || httpd -S 2>/dev/null
            echo ""
        elif [[ "$server" == "nginx" ]]; then
            echo "Nginx Configuration:"
            nginx -T 2>/dev/null
            echo ""
        fi
    else
        echo "$server is not installed."
    fi
done

# Docker containers
if command -v docker &> /dev/null; then
    echo "Docker Containers:"
    docker ps
    echo ""
fi

# Kubernetes pods
if command -v kubectl &> /dev/null; then
    echo "Kubernetes Pods:"
    kubectl get pods --all-namespaces
    echo ""
fi

echo "Summary report complete."
