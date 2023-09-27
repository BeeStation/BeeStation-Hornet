GLOBAL_VAR_INIT(fileaccess_timer, 0) //! For FTP requests. (i.e. downloading runtime logs.) However it'd be ok to use for accessing attack logs and such too, which are even laggier.

GLOBAL_VAR_INIT(TAB, "&nbsp;&nbsp;&nbsp;&nbsp;")

GLOBAL_DATUM_INIT(data_core, /datum/datacore, new)

GLOBAL_VAR_INIT(bsa_unlock, FALSE)	//! BSA unlocked by head ID swipes

GLOBAL_LIST_EMPTY(player_details)	//! ckey -> /datum/player_details

///All currently running polls held as datums
GLOBAL_LIST_EMPTY(polls)
GLOBAL_PROTECT(polls)
///Active polls
GLOBAL_LIST_EMPTY(active_polls)
GLOBAL_PROTECT(active_polls)

///All poll option datums of running polls
GLOBAL_LIST_EMPTY(poll_options)
GLOBAL_PROTECT(poll_options)

// Monkeycube/chicken/slime spam prevention
GLOBAL_VAR_INIT(total_cube_monkeys, 0)
GLOBAL_VAR_INIT(total_chickens, 0)
GLOBAL_VAR_INIT(total_slimes, 0)

///Global var for insecure comms key rate limiting
GLOBAL_VAR_INIT(topic_cooldown, 0)

//Upload code for law changes
GLOBAL_VAR(upload_code)

// Topic stuff
GLOBAL_LIST_EMPTY(topic_commands)
GLOBAL_PROTECT(topic_commands)
GLOBAL_LIST_EMPTY(topic_tokens)
GLOBAL_PROTECT(topic_tokens)
GLOBAL_LIST_EMPTY(topic_servers)
GLOBAL_PROTECT(topic_servers)

// Tooltips. tooltip is stored in "config/tooltips.txt"
GLOBAL_LIST_EMPTY(tooltips)

//Should be in the form of "tag to be replaced" = list("replacement for beginning", "replacement for end")
GLOBAL_LIST_INIT(markup_tags, list("_"  = list("<i>", "</i>"),
								   "**" = list("<b>", "</b>")))
//Should be in the form of "((\\W|^)@)(\[^@\]*)(@(\\W|$)), "g"", where @ is the appropriate tag from markup_tags
GLOBAL_LIST_INIT(markup_regex, list("_"  = new /regex("((\\W|^)_)(\[^_\]*)(_(\\W|$))", "g"),
									"**" = new /regex("((\\W|^)\\*\\*)(\[^\\*\\*\]*)(\\*\\*(\\W|$))", "g")))
