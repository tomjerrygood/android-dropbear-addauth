#!/bin/bash
# patch_hardcode_root.sh
# android-dropbear-addauth，源码在仓库根目录，无dropbear子文件夹
# Hardcode user=root pass=root123

# 当前已经在源码根目录，不要cd dropbear

# 替换 svr-authpasswd.c check_password
cat > /tmp/authpatch.txt <<'EOF'
#include "dropbear.h"
int check_password(const char *username, const char *password)
{
    // HARDCODE: root / root123
    if (strcmp(username, "root") == 0 && strcmp(password, "root123") == 0)
    {
        return 1; //认证成功
    }
    return 0; //其他全部拒绝
}
EOF

# 备份原文件，写入新代码
cp src/svr-authpasswd.c src/svr-authpasswd.c.orig
cp /tmp/authpatch.txt src/svr-authpasswd.c

# 写入localoptions.h，开启密码登录、SFTP
cat > localoptions.h <<'EOF'
#define DROPBEAR_SVR_PASSWORD_AUTH 1
#define DROPBEAR_SVR_PUBKEY_AUTH 1
#define DROPBEAR_SFTPSERVER 1
#define DROPBEAR_USE_SSH_CONFIG 0
#define DROPBEAR_TCP_FORWARDING 1
#define DROPBEAR_UNIX_FORWARDING 0
EOF
