#!/bin/bash

###############
### Install ###
###############

### Partitions
fdisk /dev/sdb
n
p
1
<Enter>
+100M
n
p
2
<Enter>
<Enter>
t
1
c
w

dd bs=1024M if=/dev/zero of=/dev/sdb status=progress

## Format
rm boot root -fR; mkdir boot root
mkfs.vfat /dev/sdb1 && mount /dev/sdb1 boot
mkfs.f2fs /dev/sdb2 && mount -t f2fs /dev/sdb2 root

## Install
# wget -c http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-2-latest.tar.gz
bsdtar -xpf ArchLinuxARM-rpi-2-latest.tar.gz -C root; sync

mv root/boot/* boot

#### https://www.zybuluo.com/yangxuan/note/344907
_f2fs(){
  echo '/dev/mmcblk0p2 / f2fs defaults,noatime,discard 0 0' >>root/etc/fstab
  echo 'tmpfs   /tmp     tmpfs   nodev,nosuid,size=2G  0 0' >>root/etc/fstab
  cp root/bin/true root/sbin/fsck.f2fs
  sed -i 's/$/& rootfstype=f2fs/' boot/cmdline.txt # Mouse lag
  sed -i 's/$/& usbhid.mousepoll=0/' boot/cmdline.txt # Rootfs type
  echo 'dtparam=audio=on' >>boot/config.txt
  echo 'hdmi_drive=2' >>boot/config.txt
  echo 'dtparam=sd_overclock=100' >>boot/config.txt #Class 10 SD card
  umount boot root
}; _f2fs


############
### Init ###
############
ssh -l alarm pi
passwd: alarm
su
# passwd: root
echo "root:aamu02" | chpasswd
echo "alarm:aamu02" | chpasswd

## Swap File
_swap(){
  dd if=/dev/zero of=/swapfile bs=1M count=512
  chmod 0600 /swapfile 
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap defaults 0 0' >>/etc/fstab
}; _swap

## ILoveCandy
_ilovecandy(){
  sed -i 's/VerbosePkgLists/VerbosePkgLists\nILoveCandy/' /etc/pacman.conf
  sed -i '/Color/s/#//' /etc/pacman.conf
  rm /etc/ssl/certs/ca-certificates.crt
  pacman-key --init
  pacman -Syu --noconfirm
}; _ilovecandy

## Configurations
_configs(){
  pacman -S --noconfirm sudo rsync git docker wget screen tmux htop cpio screenfetch
# Sudo
  echo 'alarm  ALL=NOPASSWD: ALL' >>/etc/sudoers.d/myOverrides
# Locale
  sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
  locale-gen
  echo 'export LANG=en_US.UTF-8' >>/etc/profile
  echo 'export LC_ALL=en_US.UTF-8' >>/etc/profile
# Docker
  systemctl enable docker
  usermod -aG docker `ls /home/`
}; _configs

#####################
#####################

### Web Server
_webserver(){
  pacman -S --noconfirm apache
  sed -i '/DocumentRoot/s/\/srv\/http/\/srv\/http\/ftp/g' /etc/httpd/conf/httpd.conf
  ln -s /mnt/ftp/ /srv/http/ftp
  systemctl enable httpd
  systemctl start httpd
  #rsync -avz --delete --progress /aux/ alarm@pi:/mnt/ftp
  #sshpass -p "aamu02" rsync -avz --delete --progress /aux/ alarm@pi:/mnt/ftp
# Mountpoint
  echo '/dev/sda1 /mnt auto noatime 0 0' >>/etc/fstab
}; _webserver

#####################
### <ctrl>d alarm ###
#####################

## Bashrc
_bashrc(){
  curl -L https://github.com/luvres/workstation/blob/master/bashrc.tar.gz?raw=true | tar -xzf - -C $HOME
  echo '' >>$HOME/.bashrc
  echo screenfetch >>$HOME/.bashrc
}; _bashrc

## Yaourt
_yaourt(){
  sudo sh -c "echo '[archlinuxfr]' >> /etc/pacman.conf"
  sudo sh -c "echo 'SigLevel = Never' >> /etc/pacman.conf"
  sudo sh -c "echo 'Server = http://repo.archlinux.fr/arm' >> /etc/pacman.conf"
  sudo pacman -Syy && pacman -S --needed base-devel
  cd ~ && curl -O https://aur.archlinux.org/cgit/aur.git/snapshot/package-query.tar.gz
  tar zxvf package-query.tar.gz && cd package-query
  makepkg -si
  sudo pacman -S yaourt
  cd ~ && rm package-query* -fR
}; _yaourt

############
### Xorg ###
############
_xorgMinimal(){
  # Xorg
  pacman -S --noconfirm \
  xorg-server xf86-video-fbdev xorg-xrefresh #xorg-xinit xorg-utils

  # Video drivers
  pacman -S --noconfirm \
  xf86-video-vesa xf86-video-fbdev
  #virtualbox-guest-utils

  # Sound
  pacman -S --noconfirm \
  alsa-utils alsa-plugins pulseaudio pulseaudio-alsa

  # Input Drivers
  pacman -S --noconfirm \
  xf86-input-keyboard xf86-input-mouse

  # Fonts
  pacman -S --noconfirm \
  artwiz-fonts font-bh-ttf font-bitstream-speedo gsfonts sdl_ttf \
  ttf-bitstream-vera ttf-cheapskate ttf-dejavu ttf-liberation xorg-fonts-type1

  # Print
  pacman -S --noconfirm \
  cups cups-pdf ghostscript

  systemctl enable org.cups.cupsd
}; _xorgMinimal

## xf86-video-fbturbo
_fbturbo(){
    sudo pacman -S make gcc git-core automake autoconf pkg-config libtool
    cd ~
    git clone https://github.com/robclark/libdri2.git
    git clone https://github.com/ssvb/xf86-video-fbturbo
    cd ~/libdri2
    ./autogen.sh --prefix=/usr
    sudo make install
    cd ~/xf86-video-fbturbo
    autoreconf -vi
    ./configure --prefix=/usr
    make
    sudo make install
    sudo cp xorg.conf /usr/share/X11/xorg.conf.d/99-fbturbo.conf
}; _fbturbo

#################
## Xorg
1) xf86-video-vesa  2) xorg-bdftopcf  3) xorg-docs  4) xorg-font-util  5) xorg-fonts-100dpi
6) xorg-fonts-75dpi  7) xorg-fonts-encodings  8) xorg-iceauth  9) xorg-luit  10) xorg-mkfontdir
11) xorg-mkfontscale  12) xorg-server  13) xorg-server-common  14) xorg-server-devel  15) xorg-server-xdmx
16) xorg-server-xephyr  17) xorg-server-xnest  18) xorg-server-xvfb  19) xorg-server-xwayland
20) xorg-sessreg  21) xorg-setxkbmap  22) xorg-smproxy  23) xorg-x11perf  24) xorg-xauth
25) xorg-xbacklight  26) xorg-xcmsdb  27) xorg-xcursorgen  28) xorg-xdpyinfo  29) xorg-xdriinfo
30) xorg-xev  31) xorg-xgamma  32) xorg-xhost  33) xorg-xinput  34) xorg-xkbcomp  35) xorg-xkbevd
36) xorg-xkbutils  37) xorg-xkill  38) xorg-xlsatoms  39) xorg-xlsclients  40) xorg-xmodmap  41) xorg-xpr
42) xorg-xprop  43) xorg-xrandr  44) xorg-xrdb  45) xorg-xrefresh  46) xorg-xset  47) xorg-xsetroot
48) xorg-xvinfo  49) xorg-xwd  50) xorg-xwininfo  51) xorg-xwud
#############
### Xfce4 ###
#############
_xfce4(){
  # Core
  pacman -S --noconfirm \
  xfce4-panel xfce4-session xfce4-settings xfdesktop xfwm4
  # cp /etc/X11/xinit/xinitrc /home/`ls /home/`/.xinitrc
  # sed -i 's/exec xterm/#exec xterm/' /home/`ls /home/`/.xinitrc
  # sed -i "/twm/s/twm &/exec startxfce4\n&/" /home/`ls /home/`/.xinitrc
  echo "exec startxfce4 &" >/home/`ls /home/`/.xinitrc
  chown -R `ls /home/`. /home/`ls /home/`/.xinitrc

  # Packages base
  pacman -S --noconfirm \
  xfce4-power-manager xfce4-pulseaudio-plugin \
  lxappearance gnome-system-monitor gksu \
  xfce4-terminal ristretto leafpad chromium
  sed -i 's/NotShowIn/#NotShowIn/' /usr/share/applications/lxappearance.desktop
}; _xfce4

## Thunar
_thunar(){
  pacman -S --noconfirm \
  thunar thunar-volman gvfs xdg-user-dirs
}; _thunar

## NetworkManager
_networkmanager(){
  pacman -S --noconfirm \
  networkmanager networkmanager-dispatcher-ntpd network-manager-applet \
  wireless_tools dialog
  systemctl enable NetworkManager
  # Bluetooth
  pacman -S --noconfirm blueman bluez-utils
  systemctl enable bluetooth.service
}; _networkmanager

## sddm
_sddm(){
  pacman -S --noconfirm sddm
  systemctl enable sddm.service
}; _sddm

## Packages
_packages(){
  pacman -S --noconfirm \
  gftp youtube-dl screenfetch \
  firefox flashplugin vlc qt4 \
  libreoffice-fresh gimp blender
}; _packages

## Development
_development(){
  pacman -S --noconfirm \
  qt5-base qtcreator eclipse-jee netbeans arduino atom
}; _development

## Background
_background(){
  curl -L https://github.com/luvres/workstation/blob/master/background.tar.gz?raw=true | tar -xzf - -C /usr/share/backgrounds/
}; _background

## Plank
_plank(){
  pacman -S --noconfirm plank
  git clone https://github.com/mateuspv/plank-themes.git
  cp -a plank-themes/themes/Translucent-Panel /usr/share/plank/themes/
  rm plank-themes/ -fR
  cp /usr/share/plank/themes/Translucent-Panel/dock.theme /usr/share/plank/themes/Default/

  #echo "plank &" >>/home/`ls /home/`/.xinitrc
  chown -R `ls /home/`. /home/`ls /home/`/.xinitrc
}; _plank

## Mac OS X Themes
_macosx(){
  # Themes
  mkdir /home/`ls /home/`/.themes
  curl http://logico.com.ar/downloads/xosemite-gtk.tar.gz | tar -xzf - -C /home/`ls /home/`/.themes
  curl http://logico.com.ar/downloads/xosemite-xfce.tar.gz | tar -xzf - -C /home/`ls /home/`/.themes
  chown -R `ls /home/`. /home/`ls /home/`/.themes

  # Fonts
  mkdir /home/`ls /home/`/.fonts
  curl -L https://github.com/supermarin/YosemiteSanFranciscoFont/blob/master/System%20San%20Francisco%20Display%20Bold.ttf?raw=true -o /home/`ls /home/`/.fonts/System\ San\ Francisco\ Display\ Bold.ttf
  curl -L https://github.com/supermarin/YosemiteSanFranciscoFont/blob/master/System%20San%20Francisco%20Display%20Regular.ttf?raw=true -o /home/`ls /home/`/.fonts/System\ San\ Francisco\ Display\ Regular.ttf
  curl -L https://github.com/supermarin/YosemiteSanFranciscoFont/blob/master/System%20San%20Francisco%20Display%20Thin.ttf?raw=true -o /home/`ls /home/`/.fonts/System\ San\ Francisco\ Display\ Thin.ttf
  curl -L https://github.com/supermarin/YosemiteSanFranciscoFont/blob/master/System%20San%20Francisco%20Display%20Ultralight.ttf?raw=true -o /home/`ls /home/`/.fonts/System\ San\ Francisco\ Display\ Ultralight.ttf
  curl -L https://github.com/hbin/top-programming-fonts/blob/master/Menlo-Regular.ttf?raw=true -o /home/`ls /home/`/.fonts/Menlo-Regular.ttf
  chown -R `ls /home/`. /home/`ls /home/`/.fonts
}; _macosx


###########
### VNC ###
###########
pacman -S tigervnc
vncserver
x0vncserver -display :0 -passwordfile ~/.vnc/passwd


###########################
###########################
###########################

# Bashrc
nano $HOME/.bashrc
alias ls='ls --color=auto'
alias ll='ls -lA'
alias l='ll -h'
alias pacman='pacman --color=auto'
alias h='history'
alias grep='grep --color'
source $HOME/.bashrc

### packer
sudo pacman -S packer
sudo sed -i '/${EDITOR:-vi}/s/vi/nano/g' /usr/bin/packer


###############
### Desktop ###
###############
sudo pacman -S \
xorg-server-devel xorg-server \
xf86-video-fbdev xorg-xrefresh xorg-util-macros mesa-libgl \
make gcc git-core automake autoconf pkg-config libtool

cd
git clone https://github.com/ssvb/xf86-video-fbturbo
cd $HOME/xf86-video-fbturbo
autoreconf -vi
./configure --prefix=/usr
make
sudo make install
sudo cp xorg.conf /usr/share/X11/xorg.conf.d/99-fbturbo.conf

### XFCE4
sudo pacman -S xfce4 xfce4-goodies xarchiver
sudo pacman -S sddm fakeroot
sudo sh -c "sddm --example-config >/etc/sddm.conf"

# SDDM theme
packer -S archlinux-themes-sddm
sudo systemctl enable sddm
sudo systemctl start sddm

# Mouse lag
nano /boot/cmdline.txt
usbhid.mousepoll=0

# Keyboard map
echo 'setxkbmap -model abnt2 -layout br -variant abnt2' >>$HOME/.bashrc

sudo reboot


sudo nano /etc/sddm.conf
  [Autologin]
  Session=xfce.desktop
  User=alarm
  ......
  Current=archlinux-simplyblack
  
# icon, theme, font, terminal font:
packer -S \
paper-icon-theme-git \
gtk-theme-arc-git \
ttf-roboto \
ttf-roboto-mono

# Wi-Fi
sudo pacman -Syu networkmanager network-manager-applet
systemctl enable NetworkManager
#systemctl start NetworkManager
sudo ifconfig wlan0 up
ifconfig wlan0

# Bluetooth
packer -S yaourt blueman bluez-utils
yaourt -S --noconfirm pi-bluetooth
#systemctl start bluetooth.service
systemctl enable bluetooth.service
systemctl enable brcm43438.service
sudo reboot

# Chromium
packer -S chromium gimp blender 

### Conky
packer -S conky-manager


#######################
#######################
#######################

# FFmpeg with MMAL
mkdir ffmpeg_build
cd ffmpeg_build
mkdir $(date +%Y-%m-%d)
cd $(date +%Y-%m-%d)
wget https://raw.githubusercontent.com/archlinuxarm/PKGBUILDs/master/extra/ffmpeg/PKGBUILD
sed -i "/arch=/s/'i686' 'x86_64'/'any'/g" PKGBUILD
sed -i 's/enable-x11grab/enable-x11grab \\\n    --enable-mmal/' PKGBUILD
sudo sed -i 's/#MAKEFLAGS=/MAKEFLAGS=/' /etc/makepkg.conf
sudo sed -i '/MAKEFLAGS=/s/j2/j4/g' /etc/makepkg.conf
sudo sed -i '/COMPRESSXZ=/s/-)/- --threads=4)/g' /etc/makepkg.conf

makepkg
sudo pacman -U *.pkg.tar.xz

sudo nano /etc/pacman.conf
  IgnorePkg = ffmpeg

sudo pacman -Rdd openjpeg2
sudo pacman -S openjpeg2


# wallpaper -> http://img2.goodfon.su/original/1366x768/3/b6/android-5-0-lollipop-material-5355.jpg

# menu icon -> https://icons8.com/web-app/11287/raspberry-pi
	    -> /usr/share/raspberrypi-artwork/raspitr.png
	    
# Disable screen saver blanking
xset q
# if you got:
xset:  unable to open display ""
# type:
export DISPLAY=:0
# then disable DPMS and prevent screen from blanking:
xset s off -dpms


## Window tiling
# Windows Manager -> Advanced -> Wrap workspaces when reaching the screen edge
# uncheck: With a dragged windows
# Windows Manager Tweaks -> Accessibility
# check: Automatically tile windows when moving toward the screen edge

### Conky
packer -S conky-lua conky-manager
# then select the widgets from Conky Manager, select Gotham for example
# check
cat $HOME/.conky/Gotham/Gotham

# you can edit the file manually in a text editor
# here is some reference:
# https://ubuntuforums.org/showthread.php?t=1943490&p=11778553#post11778553


### Powerline
sudo pip install powerline-status
packer -S powerline-fonts-git tmux

cat >> $HOME/.bashrc <<EOF

# Powerline
if [ -f `which powerline-daemon` ]; then
powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
. /usr/lib/python3.5/site-packages/powerline/bindings/bash/powerline.sh
fi
EOF

mkdir ~/.config/powerline
cp /usr/lib/python3.5/site-packages/powerline/config_files/config.json ~/.config/powerline

sudo nano ~/.config/powerline/config.json
   "shell": {
           ...
           #"theme": "default",
           "theme": "default_leftonly",

powerline-daemon --replace


# Tmux
cat >>$HOME/.tmux.conf <<EOF

source /usr/lib/python3.5/site-packages/powerline/bindings/tmux/powerline.conf
set-option -g default-terminal "screen-256color"
EOF

# Vim
packer -S gvim
cat >>$HOME/.vimrc <<EOF
set  rtp+=/usr/lib/python3.5/site-packages/powerline/bindings/vim
set laststatus=2
set t_Co=256
EOF


### backup/migration
sudo pacman -Syu rsync
sudo rsync -aAXv --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"} / /path/to/backup/folder

### Samba
sudo pacman -S samba
sudo cp /etc/samba/smb.conf.default /etc/samba/smb.conf
sudo pdbedit -a -u username
sudo systemctl start smbd nmbd
sudo systemctl enable smbd nmbd
sudo pacman -S gvfs-smb


### VNC ###
pacman –S tigervnc
vncserver
x0vncserver -display :0 -passwordfile ~/.vnc/passwd

pacman -Syu networkmanager network-manager-applet
systemctl enable NetworkManager
systemctl start NetworkManager
ifconfig wlan0 up
pacman -Sc


### XFCE
pacman -S xorg-server
pacman -S xf86-video-fbdev xf86-video-vesa
pacman -S xfce4 xfce4-goodies xarchiver
pacman –S git zsh wget base-devel diffutils libnewt dialog wpa_supplicant wireless_tools iw crda lshw


### MATE ###
sudo pacman -S xorg-server xorg-server-utils xorg-xinit xorg-utils 
sudo pacman -S mate mate-extra
echo 'exec mate-session' >$HOME/.xinitrc


### NFS
pacman -S nfs-utils rpcbind
mkdir $HOME/www
echo '$HOME/www 191.96.255.100/27(rw,sync,no_subtree_check)' >>/etc/exports
systemctl start rpcbind
systemctl start nfs-server.service
## Reinstall
#pacman -R nfs-utils
#rm -r /var/lib/nfs
#pacman -S nfs-utils
##
pacman -S nfs-utils rpcbind
mkdir $HOME/www
echo '$HOME/www 191.96.255.100/27(rw,sync,no_subtree_check)' >>/etc/exports
echo '$HOME/www *(rw,sync,no_subtree_check)' >>/etc/exports
##
systemd start rpcbind
systemd start nfs-server
##
exportfs -ra
##
sudo systemctl enable rpc-idmapd
sudo systemctl start rpc-idmapd
sudo systemctl enable rpc-mountd
sudo systemctl start rpc-mountd


# RPI 3
#wget -c http://archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz
#wget -c http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-3-latest.tar.gz
#cp /aux/Workstation/RaspberryPi/ArchLinuxARM-rpi-3-latest.tar.gz .
#bsdtar -xpf ArchLinuxARM-aarch64-latest.tar.gz -C root
#bsdtar -xpf ArchLinuxARM-rpi-3-latest.tar.gz -C root


#git clone https://github.com/robclark/libdri2.git
#cd $HOME/libdri2
#./autogen.sh --prefix=/usr
#sudo make install


