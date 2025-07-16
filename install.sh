# set root user password

$target = $1
$configfile = $2

ssh-keygen -f "/home/wayne/.ssh/known_hosts" -R $target


# copy ssh cert to server
ssh-copy-id root@$target

# Copy cofiguration file
scp ~/scripts/nixos/$configfile root@$target:/root/configuration.nix
scp ~/scripts/nixos/prepare.sh root@$target:/root

# prepare server
ssh root@$target 'bash /root/prepare.sh'
