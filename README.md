# Migrator
Migrator for Mac OS with a simple graphical user interface. AppleScript powered. Designed for fast save and restore Mac OS applications and their settings.

The application is useful if you are reinstalling Mac OS or want to transfer configured applications to another computer.

КАРТИНКИ

## Features

Migrator itself does not scan your Applications directory. You enter the data into it yourself. Enter only the data that you need for the normal functioning of the application in the new location. There is no need to collect any service databases (sometimes quite large), caches, and more.

The application does not have any built-in database or interface for editing it. This is due to the fact that the necessary entries are made, as a rule, once. And only occasionally are they supplemented or changed. Having built-in functionality for this would unnecessarily complicate this project.

- The settings are stored in a plist file. Plist file <em>must be in the same directory</em> as the application. For editing, you can use any plist file editor.
- Don't worry if your username is in the settings path. When transferred to a machine with another user, the name will change to match the new location.
- If you do not want to delete an entry from the file, but want to hide it, then put an asterisk anywhere in the key line.






## System Requirements
- Mac OS Yosemite (10.10) or later
- Not tested on Apple M-series
