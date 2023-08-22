export IPADDR="192.168.1.2/24"
export IPGATE="192.168.1.254"
export DEV=wlan0


## up if
ip link set ${DEV} up 

## add
ip addr add ${IPADDR} dev ${DEV} 
ip route add default via ${IPGATE} dev ${DEV}

## del
ip addr del ${IPADDR} dev ${DEV} 

ip route del default via ${IPGATE} dev ${DEV}

## down if
ip link set ${DEV} down


