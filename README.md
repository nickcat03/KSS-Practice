# Kirby Super Star Practice Hack

This page hosts the source code for the Kirby Super Star speedrunning practice hack. Feel free to contribute or use this code in your own projects.

## How to patch:
Stable IPS patches will be uploaded to [this site](https://nippoverse.xyz/kss-practice/), but you can patch the ROM using the most recent version in this repository. Note that this version may not produce the most stable results, as the IPS files are intended to be more "complete" versions. 

You may use [Lunar IPS](http://fusoya.eludevisibility.org/lips/) or [Floating IPS](https://www.romhacking.net/utilities/1040/) to patch the ROM this way. The patch is expecting a Japanese 1.0 ROM file.

1. Clone the repository (click the big green button at the top)
2. Download [asar](https://github.com/RPGHacker/asar) and place it in the project folder.
3. Place a Japanese 1.0 ROM of Kirby Super Star in the project folder, and name it "original.sfc".
4. Run make_file.bat (Windows) or make_file.sh (Unix).
5. You should now have "patched.sfc" which is the patched file.

Please note that any other Japanese ROM version may not work, it needs to be 1.0.
