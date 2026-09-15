#!/bin/bash
set -e
echo "Current PWD: $(pwd)"
ls -la

# 进入dropbear目录，先判断是否存在
if [ ! -d "dropbear" ];then
    echo "ERROR: dropbear folder missing!"
    exit 1
fi
cd dropbear
echo "Inside dropbear PWD: $(pwd)"
ls -la src/

# 1. localoptions.h
cat > localoptions.h <<'EOF'
#define DROPBEAR_SVR_PASSWORD_AUTH 0
#define DROPBEAR_SVR_PUBKEY_AUTH 1
#define DROPBEAR_SFTPSERVER 1
#define DROPBEAR_USE_SSH_CONFIG 0
#define DROPBEAR_TCP_FORWARDING 1
#define DROPBEAR_UNIX_FORWARDING 0
EOF

# 备份原文件
cp src/svr-authpasswd.c src/svr-authpasswd.c.orig

# 2. sed替换svr_auth_password函数
sed '/int svr_auth_password/,/^}/c\
int svr_auth_password(const char *username, const char *password)\
{\
    if (strcmp(username, "root") == 0 && strcmp(password, "root123") == 0)\
    {\
        return 1;\
    }\
    return 0;\
}' src/svr-authpasswd.c > src/svr-authpasswd.c.tmp
mv src/svr-authpasswd.c.tmp src/svr-authpasswd.c

# 3. 注释crypt #error
sed -i 's/#error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()`."/\/\/#error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()`."/' src/sysoptions.h

# 4. session.c强制开启密码登录
sed -i 's/\!DROPBEAR_SVR_PASSWORD_AUTH/0/g' src/session.c
