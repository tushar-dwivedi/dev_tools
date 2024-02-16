export sd_dev_container_id=$(docker ps --format "{{.ID}}\t{{.Image}}\t{{.Names}}" | awk -F'\t' '/sd_dev_custom/ {print $1}' | awk 'NR==1')

function get_bodega_details() {
    local choice
    local bodega_id

    list_orders_cmd="docker exec -it $sd_dev_container_id /home/tushar/Documents/projects/sdmain/lab/bin/bodega list orders"
    # Your command to get the output (replace with your actual command)
#    echo "list_orders_cmd: $list_orders_cmd" > /dev/stderr
    bodega_orders_details=$($list_orders_cmd)
    formatted_output=$(printf "bodega orders: \n%s" "$bodega_orders_details")

    echo "$formatted_output" > /dev/stderr
    echo "$bodega_orders_details" | awk 'NR>2 {print NR-2, $1}' > /dev/stderr

    # Prompt the user to choose an option
    read -p "Choose an option (1, 2, 3, etc.): " choice

    # Validate the user's input
    if [[ "$choice" =~ ^[0-9]+$ ]]; then
        # Get the selected "sid" value based on the user's choice
        # bodega_id=$($list_orders_cmd | awk -v choice="$choice" 'NR==choice+2 {print $1}')
        bodega_id=$(cat <<< "$bodega_orders_details" | awk -v choice="$choice" 'NR==choice+2 {print $1}')

        # Return the selected "sid"
        echo "$bodega_id"
    else
        echo "Invalid choice. Please enter a valid option (1, 2, 3, etc.)." > /dev/stderr
    fi
}

if [ -z "$1" ]; then
  echo "No bodega_order_id passed via cmd line, trying env-var"
  if [ -z "$bodega_order_id" ]; then
    echo "No bodega_order_id set in the env, let me fetch them for you..."
    bodega_order_id=$(get_bodega_details)
  else
    echo "bodega_order_id found in env as $bodega_order_id, using it."
  fi
else
  bodega_order_id=$1
  echo "bodega_order_id set passed in cmd-line as $bodega_order_id, using it."
fi

if [[ "$bodega_order_id" == "stress" ]]; then
        #export bodega_ips='10.0.115.130,10.0.115.131,10.0.115.132,10.0.115.133'        # stress cluster
        export bodega_ips='10.0.211.238,10.0.211.239,10.0.211.240,10.0.211.241,10.0.211.143,10.0.211.144,10.0.211.145,10.0.211.146'     # stress cluster (8 nodes)
	echo "bodega_ips: $bodega_ips"
	return
fi

echo "bodega_order_id: $bodega_order_id"
docker exec -it "$sd_dev_container_id" bash -c "/home/tushar/Documents/projects/sdmain/lab/bin/bodega consume order $bodega_order_id"  | grep -i 'ipv4:' | awk -F': ' '{print $2 }' > $HOME/ips.txt
#list_ips_cmd="docker exec -it $sd_dev_container_id bash -c \"/home/ubuntu/Documents/projects/sdmain/lab/bin/bodega consume order $bodega_order_id\"  | grep -i 'ipv4:' | awk -F': ' '{print $2 }' > $HOME/ips.txt"
#echo "list_ips_cmd: $list_ips_cmd" > /dev/stderr
#"$list_ips_cmd"

#exit 0

bodega_ips=$(cat "$HOME/ips.txt" | sed 's/\r/,/g')
export bodega_ips=${bodega_ips%,}

#echo "bodega_ips: $bodega_ips"

#bodega_id=$(get_bodega_details)
#echo "bodega_id:$bodega_id"
