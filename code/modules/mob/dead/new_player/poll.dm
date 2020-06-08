/datum/polloption
	var/optionid
	var/optiontext

/mob/dead/new_player/proc/handle_player_polling()
	if(!SSdbcore.IsConnected())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	var/datum/DBQuery/query_poll_get = SSdbcore.NewQuery("SELECT id, question FROM [format_table_name("poll_question")] WHERE Now() BETWEEN starttime AND endtime [(client.holder ? "" : "AND adminonly = false")]")
	if(!query_poll_get.warn_execute())
		qdel(query_poll_get)
		return
	var/output = "<div align='center'><B>Player polls</B><hr><table>"
	var/i = 0
	var/rs = REF(src)
	while(query_poll_get.NextRow())
		var/pollid = query_poll_get.item[1]
		var/pollquestion = query_poll_get.item[2]
		output += "<tr bgcolor='#[ (i % 2 == 1) ? "e2e2e2" : "e2e2e2" ]'><td><a href=\"byond://?src=[rs];pollid=[pollid]\"><b>[pollquestion]</b></a></td></tr>"
		i++
	qdel(query_poll_get)
	output += "</table>"
	if(!QDELETED(src))
		src << browse(output,"window=playerpolllist;size=500x300")

/mob/dead/new_player/proc/poll_player(pollid)
	if(!pollid)
		return
	if (!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	var/datum/DBQuery/query_poll_get_details = SSdbcore.NewQuery("SELECT starttime, endtime, question, polltype, multiplechoiceoptions, minimumplaytime FROM [format_table_name("poll_question")] WHERE id = [pollid]")
	if(!query_poll_get_details.warn_execute())
		qdel(query_poll_get_details)
		return
	var/pollstarttime = ""
	var/pollendtime = ""
	var/pollquestion = ""
	var/polltype = ""
	var/multiplechoiceoptions = 0
	var/minimumplaytime = 0
	if(query_poll_get_details.NextRow())
		pollstarttime = query_poll_get_details.item[1]
		pollendtime = query_poll_get_details.item[2]
		pollquestion = query_poll_get_details.item[3]
		polltype = query_poll_get_details.item[4]
		multiplechoiceoptions = text2num(query_poll_get_details.item[5])
		minimumplaytime = text2num(query_poll_get_details.item[6])
	qdel(query_poll_get_details)
	var/player_playtime = round(client?.get_exp_living(FALSE) / 60)
	if(!isnull(player_playtime) && (player_playtime < minimumplaytime))
		to_chat(usr, "<span class='warning'>You do not have sufficient playtime to vote in this poll. Minimum: [minimumplaytime] hour(s). Your playtime: [player_playtime] hour(s).</span>")
		return
	switch(polltype)
		if(POLLTYPE_OPTION)
			var/datum/DBQuery/query_option_get_votes = SSdbcore.NewQuery("SELECT optionid FROM [format_table_name("poll_vote")] WHERE pollid = [pollid] AND ckey = '[ckey]'")
			if(!query_option_get_votes.warn_execute())
				qdel(query_option_get_votes)
				return
			var/votedoptionid = 0
			if(query_option_get_votes.NextRow())
				votedoptionid = text2num(query_option_get_votes.item[1])
			qdel(query_option_get_votes)
			var/list/datum/polloption/options = list()
			var/datum/DBQuery/query_option_options = SSdbcore.NewQuery("SELECT id, text FROM [format_table_name("poll_option")] WHERE pollid = [pollid]")
			if(!query_option_options.warn_execute())
				qdel(query_option_options)
				return
			while(query_option_options.NextRow())
				var/datum/polloption/PO = new()
				PO.optionid = text2num(query_option_options.item[1])
				PO.optiontext = query_option_options.item[2]
				options += PO
			qdel(query_option_options)
			var/output = "<div align='center'><B>Player poll</B><hr>"
			output += "<b>Question: [pollquestion]</b><br>"
			output += "<font size='2'>Poll runs from <b>[pollstarttime]</b> until <b>[pollendtime]</b></font><p>"
			if(!votedoptionid)
				output += "<form name='cardcomp' action='?src=[REF(src)]' method='get'>"
				output += "<input type='hidden' name='src' value='[REF(src)]'>"
				output += "<input type='hidden' name='votepollid' value='[pollid]'>"
				output += "<input type='hidden' name='votetype' value=[POLLTYPE_OPTION]>"
			output += "<table><tr><td>"
			for(var/datum/polloption/O in options)
				if(O.optionid && O.optiontext)
					if(votedoptionid)
						if(votedoptionid == O.optionid)
							output += "<b>[O.optiontext]</b><br>"
						else
							output += "[O.optiontext]<br>"
					else
						output += "<input type='radio' name='voteoptionid' value='[O.optionid]'>[O.optiontext]<br>"
			output += "</td></tr></table>"
			if(!votedoptionid)
				output += "<p><input type='submit' value='Vote'>"
				output += "</form>"
			output += "</div>"
			src << browse(null ,"window=playerpolllist")
			src << browse(output,"window=playerpoll;size=500x250")
		if(POLLTYPE_TEXT)
			var/datum/DBQuery/query_text_get_votes = SSdbcore.NewQuery("SELECT replytext FROM [format_table_name("poll_textreply")] WHERE pollid = [pollid] AND ckey = '[ckey]'")
			if(!query_text_get_votes.warn_execute())
				qdel(query_text_get_votes)
				return
			var/vote_text = ""
			if(query_text_get_votes.NextRow())
				vote_text = query_text_get_votes.item[1]
			qdel(query_text_get_votes)
			var/output = "<div align='center'><B>Player poll</B><hr>"
			output += "<b>Question: [pollquestion]</b><br>"
			output += "<font size='2'>Feedback gathering runs from <b>[pollstarttime]</b> until <b>[pollendtime]</b></font><p>"
			output += "<form name='cardcomp' action='?src=[REF(src)]' method='get'>"
			output += "<input type='hidden' name='src' value='[REF(src)]'>"
			output += "<input type='hidden' name='votepollid' value='[pollid]'>"
			output += "<input type='hidden' name='votetype' value=[POLLTYPE_TEXT]>"
			output += "<font size='2'>Please provide feedback below. You can use any letters of the English alphabet, numbers and the symbols: . , ! ? : ; -</font><br>"
			output += "<textarea name='replytext' cols='50' rows='14'>[vote_text]</textarea>"
			output += "<p><input type='submit' value='Submit'></form>"
			output += "<form name='cardcomp' action='?src=[REF(src)]' method='get'>"
			output += "<input type='hidden' name='src' value='[REF(src)]'>"
			output += "<input type='hidden' name='votepollid' value='[pollid]'>"
			output += "<input type='hidden' name='votetype' value=[POLLTYPE_TEXT]>"
			output += "<input type='hidden' name='replytext' value='ABSTAIN'>"
			output += "<input type='submit' value='Abstain'></form>"

			src << browse(null ,"window=playerpolllist")
			src << browse(output,"window=playerpoll;size=500x500")
		if(POLLTYPE_RATING)
			var/datum/DBQuery/query_rating_get_votes = SSdbcore.NewQuery("SELECT o.text, v.rating FROM [format_table_name("poll_option")] o, [format_table_name("poll_vote")] v WHERE o.pollid = [pollid] AND v.ckey = '[ckey]' AND o.id = v.optionid")
			if(!query_rating_get_votes.warn_execute())
				qdel(query_rating_get_votes)
				return
			var/output = "<div align='center'><B>Player poll</B><hr>"
			output += "<b>Question: [pollquestion]</b><br>"
			output += "<font size='2'>Poll runs from <b>[pollstarttime]</b> until <b>[pollendtime]</b></font><p>"
			var/rating
			while(query_rating_get_votes.NextRow())
				var/optiontext = query_rating_get_votes.item[1]
				rating = query_rating_get_votes.item[2]
				output += "<br><b>[optiontext] - [rating]</b>"
			qdel(query_rating_get_votes)
			if(!rating)
				output += "<form name='cardcomp' action='?src=[REF(src)]' method='get'>"
				output += "<input type='hidden' name='src' value='[REF(src)]'>"
				output += "<input type='hidden' name='votepollid' value='[pollid]'>"
				output += "<input type='hidden' name='votetype' value=[POLLTYPE_RATING]>"
				var/minid = 999999
				var/maxid = 0
				var/datum/DBQuery/query_rating_options = SSdbcore.NewQuery("SELECT id, text, minval, maxval, descmin, descmid, descmax FROM [format_table_name("poll_option")] WHERE pollid = [pollid]")
				if(!query_rating_options.warn_execute())
					qdel(query_rating_options)
					return
				while(query_rating_options.NextRow())
					var/optionid = text2num(query_rating_options.item[1])
					var/optiontext = query_rating_options.item[2]
					var/minvalue = text2num(query_rating_options.item[3])
					var/maxvalue = text2num(query_rating_options.item[4])
					var/descmin = query_rating_options.item[5]
					var/descmid = query_rating_options.item[6]
					var/descmax = query_rating_options.item[7]
					if(optionid < minid)
						minid = optionid
					if(optionid > maxid)
						maxid = optionid
					var/midvalue = round( (maxvalue + minvalue) / 2)
					output += "<br>[optiontext]: <select name='o[optionid]'>"
					output += "<option value='abstain'>abstain</option>"
					for (var/j = minvalue; j <= maxvalue; j++)
						if(j == minvalue && descmin)
							output += "<option value='[j]'>[j] ([descmin])</option>"
						else if (j == midvalue && descmid)
							output += "<option value='[j]'>[j] ([descmid])</option>"
						else if (j == maxvalue && descmax)
							output += "<option value='[j]'>[j] ([descmax])</option>"
						else
							output += "<option value='[j]'>[j]</option>"
					output += "</select>"
				qdel(query_rating_options)
				output += "<input type='hidden' name='minid' value='[minid]'>"
				output += "<input type='hidden' name='maxid' value='[maxid]'>"
				output += "<p><input type='submit' value='Submit'></form>"
			if(!QDELETED(src))
				src << browse(null ,"window=playerpolllist")
				src << browse(output,"window=playerpoll;size=500x500")
		if(POLLTYPE_MULTI)
			var/datum/DBQuery/query_multi_get_votes = SSdbcore.NewQuery("SELECT optionid FROM [format_table_name("poll_vote")] WHERE pollid = [pollid] AND ckey = '[ckey]'")
			if(!query_multi_get_votes.warn_execute())
				qdel(query_multi_get_votes)
				return
			var/list/votedfor = list()
			while(query_multi_get_votes.NextRow())
				votedfor.Add(text2num(query_multi_get_votes.item[1]))
			qdel(query_multi_get_votes)
			var/list/datum/polloption/options = list()
			var/maxoptionid = 0
			var/minoptionid = 0
			var/datum/DBQuery/query_multi_options = SSdbcore.NewQuery("SELECT id, text FROM [format_table_name("poll_option")] WHERE pollid = [pollid]")
			if(!query_multi_options.warn_execute())
				qdel(query_multi_options)
				return
			while(query_multi_options.NextRow())
				var/datum/polloption/PO = new()
				PO.optionid = text2num(query_multi_options.item[1])
				PO.optiontext = query_multi_options.item[2]
				if(PO.optionid > maxoptionid)
					maxoptionid = PO.optionid
				if(PO.optionid < minoptionid || !minoptionid)
					minoptionid = PO.optionid
				options += PO
			qdel(query_multi_options)
			var/output = "<div align='center'><B>Player poll</B><hr>"
			output += "<b>Question: [pollquestion]</b><br>You can select up to [multiplechoiceoptions] options. If you select more, the first [multiplechoiceoptions] will be saved.<br>"
			output += "<font size='2'>Poll runs from <b>[pollstarttime]</b> until <b>[pollendtime]</b></font><p>"
			if(!votedfor.len)
				output += "<form name='cardcomp' action='?src=[REF(src)]' method='get'>"
				output += "<input type='hidden' name='src' value='[REF(src)]'>"
				output += "<input type='hidden' name='votepollid' value='[pollid]'>"
				output += "<input type='hidden' name='votetype' value=[POLLTYPE_MULTI]>"
				output += "<input type='hidden' name='maxoptionid' value='[maxoptionid]'>"
				output += "<input type='hidden' name='minoptionid' value='[minoptionid]'>"
			output += "<table><tr><td>"
			for(var/datum/polloption/O in options)
				if(O.optionid && O.optiontext)
					if(votedfor.len)
						if(O.optionid in votedfor)
							output += "<b>[O.optiontext]</b><br>"
						else
							output += "[O.optiontext]<br>"
					else
						output += "<input type='checkbox' name='option_[O.optionid]' value='[O.optionid]'>[O.optiontext]<br>"
			output += "</td></tr></table>"
			if(!votedfor.len)
				output += "<p><input type='submit' value='Vote'></form>"
			output += "</div>"
			src << browse(null ,"window=playerpolllist")
			src << browse(output,"window=playerpoll;size=500x250")
		if(POLLTYPE_IRV)
			var/datum/asset/irv_assets = get_asset_datum(/datum/asset/group/IRV)
			irv_assets.send(src)

/**
  * Shows voting window for an option type poll, listing its options and relevant details.
  *
  * If already voted on, the option a player voted for is pre-selected.
  *
  */
/mob/dead/new_player/proc/poll_player_option(datum/poll_question/poll)
	var/datum/DBQuery/query_option_get_voted = SSdbcore.NewQuery({"
		SELECT optionid FROM [format_table_name("poll_vote")]
		WHERE pollid = :pollid AND ckey = :ckey AND deleted = 0
	"}, list("pollid" = poll.poll_id, "ckey" = ckey))
	if(!query_option_get_voted.warn_execute())
		qdel(query_option_get_voted)
		return
	var/voted_option_id = 0
	if(query_option_get_voted.NextRow())
		voted_option_id = text2num(query_option_get_voted.item[1])
	qdel(query_option_get_voted)
	var/list/output = list("<div align='center'><B>Player poll</B><hr><b>Question: [poll.question]</b><br>")
	if(poll.subtitle)
		output += "[poll.subtitle]<br>"
	output += "<font size='2'>Poll runs from <b>[poll.start_datetime]</b> until <b>[poll.end_datetime]</b></font><br>"
	if(poll.allow_revoting)
		output += "<font size='2'>Revoting is enabled.</font>"
	if(!voted_option_id || poll.allow_revoting)
		output += {"<form action='?src=[REF(src)]' method='get'>
		<input type='hidden' name='src' value='[REF(src)]'>
		<input type='hidden' name='votepollref' value='[REF(poll)]'>
		"}
	output += "<table><tr><td>"
	for(var/o in poll.options)
		var/datum/poll_option/option = o
		output += "<label><input type='radio' name='voteoptionref' value='[REF(option)]'"
		if(voted_option_id && !poll.allow_revoting)
			output += " disabled"
		if(voted_option_id == option.option_id)
			output += " selected"
		output += ">[option.text]</label><br>"
	output += "</td></tr></table>"
	if(!voted_option_id || poll.allow_revoting)
		output += "<p><input type='submit' value='Vote'></form>"
	output += "</div>"
	src << browse(jointext(output, ""),"window=playerpoll;size=500x250")

/**
  * Shows voting window for a text response type poll, listing its relevant details.
  *
  * If already responded to, the saved response of a player is shown.
  *
  */
/mob/dead/new_player/proc/poll_player_text(datum/poll_question/poll)
	var/datum/DBQuery/query_text_get_replytext = SSdbcore.NewQuery({"
		SELECT replytext FROM [format_table_name("poll_textreply")]
		WHERE pollid = :pollid AND ckey = :ckey AND deleted = 0
	"}, list("pollid" = poll.poll_id, "ckey" = ckey))
	if(!query_text_get_replytext.warn_execute())
		qdel(query_text_get_replytext)
		return
	var/reply_text = ""
	if(query_text_get_replytext.NextRow())
		reply_text = query_text_get_replytext.item[1]
	qdel(query_text_get_replytext)
	var/list/output = list("<div align='center'><B>Player poll</B><hr><b>Question: [poll.question]</b><br>")
	if(poll.subtitle)
		output += "[poll.subtitle]<br>"
	output += "<font size='2'>Feedback gathering runs from <b>[poll.start_datetime]</b> until <b>[poll.end_datetime]</b></font><br>"
	if(poll.allow_revoting)
		output += "<font size='2'>Revoting is enabled.</font>"
	if(!reply_text || poll.allow_revoting)
		output += {"<form action='?src=[REF(src)]' method='get'>
		<input type='hidden' name='src' value='[REF(src)]'>
		<input type='hidden' name='votepollref' value='[REF(poll)]'>
		<font size='2'>Please provide feedback below. You can use any letters of the English alphabet, numbers and the symbols: . , ! ? : ; -</font><br>
		<textarea name='replytext' cols='50' rows='14'>[reply_text]</textarea>
		<p><input type='submit' value='Submit'></form>
		"}
	else
		output += "[reply_text]"
	output += "</div>"
	src << browse(jointext(output, ""),"window=playerpoll;size=500x500")

/**
  * Shows voting window for a rating type poll, listing its options and relevant details.
  *
  * If already voted on, the options a player voted for are pre-selected.
  *
  */
/mob/dead/new_player/proc/poll_player_rating(datum/poll_question/poll)
	var/datum/DBQuery/query_rating_get_votes = SSdbcore.NewQuery({"
		SELECT optionid, rating FROM [format_table_name("poll_vote")]
		WHERE pollid = :pollid AND ckey = :ckey AND deleted = 0
	"}, list("pollid" = poll.poll_id, "ckey" = ckey))
	if(!query_rating_get_votes.warn_execute())
		qdel(query_rating_get_votes)
		return
	var/list/voted_ratings = list()
	while(query_rating_get_votes.NextRow())
		voted_ratings += list("[query_rating_get_votes.item[1]]" = query_rating_get_votes.item[2])
	qdel(query_rating_get_votes)
	var/list/output = list("<div align='center'><B>Player poll</B><hr><b>Question: [poll.question]</b><br>")
	if(poll.subtitle)
		output += "[poll.subtitle]<br>"
	output += "<font size='2'>Poll runs from <b>[poll.start_datetime]</b> until <b>[poll.end_datetime]</b></font><br>"
	if(poll.allow_revoting)
		output += "<font size='2'>Revoting is enabled.</font>"
	if(!length(voted_ratings) || poll.allow_revoting)
		output += {"<form action='?src=[REF(src)]' method='get'>
		<input type='hidden' name='src' value='[REF(src)]'>
		<input type='hidden' name='votepollref' value='[REF(poll)]'>
		"}
	for(var/o in poll.options)
		var/datum/poll_option/option = o
		var/mid_val = round((option.max_val + option.min_val) / 2)
		var/selected_rating = text2num(voted_ratings["[option.option_id]"])
		output += "<label><br>[option.text]: <select name='[REF(option)]'"
		if(length(voted_ratings) && !poll.allow_revoting)
			output += " disabled"
		output += ">"
		for(var/rating in option.min_val to option.max_val)
			output += "<option value='[rating]'"
			if(selected_rating == rating)
				output += " selected"
			output += ">[rating]"
			if(option.desc_min && rating == option.min_val)
				output += " ([option.desc_min])"
			else if(option.desc_mid && rating == mid_val)
				output += " ([option.desc_mid])"
			else if(option.desc_max && rating == option.max_val)
				output += " ([option.desc_max])"
			output += "</option>"
		output += "</select></label>"
	if(!length(voted_ratings) || poll.allow_revoting)
		output += "<p><input type='submit' value='Submit'></form>"
	output += "</div>"
	src << browse(jointext(output, ""),"window=playerpoll;size=500x500")

/**
  * Shows voting window for a multiple choice type poll, listing its options and relevant details.
  *
  * If already voted on, the options a player voted for are pre-selected.
  *
  */
/mob/dead/new_player/proc/poll_player_multi(datum/poll_question/poll)
	var/datum/DBQuery/query_multi_get_votes = SSdbcore.NewQuery({"
		SELECT optionid FROM [format_table_name("poll_vote")]
		WHERE pollid = :pollid AND ckey = :ckey AND deleted = 0
	"}, list("pollid" = poll.poll_id, "ckey" = ckey))
	if(!query_multi_get_votes.warn_execute())
		qdel(query_multi_get_votes)
		return
	var/list/voted_for = list()
	while(query_multi_get_votes.NextRow())
		voted_for += text2num(query_multi_get_votes.item[1])
	qdel(query_multi_get_votes)
	var/list/output = list("<div align='center'><B>Player poll</B><hr><b>Question: [poll.question]</b><br>")
	if(poll.subtitle)
		output += "[poll.subtitle]<br>"
	output += "You can select up to [poll.options_allowed] options. If you select more, the first [poll.options_allowed] will be saved.<br><font size='2'>Poll runs from <b>[poll.start_datetime]</b> until <b>[poll.end_datetime]</b></font><br>"
	if(poll.allow_revoting)
		output += "<font size='2'>Revoting is enabled.</font>"
	if(!length(voted_for) || poll.allow_revoting)
		output += {"<form action='?src=[REF(src)]' method='get'>
		<input type='hidden' name='src' value='[REF(src)]'>
		<input type='hidden' name='votepollref' value='[REF(poll)]'>
		"}
	output += "<table><tr><td>"
	for(var/o in poll.options)
		var/datum/poll_option/option = o
		output += "<label><input type='checkbox' name='[REF(option)]' value='[option.option_id]'"
		if(length(voted_for) && !poll.allow_revoting)
			output += " disabled"
		if(option.option_id in voted_for)
			output += " checked"
		output += ">[option.text]</label><br>"
	output += "</td></tr></table>"
	if(!length(voted_for) || poll.allow_revoting)
		output += "<p><input type='submit' value='Vote'></form>"
	output += "</div>"
	src << browse(jointext(output, ""),"window=playerpoll;size=500x300")

/**
  * Shows voting window for an IRV type poll, listing its options and relevant details.
  *
  * If already voted on, the options are sorted how a player voted for them, otherwise they are randomly shuffled.
  *
  */
/mob/dead/new_player/proc/poll_player_irv(datum/poll_question/poll)
	var/datum/asset/irv_assets = get_asset_datum(/datum/asset/group/IRV)
	irv_assets.send(src)
	var/datum/DBQuery/query_irv_get_votes = SSdbcore.NewQuery({"
		SELECT optionid FROM [format_table_name("poll_vote")]
		WHERE pollid = :pollid AND ckey = :ckey AND deleted = 0
	"}, list("pollid" = poll.poll_id, "ckey" = ckey))
	if(!query_irv_get_votes.warn_execute())
		qdel(query_irv_get_votes)
		return
	var/list/voted_for = list()
	while(query_irv_get_votes.NextRow())
		voted_for += text2num(query_irv_get_votes.item[1])
	qdel(query_irv_get_votes)
	var/list/prepared_options = list()
	//if they've already voted we use the order they voted in plus a shuffle of any options they haven't voted for, if any
	if(length(voted_for))
		for(var/vote_id in voted_for)
			for(var/o in poll.options)
				var/datum/poll_option/option = o
				if(option.option_id == vote_id)
					prepared_options += option
		var/list/shuffle_options = poll.options - prepared_options
		if(length(shuffle_options))
			shuffle_options = shuffle(shuffle_options)
			for(var/shuffled in shuffle_options)
				prepared_options += shuffled
	//otherwise just shuffle the options
	else
		prepared_options = shuffle(poll.options)
	var/list/output = list({"<html><head><meta http-equiv="X-UA-Compatible" content="IE=edge" />
	<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
	<script src="jquery.min.js"></script>
	<script src="jquery-ui.custom-core-widgit-mouse-sortable-min.js"></script>
	<style>
		#sortable { list-style-type: none; margin: 0; padding: 2em; }
		#sortable li { min-height: 1em; margin: 0px 1px 1px 1px; padding: 1px; border: 1px solid black; border-radius: 5px; background-color: white; cursor:move;}
		#sortable .sortable-placeholder-highlight { min-height: 1em; margin: 0 2px 2px 2px; padding: 2px; border: 1px dotted blue; border-radius: 5px; background-color: GhostWhite; }
		span.grippy { content: '....'; width: 10px; height: 20px; display: inline-block; overflow: hidden; line-height: 5px; padding: 3px 1px; cursor: move; vertical-align: middle; margin-top: -.7em; margin-right: .3em; font-size: 12px; font-family: sans-serif; letter-spacing: 2px; color: #cccccc; text-shadow: 1px 0 1px black; }
		span.grippy::after { content: '.. .. .. ..';}
	</style>
	<script>
		$(function() {
			$( "#sortable" ).sortable({
				placeholder: "sortable-placeholder-highlight",
				axis: "y",
				containment: "#ballot",
				scroll: false,
				cursor: "ns-resize",
				tolerance: "pointer"
			});
			$( "#sortable" ).disableSelection();
			$('form').submit(function(){
				$('#IRVdata').val($( "#sortable" ).sortable("toArray", { attribute: "optionref" }));
			});
		});
	</script>
	</head>
	<body>
	<div align='center'><B>Player poll</B><hr><b>Question: [poll.question]</b><br>"})
	if(poll.subtitle)
		output += "[poll.subtitle]<br>"
	output += "<font size='2'>Poll runs from <b>[poll.start_datetime]</b> until <b>[poll.end_datetime]</b></font><br>"
	if(poll.allow_revoting)
		output += "<font size='2'>Revoting is enabled.</font>"
	output += "Please sort the options in the order of <b>most preferred</b> to <b>least preferred</b><br></div>"
	if(!length(voted_for) || poll.allow_revoting)
		output += {"<form action='?src=[REF(src)]' method='POST'>
		<input type='hidden' name='src' value='[REF(src)]'>
		<input type='hidden' name='votepollref' value='[REF(poll)]'>
		<input type='hidden' name='IRVdata' id='IRVdata'>
		"}
	output += "<div id='ballot' class='center'><b><center>Most Preferred</center></b><ol id='sortable' class='rankings' style='padding:0px'>"
	for(var/o in prepared_options)
		var/datum/poll_option/option = o
		output += "<li optionref='[REF(option)]' class='ranking'><span class='grippy'></span> [option.text]</li>\n"
	output += "</ol><b><center>Least Preferred</center></b><br>"
	if(!length(voted_for) || poll.allow_revoting)
		output += "<p><input type='submit' value='Vote'></form>"
	output += "</div>"
	src << browse(jointext(output, ""),"window=playerpoll;size=500x500")

	var/output = {"
		<html>
		<head>
		<meta http-equiv='X-UA-Compatible' content='IE=edge' />
		<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
		<script src="jquery.min.js"></script>
		<script src="jquery-ui.custom-core-widgit-mouse-sortable-min.js"></script>
		<style>
			#sortable { list-style-type: none; margin: 0; padding: 2em; }
			#sortable li { min-height: 1em; margin: 0px 1px 1px 1px; padding: 1px; border: 1px solid black; border-radius: 5px; background-color: white; cursor:move;}
			#sortable .sortable-placeholder-highlight { min-height: 1em; margin: 0 2px 2px 2px; padding: 2px; border: 1px dotted blue; border-radius: 5px; background-color: GhostWhite; }
			span.grippy { content: '....'; width: 10px; height: 20px; display: inline-block; overflow: hidden; line-height: 5px; padding: 3px 1px; cursor: move; vertical-align: middle; margin-top: -.7em; margin-right: .3em; font-size: 12px; font-family: sans-serif; letter-spacing: 2px; color: #cccccc; text-shadow: 1px 0 1px black; }
			span.grippy::after { content: '.. .. .. ..';}
		</style>
		<script>
			$(function() {
				$( "#sortable" ).sortable({
					placeholder: "sortable-placeholder-highlight",
					axis: "y",
					containment: "#ballot",
					scroll: false,
					cursor: "ns-resize",
					tolerance: "pointer"
				});
				$( "#sortable" ).disableSelection();
				$('form').submit(function(){
					$('#IRVdata').val($( "#sortable" ).sortable("toArray", { attribute: "voteid" }));
				});
			});

		</script>
		</head>
		<body>
		<div align='center'><B>Player poll</B><hr>
		<b>Question: [pollquestion]</b><br>Please sort the options in the order of <b>most preferred</b> to <b>least preferred</b><br>
		<font size='2'>Revoting has been enabled on this poll, if you think you made a mistake, simply revote<br></font>
		<font size='2'>Poll runs from <b>[pollstarttime]</b> until <b>[pollendtime]</b></font><p>
		</div>
		<form name='cardcomp' action='?src=[REF(src)]' method='POST'>
		<input type='hidden' name='src' value='[REF(src)]'>
		<input type='hidden' name='votepollid' value='[pollid]'>
		<input type='hidden' name='votetype' value=[POLLTYPE_IRV]>
		<input type='hidden' name='IRVdata' id='IRVdata'>
		<div id="ballot" class="center">
		<b><center>Most Preferred</center></b>
		<ol id="sortable" class="rankings" style="padding:0px">
	"}
	for(var/O in options)
		var/datum/polloption/PO = options["[O]"]
		if(PO.optionid && PO.optiontext)
			output += "<li voteid='[PO.optionid]' class='ranking'><span class='grippy'></span> [PO.optiontext]</li>\n"
	output += {"
		</ol>
			<b><center>Least Preferred</center></b><br>
		</div>
			<p><input type='submit' value='[( votedfor.len ? "Re" : "")]Vote'></form>
	"}
	src << browse(null ,"window=playerpolllist")
	src << browse(output,"window=playerpoll;size=500x500")
	return

//Returns null on failure, TRUE if already voted, FALSE if not voted yet.
/mob/dead/new_player/proc/poll_check_voted(pollid, text = FALSE, silent = FALSE)
	var/table = "poll_vote"
	if (text)
		table = "poll_textreply"
	if (!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	var/datum/DBQuery/query_hasvoted = SSdbcore.NewQuery("SELECT id FROM `[format_table_name(table)]` WHERE pollid = [pollid] AND ckey = '[ckey]'")
	if(!query_hasvoted.warn_execute())
		qdel(query_hasvoted)
		return
	if(query_hasvoted.NextRow())
		qdel(query_hasvoted)
		if(!silent)
			to_chat(usr, "<span class='danger'>You've already replied to this poll.</span>")
		return TRUE
	qdel(query_hasvoted)
	return FALSE

//Returns adminrank for use in polls.
/mob/dead/new_player/proc/poll_rank()
	. = "Player"
	if(client.holder)
		. = client.holder.rank.name


/mob/dead/new_player/proc/vote_rig_check()
	if (usr != src)
		if (!usr || !src)
			return 0
		//we gots ourselfs a dirty cheater on our hands!
		log_game("[key_name(usr)] attempted to rig the vote by voting as [key]")
		message_admins("[key_name_admin(usr)] attempted to rig the vote by voting as [key]")
		to_chat(usr, "<span class='danger'>You don't seem to be [key].</span>")
		to_chat(src, "<span class='danger'>Something went horribly wrong processing your vote. Please contact an administrator, they should have gotten a message about this</span>")
		return
	var/admin_rank
	if(client.holder)
		admin_rank = client.holder.rank.name
	else
		if(poll.admin_only)
			return
		else
			admin_rank = "Player"
	var/table = "poll_vote"
	if(poll.poll_type == POLLTYPE_TEXT)
		table = "poll_textreply"
	var/sql_poll_id = poll.poll_id
	var/vote_id //only used for option and text polls to save needing another query
	var/datum/DBQuery/query_validate_poll_vote = SSdbcore.NewQuery({"
		SELECT
			(SELECT id FROM [format_table_name(table)] WHERE ckey = :ckey AND pollid = :pollid AND deleted = 0 LIMIT 1)
		FROM [format_table_name("poll_question")]
		WHERE NOW() BETWEEN starttime AND endtime AND deleted = 0 AND id = :pollid
	"}, list("ckey" = ckey, "pollid" = sql_poll_id))
	if(!query_validate_poll_vote.warn_execute())
		qdel(query_validate_poll_vote)
		return
	//triple state return: no row returned if poll isn't running, null if no vote found, otherwise returns the vote id
	if(query_validate_poll_vote.NextRow())
		vote_id = text2num(query_validate_poll_vote.item[1])
		if(vote_id && !poll.allow_revoting)
			to_chat(usr, "<span class='danger'>Poll revoting is disabled and you've already replied to this poll.</span>")
			qdel(query_validate_poll_vote)
			return
	else
		to_chat(usr, "<span class='danger'>Selected poll is not open.</span>")
		qdel(query_validate_poll_vote)
		return
	qdel(query_validate_poll_vote)
	var/vote_success = FALSE
	switch(poll.poll_type)
		if(POLLTYPE_OPTION)
			vote_success = vote_on_poll_option(poll, href_list, admin_rank, sql_poll_id, vote_id)
		if(POLLTYPE_TEXT)
			vote_success = vote_on_poll_text(href_list, admin_rank, sql_poll_id, vote_id)
		if(POLLTYPE_RATING)
			vote_success = vote_on_poll_rating(poll, href_list, admin_rank, sql_poll_id)
		if(POLLTYPE_MULTI)
			vote_success = vote_on_poll_multi(poll, href_list, admin_rank, sql_poll_id)
		if(POLLTYPE_IRV)
			vote_success = vote_on_poll_irv(poll, href_list, admin_rank, sql_poll_id)
	if(vote_success)
		if(!vote_id)
			poll.poll_votes++
		to_chat(usr, "<span class='notice'>Vote successful.</span>")

/mob/dead/new_player/proc/vote_valid_check(pollid, holder, type)
	if (!SSdbcore.Connect())
		to_chat(src, "<span class='danger'>Failed to establish database connection.</span>")
		return
	if(IsAdminAdvancedProcCall())
		return
	var/datum/poll_option/option = locate(href_list["voteoptionref"]) in poll.options
	if(!option)
		to_chat(src, "<span class='danger'>No option was selected.</span>")
		return
	var/datum/DBQuery/query_vote_option = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("poll_vote")] (id, datetime, pollid, optionid, ckey, ip, adminrank)
		VALUES (:vote_id, NOW(), :poll_id, :option_id, :ckey, INET_ATON(:ip), :admin_rank)
		ON DUPLICATE KEY UPDATE datetime = NOW(), optionid = :option_id, ip = INET_ATON(:ip), adminrank = :admin_rank
	"}, list(
		"vote_id" = vote_id,
		"poll_id" = sql_poll_id,
		"option_id" = option.option_id,
		"ckey" = ckey,
		"ip" = client.address,
		"admin_rank" = admin_rank,
	))
	if(!query_vote_option.warn_execute())
		qdel(query_vote_option)
		return
	qdel(query_vote_option)
	return TRUE

/mob/dead/new_player/proc/vote_on_irv_poll(pollid, list/votelist)
	if (!SSdbcore.Connect())
		to_chat(src, "<span class='danger'>Failed to establish database connection.</span>")
		return 0
	if (!vote_rig_check())
		return 0
	pollid = text2num(pollid)
	if (!pollid || pollid < 0)
		return 0
	if (!votelist || !istype(votelist) || !votelist.len)
		return 0
	if (!client)
		return 0
	//save these now so we can still process the vote if the client goes away while we process.
	var/datum/admins/holder = client.holder
	var/rank = "Player"
	if (holder)
		rank = holder.rank.name
	var/ckey = client.ckey
	var/address = client.address

	//validate the poll
	if (!vote_valid_check(pollid, holder, POLLTYPE_IRV))
		return 0

	//lets collect the options
	var/datum/DBQuery/query_irv_id = SSdbcore.NewQuery("SELECT id FROM [format_table_name("poll_option")] WHERE pollid = [pollid]")
	if(!query_irv_id.warn_execute())
		qdel(query_irv_id)
		return 0
	var/list/optionlist = list()
	while (query_irv_id.NextRow())
		optionlist += text2num(query_irv_id.item[1])
	qdel(query_irv_id)

	//validate their votes are actually in the list of options and actually numbers
	var/list/numberedvotelist = list()
	for (var/vote in votelist)
		vote = text2num(vote)
		numberedvotelist += vote
		if (!vote) //this is fine because voteid starts at 1, so it will never be 0
			to_chat(src, "<span class='danger'>Error: Invalid (non-numeric) votes in the vote data.</span>")
			return 0
		if (!(vote in optionlist))
			to_chat(src, "<span class='danger'>Votes for choices that do not appear to be in the poll detected.</span>")
			return 0
	if (!numberedvotelist.len)
		to_chat(src, "<span class='danger'>Invalid vote data</span>")
		return 0

	//lets add the vote, first we generate an insert statement.

	var/sqlrowlist = ""
	for (var/vote in numberedvotelist)
		if (sqlrowlist != "")
			sqlrowlist += ", " //a comma (,) at the start of the first row to insert will trigger a SQL error
		sqlrowlist += "(Now(), [pollid], [vote], '[sanitizeSQL(ckey)]', INET_ATON('[sanitizeSQL(address)]'), '[sanitizeSQL(rank)]')"

	//now lets delete their old votes (if any)
	var/datum/DBQuery/query_irv_del_old = SSdbcore.NewQuery("DELETE FROM [format_table_name("poll_vote")] WHERE pollid = [pollid] AND ckey = '[ckey]'")
	if(!query_irv_del_old.warn_execute())
		qdel(query_irv_del_old)
		return 0
	qdel(query_irv_del_old)

	//now to add the new ones.
	var/datum/DBQuery/query_irv_vote = SSdbcore.NewQuery("INSERT INTO [format_table_name("poll_vote")] (datetime, pollid, optionid, ckey, ip, adminrank) VALUES [sqlrowlist]")
	if(!query_irv_vote.warn_execute())
		qdel(query_irv_vote)
		return 0
	qdel(query_irv_vote)
	if(!QDELETED(src))
		src << browse(null,"window=playerpoll")
	return 1


/mob/dead/new_player/proc/vote_on_poll(pollid, optionid)
	if (!SSdbcore.Connect())
		to_chat(src, "<span class='danger'>Failed to establish database connection.</span>")
		return 0
	if (!vote_rig_check())
		return 0
	if(!pollid || !optionid)
		return
	//validate the poll
	if (!vote_valid_check(pollid, client.holder, POLLTYPE_OPTION))
		return 0
	var/voted = poll_check_voted(pollid)
	if(isnull(voted) || voted) //Failed or already voted.
		return
	var/reply_text = href_list["replytext"]
	if(!reply_text || (length(reply_text) > 2048))
		to_chat(src, "<span class='danger'>The text you entered was blank or too long. Please correct the text and submit again.</span>")
		return
	var/datum/DBQuery/query_vote_text = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("poll_textreply")] (id, datetime, pollid, ckey, ip, replytext, adminrank)
		VALUES (:vote_id, NOW(), :poll_id, :ckey, INET_ATON(:ip), :reply_text, :admin_rank)
		ON DUPLICATE KEY UPDATE datetime = NOW(), ip = INET_ATON(:ip), replytext = :reply_text, adminrank = :admin_rank
	"}, list(
		"vote_id" = vote_id,
		"poll_id" = sql_poll_id,
		"ckey" = ckey,
		"ip" = client.address,
		"reply_text" = reply_text,
		"admin_rank" = admin_rank,
	))
	if(!query_vote_text.warn_execute())
		qdel(query_vote_text)
		return
	qdel(query_option_vote)
	if(!QDELETED(usr))
		usr << browse(null,"window=playerpoll")
	return 1

/mob/dead/new_player/proc/log_text_poll_reply(pollid, replytext)
	if (!SSdbcore.Connect())
		to_chat(src, "<span class='danger'>Failed to establish database connection.</span>")
		return 0
	if (!vote_rig_check())
		return 0
	if(!pollid)
		return
	//validate the poll
	if (!vote_valid_check(pollid, client.holder, POLLTYPE_TEXT))
		return 0
	if(!replytext)
		to_chat(usr, "The text you entered was blank. Please correct the text and submit again.")
		return
	var/list/votes = list()
	var/datum/DBQuery/query_get_rating_votes = SSdbcore.NewQuery({"
		SELECT id, optionid FROM [format_table_name("poll_vote")]
		WHERE pollid = :pollid AND ckey = :ckey AND deleted = 0
	"}, list("pollid" = sql_poll_id, "ckey" = ckey))
	if(!query_get_rating_votes.warn_execute())
		qdel(query_get_rating_votes)
		return
	while(query_get_rating_votes.NextRow())
		votes += list("[query_get_rating_votes.item[2]]" = text2num(query_get_rating_votes.item[1]))
	qdel(query_get_rating_votes)
	href_list.Cut(1,3) //first two values aren't options

	var/special_columns = list(
		"datetime" = "NOW()",
		"ip" = "INET_ATON(?)",
	)

	var/sql_votes = list()
	for(var/h in href_list)
		var/datum/poll_option/option = locate(h) in poll.options
		sql_votes += list(list(
			"id" = votes["[option.option_id]"],
			"pollid" = sql_poll_id,
			"optionid" = option.option_id,
			"ckey" = ckey,
			"ip" = client.address,
			"adminrank" = admin_rank,
			"rating" = href_list[h]
		))
	SSdbcore.MassInsert(format_table_name("poll_vote"), sql_votes, duplicate_key = TRUE, special_columns = special_columns)
	return TRUE

/**
  * Processes vote form data and saves results to the database for a multiple choice type poll.
  *
  */
/mob/dead/new_player/proc/vote_on_poll_multi(datum/poll_question/poll, list/href_list, admin_rank, sql_poll_id)
	if(!SSdbcore.Connect())
		to_chat(src, "<span class='danger'>Failed to establish database connection.</span>")
		return
	replytext = sanitizeSQL(replytext)
	if(!(length(replytext) > 0) || !(length(replytext) <= 8000))
		to_chat(usr, "The text you entered was invalid or too long. Please correct the text and submit again.")
		return
	if(length(href_list) > 2)
		href_list.Cut(1,3) //first two values aren't options
	else
		to_chat(src, "<span class='danger'>No options were selected.</span>")

	var/special_columns = list(
		"datetime" = "NOW()",
		"ip" = "INET_ATON(?)",
	)

	var/sql_votes = list()
	var/vote_count = 0
	for(var/h in href_list)
		if(vote_count == poll.options_allowed)
			to_chat(src, "<span class='danger'>Allowed option count exceeded, only the first [poll.options_allowed] selected options have been saved.</span>")
			break
		vote_count++
		var/datum/poll_option/option = locate(h) in poll.options
		sql_votes += list(list(
			"pollid" = sql_poll_id,
			"optionid" = option.option_id,
			"ckey" = ckey,
			"ip" = client.address,
			"adminrank" = admin_rank
		))
	/*with revoting and poll editing possible there can be an edge case where a poll is changed to allow less multiple choice options than a user has already voted on
	rather than trying to calculate which options should be updated and which deleted, we just delete all of a user's votes and re-insert as needed*/
	var/datum/DBQuery/query_delete_multi_votes = SSdbcore.NewQuery({"
		UPDATE [format_table_name("poll_vote")] SET deleted = 1 WHERE pollid = :pollid AND ckey = :ckey
	"}, list("pollid" = sql_poll_id, "ckey" = ckey))
	if(!query_delete_multi_votes.warn_execute())
		qdel(query_delete_multi_votes)
		return
	qdel(query_delete_multi_votes)
	SSdbcore.MassInsert(format_table_name("poll_vote"), sql_votes, special_columns = special_columns)
	return TRUE

/mob/dead/new_player/proc/vote_on_numval_poll(pollid, optionid, rating)
	if (!SSdbcore.Connect())
		to_chat(src, "<span class='danger'>Failed to establish database connection.</span>")
		return 0
	if (!vote_rig_check())
		return 0
	if(!pollid || !optionid || !rating)
		return
	//validate the poll
	if (!vote_valid_check(pollid, client.holder, POLLTYPE_RATING))
		return 0
	var/datum/DBQuery/query_numval_hasvoted = SSdbcore.NewQuery("SELECT id FROM [format_table_name("poll_vote")] WHERE optionid = [optionid] AND ckey = '[ckey]'")
	if(!query_numval_hasvoted.warn_execute())
		qdel(query_numval_hasvoted)
		return
	if(query_numval_hasvoted.NextRow())
		qdel(query_numval_hasvoted)
		to_chat(usr, "<span class='danger'>You've already replied to this poll.</span>")
		return
	var/list/votelist = splittext(href_list["IRVdata"], ",")
	if(!length(votelist))
		to_chat(src, "<span class='danger'>No ordering data found. Please try again or contact an administrator.</span>")

	var/list/special_columns = list(
		"datetime" = "NOW()",
		"ip" = "INET_ATON(?)",
	)

	var/sql_votes = list()
	for(var/o in votelist)
		var/datum/poll_option/option = locate(o) in poll.options
		sql_votes += list(list(
			"pollid" = sql_poll_id,
			"optionid" = option.option_id,
			"ckey" = ckey,
			"ip" = client.address,
			"adminrank" = admin_rank
		))
	//IRV results are calculated based on id order, we delete all of a user's votes to avoid potential errors caused by revoting and option editing
	var/datum/DBQuery/query_delete_irv_votes = SSdbcore.NewQuery({"
		UPDATE [format_table_name("poll_vote")] SET deleted = 1 WHERE pollid = :pollid AND ckey = :ckey
	"}, list("pollid" = sql_poll_id, "ckey" = ckey))
	if(!query_delete_irv_votes.warn_execute())
		qdel(query_delete_irv_votes)
		return
	qdel(query_delete_irv_votes)
	SSdbcore.MassInsert(format_table_name("poll_vote"), sql_votes, special_columns = special_columns)
	return TRUE
