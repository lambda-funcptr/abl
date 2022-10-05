#!/usr/bin/chibi-scheme -q

(import (chibi app))
(import (chibi filesystem))
(import (chibi io))
(import (chibi json))
(import (chibi process))
(import (scheme base))
(import (scheme r5rs))
(import (scheme process-context))
(import (srfi 130))

(define pkg-list 
  '("alpine-base"
    "busybox"
    "cpio"
    "cryptsetup"
    "efibootmgr"
    "gcompat"
    "kexec-tools"
    "lvm2"
    "mdadm"
    "ncurses-libs"
    "util-linux"))

(define (clone-kernel-sources)
  (begin
    (display ">>> Cloning kernel from upstream...") (newline)
    (with-directory "/tmp/dist"
      (lambda ()
        (system '(git clone --depth 1 --no-tags git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git linux))))
    (display ">>> Finished cloning kernel") (newline)))

(define (setup-kernel-sources) 
  (if (file-directory? "/tmp/dist/linux")
    (begin 
      (display ">>> Kernel sources found - skipping clone") (newline))
    (begin 
      (display ">>> Kernel sources not detected") (newline)
      (clone-kernel-sources))))

(define (cfg-kernel interactive) 
  (if (not (file-exists? "/tmp/dist/kernel.config")) 
    (begin 
      (display ">>> No kernel configuration detected, copying in initial config - this may need to be updated") (newline)
      (system '(cp /opt/abl/kernel.config /tmp/dist/linux/.config))
      (system '(cp /opt/abl/kernel.config /tmp/dist/kernel.config))
      (with-directory "/tmp/dist/linux"
        (lambda ()
          (system '(make oldconfig))))
      (cfg-kernel interactive))
    (if interactive
      (with-directory "/tmp/dist/linux"
        (lambda ()
          (begin
            (system '(make menuconfig))
            (system '(make oldconfig))
            (system '(cp /tmp/dist/linux/.config /tmp/dist/kernel.config))
            (display "New configs saved to dist/kernel.config") (newline))))
        #f)))

(define (cmd-cfg-kernel value cmdinfo) 
  (begin
    (setup-kernel-sources)
    (cfg-kernel #t)))

(define (build-kernel?) 
  (with-directory "/tmp/dist/linux"
    (lambda ()
      (system? '(make)))))

(define (apk-init)
  (begin
    (when 
      (not 
        (and
          (create-directory* "/tmp/abl/etc/apk")
          (system? '(cp /etc/apk/repositories /tmp/abl/etc/apk/repositories)) 
          (system? (append '(apk add --initdb --root /tmp/abl --allow-untrusted busybox)))))
      (exit 1))))

(define (apkstrap packages)
  (let 
    ((pkg-add-status 
      (system?
          (append '(apk add --root /tmp/abl --allow-untrusted busybox) packages))))
    (when (not pkg-add-status) (exit 1))))

(define (chroot-shell? cmd)
  (system? "chroot" "/tmp/abl" "/bin/sh" "-c" (string-append "source /etc/profile; " cmd)))

(define (cmd-build-abl value cmdinfo)
  (begin
    (display ">>> Setting up kernel sources...") (newline)
    (setup-kernel-sources)
    (cfg-kernel #f)
    (display ">>> Configuring apk...") (newline)
    (apk-init)
    (display ">>> Installing packages...") (newline)
    (apkstrap pkg-list)
    (display ">>> Applying ABL userspace...") (newline)
    (system '(rsync -avr /opt/abl/overlay/ /tmp/abl/)) (newline)
    (chroot-shell? "rc-update add mdev sysinit")
    (chroot-shell? "rc-update add syslog boot")
    (chroot-shell? "rc-update add mount-ro shutdown")
    (chroot-shell? "rc-update add killprocs shutdown")
    (display ">>> Building Kernel...") (newline)
    (unless (build-kernel?)
      (display "!!! Failed to build kernel!") (newline)
      (exit 1))
    (system '(cp /tmp/dist/linux/arch/x86/boot/bzImage /tmp/dist/abl))
    (display ">>> Successfully built ABL to dist/abl") (newline)))

(run-application 
  `(build.scm
    "ABL Build Tool"
    (or
      (config "Configure kernel" () (,cmd-cfg-kernel))
      (build "Build ABL EFI Binary" () (,cmd-build-abl))
      (help "Prints help" () (,app-help-command))))
  (command-line))
