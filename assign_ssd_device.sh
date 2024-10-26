HARDWARE_ID="126f:2262"
VM_NAME="win_passthrough"

PCI_DEVICES=$(lspci -nn | grep "$HARDWARE_ID" | awk '{print $1}')

if [ -z "$PCI_DEVICES" ]; then
    echo "No devices found with hardware ID $HARDWARE_ID"
    exit 1
fi

# 检查虚拟机是否关机
VM_STATE=$(virsh domstate $VM_NAME 2>&1)
if [[ "$VM_STATE" != "shut off" && "$VM_STATE" != "关闭" ]]; then
    echo "VM $VM_NAME is not shut off. Please shut down the VM before assigning devices."
    exit 1
fi

assign_device() {
    local PCI_DEVICE=$1
    echo "Assigning device $PCI_DEVICE to VM $VM_NAME..."

    TMP_FILE=$(mktemp)
    cat <<EOF > $TMP_FILE
<hostdev mode='subsystem' type='pci' managed='yes'>
  <source>
    <address domain='0x0000' bus='0x${PCI_DEVICE:0:2}' slot='0x${PCI_DEVICE:3:2}' function='0x${PCI_DEVICE:6:1}'/>
  </source>
</hostdev>
EOF

    sudo virsh attach-device $VM_NAME --file $TMP_FILE --config
    if [ $? -ne 0 ]; then
        echo "Failed to attach device $PCI_DEVICE to VM $VM_NAME"
        rm -f $TMP_FILE
        exit 1
    fi

    rm -f $TMP_FILE
    echo "Device $PCI_DEVICE assigned to VM $VM_NAME."
}

for PCI_DEVICE in $PCI_DEVICES; do
    # 确认设备已经被 vfio-pci 接管
    DRIVER=$(lspci -k -s $PCI_DEVICE | grep 'Kernel driver in use' | awk '{print $5}')
    if [ "$DRIVER" != "vfio-pci" ]; then
        echo "Device $PCI_DEVICE is not managed by vfio-pci"
        exit 1
    fi

    assign_device $PCI_DEVICE
done
