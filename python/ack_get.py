# Change log level to suppress annoying IPv6 error
import logging

logging.getLogger("scapy.runtime").setLevel(logging.ERROR)

# Import scapy
from scapy.all import *

# Print info header
print "[*] ACK-GET example"

# Prepare GET statement
get = 'GET / HTTP/1.0\r\n'

# Set up target IP
ip = IP(dst="www.runoob.com")

# Generate random source port number
port = RandNum(1024, 65535)

# Create SYN packet
SYN = ip / TCP(sport=port, dport=80, flags="S", seq=42)

# Send SYN and receive SYN,ACK
print "\n[*] Sending SYN packet"
SYNACK = sr1(SYN)

# Create ACK with GET request
ACK = ip / TCP(sport=SYNACK.dport, dport=80, flags="A", seq=SYNACK.ack, ack=SYNACK.seq + 1) / get

# SEND our ACK-GET request
print "\n[*] Sending ACK-GET packet"
reply, error = sr(ACK)

# print reply from server
print "\n[*] Reply from server:"
print reply.show()

print '\n[*] Done!'
