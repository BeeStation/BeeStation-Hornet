/client/proc/_replacetext_player_report(text)
		text = replacetext(text, "%CKEY%", src.key)
		text = replacetext(text, "%MOB_NAME%", mob.name)
		text = replacetext(text, "%DATE%", time2text(world.realtime, "YYYY-MM-DD, hh:mm"))
		text = replacetext(text, "%ROUND_ID%", GLOB.round_id || "Unknown")
		text = replacetext(text, "%SERVER_NAME%", CONFIG_GET(string/servername) || "Unnamed Server")
		return text

/client/verb/get_ingame_report()
	set category = "Admin"
	set name = "Copy In-game Report Template"

	var/static/list/template_content = world.file2list("config/player_report_template.txt")
	var/list/textlines = template_content.Copy(2) // do not copy first line
	for(var/idx in 1 to length(textlines))
		var/text = textlines[idx]
		if(length(text))
			textlines[idx] = "<li>[text] </li>"
		else
			textlines[idx] = "<br class='no_text'>"

// NOTE: Because Byond uses IE11 (alike), Javascript is limited. You're welcome to change this someday.
	var/body = {"\
<script>
function copyToClipboard() {
	var textarea = document.getElementById('copy_area');
	textarea.value = document.getElementById('copy_content').innerText;
	textarea.style.display = 'inline';
	textarea.select();
	var successful = document.execCommand('copy');
	if (successful) {
		var copy_button = document.getElementById('copy_button');
		copy_button.innerText = 'Copy Successful!';
	} else {
		var copy_button = document.getElementById('copy_button');
		copy_button.innerText = 'Copy Failed!';
	}
	textarea.style.display = 'none';
}
</script>
<style>
#copy_content ul{
	margin: 0px;
	list-style-type: none;
}
#copy_area {
	display: none
}
.no_text br{
	margin: 10px 0;
}
</style>
<html>
	<body>
		<button id='copy_button' onclick='copyToClipboard()'>Copy to Clipboard</button>
		<textarea id='copy_area' rows='0' cols='0'></textarea>
		<span id='copy_content'>
			<ul>
				[_replacetext_player_report(textlines.Join())]
			</ul>
		</span>
	</html>
</body>
"}

	usr << browse(body, "window=template_report")
