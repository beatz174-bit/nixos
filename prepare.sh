#create MBR table
parted /dev/sda -- mklabel msdos
#create nixos partition
parted /dev/sda -- mkpart primary 1MB -8GB
#set nixos partition to bootable
parted /dev/sda -- set 1 boot on
# create swap partition
parted /dev/sda -- mkpart primary linux-swap -8GB 100%

#format OS partition
mkfs.ext4 -L nixos /dev/sda1
#format swap
mkswap -L swap /dev/sda2

#activate swap
swapon /dev/sda2

#mount nixos partition
mount /dev/disk/by-label/nixos /mnt
export TMPDIR=/mnt/install-tmp
mkdir -p /mnt/install-tmp
#Generate config
#nixos-generate-config --root /mnt/

#copy customised configuration over
#cp configuration.nix /mnt/etc/nixos/configuration.nix

#nixos-install --no-root-passwd

#reboot