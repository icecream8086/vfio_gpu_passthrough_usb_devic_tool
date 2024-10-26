#!/bin/bash

# 检查参数数量
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <vm_name>"
    exit 1
fi

VM_NAME=$1

# 检查 virsh 命令是否存在
if ! command -v virsh &> /dev/null; then
    echo "virsh command not found. Please install libvirt."
    exit 1
fi

# 获取虚拟机的 XML 配置文件
VM_XML=$(virsh dumpxml $VM_NAME)
if [ $? -ne 0 ]; then
    echo "Failed to get XML configuration for VM $VM_NAME"
    exit 1
fi

# 创建临时文件保存修改后的 XML 配置
TMP_FILE=$(mktemp)

# 查找并移除所有无效的 PCIe 设备条目
echo "$VM_XML" | xmllint --format - | sed '/<hostdev mode=.subsystem. type=.pci. managed=.yes.>/,/<\/hostdev>/d' > $TMP_FILE

# 更新虚拟机的配置文件
virsh define $TMP_FILE
if [ $? -ne 0 ]; then
    echo "Failed to update XML configuration for VM $VM_NAME"
    rm -f $TMP_FILE
    exit 1
fi

rm -f $TMP_FILE
echo "Removed all invalid PCIe addresses from VM $VM_NAME."
