#!/bin/bash
#
# get_nic_number
function get_nic_number()
{
    lspci | egrep -i 'network|ethernet' | wc -l
}

# validate_input
function validate_char_input()
{
    local CHAR_INPUT=$1
    local VALIDATOR=$2
    local RESULT="fail"
    CHAR_INPUT=`printf $CHAR_INPUT | tr [A-Z] [a-z]`
    if [[ "${CHAR_INPUT}" = "${VALIDATOR}" ]]; then
        RESULT="pass"
    else
        RESULT="fail"
    fi
    printf ${RESULT}
}

# read_deploy_mode2
function read_deploy_mode2()
{
    local VALIDATE_RESULT="fail"
    while [ "${VALIDATE_RESULT}" = "fail" ]; do
        read DEPLOY_CHOICE
        DEPLOY_CHOICE=`printf $DEPLOY_CHOICE | tr [A-Z] [a-z]`
        
        if [[ "${DEPLOY_CHOICE}" = "allinone" ]]   ||   \
           [[ "${DEPLOY_CHOICE}" = "controller" ]] ||   \
           [[ "${DEPLOY_CHOICE}" = "compute" ]]; then
            VALIDATE_RESULT="pass"
        else
            VALIDATE_RESULT="fail"
            printf "%s\n" "Invalid input!"
            printf "%s\n" "Please input one of (allinone|controller|compute)"
        fi
    done
    eval "$1=${DEPLOY_CHOICE}"
}

# read_bool_choice2
function read_bool_choice2()
{
    local VALIDATE_RESULT="fail"
    while [ "${VALIDATE_RESULT}" = "fail" ]; do
        read BOOL_CHOICE
        BOOL_CHOICE=`printf $BOOL_CHOICE | tr [A-Z] [a-z]`
        BOOL_CHOICE=${BOOL_CHOICE:0:1}

        if [[ "${BOOL_CHOICE}" = "y" ]] || [[ "${BOOL_CHOICE}" = "n" ]]; then
            VALIDATE_RESULT="pass"
        else
            VALIDATE_RESULT="fail"
            printf "%s\n" "Invalid input!"
            printf "%s\n" "Please input (Y|y) or (N|n)"
        fi
    done
    eval "$1=${BOOL_CHOICE}"
}

