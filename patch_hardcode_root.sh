#!/bin/bash
# patch_hardcode_root.sh
# build脚本自动clone dropbear到 ./dropbear

cd dropbear

# 硬编码 root / root123
cat > /tmp/authpatch.txt <<'EOF'
#include "dropbear.h"
int check_password(const char *username, const char *password)
{
    if (strcmp(username, "root") == 0 && strcmp(password, "root123") == 0)
    {
        return 1;
    }
    return 0;
}
EOF

cp src/svr-authpasswd.c src/svr-authpasswd.c.orig
cp /tmp/authpatch.txt src/svr-authpasswd.c

# localoptions.h 放到dropbear源码目录
cat > localoptions.h <<'EOF'
#define DROPBEAR_SVR_PASSWORD_AUTH 1
#define DROPBEAR_SVR_PUBKEY_AUTH 1
#define DROPBEAR_SFTPSERVER 1
#define DROPBEAR_USE_SSH_CONFIG 0
#define DROPBEAR_TCP_FORWARDING 1
#define DROPBEAR_UNIX_FORWARDING 0
EOF
