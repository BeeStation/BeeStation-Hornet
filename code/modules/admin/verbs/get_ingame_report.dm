
#define HTML_LISTIFY(_text) "<li>[_text]</li>"
/client/verb/get_ingame_report()
	set category = "Admin"
	set name = "Copy In-game Report Template"

	var/list/contents = list(
		HTML_LISTIFY("# In-game report: (by In-game template)"),
		HTML_LISTIFY("&lt!-- \[READ ME\] Title should be: \[Offender's CKEY\] Player Report --&gt"),
		HTML_LISTIFY("CKEY: [src.key]"),
		HTML_LISTIFY("Your Character Name: [mob.name]"),
		HTML_LISTIFY("Your Discord: "),
		HTML_LISTIFY("Offender's CKEY: "),
		HTML_LISTIFY("Offender's In-Game Name: "),
		HTML_LISTIFY("Date (YYYY-MM-DD): (UST) [time2text(world.realtime, "YYYY-MM-DD, hh:mm")] (template copied)"),
		HTML_LISTIFY("Round Number: [GLOB.round_id || "Unknown"] ([CONFIG_GET(string/servername) || "Unnamed Server"])"),
		HTML_LISTIFY("Rules Broken: "),
		HTML_LISTIFY("Incident Description: "),
		HTML_LISTIFY("Additional Information: ")
	)

// NOTE: Because Byond uses IE11 (alike), Javascript is limited. You're welcome to change this someday.
	var/body = {"\
<script>
function copyToClipboard() {
	var textToCopy = document.getElementById('copy_content').innerText;
	var tempTextarea = document.createElement('textarea');
	tempTextarea.value = textToCopy;
	document.body.appendChild(tempTextarea);
	tempTextarea.select();
	var successful = document.execCommand('copy');
	if (successful) {
		var copy_button = document.getElementById('copy_button');
		copy_button.innerText = 'Copy Successful!';
	} else {
		var copy_button = document.getElementById('copy_button');
		copy_button.innerText = 'Copy Failed!';
	}
	document.body.removeChild(tempTextarea);
}
</script>
<style>
#copy_content br{
	margin: 10px 0;
}
#copy_content ul{
	margin: 0px;
	list-style-type: none;
}
</style>
<html>
	<body>
		<button id='copy_button' onclick='copyToClipboard()'>Copy to Clipboard</button>
		<span id='copy_content'>
			<ul>
				[contents.Join("<br/>")]
			</ul>
		</span>
	</html>
</body>
"}

	usr << browse(body, "window=template_report")
#undef HTML_LISTIFY
