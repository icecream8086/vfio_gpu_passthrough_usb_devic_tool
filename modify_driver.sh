# sudo echo 0000:01:00.2 > /sys/bus/pci/drivers/xhci_hcd/unbind
# sudo echo 0000:01:00.2 > /sys/bus/pci/drivers/vfio-pci/bind
#!/bin/bash

# 检查是否传入了PCI设备ID
if [ -z "$1" ]; then
  echo "请提供PCI设备ID作为参数。"
  exit 1
fi

PCI_DEVICE_ID=$1

# 获取PCIE地址
PCIE_ADDRESS=$(lspci -nn | grep "$PCI_DEVICE_ID" | awk '{print $1}')

if [ -z "$PCIE_ADDRESS" ]; then
  echo "未找到PCI设备ID为$PCI_DEVICE_ID的设备。"
  exit 1
fi

# 检查设备是否使用xhci_hcd驱动
DRIVER=$(readlink /sys/bus/pci/devices/0000:$PCIE_ADDRESS/driver)

if [[ "$DRIVER" != *"xhci_hcd"* ]]; then
  echo "设备$PCIE_ADDRESS未使用xhci_hcd驱动。"
  exit 1
fi

# 卸载xhci_hcd驱动并绑定vfio-pci驱动
sudo sh -c "echo 0000:$PCIE_ADDRESS > /sys/bus/pci/drivers/xhci_hcd/unbind"
sudo sh -c "echo 0000:$PCIE_ADDRESS > /sys/bus/pci/drivers/vfio-pci/bind"

echo "成功将设备$PCIE_ADDRESS从xhci_hcd驱动切换到vfio-pci驱动。"