# AUR-PKGBUILD
PKGBUILDs in AUR.

Using GitHub actions to auto-update the pkgver and sha256sum, and build Arch packages.

If you don't want to build the packages yourself, you can try my repostries.

## Add my repositry
The packages are located at OneDrive and Cloudflare R2 Storage, choose one of you like.

Add the following code snippet to your `/etc/pacman.conf`:

```
[archlinux-sving1024]
#Cloudflare R2
Server = https://repo.sving1024.top/archlinux/
#Onedrive
Server = https://repo-vercel.sving1024.top/
Server = https://repo-onedrive.sving1024.top/api/raw?path=/
```

And import my pubkey:

```Bash
sudo pacman-key --recv-keys B3D5A089ABA053169C5FED50E3B24814F9927AFB && sudo pacman-key --lsign-key sving1024@outlook.com 
```

Then, run `sudo pacman -Syu` to update the repository and upgrade the system.

Now you can use `sudo pacman -S <pkg_name>` to install packages from my repository.

You may also want to use [archlinuxcn](https://github.com/archlinuxcn/repo) with the repo together. Some of the dependencies are provided in the repo.

Thanks vifly for his [arch-build](https://github.com/vifly/arch-build) project. If you want to build a repo like this, you can read [his post](https://viflythink.com/Use_GitHubActions_to_build_AUR/).
