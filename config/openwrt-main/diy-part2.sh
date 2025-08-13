#!/bin/bash
#========================================================================================================================
# https://github.com/ophub/amlogic-s9xxx-openwrt
# Description: Automatically Build OpenWrt
# Function: Diy script (After Update feeds, Modify the default IP, hostname, theme, add/remove software packages, etc.)
# Source code repository: https://github.com/openwrt/openwrt / Branch: main
#========================================================================================================================

# ------------------------------- Main source started -------------------------------
#
# Add the default password for the 'root' user（Change the empty password to 'password'）
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow

# Set etc/openwrt_release
sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" package/base-files/files/etc/openwrt_release
#sed -i.bak "s/\(DISTRIB_DESCRIPTION='.*\)'/\1 $(date +%Y-%m-%d)'/" package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCECODE='official'" >>package/base-files/files/etc/openwrt_release

#
# ------------------------------- Main source ends -------------------------------

# ------------------------------- Other started -------------------------------
#

# Add third-party software packages (The entire repository)
git clone https://github.com/hushenhui/openwrt-package.git package/lieo-package
# 默认IP等配置
cp package/lieo-package/config_generate  ./package/base-files/files/bin/

# 数据备份目录， 主要有OTA升级包目录，数据库目录
cp package/lieo-package/sysupgrade.conf  ./package/base-files/files/etc/
# 处理redis编译
cp -rf package/lieo-package/redis-patch/files/* ./feeds/packages/libs/redis/files/
cp -rf package/lieo-package/redis-patch/Makefile ./feeds/packages/libs/redis/

# 处理mosquitto编译
cp -rf package/lieo-package/mosquitto-patch/*  ./feeds/packages/net/mosquitto/

# 处理postgresql编译
cp -rf package/lieo-package/postgresql-patch/* ./feeds/packages/libs/postgresql/

# 前端文件解压
unzip package/lieo-package/iot/files/etc/iot/configs/dist.zip  -d  package/lieo-package/iot/files/etc/iot/configs/
rm -rf package/lieo-package/iot/files/etc/iot/configs/dist.zip

# wifi默认设置
cp package/lieo-package/mac80211.sh ./package/kernel/mac80211/files/lib/wifi/

# 业务进程的心跳检测机制
cp package/lieo-package/plugin-monitor ./package/base-files/files/etc/init.d/
cp package/lieo-package/plugin-monitor.sh ./package/base-files/files/bin/

# 遥测数据和，命令日志 清理脚本
cp package/lieo-package/clean_data.sh ./package/base-files/files/sbin/
chmod +x ./package/base-files/files/sbin/clean_data.sh

# 修改后的 sysupgrade 脚本，升级前先执行数据清理脚本
cp package/lieo-package/sysupgrade ./package/base-files/files/sbin/

# 二进制文件增加可执行权限
chmod +x package/lieo-package/data_collect/bin/data_collect
chmod +x package/lieo-package/iot/bin/iot

# 前面已经拷贝完了，这里删除掉
rm -rf package/lieo-package/mosquitto-patch 
rm -rf package/lieo-package/postgresql-patch 
rm -rf package/lieo-package/redis-patch
rm -rf package/lieo-package/config_generate
rm -rf package/lieo-package/sysupgrade.conf
rm -rf package/lieo-package/mac80211.sh
rm -rf package/lieo-package/plugin-monitor
rm -rf package/lieo-package/plugin-monitor.sh
rm -rf package/lieo-package/clean_data.sh
rm -rf package/lieo-package/sysupgrade

# Add third-party software packages (Specify the package)
# svn co https://github.com/libremesh/lime-packages/trunk/packages/{shared-state-pirania,pirania-app,pirania} package/lime-packages/packages
# Add to compile options (Add related dependencies according to the requirements of the third-party software package Makefile)
# sed -i "/DEFAULT_PACKAGES/ s/$/ pirania-app pirania ip6tables-mod-nat ipset shared-state-pirania uhttpd-mod-lua/" target/linux/armvirt/Makefile

# Apply patch
# git apply ../config/patches/{0001*,0002*}.patch --directory=feeds/luci
#
# ------------------------------- Other ends -------------------------------
