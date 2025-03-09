# Base Environment Bundle
Custom BASH setup for the working environment on Linux away from the clutter of $HOME while keeping `/home/$USER` for scripts.

## Install
1. Clone this repo:
```bash
git clone git@github.com:ReasonSharp/base-env.git ~/base-env
```
or
```bash
git clone https://github.com/ReasonSharp/base-env.git ~/base-env
```

2. Run the install script (optionally specify a base dir):
```bash
cd ~/base-env
./install.sh /yourbase # omit parameter to use /base
```
Follow the prompt(s) of the install script.

3. Apply changes to `.bashrc`:
```bash
source ~/.bashrc
```
or restart terminal.

## Notes
- In your scripts you can count on `$HOME` pointing to where it usually points - your actual home dir. If you want to reference files and paths in your `$BASE` dir, you should use `$BASE` instead of `$HOME` in scripts.
- Assumes BASH is you shell; tweak for others as needed.

