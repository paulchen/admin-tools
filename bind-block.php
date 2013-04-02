<?php
$blacklist_domains = array('deniedstresser.com', 'isc.org', 'ripe.net');
$whitelist_ips = array('::1', '5.9.110.236', '2a01:4f8:162:51e2::2', '78.47.148.174', '2001:4dd0:ff00:6aa::2', '91.143.83.62', '127.0.0.1', '91.143.93.242');

$already_blocked = '';
$already_blocked2 = '';
exec('iptables-save|grep "\-A INPUT -s [0-9\.]*/32 -j DROP"|sed -e "s/-A INPUT -s //g;s/\/32 -j DROP//g"|sort|uniq', $already_blocked);
exec('iptables-save|grep "\-A INPUT -s [0-9\.]*/32 -p udp -m udp --dport 53 -j DROP"|sed -e "s/-A INPUT -s //g;s/\/32 .* -j DROP//g"|sort|uniq', $already_blocked2);
foreach($already_blocked2 as $ip) {
	if(!in_array($ip, $already_blocked)) {
		$already_blocked[] = $ip;
	}
}

$malicious_ips = array();
foreach($blacklist_domains as $domain) {
	$output = '';
	exec('grep ' . $domain . ' /var/log/bind9/query.log|sed -e "s/.*client //g;s/#.*$//g"|sort|uniq', $output);
	foreach($output as $ip) {
		if(!in_array($ip, $malicious_ips) && !in_array($ip, $already_blocked) && !in_array($ip, $whitelist_ips)) {
			$malicious_ips[] = $ip;
		}
	}
}

if(count($malicious_ips) > 0) {
	foreach($malicious_ips as $ip) {
		exec("iptables -A INPUT -s $ip -p udp -m udp --dport 53 -j DROP", $output);
	}
	exec("iptables-save > /etc/iptables.conf");

	$file = fopen('/root/bind-block-log', 'a');
	echo "IPs added to blacklist:\n";
	foreach($malicious_ips as $ip) {
		echo " * $ip\n";
		fwrite($file, date('Y-m-d H:i') . " - added IP: $ip\n");
	}
	fclose($file);
}

