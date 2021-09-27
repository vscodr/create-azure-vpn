#Run the following command in Azure Cloud Shell to create the Azure-VNet-1 virtual network and the Services subnet.

az network vnet create \
    --resource-group learn-95c64d51-3b57-4da3-8b0c-c84b7ce80db7 \
    --name Azure-VNet-1 \
    --address-prefixes 10.0.0.0/16 \
    --subnet-name Services \
    --subnet-prefixes 10.0.0.0/24

    #Run the following command in Cloud Shell to add the GatewaySubnet subnet to Azure-VNet-1.

    az network vnet subnet create \
    --resource-group learn-95c64d51-3b57-4da3-8b0c-c84b7ce80db7 \
    --vnet-name Azure-VNet-1 \
    --address-prefixes 10.0.255.0/27 \
    --name GatewaySubnet

    #Run the following command in Cloud Shell to create the LNG-HQ-Network local network gateway.

    az network local-gateway create \
    --resource-group learn-95c64d51-3b57-4da3-8b0c-c84b7ce80db7 \
    --gateway-ip-address 94.0.252.160 \
    --name LNG-HQ-Network \
    --local-address-prefixes 172.16.0.0/16

    #This gateway represents the on-premises network that you're connecting to. 
    #The IP address specified as the remote gateway (which is the simulated on-premises network) will need to be updated later 
    #because it doesn't exist yet in our scenario.

    #Run the following command in Cloud Shell to create the HQ-Network virtual network and the Applications subnet.

    az network vnet create \
    --resource-group learn-95c64d51-3b57-4da3-8b0c-c84b7ce80db7 \
    --name HQ-Network \
    --address-prefixes 172.16.0.0/16 \
    --subnet-name Applications \
    --subnet-prefixes 172.16.0.0/24

    #Run the following command in Cloud Shell to add GatewaySubnet to HQ-Network.

    az network vnet subnet create \
    --resource-group learn-95c64d51-3b57-4da3-8b0c-c84b7ce80db7 \
    --address-prefixes 172.16.255.0/27 \
    --name GatewaySubnet \
    --vnet-name HQ-Network

    #Run the following command in Cloud Shell to create the LNG-Azure-VNet-1 local network gateway.

    az network local-gateway create \
    --resource-group learn-95c64d51-3b57-4da3-8b0c-c84b7ce80db7 \
    --gateway-ip-address 94.0.252.160 \
    --name LNG-Azure-VNet-1 \
    --local-address-prefixes 172.16.255.0/27

    # Verify the topology:
    
    az network vnet list --output table

    az network local-gateway list \
    --resource-group learn-95c64d51-3b57-4da3-8b0c-c84b7ce80db7 \
    --output table

    #Create the Azure-side VPN gateway

    #Run the following command in Cloud Shell to create the PIP-VNG-Azure-VNet-1 public IP address.

    az network public-ip create \
    --resource-group learn-95c64d51-3b57-4da3-8b0c-c84b7ce80db7 \
    --name PIP-VNG-Azure-VNet-1 \
    --allocation-method Dynamic

    #Run the following command in Cloud Shell to create the VNG-Azure-VNet-1 virtual network.

    az network vnet create \
    --resource-group learn-95c64d51-3b57-4da3-8b0c-c84b7ce80db7 \
    --name VNG-Azure-VNet-1 \
    --subnet-name GatewaySubnet

    #Run the following command in Cloud Shell to create the VNG-Azure-VNet-1 virtual network gateway.


    az network vnet-gateway create \
    --resource-group learn-95c64d51-3b57-4da3-8b0c-c84b7ce80db7 \
    --name VNG-Azure-VNet-1 \
    --public-ip-addresses PIP-VNG-Azure-VNet-1 \
    --vnet VNG-Azure-VNet-1 \
    --gateway-type Vpn \
    --vpn-type RouteBased \
    --sku VpnGw1 \
    --no-wait

    #Create the on-premises VPN gateway

    #Run the following command in Cloud Shell to create the PIP-VNG-HQ-Network public IP address.

    az network public-ip create \
    --resource-group learn-95c64d51-3b57-4da3-8b0c-c84b7ce80db7 \
    --name PIP-VNG-HQ-Network \
    --allocation-method Dynamic

    #Run the following command in Cloud Shell to create the VNG-HQ-Network virtual network.

    az network vnet create \
    --resource-group learn-95c64d51-3b57-4da3-8b0c-c84b7ce80db7 \
    --name VNG-HQ-Network \
    --subnet-name GatewaySubnet

    #Run the following command in Cloud Shell to create the VNG-HQ-Network virtual network gateway.

    az network vnet-gateway create \
    --resource-group learn-95c64d51-3b57-4da3-8b0c-c84b7ce80db7 \
    --name VNG-HQ-Network \
    --public-ip-addresses PIP-VNG-HQ-Network \
    --vnet VNG-HQ-Network \
    --gateway-type Vpn \
    --vpn-type RouteBased \
    --sku VpnGw1 \
    --no-wait
    

    #Gateway creation takes approximately 30+ minutes to complete. To monitor the progress of the gateway creation, run the following command. 
    #We're using the Linux watch command to run the az network vnet-gateway list command periodically, which enables you to monitor the progress.

    watch -d -n 5 az network vnet-gateway list \
    --resource-group learn-95c64d51-3b57-4da3-8b0c-c84b7ce80db7 \
    --output table

    #After each VPN gateway shows a ProvisioningState of Succeeded, you're ready to continue. Press Ctrl+C to halt the command after the gateway is created.


    #Update the local network gateway IP references

    #Run the following Azure CLI command to check whether both virtual network gateways have been created. 
    #The initial state will show Updating. You want to see Succeeded on both VNG-Azure-VNet-1 and VNG-HQ-Network.

    az network vnet-gateway list \
    --resource-group learn-95c64d51-3b57-4da3-8b0c-c84b7ce80db7 \
    --output table

    #Run the following command in Cloud Shell to retrieve the IPv4 address assigned to PIP-VNG-Azure-VNet-1 and store it in a variable.

    PIPVNGAZUREVNET1=$(az network public-ip show \
    --resource-group learn-95c64d51-3b57-4da3-8b0c-c84b7ce80db7 \
    --name PIP-VNG-Azure-VNet-1 \
    --query "[ipAddress]" \
    --output tsv)

    #Run the following command in Cloud Shell to retrieve the IPv4 address assigned to PIP-VNG-Azure-VNet-1 and store it in a variable.

    az network local-gateway update \
    --resource-group learn-95c64d51-3b57-4da3-8b0c-c84b7ce80db7 \
    --name LNG-Azure-VNet-1 \
    --gateway-ip-address $PIPVNGAZUREVNET1

    #Run the following command in Cloud Shell to retrieve the IPv4 address assigned to PIP-VNG-HQ-Network and store it in a variable.


    PIPVNGHQNETWORK=$(az network public-ip show \
    --resource-group learn-95c64d51-3b57-4da3-8b0c-c84b7ce80db7 \
    --name PIP-VNG-HQ-Network \
    --query "[ipAddress]" \
    --output tsv)

    #Run the following command in Cloud Shell to update the LNG-HQ-Network local network gateway so that it points to the public IP address attached to the VNG-HQ-Network virtual network gateway.

    az network local-gateway update \
    --resource-group learn-95c64d51-3b57-4da3-8b0c-c84b7ce80db7 \
    --name LNG-HQ-Network \
    --gateway-ip-address $PIPVNGHQNETWORK

    #Create the connections

    #Create the shared key to use for the connections. In the following command, replace <shared key> with a text string to use for the IPSec pre-shared key. The pre-shared key is a string of printable ASCII characters no longer than 128 characters. It cannot contain special characters, like hyphens and tildes. You'll use this pre-shared key on both connections.

    # In this example, any set of numbers will work for a shared key: SHAREDKEY=123456789. In production environments, we recommend using a string of printable ASCII characters no longer than 128 characters without special characters, like hyphens or tildes.


    SHAREDKEY=<shared key>

    # Remember that LNG-HQ-Network contains a reference to the IP address on your simulated on-premises VPN device. Run the following command in Cloud Shell to create a connection from VNG-Azure-VNet-1 to LNG-HQ-Network.

    az network vpn-connection create \
    --resource-group learn-95c64d51-3b57-4da3-8b0c-c84b7ce80db7 \
    --name Azure-VNet-1-To-HQ-Network \
    --vnet-gateway1 VNG-Azure-VNet-1 \
    --shared-key $SHAREDKEY \
    --local-gateway2 LNG-HQ-Network

    #Remember that LNG-Azure-VNet-1 contains a reference to the public IP address associated with the VNG-Azure-VNet-1 VPN gateway. This connection would normally be created from your on-premises device. Run the following command in Cloud Shell to create a connection from VNG-HQ-Network to LNG-Azure-VNet-1.

    az network vpn-connection create \
    --resource-group learn-95c64d51-3b57-4da3-8b0c-c84b7ce80db7 \
    --name HQ-Network-To-Azure-VNet-1  \
    --vnet-gateway1 VNG-HQ-Network \
    --shared-key $SHAREDKEY \
    --local-gateway2 LNG-Azure-VNet-1

    #Verification steps

    az network vpn-connection show \
    --resource-group learn-95c64d51-3b57-4da3-8b0c-c84b7ce80db7 \
    --name Azure-VNet-1-To-HQ-Network  \
    --output table \
    --query '{Name:name,ConnectionStatus:connectionStatus}'

    