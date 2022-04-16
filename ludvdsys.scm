;; 我的便携操作系统

(use-modules (gnu) (guix gexp) (guix records))
(use-package-modules busybox linux radio android)
(use-service-modules base networking ssh sddm desktop dbus shepherd linux sound)

(load "module/packages/plan9.scm")

(define-public ludvdsys-os
 (operating-system
  (host-name "ludvdsys")
  (timezone "UTC")
  (locale "en_US.utf8")
  (bootloader
   (bootloader-configuration
    (bootloader grub-bootloader)
    (targets '("/dev/sda"))))
  (kernel-arguments
   (list
    "modprobe.blacklist=dvb_usb_rtl288xxu")) ; rtl-sdr
  (file-systems
   (cons*
    (file-system
     (device (file-system-label "ludvdsys-root"))
     (mount-point "/")
     (type "ext4"))
    %base-file-systems))
  (users
   (cons*
    (user-account
     (name "admin")
     (comment "Administrator")
     (group "users")
     (supplementary-groups
      (list "wheel" "audio" "video" "kvm" "input" "dialout" "lp" "netdev")))
    %base-user-accounts))
  ;; HOME的配置文件
  (skeletons 
   `((".xinitrc" ,(local-file "./data/skel/.xinitrc" "xinitrc"))
     (".xinitrc.rc" ,(local-file "./data/skel/.xinitrc.rc" "xinitrc.rc"))
     (".gitconfig" ,(local-file "./data/skel/.gitconfig" "gitconfig"))
     (".Xdefaults" ,(local-file "./data/skel/.Xdefaults" "Xdefaults"))
     (".uim" ,(local-file "./data/skel/.uim" "uim"))))
  (packages
   (cons*
    plan9port-with-ime
    (map
     specification->package
     (list
      "nss-certs" ; 默认TLS证书

      "busybox" ; 系统管理工具集
      "cryptsetup" ; 磁盘加密
      "zerofree" ; 清理磁盘
      "extundelete" "ddrescue" ; 文件恢复
      "btrfs-progs" "e2fsprogs" "xfsprogs" "f2fs-tools" ; 文件系统
      "cdrtools" ; 光盘工具
      "acpi" ; ACPI 工具
      "ncurses" ; 终端工具
      "picocom" ; 串口工具
      "htop" "bmon" "iftop" "iotop" ; 资源监视器
      "pciutils" "usbutils" "smartmontools" ; 硬件信息
      "hdparm" "sdparm" ; 磁盘工具
      "vmtouch" ; 文件缓存
      "psmisc" ; 进程管理

      "gzip" "bzip2" "xz" "zstd" "unzip" "p7zip" ; 压缩工具
      "cpio" "tar" ; 归档工具
      "file" ; 文件类型识别

      "rsync" "wget" "curl" "axel" "rtorrent" "amule" ; 下载工具

      "proxychains-ng" ; 代理工具

      "qemu" "dosbox" ; 模拟器

      "keepassxc" ; 密码管理器

      "font-gnu-unifont" "fontconfig" ; 字体
      "adwaita-icon-theme" "gnome-themes-standard" ; 外观

      "fcitx" "dbus" ; 输入法
      "sdcv" ; 词典

      "icecat" "ungoogled-chromium" ; WEB浏览器
      "w3m" "lynx" "links" ; 文本web浏览器

      "alsa-utils" "pulseaudio" ; 声音工具
      "mpg123" "mplayer" ; 媒体播放器
      "obs" "ffmpeg" ; 媒体录制工具
      "gimp" "imagemagick" "feh" "scrot" ; 图片工具
      "qrencode" ; 二维码

      "rtl-sdr" "gqrx" "dump1090" "qsstv" ; 无线电工具

      "openssh" "dropbear" "remmina" "freerdp" "tigervnc-client"
      "tigervnc-server" "drawterm" "sshfs" "virt-manager" "tmate"; 远程访问

      "sic" "ii" "irssi" ; irc 聊天
      "fdm" "msmtp" "mutt" ; 电子邮件

      "tmux" "screen" ; 终端复用器

      "wireshark" "tcpdump" ; 抓包工具
      "ethtool" "wol" ; 网络唤醒工具
      "nmap" "fping" ; 网络扫描工具
      "nftables" ; 防火墙工具

      "adb" "fastboot" ; 安卓手机工具

      "s9fes" "guile" ; Scheme Lisp
      "gcc-toolchain" "clang-toolchain" "glibc" ; Linux C Programming
      "bison" "flex" ; 词法分析
      "make" "bmake" ; 构建工具
      "man-db" "texinfo" "man-pages" "sicp" ; 文档
      "strace" "ltrace" "gdb" ; 调试工具

      "xset" "xrdb" "xsetroot" "xterm" "xkbset"  ; Xorg 图形界面工具
      ))))
  (services
    (list
     (service earlyoom-service-type ; 杀死内存占用过多触发阀值的进程
      (earlyoom-configuration
       (minimum-available-memory 10) ; 运行内存阀值
       (minimum-free-swap 10) ; 交换空间阀值
       (memory-report-interval 5)
       (prefer-regexp "(^|/)(surf|chromium|icecat)$") ; 优先杀死的进程
       (avoid-regexp "(^|/)(sshd|shepherd|mcron|Xorg)$"))) ; 白名单，无论如何都不杀死
     (service openssh-service-type)
     (service ntp-service-type ; ntp 网络校时
      (ntp-configuration
       (servers
        (list
         (ntp-server
          (type 'server)
          (address "ntp1.aliyun.com")
          (options `(iburst (version 3) (maxpoll 16) prefer)))
         (ntp-server
          (type 'server)
          (address "ntp2.aliyun.com")
          (options `(iburst (version 3) (maxpoll 16) prefer)))))))
     (service network-manager-service-type) ; 网络管理器
     (service wpa-supplicant-service-type)
     (service static-networking-service-type
      (list %loopback-static-networking)) ; loopback interface
     (service sddm-service-type ; 图形界面登录管理器
      (sddm-configuration
       (display-server "x11")
       (numlock "off") ; 笔记本不希望默认开机numlock
       (auto-login-user "admin") ; 自动登录
       (auto-login-session "xinitrc.desktop")
       (relogin? #t)))
     (syslog-service) ; 日志服务
     (service urandom-seed-service-type) ; 随机数

     ;; tty 服务
     (service virtual-terminal-service-type)
     (service login-service-type)
     (service mingetty-service-type
      (mingetty-configuration
       (tty "tty1")))
     (service mingetty-service-type
      (mingetty-configuration
       (tty "tty2")))
     (service mingetty-service-type
      (mingetty-configuration
       (tty "tty3")))
     (service mingetty-service-type
      (mingetty-configuration
       (tty "tty4")))

     ;; 一些服务的依赖
     (elogind-service)
     (dbus-service)

     ;; 硬件服务
     (service udev-service-type
      (udev-configuration
       (rules
        (list alsa-utils fuse lvm2 crda rtl-sdr android-udev-rules))))
     ;; 音频服务
     (service alsa-service-type)
     (service pulseaudio-service-type)

     ;; nscd
     (nscd-service)

     ;; Guix
     (service guix-service-type
      (guix-configuration
       (substitute-urls
        (cons*
         "https://mirrors.sjtug.sjtu.edu.cn/guix"
         %default-substitute-urls))))

     ;; 脚本解释器
     (service special-files-service-type
      `(("/bin/sh" ,(file-append busybox "/bin/sh"))
        ("/usr/bin/env" ,(file-append busybox "/bin/env"))))

     ;; 源码
     (extra-special-file "/src/ludvdsys.scm"
      (local-file "./ludvdsys.scm"))
     (extra-special-file "/src/module"
      (local-file "./module"
       #:recursive? #t))
     (extra-special-file "/src/data"
      (local-file "./data"
       #:recursive? #t))

     (extra-special-file ; 数据文件
      "/data"
      (local-file "./data"
       #:recursive? #t))))))

ludvdsys-os