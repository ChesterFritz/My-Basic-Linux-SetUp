# My Basic Linux SetUp

Post-install setup scripts. When I install a fresh Linux system, this is
the first thing I run.

| Script | Target |
|---|---|
| `Csetup.sh` | Debian and Ubuntu based systems |
| `Arch.sh` | Arch based systems |

Every install is non-interactive — the scripts pass `-y` (apt) or
`--noconfirm` (pacman), so you don't have to answer a prompt over and
over. You'll still be asked for your `sudo` password.

## What gets installed

**`Csetup.sh` (Debian/Ubuntu)**

| | |
|---|---|
| Browsers | Brave (official repository, added with a keyring) |
| Multimedia | GIMP, Scribus |
| Gaming | Steam, Lutris |
| Development | Git, default JRE and JDK |
| Cleanup | Removes `ubuntu-web-launchers`, `thunderbird`, `rhythmbox`; disables Apport |

**`Arch.sh` (Arch)**

| | |
|---|---|
| Browsers | Brave |
| Multimedia | GIMP |
| Development | Git, `jre-openjdk`, `jdk-openjdk` |

## Run it

You don't need to move the file. From wherever you cloned or downloaded it:

```bash
chmod +x Csetup.sh
./Csetup.sh
```

Or for Arch based systems:

```bash
chmod +x Arch.sh
./Arch.sh
```

## Notes

- **Brave key.** Installing it uses a keyring file in the modern
  `/etc/apt/keyrings` location. The older `apt-key` command is removed in
  Debian 12 and newer, and deprecated in Ubuntu 22.04 and newer.
- **Lutris is Ubuntu only.** It comes from a PPA, and plain Debian has no
  `add-apt-repository` PPA support. On Debian the script skips it and says so.
- **Debian vs Ubuntu.** The cleanup step targets packages that ship with
  Ubuntu (`ubuntu-web-launchers`, `rhythmbox`). On plain Debian those
  removals simply find nothing to remove, which is harmless.
- **`zenity` and `notify-send`** are installed by the scripts, so the
  "All Done!" popup works on a fresh system.
- **Arch package names differ.** Java is `jre-openjdk` and `jdk-openjdk`
  there — `default-jre` and `default-jdk` are Debian names and don't exist
  in the Arch repositories.
- Review the package lists before running. Both scripts install software
  and remove packages from your system.
