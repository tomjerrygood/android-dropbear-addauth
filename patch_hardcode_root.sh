#!/bin/bash
# patch_hardcode_root.sh
# android-dropbear-addauth root目录执行
# 硬编码账号 root，密码 root123

# 覆盖密码校验函数
cat > /tmp/authpatch.txt <<'EOF'
#include "dropbear.h"
int check_password(const char *username, const char *password)
{
    // HARDCODE LOGIN: root / root123
    if (strcmp(username, "root") == 0 && strcmp(password, "root123") == 0)
    {
        return 1;
    }
    return 0;
}
EOF

cp src/svr-authpasswd.c src/svr-authpasswd.c.orig
cp /tmp/authpatch.txt src/svr-authpasswd.c

# localoptions.h 启用密码登录、SFTP
cat > localoptions.h <<'EOF'
#define DROPBEAR_SVR_PASSWORD_AUTH 1
#define DROPBEAR_SVR_PUBKEY_AUTH 1
#define DROPBEAR_SFTPSERVER 1
#define DROPBEAR_USE_SSH_CONFIG 0
#define DROPBEAR_TCP_FORWARDING 1
#define DROPBEAR_UNIX_FORWARDING 0
EOF
