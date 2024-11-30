#!/bin/zsh

#https://ubuntu.com/download/raspberry-pi
IMAGE_URL='https://cdimage.ubuntu.com/releases/24.04.1/release/ubuntu-24.04.1-preinstalled-server-arm64+raspi.img.xz'
IMAGE_CHECKSUM='e59925e211080b20f02e4504bb2c8336b122d0738668491986ee29a95610e5b1'
IMAGE_FILENAME='ubuntu-24.04.1-preinstalled-server-arm64+raspi.img.xz'
UBUNTU_BOOT_DIR='/Volumes/system-boot/'

download() {
    if [ ! -f ${IMAGE_FILENAME} ]; then
        curl -C - --output ${IMAGE_FILENAME} ${IMAGE_URL}
    fi
}

checksum() {
    echo "${IMAGE_CHECKSUM} ${IMAGE_FILENAME}" | sha256sum -c
    
    if [ $? != 0 ]; then
        exit 1
    fi
}

cloud_init() {

cat <<'EOF' | sudo tee ${UBUNTU_BOOT_DIR}/user-data
#cloud-config
#package_update: true
#package_upgrade: true
#package_reboot_if_required: true
preserve_hostname: true
timezone: Asia/Yekaterinburg
ssh_pwauth: false
users:
  - name: pi
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC5t04rsb+FXfuHGSKfU0odf/eEacU0mEJodQNINamdRPZGayXCwEDGWptIVi4bY+QLVj0eqBfHdJIfd1+/BkF7HwPqlKtqrSKJrRKGDZnZgzYkQA2KLBM4hSc0S+H+hwiOz1fZpX96Za8u83WpmNO9PbyQkbWk64QfDeMMI1pwZ7G93tEfNSAIfEaYHRg+t8GihEsuj2fz+pL+hXJsYlsk36dBrJ0zV4fQwwDBJfdHbKZZKh3f7vGTnL0XZggS3ca+m1H1t2EWDh5IR8c1RR/y+illnxqRrRgzgVg5aXnm0XXAKRChbneHwH6fyfTyMiiUe0BvVolaVaDYsl7B08VKDx00VSnkQ9/5oolv+uNj8UtZBhSO5QjXzoGA2taQNmZrf2/dycJlbZmLKseF9594VwiOhhAoboI7PrZvH5rm43Mjd7jXvHTmoUr4LNMMWtV1PJGHuZkCBHMXlaTa6ebWaQaSPCfJvhYdV5icve8KG7zJlf49RxzG1sTFM5jcqos= 3ng1n33r@MacBook-Air.local
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAc57ug+MUP26V3NQUAeY3RDIv2H9kmiNU5lvdNzv36a 3ng1n33r@MacBook-Air.local
write_files:
  - path: /boot/firmware/config.txt
    content: |
      dtoverlay=disable-wifi
      dtoverlay=disable-bt
    append: true
runcmd:
  - hostnamectl set-hostname ip-$(ip -br a show dev 'eth0' | awk '{print $3}' | cut -d/ -f1 | sed 's/[.]/-/g')
EOF

cat <<'EOF' | sudo tee ${UBUNTU_BOOT_DIR}/network-config
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      dhcp6: false
      addresses:
        - 192.168.31.20/24
      gateway4: 192.168.31.1
      nameservers:
        addresses: [1.1.1.1, 8.8.8.8]
EOF
}

read "ANSWER?Do you want to burn the image ${IMAGE_FILENAME} to an sd card. Press [Y,y] to continue: "
if [[ "$ANSWER" =~ ^[Yy]$ ]]; then
    echo "Preparing an image."
    download
    checksum

    echo "Showing the list of disks in the system."
    diskutil list

    read "DISK_NAME?Please specify the path to the sd card. For example /dev/disk4: "
    diskutil unmountDisk ${DISK_NAME}
    
    echo "Copying the image to sd card ${DISK_NAME} can take a long time. Be patient!"
    sudo sh -c "gunzip -c ${IMAGE_FILENAME} | sudo dd of=${DISK_NAME} bs=32m"
    
    sleep 5
fi

read "ANSWER?Do you want to copy cloud-init files to sd card? Press [Y,y] to continue: "
if [[ "$ANSWER" =~ ^[Yy]$ ]]; then
    
    if [ -d ${UBUNTU_BOOT_DIR} ]; then
        cloud_init
    else
        echo "The directory ${UBUNTU_BOOT_DIR} does not exist. Please check that the sd card is present."
    fi  
fi