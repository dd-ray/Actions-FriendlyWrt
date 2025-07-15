#!/bin/bash

# {{ Add luci-app-diskman - DISABLED
# (cd friendlywrt && {
#     mkdir -p package/luci-app-diskman
#     wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/applications/luci-app-diskman/Makefile.old -O package/luci-app-diskman/Makefile
# })
# cat >> configs/rockchip/01-nanopi <<EOL
# CONFIG_PACKAGE_luci-app-diskman=y
# CONFIG_PACKAGE_luci-app-diskman_INCLUDE_btrfs_progs=y
# CONFIG_PACKAGE_luci-app-diskman_INCLUDE_lsblk=y
# CONFIG_PACKAGE_luci-i18n-diskman-zh-cn=y
# CONFIG_PACKAGE_smartmontools=y
# EOL
# }}

# {{ Add wechatpush
(cd friendlywrt/package && {
    [ -d luci-app-wechatpush ] && rm -rf luci-app-wechatpush
    git clone --depth 1 https://github.com/tty228/luci-app-wechatpush
    
    [ -d OpenWrt-nikki ] && rm -rf OpenWrt-nikki
    git clone --depth 1 https://github.com/nikkinikki-org/OpenWrt-nikki
    
    [ -d OpenClash ] && rm -rf OpenClash
    git clone --depth 1 https://github.com/vernesong/OpenClash
})
echo "CONFIG_PACKAGE_luci-app-wechatpush=y" >> configs/rockchip/01-nanopi
echo "CONFIG_PACKAGE_luci-app-openclash=y" >> configs/rockchip/01-nanopi
echo "CONFIG_PACKAGE_luci-app-nikki=y" >> configs/rockchip/01-nanopi

## rclone
echo "CONFIG_PACKAGE_rclone=y" >> configs/rockchip/01-nanopi
echo "CONFIG_PACKAGE_rclone-config=y" >> configs/rockchip/01-nanopi

echo "CONFIG_LUCI_LANG_zh_Hans=y" >> configs/rockchip/01-nanopi
echo "CONFIG_PACKAGE_kmod-nls-utf8=y" >> configs/rockchip/01-nanopi
echo "CONFIG_PACKAGE_luci-i18n-base-zh-cn=y" >> configs/rockchip/01-nanopi
echo "CONFIG_PACKAGE_zoneinfo-asia=y" >> configs/rockchip/01-nanopi
echo "CONFIG_PACKAGE_zoneinfo-core=y" >> configs/rockchip/01-nanopi
# }}

# Mosdns
(cd friendlywrt && {
    rm -rf feeds/packages/lang/golang
    git clone https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang
    rm -rf feeds/packages/net/v2ray-geodata
    git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/new/mosdns
    git clone https://github.com/sbwml/v2ray-geodata package/new/v2ray-geodata
})

echo "CONFIG_PACKAGE_luci-app-mosdns=y" >> configs/rockchip/01-nanopi

# {{ Add luci-theme-argon
(cd friendlywrt/package && {
    [ -d luci-theme-argon ] && rm -rf luci-theme-argon
    git clone https://github.com/jerrykuku/luci-theme-argon.git --depth 1 -b master
    sed -i 's#<a href="https://github.com/jerrykuku/luci-theme-argon" target="_blank">ArgonTheme <%\# vPKG_VERSION %></a> |##g' luci-theme-argon/luasrc/view/themes/argon/footer_login.htm
    sed -i 's#<a href="https://github.com/jerrykuku/luci-theme-argon" target="_blank">ArgonTheme <%\# vPKG_VERSION %></a>#<span class="footer-separator">|</span>#g' luci-theme-argon/luasrc/view/themes/argon/footer.htm
    sed -i 's#<span class="footer-separator">|</span>##g' luci-theme-argon/luasrc/view/themes/argon/footer.htm
})
echo "CONFIG_PACKAGE_luci-theme-argon=y" >> configs/rockchip/01-nanopi
sed -i -e 's/function init_theme/function old_init_theme/g' friendlywrt/target/linux/rockchip/armv8/base-files/root/setup.sh
cat > /tmp/appendtext.txt <<EOL
function init_theme() {
    if uci get luci.themes.Argon >/dev/null 2>&1; then
        uci set luci.main.mediaurlbase="/luci-static/argon"
        uci commit luci
    fi
}
EOL
sed -i -e '/boardname=/r /tmp/appendtext.txt' friendlywrt/target/linux/rockchip/armv8/base-files/root/setup.sh
# }}
