如果Nvidia GPU被 intel 音频驱动占用不需要卸载
```bash
 snd_hda_intel
```

如果Nvidia GPU usb控制器相关部分被xhci_hcd 驱动程序占用
则需要手动卸载xhci_hcd然后附加vfio-pci驱动程序
```bash
xhci_hcd
```