# validate_ip_addr
function validate_ip_addr()
{
    local IP_ADDR=$1
    local RESULT="fail"
    if [[ $IP_ADDR =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        IP_ADDR=($IP_ADDR)
        IFS=$OIFS
        if [[ ${IP_ADDR[0]} -lt 255 && ${IP_ADDR[0]} -gt 0   \
           && ${IP_ADDR[1]} -lt 255 && ${IP_ADDR[1]} -ge 0   \
           && ${IP_ADDR[2]} -lt 255 && ${IP_ADDR[2]} -ge 0   \
           && ${IP_ADDR[3]} -lt 255 && ${IP_ADDR[3]} -gt 0 ]]; then
            RESULT="pass"
        else
            RESULT="fail"
        fi
    else
        RESULT="fail"
    fi
    printf ${RESULT}
}


# validate_mask
function validate_mask()
{
    local NET_MASK=$1
    local RESULT="fail"
    if [[ $NET_MASK =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        NET_MASK=($NET_MASK)
        IFS=$OIFS
        if [[ ${NET_MASK[0]} -eq 255  \
           && ${NET_MASK[1]} -le 255 && ${NET_MASK[1]} -ge 0  \
           && ${NET_MASK[2]} -le 255 && ${NET_MASK[2]} -ge 0  \
           && ${NET_MASK[3]} -lt 255 && ${NET_MASK[3]} -ge 0 ]]; then
            RESULT="pass"
        else
            RESULT="fail"
        fi
    else
        RESULT="fail"
    fi
    printf ${RESULT}
}

function validate_vlan_id()
{
    local VLAN_ID=$1
    local RESULT="fail"
    if [[ ${VLAN_ID} =~ ^[0-9]{1,4}$ \
       && ${VLAN_ID} -le 4094 && ${VLAN_ID} -gt 0 ]]; then
        RESULT="pass"
    else
        RESULT="fail"
    fi
    printf ${RESULT}
}

# read_bool_choice
function read_bool_choice()
{
    local VALIDATE_RESULT="fail"
    while [ "${VALIDATE_RESULT}" = "fail" ]; do
        read BOOL_CHOICE
        BOOL_CHOICE=`printf $BOOL_CHOICE | tr [A-Z] [a-z]`
        BOOL_CHOICE=${BOOL_CHOICE:0:1}
        local RESULT_Y=`validate_char_input "${BOOL_CHOICE}" "y"`
        local RESULT_N=`validate_char_input "${BOOL_CHOICE}" "n"`
        if [[ "${RESULT_Y}" = "pass" ]] || [[ "${RESULT_N}" = "pass" ]]; then
            VALIDATE_RESULT="pass"
        else
            VALIDATE_RESULT="fail"
            printf "%s\n" "Invalid input!"
            printf "%s\n" "Please input (Y|y) or (N|n)"
        fi
    done
    eval "$1=${BOOL_CHOICE}"
}

# read_deploy_mode
function read_deploy_mode()
{
    local VALIDATE_RESULT="fail"
    while [ "${VALIDATE_RESULT}" = "fail" ]; do
        read DEPLOY_CHOICE
        DEPLOY_CHOICE=`printf $DEPLOY_CHOICE | tr [A-Z] [a-z]`
        local RESULT_AIO=`validate_char_input "${DEPLOY_CHOICE}" "allinone"`
        local RESULT_CTR=`validate_char_input "${DEPLOY_CHOICE}" "controller"`
        local RESULT_COM=`validate_char_input "${DEPLOY_CHOICE}" "compute"`
        if [[ "${RESULT_AIO}" = "pass" ]] ||  \
           [[ "${RESULT_CTR}" = "pass" ]] ||  \
           [[ "${RESULT_COM}" = "pass" ]]; then
            VALIDATE_RESULT="pass"
        else
            VALIDATE_RESULT="fail"
            printf "%s\n" "Invalid input!"
            printf "%s\n" "Please input one of (allinone|controller|compute)"
        fi
    done
    eval "$1=${DEPLOY_CHOICE}"
}

# read_nic_port
function read_nic_port()
{
    local VALIDATE_RESULT="fail"
    while [ "${VALIDATE_RESULT}" = "fail" ]; do
        read NIC_PORT_NAME
        NIC_PORT_NAME=`printf ${NIC_PORT_NAME} | tr [A-Z] [a-z]`
        if [[ "${NIC_PORT_NAME:0:3}" = "eth" ]] &&     \
           [[ "${NIC_PORT_NAME:3}" =~ [0-9]{1,3} ]]; then
            VALIDATE_RESULT="pass"
        elif [[ "${NIC_PORT_NAME:0:2}" = "em" ]] &&    \
            [[ "${NIC_PORT_NAME:2}" =~ [0-9]{1,3} ]] ; then
            VALIDATE_RESULT="pass"
        else
            VALIDATE_RESULT="fail"
            printf "%s\n" "Invalid input!"
            printf "%s\n" "Please input again"
        fi
    done
    eval "$1=${NIC_PORT_NAME}"
}

# read_ip_addr
function read_ip_addr()
{
    local VALIDATE_RESULT="fail"
    while [ "${VALIDATE_RESULT}" = "fail" ]; do
        read IP_ADDR
        local RESULT=`validate_ip_addr "${IP_ADDR}"`
        if [[ "${RESULT}" = "pass" ]]; then
            VALIDATE_RESULT="pass"
        else
            VALIDATE_RESULT="fail"
            printf "%s\n" "Invalid input!"
            printf "%s\n" "Please input a valid IP address:"
        fi
    done
    eval "$1=${IP_ADDR}"
}

# read_net_mask
function read_net_mask()
{
    local VALIDATE_RESULT="fail"
    while [ "${VALIDATE_RESULT}" = "fail" ]; do
        read NET_MASK
        local RESULT=`validate_mask "${NET_MASK}"`
        if [[ "${RESULT}" = "pass" ]]; then
            VALIDATE_RESULT="pass"
        else
            VALIDATE_RESULT="fail"
            printf "%s\n" "Invalid input!"
            printf "%s\n" "Please input a subnet mask:"
        fi
    done
    eval "$1=${NET_MASK}"
}

# read_vlan_id
function read_vlan_id()
{
    local VALIDATE_RESULT="fail"
    while [ "${VALIDATE_RESULT}" = "fail" ]; do
        read VLAN_ID
        local RESULT=`validate_vlan_id "${VLAN_ID}"`
        if [[ "${RESULT}" = "pass" ]]; then
            VALIDATE_RESULT="pass"
        else
            VALIDATE_RESULT="fail"
            printf "%s\n" "Invalid input!"
            printf "%s\n" "Please input a valid VLAN ID (1~4094):"
        fi
    done
    eval "$1=${VLAN_ID}"
}

function read_mgmt_ip_info()
{
    printf "\t%s\n" "Input IP address for management network"
    MGMT_NET_IP=''
    read_ip_addr MGMT_NET_IP
    printf "\t%s\n" "Input subnet mask for management network"
    MGMT_NET_MASK=''
    read_net_mask MGMT_NET_MASK
}

function read_blk_ip_info()
{
    printf "\t%s\n" "Input IP address for block storage network"
    BLK_NET_IP=''
    read_ip_addr BLK_NET_IP
    printf "\t%s\n" "Input subnet mask for block storage network"
    BLK_NET_MASK=''
    read_net_mask BLK_NET_MASK
}

function read_tun_ip_info()
{
    printf "\t%s\n" "Input IP address for tenant network"
    TUN_NET_IP=''
    read_ip_addr TUN_NET_IP
    printf "\t%s\n" "Input subnet mask for tenant network"
    TUN_NET_MASK=''
    read_net_mask TUN_NET_MASK
}

function read_ext_ip_info()
{
    printf "\t%s\n" "Input IP address for external network"
    EXT_NET_IP=''
    read_ip_addr EXT_NET_IP
    printf "\t%s\n" "Input subnet mask for external network"
    EXT_NET_MASK=''
    read_net_mask EXT_NET_MASK
    printf "\t%s\n" "Input gateway for external network"
    EXT_NET_GW=''
    read_ip_addr EXT_NET_GW
    printf "\t%s\n" "Input DNS server for external network"
    EXT_NET_DNS=''
    read_ip_addr EXT_NET_DNS
}

# get nic numbers available on this server
printf "%s\n" "------------------------------------------------------------------------"
printf "%s\n" "|       Start to deploy OpenStack Kilo on Ubuntu Trusty                |"
printf "%s\n" "------------------------------------------------------------------------"
NIC_NUM=`get_nic_number`
FREE_NIC_NUM=${NIC_NUM}
printf "%s\n" "There are (${NIC_NUM}) physical NICs founded."
printf "%s\n" ""
printf "%s\n" "Logical name list reference:"
printf "\t%s\n" `ifquery --list -X lo`
printf "%s\n" ""
# suggest network topology based on the NIC_NUM

# choose deployment mode
printf "%s\n" "Choose node role: (allinone|controller|compute)"
NODE_ROLE_CHOICE=''
read_deploy_mode2 NODE_ROLE_CHOICE
NODE_ROLE="$NODE_ROLE_CHOICE"
printf "%s\n" "This node will be configured as (${NODE_ROLE})"
printf "%s\n" ""

#### for allinone role
if [[ "${NODE_ROLE}" = "allinone" ]]; then
    printf "%s\n" "Input FQDN for management network (like: kilo.openstack.local)"
    read CONTROLLER_MGMT_FQDN
    printf "%s\n" "Input FQDN for user access network (like: kilo.demo.com)"
    read CONTROLLER_EXT_FQDN
    ## Setting up management network
    printf "%s\n" "Setting up management network ..."
    printf "%s\n" ""
    if [[ "${FREE_NIC_NUM}" -lt '1' ]]; then
        # <1, error
        printf "%s\n" "Check the physical NICs!! only ${FREE_NIC_NUM} available."
        printf "%s\n" ""
        exit 1
    elif [[ "${FREE_NIC_NUM}" -gt '1' ]]; then
        # >1, bonding or not
        printf "\t%s\n" "(${FREE_NIC_NUM}) physical NICs free."
        printf "\t%s\n" "Use bonding for management network? (Y|N)"
        MGMT_BOND_CHOICE=''
        read_bool_choice MGMT_BOND_CHOICE
        if [[ "${MGMT_BOND_CHOICE}" = "y" ]]; then
            FREE_NIC_NUM=$((${FREE_NIC_NUM}-2))
            MGMT_BOND_NAME="bond-mgmt"
            printf "\t%s\n" "Input bonding 1st member of management bonding"
            printf "\t%s\n" ""
            MGMT_BOND_NIC1=''
            read_nic_port MGMT_BOND_NIC1
            printf "\t%s\n" "Input bonding 2nd member of management bonding"
            printf "\t%s\n" ""
            MGMT_BOND_NIC2=''
            read_nic_port MGMT_BOND_NIC2
        elif [[ "${MGMT_BOND_CHOICE}" = "n" ]]; then
            FREE_NIC_NUM=$((${FREE_NIC_NUM}-1))
            printf "\t%s\n" "Input mangement NIC port"
            printf "\t%s\n" ""
            MGMT_NIC_PORT=''
            read_nic_port MGMT_NIC_PORT
        else
            printf "\t%s\n" "Unkown error @ (${MGMT_BOND_CHOICE})"
            printf "\t%s\n" ""
            exit 1
        fi
    else
        # =1, use it
        printf "\t%s\n" "(${FREE_NIC_NUM}) physical NICs free."
        FREE_NIC_NUM=$((${FREE_NIC_NUM}-1))
        printf "\t%s\n" "Input mangement NIC port"
        MGMT_NIC_PORT=''
        read_nic_port MGMT_NIC_PORT
    fi
    # get ip info
    read_mgmt_ip_info
    
    ## Setting up block storage network
    printf "%s\n" "Setting up block storage network ..."
    printf "\t%s\n" "Block storage network will be combined with management network"
    
    ## Setting up tunnel network
    printf "%s\n" "Setting up tunnel network ..."
    printf "\t%s\n" "Tunnel network will be combined with management network"
    
    ## Setting up external network
    printf "%s\n" "Setting up external network ..."
    if [[ "${FREE_NIC_NUM}" -lt '1' ]]; then
        # < 1, use vlan interface
        printf "\t%s\n" "No physical NIC available, (${FREE_NIC_NUM}) NICs free."
        printf "\t%s\n" "Input VLAN ID for external network"
        # VLAN ID
        EXT_VLAN_ID=''
        read_vlan_id EXT_VLAN_ID
        #EXT_NIC_PORT=${MGMT_NIC_PORT}.${EXT_VLAN_ID}
        #EXT_NIC_PORT=${MGMT_BOND_NAME}.${EXT_VLAN_ID}
    elif [[ "${FREE_NIC_NUM}" -gt '1' ]]; then
        # >1, vlan interface or not
        printf "\t%s\n" "(${FREE_NIC_NUM}) physical NICs free."
        printf "\t%s\n" "Use vlan interface for external network? (Y|N)"
        # use vlan or not
        EXT_VLAN_CHOICE=''
        read_bool_choice EXT_VLAN_CHOICE
        if [[ "${EXT_VLAN_CHOICE}" = "y" ]]; then
            # VLAN ID
            EXT_VLAN_ID=''
            read_vlan_id EXT_VLAN_ID
            #EXT_NIC_PORT=${MGMT_NIC_PORT}.${EXT_VLAN_ID}
            #EXT_NIC_PORT=${MGMT_BOND_NAME}.${EXT_VLAN_ID}
        elif [[ "${EXT_VLAN_CHOICE}" = "n" ]]; then
            # >1, bonding or not
            printf "\t%s\n" "Use bonding for external network? (Y|N)"
            EXT_BOND_CHOICE=''
            read_bool_choice EXT_BOND_CHOICE
            if [[ "${EXT_BOND_CHOICE}" = "y" ]]; then
                FREE_NIC_NUM=$((${FREE_NIC_NUM}-2))
                EXT_BOND_NAME="bond-ext"
                printf "\t%s\n" "Input bonding 1st member of external bonding"
                printf "\t%s\n" ""
                EXT_BOND_NIC1=''
                read_nic_port EXT_BOND_NIC1
                printf "\t%s\n" "Input bonding 2nd member of external bonding"
                printf "\t%s\n" ""
                EXT_BOND_NIC2=''
                read_nic_port EXT_BOND_NIC2
            elif [[ "${EXT_BOND_CHOICE}" = "n" ]]; then
                FREE_NIC_NUM=$((${FREE_NIC_NUM}-1))
                printf "\t%s\n" "Input external NIC port"
                printf "\t%s\n" ""
                EXT_NIC_PORT=''
                read_nic_port EXT_NIC_PORT
            else
                printf "\t%s\n" "Unkown error @ (${EXT_BOND_CHOICE})"
                printf "\t%s\n" ""
                exit 1
            fi
        else
            printf "\t%s\n" "Unkown error @ (${EXT_VLAN_CHOICE})"
            printf "\t%s\n" ""
            exit 1
        fi
    else
        # =1, vlan interface or not
        printf "\t%s\n" "(${FREE_NIC_NUM}) physical NICs free."
        printf "\t%s\n" "Use vlan interface for block storage network? (Y|N)"
        # use vlan or not
        EXT_VLAN_CHOICE=''
        read_bool_choice EXT_VLAN_CHOICE
        if [[ "${EXT_VLAN_CHOICE}" = "y" ]]; then
            # VLAN ID
            EXT_VLAN_ID=''
            read_vlan_id EXT_VLAN_ID
            #EXT_NIC_PORT=${MGMT_NIC_PORT}.${EXT_VLAN_ID}
            #EXT_NIC_PORT=${MGMT_BOND_NAME}.${EXT_VLAN_ID}
        elif [[ "${EXT_VLAN_CHOICE}" = "n" ]]; then
            FREE_NIC_NUM=$((${FREE_NIC_NUM}-1))
            printf "\t%s\n" "Input external NIC port"
            EXT_NIC_PORT=''
            read_nic_port EXT_NIC_PORT
        else 
            printf "\t%s\n" "Unkown error @ (${EXT_VLAN_CHOICE})"
            printf "\t%s\n" ""
            exit 1
        fi
    fi
    # get ip info
    read_ext_ip_info
    
    printf "%s\n" "Admin password for horizon"
    read ADMIN_PWD
    
#### for controller role
elif [[ "${NODE_ROLE}" = "controller" ]]; then
    printf "%s\n" "Input FQDN for management network (like: kilo.openstack.local)"
    read CONTROLLER_MGMT_FQDN
    printf "%s\n" "Input FQDN for user access network (like: kilo.demo.com)"
    read CONTROLLER_EXT_FQDN
    ## Setting up management network
    printf "%s\n" "Setting up management network ..."
    printf "%s\n" ""
    if [[ "${FREE_NIC_NUM}" -lt '1' ]]; then
        # <1, error
        printf "%s\n" "Check the physical NICs!! only ${FREE_NIC_NUM} available."
        printf "%s\n" ""
        exit 1
    elif [[ "${FREE_NIC_NUM}" -gt '1' ]]; then
        # >1, bonding or not
        printf "\t%s\n" "(${FREE_NIC_NUM}) physical NICs free."
        printf "\t%s\n" "Use bonding for management network? (Y|N)"
        MGMT_BOND_CHOICE=''
        read_bool_choice MGMT_BOND_CHOICE
        if [[ "${MGMT_BOND_CHOICE}" = "y" ]]; then
            FREE_NIC_NUM=$((${FREE_NIC_NUM}-2))
            MGMT_BOND_NAME="bond-mgmt"
            printf "\t%s\n" "Input bonding 1st member of management bonding"
            printf "\t%s\n" ""
            MGMT_BOND_NIC1=''
            read_nic_port MGMT_BOND_NIC1
            printf "\t%s\n" "Input bonding 2nd member of management bonding"
            printf "\t%s\n" ""
            MGMT_BOND_NIC2=''
            read_nic_port MGMT_BOND_NIC2
        elif [[ "${MGMT_BOND_CHOICE}" = "n" ]]; then
            FREE_NIC_NUM=$((${FREE_NIC_NUM}-1))
            printf "\t%s\n" "Input mangement NIC port"
            printf "\t%s\n" ""
            MGMT_NIC_PORT=''
            read_nic_port MGMT_NIC_PORT
        else
            printf "\t%s\n" "Unkown error @ (${MGMT_BOND_CHOICE})"
            printf "\t%s\n" ""
            exit 1
        fi
    else
        # =1, use it
        printf "\t%s\n" "(${FREE_NIC_NUM}) physical NICs free."
        FREE_NIC_NUM=$((${FREE_NIC_NUM}-1))
        printf "\t%s\n" "Input mangement NIC port"
        MGMT_NIC_PORT=''
        read_nic_port MGMT_NIC_PORT
    fi
    # get ip info
    read_mgmt_ip_info
    
    ## Setting up block storage network
    printf "%s\n" "Setting up block storage network ..."
    # use separate block storage network or not?
    printf "\t%s\n" "Use separate block storage network? (Y|N)"
    BLK_SEP_CHOICE=''
    read_bool_choice BLK_SEP_CHOICE
    if [[ "${BLK_SEP_CHOICE}" = "y" ]]; then
        if [[ "${FREE_NIC_NUM}" -lt '1' ]]; then
            # < 1, use vlan interface
            printf "\t%s\n" "No physical NIC available, (${FREE_NIC_NUM}) NICs free."
            printf "\t%s\n" "Input VLAN ID for block storage network."
            # VLAN ID
            BLK_VLAN_ID=''
            read_vlan_id BLK_VLAN_ID
            #BLK_NIC_PORT=${MGMT_NIC_PORT}.${BLK_VLAN_ID}
            #BLK_NIC_PORT=${MGMT_BOND_NAME}.${BLK_VLAN_ID}
        elif [[ "${FREE_NIC_NUM}" -gt '1' ]]; then
            # >1, vlan interface or not
            printf "\t%s\n" "(${FREE_NIC_NUM}) physical NICs free."
            printf "\t%s\n" "Use vlan interface for block storage network? (Y|N)"
            # use vlan or not
            BLK_VLAN_CHOICE=''
            read_bool_choice BLK_VLAN_CHOICE
            if [[ "${BLK_VLAN_CHOICE}" = "y" ]]; then
                # VLAN ID
                BLK_VLAN_ID=''
                read_vlan_id BLK_VLAN_ID
                #BLK_NIC_PORT=${MGMT_NIC_PORT}.${BLK_VLAN_ID}
                #BLK_NIC_PORT=${MGMT_BOND_NAME}.${BLK_VLAN_ID}
            elif [[ "${BLK_VLAN_CHOICE}" = "n" ]]; then
                # >1, bonding or not
                printf "\t%s\n" "Use bonding for block storage network? (Y|N)"
                BLK_BOND_CHOICE=''
                read_bool_choice BLK_BOND_CHOICE
                if [[ "${BLK_BOND_CHOICE}" = "y" ]]; then
                    FREE_NIC_NUM=$((${FREE_NIC_NUM}-2))
                    BLK_BOND_NAME="bond-ext"
                    printf "\t%s\n" "Input bonding 1st member of block storage bonding"
                    printf "\t%s\n" ""
                    BLK_BOND_NIC1=''
                    read_nic_port BLK_BOND_NIC1
                    printf "\t%s\n" "Input bonding 2nd member of block storage bonding"
                    printf "\t%s\n" ""
                    BLK_BOND_NIC2=''
                    read_nic_port BLK_BOND_NIC2
                elif [[ "${BLK_BOND_CHOICE}" = "n" ]]; then
                    FREE_NIC_NUM=$((${FREE_NIC_NUM}-1))
                    printf "\t%s\n" "Input block storage NIC port"
                    printf "\t%s\n" ""
                    BLK_NIC_PORT=''
                    read_nic_port BLK_NIC_PORT
                else
                    printf "\t%s\n" "Unkown error @ (${BLK_BOND_CHOICE})"
                    printf "\t%s\n" ""
                    exit 1
                fi
            else
                printf "\t%s\n" "Unkown error @ (${BLK_VLAN_CHOICE})"
                printf "\t%s\n" ""
                exit 1
            fi
        else
            # =1, use it
            printf "\t%s\n" "(${FREE_NIC_NUM}) physical NICs free."
            FREE_NIC_NUM=$((${FREE_NIC_NUM}-1))
            printf "\t%s\n" "Input block storage NIC port"
            BLK_NIC_PORT=''
            read_nic_port BLK_NIC_PORT
        fi
        # get ip info
        read_blk_ip_info
    elif [[ "${BLK_SEP_CHOICE}" = "n" ]]; then
        printf "\t%s\n" "Block storage network will be combined with management network"
        printf "\t%s\n" ""
    else
        printf "%s\n" "unknown error caused by (${BLK_SEP_CHOICE})"
        printf "\t%s\n" ""
        exit 1
    fi
    
    ## Setting up tunnel network
    printf "%s\n" "Setting up tunnel network ..."
    # use separate tunnel network or not?
    printf "\t%s\n" "Use separate tunnel network? (Y|N)"
    TUN_SEP_CHOICE=''
    read_bool_choice TUN_SEP_CHOICE
    if [[ "${TUN_SEP_CHOICE}" = "y" ]]; then
        if [[ "${FREE_NIC_NUM}" -lt '1' ]]; then
            # < 1, use vlan interface
            printf "\t%s\n" "No physical NIC available, (${FREE_NIC_NUM}) NICs free."
            printf "\t%s\n" "Input VLAN ID for tunnel network."
            # VLAN ID
            TUN_VLAN_ID=''
            read_vlan_id TUN_VLAN_ID
            #TUN_NIC_PORT=${MGMT_NIC_PORT}.${TUN_VLAN_ID}
            #TUN_NIC_PORT=${MGMT_BOND_NAME}.${TUN_VLAN_ID}
        elif [[ "${FREE_NIC_NUM}" -gt '1' ]]; then
            # >1, vlan interface or not
            printf "\t%s\n" "(${FREE_NIC_NUM}) physical NICs free."
            printf "\t%s\n" "Use vlan interface for tunnel network? (Y|N)"
            # use vlan or not
            TUN_VLAN_CHOICE=''
            read_bool_choice TUN_VLAN_CHOICE
            if [[ "${TUN_VLAN_CHOICE}" = "y" ]]; then
                # VLAN ID
                TUN_VLAN_ID=''
                read_vlan_id TUN_VLAN_ID
                #TUN_NIC_PORT=${MGMT_NIC_PORT}.${TUN_VLAN_ID}
                #TUN_NIC_PORT=${MGMT_BOND_NAME}.${TUN_VLAN_ID}
            elif [[ "${TUN_VLAN_CHOICE}" = "n" ]]; then
                # >1, bonding or not
                printf "\t%s\n" "Use bonding for tunnelnetwork? (Y|N)"
                TUN_BOND_CHOICE=''
                read_bool_choice TUN_BOND_CHOICE
                if [[ "${TUN_BOND_CHOICE}" = "y" ]]; then
                    FREE_NIC_NUM=$((${FREE_NIC_NUM}-2))
                    TUN_BOND_NAME="bond-ext"
                    printf "\t%s\n" "Input bonding 1st member of tunnel bonding"
                    printf "\t%s\n" ""
                    TUN_BOND_NIC1=''
                    read_nic_port TUN_BOND_NIC1
                    printf "\t%s\n" "Input bonding 2nd member of tunnel bonding"
                    printf "\t%s\n" ""
                    TUN_BOND_NIC2=''
                    read_nic_port TUN_BOND_NIC2
                elif [[ "${TUN_BOND_CHOICE}" = "n" ]]; then
                    FREE_NIC_NUM=$((${FREE_NIC_NUM}-1))
                    printf "\t%s\n" "Input tunnel NIC port"
                    printf "\t%s\n" ""
                    TUN_NIC_PORT=''
                    read_nic_port TUN_NIC_PORT
                else
                    printf "\t%s\n" "Unkown error @ (${TUN_BOND_CHOICE})"
                    printf "\t%s\n" ""
                    exit 1
                fi
            else
                printf "\t%s\n" "Unkown error @ (${TUN_VLAN_CHOICE})"
                printf "\t%s\n" ""
                exit 1
            fi
        else
            # =1, use it
            printf "\t%s\n" "(${FREE_NIC_NUM}) physical NICs free."
            FREE_NIC_NUM=$((${FREE_NIC_NUM}-1))
            printf "\t%s\n" "Input tunnel NIC port"
            TUN_NIC_PORT=''
            read_nic_port TUN_NIC_PORT
        fi
        # get ip info
        read_tun_ip_info
    elif [[ "${TUN_SEP_CHOICE}" = "n" ]]; then
        printf "\t%s\n" "tunnel network will be combined with management network"
        printf "\t%s\n" ""
    else
        printf "%s\n" "unknown error caused by (${TUN_SEP_CHOICE})"
        printf "\t%s\n" ""
        exit 1
    fi
    
    ## Setting up external network
    printf "%s\n" "Setting up external network ..."
    if [[ "${FREE_NIC_NUM}" -lt '1' ]]; then
        # < 1, use vlan interface
        printf "\t%s\n" "No physical NIC available, (${FREE_NIC_NUM}) NICs free."
        printf "\t%s\n" "Input VLAN ID for external network"
        # VLAN ID
        EXT_VLAN_ID=''
        read_vlan_id EXT_VLAN_ID
    elif [[ "${FREE_NIC_NUM}" -gt '1' ]]; then
        # >1, vlan interface or not
        printf "\t%s\n" "(${FREE_NIC_NUM}) physical NICs free."
        printf "\t%s\n" "Use vlan interface for external network? (Y|N)"
        # use vlan or not
        EXT_VLAN_CHOICE=''
        read_bool_choice EXT_VLAN_CHOICE
        if [[ "${EXT_VLAN_CHOICE}" = "y" ]]; then
            # VLAN ID
            EXT_VLAN_ID=''
            read_vlan_id EXT_VLAN_ID
            #EXT_NIC_PORT=${MGMT_NIC_PORT}.${EXT_VLAN_ID}
            #EXT_NIC_PORT=${MGMT_BOND_NAME}.${EXT_VLAN_ID}
        elif [[ "${EXT_VLAN_CHOICE}" = "n" ]]; then
            # >1, bonding or not
            printf "\t%s\n" "Use bonding for external network? (Y|N)"
            EXT_BOND_CHOICE=''
            read_bool_choice EXT_BOND_CHOICE
            if [[ "${EXT_BOND_CHOICE}" = "y" ]]; then
                FREE_NIC_NUM=$((${FREE_NIC_NUM}-2))
                EXT_BOND_NAME="bond-ext"
                printf "\t%s\n" "Input bonding 1st member of external bonding"
                printf "\t%s\n" ""
                EXT_BOND_NIC1=''
                read_nic_port EXT_BOND_NIC1
                printf "\t%s\n" "Input bonding 2nd member of external bonding"
                printf "\t%s\n" ""
                EXT_BOND_NIC2=''
                read_nic_port EXT_BOND_NIC2
            elif [[ "${EXT_BOND_CHOICE}" = "n" ]]; then
                FREE_NIC_NUM=$((${FREE_NIC_NUM}-1))
                printf "\t%s\n" "Input external NIC port"
                printf "\t%s\n" ""
                EXT_NIC_PORT=''
                read_nic_port EXT_NIC_PORT
            else
                printf "\t%s\n" "Unkown error @ (${EXT_BOND_CHOICE})"
                printf "\t%s\n" ""
                exit 1
            fi
        else
            printf "\t%s\n" "Unkown error @ (${EXT_VLAN_CHOICE})"
            printf "\t%s\n" ""
            exit 1
        fi
    else
        # =1, vlan interface or not
        printf "\t%s\n" "(${FREE_NIC_NUM}) physical NICs free."
        printf "\t%s\n" "Use vlan interface for block storage network? (Y|N)"
        # use vlan or not
        EXT_VLAN_CHOICE=''
        read_bool_choice EXT_VLAN_CHOICE
        if [[ "${EXT_VLAN_CHOICE}" = "y" ]]; then
            # VLAN ID
            EXT_VLAN_ID=''
            read_vlan_id EXT_VLAN_ID
            #EXT_NIC_PORT=${MGMT_NIC_PORT}.${EXT_VLAN_ID}
            #EXT_NIC_PORT=${MGMT_BOND_NAME}.${EXT_VLAN_ID}
        elif [[ "${EXT_VLAN_CHOICE}" = "n" ]]; then
            FREE_NIC_NUM=$((${FREE_NIC_NUM}-1))
            printf "\t%s\n" "Input external NIC port"
            EXT_NIC_PORT=''
            read_nic_port EXT_NIC_PORT
        else 
            printf "\t%s\n" "Unkown error @ (${EXT_VLAN_CHOICE})"
            printf "\t%s\n" ""
            exit 1
        fi
    fi
    read_ext_ip_info
    
    
    printf "%s\n" "Admin password for horizon"
    read ADMIN_PWD
    
#### for compute role
elif [[ "${NODE_ROLE}" = "compute" ]]; then
    printf "%s\n" "Input controller FQDN for management network (like: controller.openstack.local)"
    read COMPT_MGMT_FQDN
    printf "%s\n" "Input controller FQDN for user access network (like: controller.demo.com)"
    read COMPT_EXT_FQDN
    printf "%s\n" "Input hostname for management network (like: compute-0)"
    read COMPT_HOSTNAME

    
    # check controller node configurations, then create necessary configurations
else
    printf "%s\n" "unknown error caused by (${NODE_ROLE})"
    printf "\t%s\n" ""
    exit 1
fi

printf "%s\n" "Are you sure, to apply above configurations? (Y|N)"
FINAL_CONFIRM=''
read_bool_choice FINAL_CONFIRM
if [[ "${FINAL_CONFIRM}" = "y" ]]; then
    printf "%s\n" "Start to generate conf files"
    # generate the system.conf
    # generate the cloud-passwords.conf
    printf "%s\n" "Start to run the configuration"
    # run setup-system.sh
    printf "%s\n" "finished."
elif [[ "${FINAL_CONFIRM}" = "n" ]]; then
    printf "%s\n" "Start to generate conf files"
    # generate the system.conf
    # generate the cloud-passwords.conf
    # exit
    printf "%s\n" "cancelled, but conf file generated."
else
    printf "%s\n" "unknown error caused by (${FINAL_CONFIRM})"
    printf "\t%s\n" ""
    exit 1
fi

printf "%s\n" "Finished here"
exit 0
