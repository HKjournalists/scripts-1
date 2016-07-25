#!/bin/bash
# Increase system file descriptor limit
sudo sysctl -w fs.file-max=100000

# Discourage Linux from swapping idle processes to disk (default = 60)
#vm.swappiness = 10
#vm.dirty_ratio = 60
#vm.dirty_background_ratio = 2

# Increase Linux autotuning TCP buffer limits
# Set max to 16MB for 1GE and 32M (33554432) or 54M (56623104) for 10GE
# Don't set tcp_mem itself! Let the kernel scale it based on RAM.
sudo sysctl -w net.core.rmem_max=33554432
sudo sysctl -w net.core.wmem_max=33554432
sudo sysctl -w net.core.rmem_default=33554432
sudo sysctl -w net.core.wmem_default=33554432
sudo sysctl -w net.core.optmem_max=25165824
sudo sysctl -w net.ipv4.tcp_rmem="87380 16777216 33554432"
sudo sysctl -w net.ipv4.tcp_wmem="65536 16777216 33554432"

# Make room for more TIME_WAIT sockets due to more clients,
# and allow them to be reused if we run out of sockets
# Also increase the max packet backlog
sudo sysctl -w net.core.netdev_max_backlog=50000
sudo sysctl -w net.ipv4.tcp_max_syn_backlog=30000
sudo sysctl -w net.ipv4.tcp_max_tw_buckets=2000000
sudo sysctl -w net.ipv4.tcp_tw_reuse=1
sudo sysctl -w net.ipv4.tcp_fin_timeout=10
sudo sysctl -w net.ipv4.tcp_syncookies=1
sudo sysctl -w net.ipv4.tcp_synack_retries=3
sudo sysctl -w net.core.somaxconn=8096

# Increase ephermeral IP ports
sudo sysctl -w net.ipv4.ip_local_port_range="18000 65535"
#sudo sysctl -w net.ipv4.netfilter.ip_conntrack_tcp_timeout_time_wait=1

# Number of times SYNACKs for passive TCP connection.
sudo sysctl -w net.ipv4.tcp_synack_retries=2

# Disable TCP slow start on idle connections
sudo sysctl -w net.ipv4.tcp_slow_start_after_idle=0

# If your servers talk UDP, also up these limits
sudo sysctl -w net.ipv4.udp_rmem_min=8192
sudo sysctl -w net.ipv4.udp_wmem_min=8192

# Log packets with impossible addresses for security
sudo sysctl -w net.ipv4.conf.all.log_martians=1
