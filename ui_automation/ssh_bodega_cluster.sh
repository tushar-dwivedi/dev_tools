#sd_dev_container_id=$(docker ps --format "{{.ID}}\t{{.Image}}\t{{.Names}}" | awk -F'\t' '/sd_dev_custom/ {print $1}' | awk 'NR==1')
#echo "sd_dev_container_id: $sd_dev_container_id"

~/Documents/projects/sdmain/devvm_scripts/common/bodega_order_details.sh

if [[ "$bodega_order_id" == "stress" || "$bodega_order_id" == "mds1" || "$bodega_order_id" == "mds2" ]]; then
	# export bodega_ips="10.0.115.130,10.0.115.131,10.0.115.132,10.0.115.133"
	# export bodega_ips='10.0.211.238,10.0.211.239,10.0.211.240,10.0.211.241,10.0.211.143,10.0.211.144,10.0.211.145,10.0.211.146'     # stress cluster (8 nodes)
	. ~/Documents/projects/sdmain/devvm_scripts/common/bodega_order_details.sh

else
	. /home/tushar/Documents/projects/dev_tools/ui_automation/common.sh
fi

#docker exec -it "$sd_dev_container_id" /home/ubuntu/Documents/projects/sdmain/lab/bin/bodega list orders
#echo "sd_dev_container_id: $sd_dev_container_id"
#echo "bodega_ips: $bodega_ips"

python3 /home/tushar/Documents/projects/dev_tools/ui_automation/ssh_bodega_clusters.py "$bodega_ips"
