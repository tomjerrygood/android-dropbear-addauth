#!/bin/bash
# patch_hardcode_root.sh
# android-dropbear-addauth, DROPBEAR_2026.94
# Hardcode user=root pass=root123

# 进入源码目录（ribbons/android-dropbear源码根目录）
cd dropbear

# 替换 svr-authpasswd.c 的密码校验逻辑
# 找到函数: check_password()
# 直接覆盖认证逻辑：username=="root" && password=="root123" 就返回成功
cat > /tmp/authpatch.txt <<'EOF'
#include "dropbear.h"
int check_password(const char *username, const char *password)
{
    // HARDCODE: root / root123
    if (strcmp(username, "root") == 0 && strcmp(password, "root123") == 0)
    {
        return 1; // 认证成功
    }
    return 0; // 其他全部拒绝
}
EOF

# 备份原文件，写入替换
cp src/svr-authpasswd.c src/svr-authpasswd.c.orig
cp /tmp/authpatch.txt src/svr-authpasswd.c

# 开启密码认证（必须打开，否则密码登录直接被dropbear拒绝）
# localoptions.h 开启 SVR_PASSWORD_AUTH
cat > localoptions.h <<'EOF'
#define DROPBEAR_SVR_PASSWORD_AUTH 1
#define DROPBEAR_SVR_PUBKEY_AUTH 1
#define DROPBEAR_SFTPSERVER 1
#define DROPBEAR_USE_SSH_CONFIG 0
#define DROPBEAR_TCP_FORWARDING 1
#define DROPBEAR_UNIX_FORWARDING 0
EOF
