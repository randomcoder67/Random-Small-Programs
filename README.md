# Random Small Programs

A repository for random small scripts and programs I write. 

## Strava

Script to get info from Strava API. Currently supports viewing one of your activities by ID, and a segment by ID.  
Uses a bash script for the main functionality and calls a Python script to get the segment leaderboard because it's not included in the Strava API free functionality.  
**ToDo:** 
* Add ability to upload a ride
* Easier way to select activities and segments than using the ID

### Setup

Dependancies: `glow`, `jq`, `python requests` and `python BeautifulSoup4`  

Run `./strava.sh` and follow instructions 

### Usage 

Activity Information: `./strava.sh -r *activity_id*`  
Segment Information: `./strava.sh -s *segment_id*`

## Pro Cycling Stats

Python script to get current race information, at the moment only displays time gaps. 
**ToDo:**
* Display more information
* Work with TTs

### Setup

Dependancies: `python requests` and `python BeautifulSoup4`

### Usage

`python3 getInfo.py *refresh_Duration* (optional, default 10(s))` will display currently active races, enter the number corresponding to the race you want and it will display current time gaps and general race stats. **Note:** does not currently work for time trials as they are formatted differently. 

## Met Office 

Python script to get weather forecast from the MetOffice. (Uses web scraping, there is a MetOffice API but it has less detail than the webpage and also doesn't use HTTPS)

**ToDo**: 
* Add way to choose location 
* Add which day is currently selected 

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

Install `python music_tag`

### Usage 

Download the song from YouTube Music using this command:  
`yt-dlp -f 140 -o "%(title)s - %(channel)s - %(album)s.%(ext)s"`  
Or `yt-music` if using the `bashrc` from my dotfiles. 

Go to Apple Music and get the album ID (in the url when on the Apple Music album page)

`python3 tagMusicFile.py filename appleMusicAlbumID` 
