As the server operator you can place sound files in this directory and then include them in music.json to be served to players.

Please make sure to include the duration property in the JSON files, otherwise we will have to resort to a length-voting system which relies on clients to tell the truth.

These are valid properties in the json:
- audio_file (required if URL is unset): The audio file to be played in MP3 or MP4 format.
- url (required if audio_file is unset): The URL to download the audio file from, for this to work YT-DLP must be setup on the server. Note that youtube songs may not work depending on where you are hosting the server from.
- duration (required): The duration of the song in DECI-SECONDS (10 = 1 second)
- title (recommended): Title of the song to display in the TGUI player
- artist (recommended): The name of the artist to display in the TGUI player
- album (optional): Which album is this song a part of
- upload_date (optional): Date which the song was uploaded
- license (recommended): Either a typepath to a codified license, or a JSON object with the properties title (name of the license to show), legal_text (string, website link to raw legal document), url (string, website link) and attribution_required (bool).
- jukebox: 0 or 1 depending on whether this should show in the jukebox.
- lobbymusic: 0 or 1 depending on whether this should play in the lobby.
- roundend: 0 or 1 depending on whether this sound should play when the round ends.
- disabled: If set to 1, will not be loaded

Any other properties will be ignored, so you can add "comment" if you wish to provide more information.

Thank you, have a nice day.
