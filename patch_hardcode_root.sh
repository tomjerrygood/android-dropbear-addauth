#!/bin/bash
set -e
echo "PWD = $(pwd)"
ls -la

if [ ! -d "dropbear" ];then
    echo "dropbear folder missing"
    exit 1
fi
cd dropbear
echo "inside dropbear: $(pwd)"
ls src

# 1. localoptions.h
cat > localoptions.h <<'EOF'
#define DROPBEAR_SVR_PASSWORD_AUTH 0
#define DROPBEAR_SVR_PUBKEY_AUTH 1
#define DROPBEAR_SFTPSERVER 1
#define DROPBEAR_USE_SSH_CONFIG 0
#define DROPBEAR_TCP_FORWARDING 1
#define DROPBEAR_UNIX_FORWARDING 0
EOF

# backup
cp src/svr-authpasswd.c src/svr-authpasswd.c.orig

# 替换svr_auth_password函数，awk稳定版本
awk '
BEGIN{infunc=0}
/int svr_auth_password/{
    print $0
    print "{"
    print "    if (strcmp(username, \"root\") == 0 && strcmp(password, \"root123\") == 0)"
    print "    {"
    print "        return 1;"
    print "    }"
    print "    return 0;"
    print "}"
    infunc=1
    next
}
infunc && /^}/{infunc=0;next}
infunc{next}
{print}
' src/svr-authpasswd.c > src/svr-authpasswd.c.tmp
mv src/svr-authpasswd.c.tmp src/svr-authpasswd.c

# comment crypt #error
sed -i 's/#error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()`."/\/\/#error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()`."/' src/sysoptions.h

# 【修复】文件名为 svr-session.c
sed -i 's/\!DROPBEAR_SVR_PASSWORD_AUTH/0/g' src/svr-session.c
