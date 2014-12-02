#### About
Kodibuntu is a Linux operating system based on the Lubuntu variant of the popular Ubuntu Linux distribution.  
It has been tailored specifically for running Kodi and comes preconfigured out of the box.

Kodibuntu has two modes of operation - *Standalone-mode* and *Desktop-mode*.  
In *Standalone-mode*, Kodibuntu acts like an appliance, making it easy to get Kodi up and running.  
In *Desktop-mode*, you get a traditional desktop with easy access to other software, such as a web browser  
while still having Kodi only a few clicks away.  

Kodibuntu gives you access to all the software available from the Ubuntu repositories
You can easily install other software on it in addition to Kodi.

***

Cronological flow of operations:

+------------------------+             Sets and Exports (according to cmdline):
| ./buildWithOptions.sh  |             * SDK_BUILDHOOKS, SDK_USELOCALLIVEBUILD, SDK_USELATESTLIVEBUILD, SDK_CHROOTSHELL, SDK_EXT2ROOTFS, SDK_BUILDx86_64
+------------------------+             * APT_HTTP_PROXY, APT_FTP_PROXY, http_proxy, ftp_proxy
          |                            * KEEP_WORKAREA
          |
          |      +-------------+
          +------| ./build.sh  |
                 +-------------+
                        |
                        |     +------------------+
                        +-----| ./buildHook-*.sh |
                        |     +------------------+
                        |
                        |
                        |     +-----------------------+
                        +-----| ./buildDEBs/build.sh  |
                        |     +-----------------------+
                        |                |
                        |                |      +------------------------+      
                        |                +------| ./buildDEBs/build-*.sh |       
                        |                       +------------------------+
                        |
                        |     +------------------+
                        +-----| ./copyFiles-*.sh |
                        |     +------------------+
                        |
                        |     +------------+
                        +-----| lb clean   |           
                              | lb config  |
                              | lb build   |
                              +------------+


Main script detailed sequence of operations (build.sh):

1. Check for required packages
2. Delete previous build objects (workarea, binary.*) if they exist
3. Create a new workarea, copying the entire SDK
4. If live-build is not installed, clone it from upstream repo and set environment accordingly
5. Execute any specified build hooks
6. Build any DEB/UDEB packages required for the Live build
7. Copy any built-downloaded files into workarea directory for the "real" build
8. Perform Live build using live-build with the preconfigured, ad-hoc config tree

***

##### Quick Kodibuntu development links

* [Submitting a patch] (http://wiki.xbmc.org/index.php?title=HOW-TO_submit_a_patch) 
* [Coding guidelines] (http://forum.xbmc.org/showthread.php?tid=5238)
* [Kodi development] (http://wiki.xbmc.org/index.php?title=XBMC_development)

##### Useful links

* [Kodi wiki] (http://kodi.wiki/)
* [Kodi community forums] (http://forum.kodi.tv/)
* [Kodi website] (http://kodi.tv)

#### Enjoy Kodi and help us improve it today. :)
