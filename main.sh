#!/bin/sh

BACKUP_LIBRARIES=true
BACKUP_LIBRARY_PATH=/usr/local/lib/compat/pkg

pkgsave() {
	cp /etc/ssh/sshd_config.pkgsave /etc/ssh/sshd_config
	cp /etc/master.passwd.pkgsave /etc/master.passwd
	cp /etc/group.pkgsave /etc/group
	cp /etc/sysctl.conf.pkgsave /etc/sysctl.conf

	pwd_mkdb -p /etc/master.passwd
}

pkgsave_del_files() {
	find / -name \*.pkgsave -delete
	rm /boot/kernel/linker.hints
}

create_base_repository() {
	echo "[+] Adding repository"
	mkdir -p /usr/local/etc/pkg/repos/
	cat <<'EOF' >/usr/local/etc/pkg/repos/FreeBSD-base.conf
FreeBSD-base: {
  url: "pkg+https://pkg.FreeBSD.org/${ABI}/base_latest",
  mirror_type: "srv",
  signature_type: "fingerprints",
  fingerprints: "/usr/share/keys/pkg",
  enabled: yes
}
EOF
	pkg update
}

install() {
	env IGNORE_OSVERSION=yes ABI=FreeBSD:15:amd64 pkg install -r FreeBSD-base -g 'FreeBSD-*'
}

main() {
	create_base_repository
	install
	pkgsave
	pkgsave_del_files
}

main $@

