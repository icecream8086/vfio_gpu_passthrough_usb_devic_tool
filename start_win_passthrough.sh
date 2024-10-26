./remove_invalid_pcie.sh win_passthrough
./modify_driver.sh 10de:1ad8
./assign_device.sh win_passthrough 0de:1e84
./assign_device.sh win_passthrough 10de:10f8
./assign_device.sh win_passthrough 10de:1ad9
./assign_device.sh win_passthrough 10de:1ad8
./assign_ssd_device.sh
