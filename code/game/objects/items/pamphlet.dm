/obj/item/paper/pamphlet
	name = "pamphlet"
	icon_state = "pamphlet"
	show_written_words = FALSE


/obj/item/paper/pamphlet/violent_video_games
	name = "pamphlet - \'Violent Video Games and You\'"
	desc = "A pamphlet encouraging the reader to maintain a balanced lifestyle and take care of their mental health, while still enjoying video games in a healthy way. You probably don't need this..."
	info = "They don't make you kill people. There, we said it. Now get back to work!"

/obj/item/paper/pamphlet/centcom/visitor_info
	name = "Visitor Info Pamphlet"
	info = "<b> XCC-P5831 Visitor Information </b><br>\
	Greetings, visitor, to  XCC-P5831! As you may know, this outpost was once \
	used as Nanotrasen's CENTRAL COMMAND STATION, organizing and coordinating company \
	projects across the vastness of space. <br>\
	Since the completion of the much more efficient CC-A5831 on March 8, 2553, XCC-P5831 no longer \
	acts as NT's base of operations but still plays a very important role its corporate affairs; \
	serving as a supply and repair depot, as well as being host to its most important legal proceedings\
	and the thrilling pay-per-view broadcasts of <i>PLASTEEL CHEF</i> and <i>THUNDERDOME LIVE</i>.<br> \
	We hope you enjoy your stay!"

//we don't want the silly text overlay!
/obj/item/paper/pamphlet/update_icon()
	return
