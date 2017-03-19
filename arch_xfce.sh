#!/bin/bash

if [ $# -ne 1 ]; then
  echo ""
  echo "   sh arch_xfce.sh [ xorg , xfce , xfce4 , packages , virtualbox ]"
  echo ""
  exit 1
fi

## Swap File
_swapfile(){
  # dd if=/dev/zero of=/swapfile bs=1M count=512
  dd if=/dev/zero of=/swapfile bs=1M count=4096
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap defaults 0 0' >>/etc/fstab

  # ILoveCnady
  sed -i 's/VerbosePkgLists/VerbosePkgLists\nILoveCandy/' /etc/pacman.conf
  sed -i '/Color/s/#//' /etc/pacman.conf

  pacman -Syu --noconfirm

  # Reflector
  pacman -S --noconfirm reflector
  cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
  reflector --verbose -l 30 -p http --sort rate --save /etc/pacman.d/mirrorlist
}

## Bashrc
_bashrc(){
  curl -L https://github.com/luvres/workstation/blob/master/bashrc.tar.gz?raw=true | tar -xzf - -C /home/`ls /home/`/
  echo '' >>/home/`ls /home/`/.bashrc
  echo screenfetch >>/home/`ls /home/`/.bashrc
}

## Xorg Minimal
_xorgMinimal(){
  # Xorg
  pacman -S --noconfirm \
  xorg-server xorg-xinit xorg-utils

  # Sound
  pacman -S --noconfirm \
  alsa-utils alsa-plugins pulseaudio pulseaudio-alsa

  # Input Drivers
  pacman -S --noconfirm \
  xf86-input-keyboard xf86-input-mouse

  # Video drivers
  pacman -S --noconfirm \
  xf86-video-vesa xf86-video-intel
  #virtualbox-guest-utils

  # Fonts
  pacman -S --noconfirm \
  artwiz-fonts font-bh-ttf font-bitstream-speedo gsfonts sdl_ttf \
  ttf-bitstream-vera ttf-cheapskate ttf-dejavu ttf-liberation xorg-fonts-type1

  # Print
  pacman -S --noconfirm \
  cups cups-pdf ghostscript

  systemctl enable org.cups.cupsd
}

## Makepkg
_makepkg(){
  sed -i '/MAKEFLAGS/s/#//' /etc/makepkg.conf
  sed -i '/MAKEFLAGS/s/2/4/' /etc/makepkg.conf
  sed -i '/COMPRESSXZ/s/c/c -T 6/' /etc/makepkg.conf
  # nano /etc/makepkg.conf #line 63
}

## Xfce4
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
}

## Thunar
_thunar(){
  pacman -S --noconfirm \
  thunar thunar-volman gvfs xdg-user-dirs
}

## NetworkManager
_networkmanager(){
  pacman -S --noconfirm \
  networkmanager networkmanager-dispatcher-ntpd network-manager-applet \
  wireless_tools dialog

  systemctl enable NetworkManager
}

## Packages
_packages(){
  pacman -S --noconfirm \
  gftp youtube-dl screenfetch \
  firefox flashplugin vlc qt4 \
  libreoffice-fresh gimp qt5-base qtcreator
}

## sddm
_sddm(){
  pacman -S --noconfirm sddm
  systemctl enable sddm.service
}

## Slim
_slim(){
  pacman -S --noconfirm slim slim-themes archlinux-themes-slim
  systemctl enable slim.service
  sed -i '/#default_user/s/#//' /etc/slim.conf
  sed -i "s/simone/`ls /home/`/" /etc/slim.conf
  sed -i '/current_theme/s/default/archlinux-simplyblack/' /etc/slim.conf
  ##
  # sed -i '/auto_login/s/#//' /etc/slim.conf
  # sed -i '/auto_login/s/no/yes/' /etc/slim.conf
  ## sed -i 's/auto_login/#auto_login/' /etc/slim.conf
  ## sed -i '/auto_login/s/yes/no/' /etc/slim.conf
}

## Background
_background(){
  curl -L https://github.com/luvres/workstation/blob/master/background.tar.gz?raw=true | tar -xzf - -C /usr/share/backgrounds/
}

## Plank
_plank(){
  pacman -S --noconfirm plank
  git clone https://github.com/mateuspv/plank-themes.git
  cp -a plank-themes/themes/Translucent-Panel /usr/share/plank/themes/
  rm plank-themes/ -fR
  cp /usr/share/plank/themes/Translucent-Panel/dock.theme /usr/share/plank/themes/Default/

  #echo "plank &" >>/home/`ls /home/`/.xinitrc
  chown -R `ls /home/`. /home/`ls /home/`/.xinitrc
}

## Virtualbox
_virtualbox(){
  pacman -S virtualbox linux-headers playonlinux
  gpasswd -a `ls /home/` vboxusers
  echo 'vboxnetadp' >>/etc/modules-load.d/virtualbox.conf
  echo 'vboxnetflt' >>/etc/modules-load.d/virtualbox.conf
  # http://download.virtualbox.org/virtualbox/
  # depmod -a
  # modprobe -a vboxnetadp vboxnetflt
}

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
}


if [[ $1 == "xorg" ]]; then
  _swapfile
  _bashrc
  _xorgMinimal
  _makepkg
fi

if [[ $1 == "xfce" ]]; then
  _xfce4
  _thunar
  _networkmanager
  _sddm
  _background
  _plank
  _macosx
fi

if [[ $1 == "packages" ]]; then
  _packages
fi

if [[ $1 == "virtualbox" ]]; then
  _virtualbox
fi

if [[ $1 == "xfce4" ]]; then
  _swapfile
  _bashrc
  _xorgMinimal
  _makepkg
  _xfce4
  _thunar
  _networkmanager
  _sddm
  _background
  _plank
  _macosx
  _packages
  _virtualbox
fi

