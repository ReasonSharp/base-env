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

3. (Optional) If you skip the script's source prompt:
```bash
source ~/.bashrc
```
or restart terminal.

## Notes
- In interactive command line, `echo $HOME` will display the value of the `$HOME` that the system will use, but `cd ~` or `cd $HOME` will actually take you to your `$BASE` directory. If you want `echo $HOME` to print your `$BASE` dir, add it as a command exception to `base-env.sh`. Beware, though, some install instructions for certain softwares rely on `echo $HOME` or `echo ~` (yes, executed from CLI) to print your actual home dir -- you can prefix them with `HOME="$REAL_HOME"` but the burden of doing so is on you.
- In your scripts you can count on `$HOME` pointing to where it usually points - your actual home dir. If you want to reference files and paths in your `$BASE` dir, you should use `$BASE` instead of `$HOME` in scripts.
- You can add more command exceptions to `adjust_home` in `base-env.sh` if you want them to use `$BASE` interactively.
- Assumes BASH is you shell; tweak for others as needed.

