#!/usr/bin/perl

# ip inicial
$inicio=1;
# ip final
$fim=253; 

$var=$inicio;
$var2=$inicio+1;

# porta udp inicial
$porta='7064';

# classe da vpn 
$class_vpn="11.0.1";
# classe que a vpn tera acesso dentro da empresa
$class_access="192.168.0.0";
# ip servidor vpn
$remote_host="200.204.0.10";

while ($var <= $fim ) {


# ARQUIVO DE CONF DO SERVIDOR
open(CONF, ">temporario${porta}.conf");
print CONF "
dev tun
ifconfig $class_vpn.$var $class_vpn.$var2
cd /etc/openvpn
secret temporario${porta}_key
port $porta 
user nobody
group nobody
comp-lzo
ping 15
verb 3
";
close(CONF);

system("openvpn --genkey --secret temporario${porta}_key");

# ARQUIVO DE CONF DO CLIENT
open(CONFC, ">cl_temporario${porta}.conf");
print CONFC "dev tun\r\nifconfig $class_vpn.$var2 $class_vpn.$var\r\nremote $remote_host\r\nport $porta\r\nsecret cl_temporario${porta}_key\r\ncomp-lzo\r\nverb 6\r\n";
close(CONFC);

open(KEY, "temporario${porta}_key");
open(CLKEY, ">cl_temporario${porta}_key"); 
while (<KEY>) {
s/\n/\r\n/g;
print CLKEY "$_";
}
close(KEY);
close(CLKEY);

open(ROTA, ">rota_$porta.bat");
print ROTA "route add $class_access mask 255.255.255.0 $class_vpn.$var metric 3\r\n"; 
close(ROTA);


	$var+=4;
	$var2=$var+1;
	++$porta;

}
