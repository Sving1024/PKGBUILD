# Ignore "." and ".." to prevent errors when glob pattern for assets matches hidden files
GLOBIGNORE=".:.."

ssh_keyscan_types='rsa,ecdsa,ed25519'

echo '::group::Adding aur.archlinux.org to known hosts'
ssh-keyscan -v -t "$ssh_keyscan_types" aur.archlinux.org >> /home/builder/.ssh/known_hosts
echo '::endgroup::'

echo '::group::Importing private key'
echo $1
echo $2
echo $3
echo "$1" > /home/builder/.ssh/aur
chmod -vR 600 /home/builder/.ssh/aur*
ssh-keygen -vy -f /home/builder/.ssh/aur > /home/builder/.ssh/aur.pub
echo '::endgroup::'

echo '::group::Checksums of SSH keys'
sha512sum /home/builder/.ssh/aur /home/builder/.ssh/aur.pub
cat /home/builder/.ssh/aur.pub
echo '::endgroup::'
