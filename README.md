# Random Small Programs

A repository for random small scripts and programs I write.  
Some finished and usable, some WIP. 

## REPO ARCHIVED

**I've moved these programs to other repos**

The current Strava script is now part of my dotfiles: [XFCE-Laptop-Config](https://github.com/randomcoder67/XFCE-Laptop-Config)  
In the future I plan to make a better Strava terminal program using Go, which will be here: [Go Terminal Strava](https://github.com/randomcoder67/Go-Terminal-Strava)

The Met Office program is now here (and will be improved): [Go Terminal Weather](https://github.com/randomcoder67/Go-Terminal-Weather)

Music Tag program is in my dotfiles: [XFCE-Laptop-Config](https://github.com/randomcoder67/XFCE-Laptop-Config)

md To Groff is also in my dotfiles: [XFCE-Laptop-Config](https://github.com/randomcoder67/XFCE-Laptop-Config)

The Pro Cycling Stats program broke, in the future I might remake it and add it to my dotfiles

## Strava

Script to interact with Strava API, can display activity and segment information, and upload a ride.  
Allows viewing Strava rides and segments and uploading rides without using a web browser.  
Uses a bash script for the main functionality and calls a Python script to get the segment leaderboard because it's not included in the Strava API free functionality.

**ToDo:** 
* Add ability to upload a ride - **DONE**
* Easier way to select activities and segments than using the ID - **DONE**

### Setup

Dependancies: `glow`, `jq`, `python requests` and `python BeautifulSoup4`  

Run `./strava.sh` and follow instructions 

### Usage 

Activity Information: `./strava.sh -r activity_id`  
Segment Information: `./strava.sh -s segment_id/index`

When you view an activity, it displays all the segments with an index. You can then run `./strava.sh -s index` to view the information for that segment. This saves typing the segment ID. The indexes are the same until a new activity is viewer. 

## Pro Cycling Stats

Python script to get current race information, at the moment only displays time gaps. 

**ToDo:**
* Display more information
* Work with TTs
* Fix (might be broken)

### Setup

Dependancies: `python requests` and `python BeautifulSoup4`

### Usage

`python3 getInfo.py *refresh_Duration* (optional, default 10(s))` will display currently active races, enter the number corresponding to the race you want and it will display current time gaps and general race stats. **Note:** does not currently work for time trials as they are formatted differently. 

## Met Office 

Python script to get weather forecast from the MetOffice. (Uses web scraping, there is a MetOffice API but it has less detail than the webpage and also doesn't use HTTPS)
Gives `curl wttr.in` like functionality but with more detail and more accuracy (at least in the UK) 

**ToDo**: 
* Add way to choose location - **DONE** 
* Add which day is currently selected - **DONE** 

### Setup 

Dependancies: `python BeautifulSoup4` `python requests` `python curses`

Create file `locations.csv` in the same directory as metOffice.py of the format:
```
Location Name|Location ID
Location Name|Location ID
```

`Location ID` is the string after forecast in the url

### Usage 

`python3 metOffice.py`

The program uses a Curses interface. Use `Left` and `Right` to go between days, and `Up` and `Down` to go forwards backwards in a day when applicable.  
`l` to show Legend/Key  
`q` to quit

## Music Tag 

Python script to tag a music file downloaded from YouTube music. 

### Setup 

Install `python music_tag` using pip or manually or Arch  
`pacman -S python-mutagen python-pillow`  

### Usage 

Download the song from YouTube Music using this command:  
`yt-dlp -f 140 -o "%(title)s - %(channel)s - %(album)s.%(ext)s"`  
Or `yt-music` if using the `bashrc` from my dotfiles. 

Go to Apple Music and get the album ID (in the url when on the Apple Music album page)

`python3 tagMusicFile.py filename appleMusicAlbumID`

## md To Groff 

Program to convert a markdown file into a pdf without the use of pandoc or latex. WIP 

Still figuring out how best to handle images. Using `.pdf` images looks the best, but it requires the `-U` unsafe option for groff, unlike `.ps` or `.eps` images. 

### Setup 

`go mod tidy`  
`go get github.com/gomarkdown/markdown`

### Usage 

`go run groff.go input.md output.pdf`
