# 显卡自带usb驱动切换工具

## 简介

用于解决显卡直通时卸载显卡自带的USB控制器驱动并自动附加vfio-pci驱动带来的直通失败问题。某些显卡自带usb控制器，vfio-pci有可能接管失败，具体表现症状为virt-mannger启动带有pci-e设备直通的虚拟机启动失败，或者是启动很慢，关机失败等症状，解决问题的方法肯定不是直接把usb控制器驱动给ban了，这个ban了什么usb设备都不能用，所以需要手动卸载附加vfio-pci驱动。

理论上其他设备也可以通过类似原理解决

## 使用方法

1. 下载脚本

```bash
    # 运行脚本 check_driver.sh 查看自己的pci设备的具体信息
    # ! 在此之前请确保填写正确的pci设备,填写内容为显卡的pcie设备id,内容为GPU所在的iommu组,所有GPU设备的id都需要填写
    ./check_driver.sh
```

2. 使用modify_driver.sh附加vfio-pci驱动

```bash
    # 运行脚本 modify_driver.sh 附加vfio-pci驱动,运行时可以指定pcie设备id
    ./modify_driver.sh 10de:1ad8
    # 再次运行脚本 check_driver.sh 查看自己的pci设备的具体信息
    # 保证GPU的驱动已经切换为vfio-pci，没有被xhci_hcd占用
    # 音频控制器如果被snd_hda_intel占用问题不大，不影响直通
```
## 前置条件

- 已经开完成显卡直通
- vfio-pci驱动工作正常
- 显卡自带usb控制器
