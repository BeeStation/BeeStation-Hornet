## DOWNLOADING

There are a number of ways to download the source code. Some are described here, an alternative all-inclusive guide is also located at <https://wiki.beestation13.com/view/Downloading_the_source_code>.

Option 1:
Follow this: <https://wiki.beestation13.com/view/Setting_up_git>.

Option 2: Download the source code as a zip by clicking the ZIP button in the code tab of <https://github.com/Monkestation/MonkeStation>.
(note: this will use a lot of bandwidth if you wish to update and is a lot of hassle if you want to make any changes at all, so it's not recommended.)

Option 3: Use our docker image that tracks the master branch (See commits for build status. Again, same caveats as option 2)

```text
docker run -d -p <your port>:1337 -v /path/to/your/config:/beestation/config -v /path/to/your/data:/beestation/data beestation/beestation <dream daemon options i.e. -public or -params>
```
