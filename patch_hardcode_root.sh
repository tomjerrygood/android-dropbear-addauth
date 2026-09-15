#!/bin/bash
cd dropbear

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

# 2. 用sed替换svr_auth_password函数内容，保留原有头文件
# 匹配 int svr_auth_password(...) { ... } 整块替换
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

# 3. 注释掉crypt() #error
sed -i 's/#error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()`."/\/\/#error "DROPBEAR_SVR_PASSWORD_AUTH requires `crypt()`."/' src/sysoptions.h

# 4. session.c强制开启密码登录分支
sed -i 's/\!DROPBEAR_SVR_PASSWORD_AUTH/0/g' src/session.c
