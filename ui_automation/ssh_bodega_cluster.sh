#sd_dev_container_id=$(docker ps --format "{{.ID}}\t{{.Image}}\t{{.Names}}" | awk -F'\t' '/sd_dev_custom/ {print $1}' | awk 'NR==1')
#echo "sd_dev_container_id: $sd_dev_container_id"

if [[ "$bodega_order_id" == "stress" ]]; then
	export bodega_ips="10.0.115.130,10.0.115.131,10.0.115.132,10.0.115.133"
else
	. /home/tushar/Documents/projects/dev_tools/ui_automation/common.sh
fi

#docker exec -it "$sd_dev_container_id" /home/ubuntu/Documents/projects/sdmain/lab/bin/bodega list orders
#echo "sd_dev_container_id: $sd_dev_container_id"



#echo "bodega_ips: $bodega_ips"

python3 /home/tushar/Documents/projects/dev_tools/ui_automation/ssh_bodega_clusters.py "$bodega_ips"
