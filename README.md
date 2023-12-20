# Migrator

Migrator for Mac OS with a simple graphical user interface. AppleScript powered. Designed for fast save and restore Mac OS applications and their settings.

The application is useful if you are reinstalling Mac OS or want to transfer configured applications to another computer. You don’t have to open .dmg files of each application, drag each one into Applications or run installers and re-enter a huge number of settings.

<p align="center">
<img width="420" src="https://github.com/telenkor/migrator/assets/31967374/4dcafa0c-4e0c-41c1-b1dc-88ef4be6d293">
</p>

<p align="center">
<img width="332" src="https://github.com/telenkor/migrator/assets/31967374/929221ea-d04b-43d3-b55e-9c594ceb569b">
</p>

<p align="center">
<img width="605" src="https://github.com/telenkor/migrator/assets/31967374/3c7b9421-5b0b-4a1e-a2bb-1892eec618e4">
</p>

## Features

Migrator itself does not scan your Applications directory. You enter the data into it yourself. Enter only the data that you need for the normal functioning of the application in the new location. There is no need to collect any service databases (sometimes quite large), caches, and more.

The application does not have any built-in database or interface for editing it. This is due to the fact that the necessary entries are made, as a rule, once. And only occasionally are they supplemented or changed. Having built-in functionality for this would unnecessarily complicate this project.

- The data are stored in a config.plist file. Config file <em>must be in the same directory</em> as the application. For editing, you can use any plist file editor.
- If you do not want to delete an entry from the file, but want to hide it, then add an asterisk to the appname (see point 1 below).
- If a backup for this application already exists, then Migrator will create a new one with a name: %appname% [YYYY.MM.DD.HHMM]

## Structure config.plist

<p align="center">
<img width="691" src="https://github.com/telenkor/migrator/assets/31967374/a4a9fcea-41bf-4179-91be-73e59e30be56">
</p>
The structure of the config.plist file opened in the PlistEdit Pro application is shown.

1. The name of the application as it will be shown in the Migrator GUI.
2. Names of child keys. They can be anything, but they must be different.
3. The name of the user's home directory when creating the backup. When installing from this backup on a system with a different home directory, this name will be changed to the current one automatically.

The source contains the <em>sample_config.plist</em>, which contains the paths of some popular applications and their settings.

You can also find settings for your application by searching for its <em>Bundle ID</em> on the system drive.

## Important

In the directory where applications with their settings are saved, do not create your own files or folders.

## System Requirements
- Mac OS Yosemite (10.10) or later
- Not tested on Apple M-series
