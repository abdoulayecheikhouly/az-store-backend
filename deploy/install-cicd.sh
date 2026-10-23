#!/usr/bin/env bash
# Run only after the owner approves the new restricted deployment account and keys.
set -euo pipefail
backend_key=${1:?path to approved backend PUBLIC key}
frontend_key=${2:?path to approved frontend PUBLIC key}
[[ $(id -u) -eq 0 ]] || exit 77
for file in "$backend_key" "$frontend_key"; do
  grep -q '^ssh-ed25519 ' "$file" || { echo 'Expected an Ed25519 public key'; exit 64; }
done
if ! id deploy-azstore >/dev/null 2>&1; then
  useradd --create-home --shell /bin/sh deploy-azstore
  passwd -l deploy-azstore >/dev/null
fi
chown root:root /home/deploy-azstore
chmod 755 /home/deploy-azstore
install -d -o root -g root -m 755 /home/deploy-azstore/.ssh
install -o root -g root -m 755 /opt/azstore/repos/backend/deploy/azstore-ci.sh /usr/local/sbin/azstore-ci
{
  printf 'restrict,command="/usr/bin/sudo -n /usr/local/sbin/azstore-ci backend \\"$SSH_ORIGINAL_COMMAND\\"" %s\n' "$(cat "$backend_key")"
  printf 'restrict,command="/usr/bin/sudo -n /usr/local/sbin/azstore-ci frontend \\"$SSH_ORIGINAL_COMMAND\\"" %s\n' "$(cat "$frontend_key")"
} > /home/deploy-azstore/.ssh/authorized_keys
chmod 644 /home/deploy-azstore/.ssh/authorized_keys
printf '%s\n' 'deploy-azstore ALL=(root) NOPASSWD: /usr/local/sbin/azstore-ci backend *, /usr/local/sbin/azstore-ci frontend *' > /etc/sudoers.d/azstore-ci
chmod 440 /etc/sudoers.d/azstore-ci
visudo -cf /etc/sudoers.d/azstore-ci
echo 'Two restricted deployment keys installed. No root authorized_keys entry added.'
