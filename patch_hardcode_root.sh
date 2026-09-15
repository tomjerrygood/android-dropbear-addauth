#!/bin/bash
cd dropbear

# 1. 写入localoptions.h：关闭原生密码认证，打开sftp、公钥
cat > localoptions.h <<'EOF'
#define DROPBEAR_SVR_PASSWORD_AUTH 0
#define DROPBEAR_SVR_PUBKEY_AUTH 1
#define DROPBEAR_SFTPSERVER 1
#define DROPBEAR_USE_SSH_CONFIG 0
#define DROPBEAR_TCP_FORWARDING 1
#define DROPBEAR_UNIX_FORWARDING 0
EOF

# 2. 打补丁修改 svr-authpasswd.c
# 这里我们不走dropbear原生password auth框架，直接修改 svr_auth_password 入口
cat > /tmp/authpatch.txt <<'EOF'
#include "dropbear.h"

int svr_auth_password(const char *username, const char *password)
{
    // Hardcode root / root123
    if (strcmp(username, "root") == 0 && strcmp(password, "root123") == 0)
    {
        return 1;
    }
    return 0;
}
EOF

cp src/svr-authpasswd.c src/svr-authpasswd.c.orig
cp /tmp/authpatch.txt src/svr-authpasswd.c

# 关键：修改 sysoptions.h，注释掉 crypt 相关#error，彻底干掉编译阻断
sed -i 's/#error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()`."/\/\/#error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()`."/' src/sysoptions.h
