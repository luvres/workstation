#!/bin/bash

### Swap File
# sudo su
dd if=/dev/zero of=/swapfile bs=1M count=4096
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
sh -c "echo '/swapfile none swap defaults 0 0' >>/etc/fstab"

pacman -Syu --noconfirm

pacman -S --noconfirm \
xorg-server xorg-server-devel xorg-server-utils xorg-server-xwayland \
xorg-xinit xorg-twm xorg-xkill xterm xorg-xclock xorg-xinput \
xf86-video-vesa xf86-video-intel xf86-input-libinput \
ttf-dejavu ttf-liberation alsa-utils \
mesa mesa-libgl lib32-mesa-libgl mesa-vdpau lib32-mesa-vdpau

###########
## Xfce4 ##
###########
# xfce4-appfinder xfwm4-themes
# sudo su
pacman -S --noconfirm \
xfce4-panel xfce4-session xfce4-settings xfdesktop xfwm4 \
xfce4-terminal thunar thunar-volman gvfs xfce4-power-manager lxappearance \
mate-system-monitor xdg-user-dirs leafpad ristretto gksu gftp youtube-dl \
networkmanager networkmanager-dispatcher-ntpd network-manager-applet \
wireless_tools dialog pulseaudio-alsa \
screenfetch firefox flashplugin vlc qt4

systemctl enable NetworkManager

## Slim
# sudo su
pacman -S --noconfirm slim slim-themes archlinux-themes-slim
systemctl enable slim.service
sed -i '/#default_user/s/#//' /etc/slim.conf
sed -i "s/simone/`users | awk '{print $1}'`/" /etc/slim.conf
sed -i '/current_theme/s/default/archlinux-simplyblack/' /etc/slim.conf
# sed -i '/auto_login/s/#//' /etc/slim.conf
# sed -i '/auto_login/s/no/yes/' /etc/slim.conf
## sed -i 's/auto_login/#auto_login/' /etc/slim.conf
## sed -i '/auto_login/s/yes/no/' /etc/slim.conf

## Makepkg
# sudo su
sed -i '/MAKEFLAGS/s/#//' /etc/makepkg.conf
sed -i '/MAKEFLAGS/s/2/4/' /etc/makepkg.conf
sed -i '/COMPRESSXZ/s/c/c -T 6/' /etc/makepkg.conf
sed -i 's/NotShowIn/#NotShowIn/' /usr/share/applications/lxappearance.desktop
# nano /etc/makepkg.conf #line 63

## Background
# sudo su
curl -L https://github.com/luvres/workstation/blob/master/background.zip?raw=true -o ./background.zip
unzip background.zip -d /usr/share/backgrounds
rm background.zip

## Plank
pacman -S --noconfirm plank
git clone https://github.com/mateuspv/plank-themes.git
sudo cp -a plank-themes/themes/Translucent-Panel /usr/share/plank/themes/
rm plank-themes/ -fR
sudo cp /usr/share/plank/themes/Translucent-Panel/dock.theme /usr/share/plank/themes/Default/

cp /etc/X11/xinit/xinitrc /home/`users | awk '{print $1}'`/.xinitrc
sed -i 's/exec xterm/#exec xterm/' /home/`users | awk '{print $1}'`/.xinitrc
sed -i "/twm/s/twm &/exec startxfce4\n&/" /home/`users | awk '{print $1}'`/.xinitrc

## Mac OS X Themes
# Themes
mkdir $HOME/.themes
curl http://logico.com.ar/downloads/xosemite-gtk.tar.gz | tar -xzf - -C /home/`users | awk '{print $1}'`/.themes
curl http://logico.com.ar/downloads/xosemite-xfce.tar.gz | tar -xzf - -C /home/`users | awk '{print $1}'`/.themes
# Fonts
mkdir $HOME/.fonts
curl -L https://github.com/supermarin/YosemiteSanFranciscoFont/blob/master/System%20San%20Francisco%20Display%20Bold.ttf?raw=true -o /home/`users | awk '{print $1}'`/.fonts/System\ San\ Francisco\ Display\ Bold.ttf
curl -L https://github.com/supermarin/YosemiteSanFranciscoFont/blob/master/System%20San%20Francisco%20Display%20Regular.ttf?raw=true -o /home/`users | awk '{print $1}'`/.fonts/System\ San\ Francisco\ Display\ Regular.ttf
curl -L https://github.com/supermarin/YosemiteSanFranciscoFont/blob/master/System%20San%20Francisco%20Display%20Thin.ttf?raw=true -o /home/`users | awk '{print $1}'`/.fonts/System\ San\ Francisco\ Display\ Thin.ttf
curl -L https://github.com/supermarin/YosemiteSanFranciscoFont/blob/master/System%20San%20Francisco%20Display%20Ultralight.ttf?raw=true -o /home/`users | awk '{print $1}'`/.fonts/System\ San\ Francisco\ Display\ Ultralight.ttf
curl -L https://github.com/hbin/top-programming-fonts/blob/master/Menlo-Regular.ttf?raw=true -o /home/`users | awk '{print $1}'`/.fonts/Menlo-Regular.ttf

reboot


