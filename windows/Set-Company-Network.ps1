# Setup internet connection with modem in company intranet

# Windows10 use
# Set-NetIPInterface -InterfaceIndex "57" -InterfaceMetric "5"
# Set-NetIPInterface -InterfaceIndex "13" -InterfaceMetric "10"
# Set-NetIPInterface -InterfaceIndex "25" -InterfaceMetric "15"
# Get-NetIPInterface

# Route the intranet LAN IP to LAN Gateway
$company_gateway='160.68.161.254'
$company_network='160.0.0.0'
$company_mask='255.0.0.0'
$modem_gateway='192.168.8.1'
#private ip
route -p add 10.0.0.0 mask 255.0.0.0 $company_gateway
route -p add 172.16.0.0 mask 255.240.0.0 $company_gateway
route -p add 192.168.0.0 mask 255.255.0.0 $company_gateway
#company ip
route -p add $company_network mask $company_mask $company_gateway
#others
route -p add 0.0.0.0 mask 0.0.0.0 $modem_gateway
route print
# Renew all the network connection
ipconfig /renew
ipconfig /all