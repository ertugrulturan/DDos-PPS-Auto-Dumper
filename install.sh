cat >> /var/ddos-pps.sh <<'EOF'
interface=eth0
echo "DDos PPS dumper started"
while /bin/true; do
  pkt_old=`grep $interface: /proc/net/dev | cut -d :  -f2 | awk '{ print $2 }'`
  sleep 1
  pkt_new=`grep $interface: /proc/net/dev | cut -d :  -f2 | awk '{ print $2 }'`

  pkt=$(( $pkt_new - $pkt_old ))
  if [ $pkt -gt 10000 ]; then
    tcpdump -n -i eth0 -s0 -c 1200 -w /var/logs/ddos.`date +"%Y-%m-%d--%H-%M-%S"`.pcap
    echo "Dumping"
  fi
done
EOF
cat >> /lib/systemd/system/ddos-pps.service <<'EOF'
[Unit]
Description=PPS Detector
After=multi-user.target
[Service]
ExecStart=/var/ddos-pps.sh
SyslogIdentifier=PPS-DUMP
Type=idle
Restart=always
RestartSec=15
RestartPreventExitStatus=0
[Install]
WantedBy=multi-user.target
EOF
chmod +x /var/ddos-pps.sh
systemctl enable ddos-pps
systemctl start ddos-pps
