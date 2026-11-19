# My Basic Linux SetUp

Post-install setup scripts. When I install a fresh Linux system, this is
the first thing I run.

| Script | Target |
|---|---|
| `Csetup.sh` | Debian and Ubuntu based systems |
| `Arch.sh` | Arch based systems |
| `setup.sh` | Menu launcher that picks one of the above |

Every install is non-interactive — the scripts pass `-y` (apt) or
`--noconfirm` (pacman), so you don't have to answer a prompt over and
over. You're asked for your `sudo` password once at the start, and it's
kept alive for the whole run.

Both scripts are built to be quick: repositories are added up front so
the package lists refresh only once, and packages install in one batch.
If anything fails, the script keeps going, lists what failed at the end,
and exits non-zero.

## What gets installed

**`Csetup.sh` (Debian/Ubuntu)**

| | |
|---|---|
| Browsers | Brave (official repository, added with a keyring) |
| Multimedia | GIMP, Scribus |
| Gaming | Steam (enables i386), Lutris (Ubuntu only) |
| Development | Git, default JRE and JDK |
| Cleanup | Purges `ubuntu-web-launchers`, `thunderbird`, `rhythmbox` if installed; disables Apport |

**`Arch.sh` (Arch)**

| | |
|---|---|
| Browsers | Brave (`brave-bin` from the AUR via paru/yay, or Flatpak) |
| Multimedia | GIMP |
| Development | Git, `jdk-openjdk` (includes `jre-openjdk`) |

## Run it

From wherever you cloned or downloaded it:

```bash
chmod +x setup.sh
./setup.sh
```

A menu asks you to pick **Debian/Ubuntu** or **Arch** (your current distro
is pre-selected), shows what will be installed, and runs the matching
script once you confirm. It uses `whiptail` or `dialog` if one is
installed, and falls back to a numbered text menu otherwise.

You can still run a script directly: `./Csetup.sh` or `./Arch.sh`.

## Notes

- **Brave key.** Installing it uses a keyring file in the modern
  `/etc/apt/keyrings` location. The older `apt-key` command is removed in
  Debian 12 and newer, and deprecated in Ubuntu 22.04 and newer.
- **Lutris is Ubuntu only.** It comes from a PPA, and plain Debian has no
  `add-apt-repository` PPA support. On Debian the script skips it and says so.
- **Debian vs Ubuntu.** The cleanup step only removes packages that are
  actually installed, so names that don't exist on Debian
  (`ubuntu-web-launchers`) don't break it.
- **Steam on Debian** needs the `contrib` and `non-free` components enabled
  in your apt sources. If they're off, Steam shows up as failed in the
  summary and everything else still installs.
- **Brave on Arch** isn't in the official repos. The script uses `paru` or
  `yay` if you have one installed, then Flatpak; otherwise it skips Brave.
- **`zenity` and `notify-send`** are installed by the scripts, so the
  "All Done!" popup works on a fresh system.
- **Arch package names differ.** Java is `jdk-openjdk` there — `default-jre` and `default-jdk` are Debian names and don't exist
  in the Arch repositories.
- Review the package lists before running. Both scripts install software
  and remove packages from your system.
