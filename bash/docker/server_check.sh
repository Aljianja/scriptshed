#!/bin/bash

# Detect Linux distribution
OS=$(awk -F= '/^NAME/{print $2}' /etc/os-release)

echo ""
echo "========================="
echo "Server Information Summary"
echo "========================="
echo ""

# List specific installed packages related to web development
echo "Installed Packages (Web Development Related):"
echo "========================="
echo ""
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
echo "========================="
echo ""
web_processes=("apache2" "httpd" "nginx" "mysqld" "postgres" "php-fpm" "python" "node" "ruby" "java" "tomcat" "perl" "django" "flask" "rails" "express" "spring")
ps aux | grep -E "$(IFS=\|; echo "${web_processes[*]}")" | grep -v grep
echo ""

# List active services related to web development
echo "Active Services (Web Development Related):"
echo "========================="
echo ""
systemctl list-units --type=service --state=running | grep -E "$(IFS=\|; echo "${web_processes[*]}")"
echo ""

# Check open ports using netstat, ss, or lsof
echo "Open Ports:"
echo "========================="
echo ""
if command -v netstat &> /dev/null; then
    netstat -tuln
elif command -v ss &> /dev/null; then
    ss -tuln
elif command -v lsof &> /dev/null; then
    lsof -i -P -n | grep LISTEN
else
    echo "Neither netstat, ss, nor lsof is installed."
fi
echo ""

# Check if web-related services are listening on ports
echo "Web-Related Services Listening on Ports:"
echo "========================="
echo ""
for process in "${web_processes[@]}"; do
    if command -v netstat &> /dev/null; then
        netstat -tuln | grep $process
    elif command -v ss &> /dev/null; then
        ss -tuln | grep $process
    elif command -v lsof &> /dev/null; then
        lsof -i -P -n | grep LISTEN | grep $process
    fi
done
echo ""

# Check for available web servers and list websites
echo "Web Servers and Websites:"
echo "========================="
echo ""
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

# Check for running Node.js applications managed by pm2
if command -v pm2 &> /dev/null; then
    echo "Node.js Applications Managed by pm2:"
    pm2 list
    echo ""
fi

# Check for running applications managed by supervisor
if command -v supervisorctl &> /dev/null; then
    echo "Applications Managed by supervisor:"
    supervisorctl status
    echo ""
fi

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

# Check ports used by specific processes using lsof and fuser
echo "Ports Used by Specific Processes:"
echo "========================="
echo ""
for process in "${web_processes[@]}"; do
    pid=$(pgrep -f $process)
    if [[ -n $pid ]]; then
        echo "Process: $process (PID: $pid)"
        if command -v lsof &> /dev/null; then
            ports=$(lsof -Pan -p $pid -iTCP -sTCP:LISTEN)
            if [[ -n $ports ]]; then
                echo "$ports"
            else
                echo "No ports found for $process (PID: $pid)"
            fi
        elif command -v fuser &> /dev/null; then
            ports=$(fuser -v -n tcp -n udp -p $pid 2>&1 | grep -v "no such file")
            if [[ -n $ports ]]; then
                echo "$ports"
            else
                echo "No ports found for $process (PID: $pid)"
            fi
        else
            echo "Neither lsof nor fuser is installed."
        fi
        echo ""
    else
        echo "Process $process is not running."
    fi
done

echo "Summary report complete."
