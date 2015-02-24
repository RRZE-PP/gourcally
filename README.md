# gourcally

## Description

gourcally is a little bash script that renders automatically videos for list of subversion repositories with [gource](http://code.google.com/p/gource/). It also checks if a video of the actual revision of a repository already exists and skips it in this case (to save render time).

## Requirements

To use this script you need the following software:

* [bash](http://www.gnu.org/software/bash/)
* [subversion](http://subversion.apache.org/)
* [gource](http://subversion.apache.org/)
* [avconv](https://libav.org/avconv.html)

## Usage

Before you start using the script you have to create a config file with your settings. Use the config_template file to create your own config file. There are comments in the template file, which explain what you have to put there. For the gource options in the config file also have a look at the [gource wiki](http://code.google.com/p/gource/wiki/Controls). After you created your own config file you can use this script with the following options:

```
Usage: ./gourcally [options]

  -h		show this help text
  -c [FILE]	path to config file (see config_template for help) [MANDATORY]
  -f		force rendering of all videos (i.e. no check if there is already a up-to-date video)
```

## Motivation

The script was written to render videos with gource for the numerous repositories of the [Projects & Processes](http://blogs.fau.de/pp/) department of the [Regional Computing Centre of Erlangen (RRZE)](http://www.rrze.fau.de/). We want to automate the rendering of gource videos for more than one repository to save time and also make gource easier to use.

## License

This script is licensed under [GPL 3 license](http://www.gnu.org/licenses/gpl.html).

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.
