iptables -t filter -P INPUT DROP  
iptables -t filter -P OUTPUT ACCEPT 
iptables -t filter -P FORWARD ACCEPT 

iptables -t filter -A INPUT -i lo -j ACCEPT

