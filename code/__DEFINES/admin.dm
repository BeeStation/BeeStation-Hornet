//A set of constants used to determine which type of mute an admin wishes to apply:
//Please read and understand the muting/automuting stuff before changing these. MUTE_IC_AUTO etc = (MUTE_IC << 1)
//Therefore there needs to be a gap between the flags for the automute flags
#define MUTE_IC			(1<<0)
#define MUTE_OOC		(1<<1)
#define MUTE_PRAY		(1<<2)
#define MUTE_ADMINHELP	(1<<3)
#define MUTE_DEADCHAT	(1<<4)
#define MUTE_MHELP		(1<<5)
#define MUTE_ALL		(~0)

//Admin Permissions
#define R_BUILD		(1<<0)
#define R_ADMIN			(1<<1)
#define R_BAN			(1<<2)
#define R_FUN			(1<<3)
#define R_SERVER		(1<<4)
#define R_DEBUG			(1<<5)
#define R_POSSESS		(1<<6)
#define R_PERMISSIONS	(1<<7)
#define R_STEALTH		(1<<8)
#define R_POLL			(1<<9)
#define R_VAREDIT		(1<<10)
#define R_SOUND		(1<<11)
#define R_SPAWN			(1<<12)
#define R_AUTOADMIN		(1<<13)
#define R_DBRANKS		(1<<14)
#define R_SUPPRESS	(1<<15) //GDPR/R5 Compliance

#define R_DEFAULT R_AUTOADMIN

#define R_EVERYTHING (1<<16)-1 //the sum of all other rank permissions, used for +EVERYTHING

#define ADMIN_QUE(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];adminmoreinfo=[REF(user)]'>?</a>)"
#define ADMIN_FLW(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];adminplayerobservefollow=[REF(user)]'>FLW</a>)"
#define ADMIN_PP(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];adminplayeropts=[REF(user)]'>PP</a>)"
#define ADMIN_VV(atom) "(<a href='byond://?_src_=vars;[HrefToken(TRUE)];Vars=[REF(atom)]'>VV</a>)"
#define ADMIN_SM(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];subtlemessage=[REF(user)]'>SM</a>)"
#define ADMIN_TP(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];traitor=[REF(user)]'>TP</a>)"
#define ADMIN_KICK(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];boot2=[REF(user)]'>KICK</a>)"
#define ADMIN_CENTCOM_REPLY(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];CentComReply=[REF(user)]'>RPLY</a>)"
#define ADMIN_SYNDICATE_REPLY(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];SyndicateReply=[REF(user)]'>RPLY</a>)"
#define ADMIN_SC(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];adminspawncookie=[REF(user)]'>SC</a>)"
#define ADMIN_SMITE(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];adminsmite=[REF(user)]'>SMITE</a>)"
#define ADMIN_LOOKUP(user) "[key_name_admin(user)][ADMIN_QUE(user)]"
#define ADMIN_LOOKUPFLW(user) "[key_name_admin(user)][ADMIN_QUE(user)] [ADMIN_FLW(user)]"
#define ADMIN_SET_SD_CODE "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];set_selfdestruct_code=1'>SETCODE</a>)"
#define ADMIN_FULLMONTY_NONAME(user) "[ADMIN_QUE(user)] [ADMIN_PP(user)] [ADMIN_VV(user)] [ADMIN_SM(user)] [ADMIN_FLW(user)] [ADMIN_TP(user)] [ADMIN_INDIVIDUALLOG(user)] [ADMIN_SMITE(user)]"
#define ADMIN_FULLMONTY(user) "[key_name_admin(user)] [ADMIN_FULLMONTY_NONAME(user)]"
#define ADMIN_JMP(src) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)"
#define COORD(src) "[src ? "([src.x],[src.y],[src.z])" : "nonexistent location"]"
#define AREACOORD(src) "[src ? "[get_area_name(src, TRUE)] ([src.x], [src.y], [src.z])" : "nonexistent location"]"
#define ADMIN_COORDJMP(src) "[src ? "[COORD(src)] [ADMIN_JMP(src)]" : "nonexistent location"]"
#define ADMIN_VERBOSEJMP(src) "[src ? "[AREACOORD(src)] [ADMIN_JMP(src)]" : "nonexistent location"]"
#define ADMIN_INDIVIDUALLOG(user) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];individuallog=[REF(user)]'>LOGS</a>)"
#define ADMIN_RETRIEVE_BOH_ITEMS(boh) "(<a href='byond://?_src_=holder;[HrefToken(TRUE)];retrieveboh=[REF(boh)]'>RETRIEVE CONSUMED ITEMS</a>)"
/// Displays "(SHOW)" in the chat, when clicked it tries to show atom(paper). First you need to set the request_state variable to TRUE for the paper.
#define ADMIN_SHOW_PAPER(atom) "(<A href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];show_paper=[REF(atom)]'>SHOW</a>)"

#define TICKET_UNCLAIMED 1
#define TICKET_ACTIVE 2
#define TICKET_CLOSED 3
#define TICKET_RESOLVED 4

#define ROUNDSTART_LOGOUT_REPORT_TIME	6000 //Amount of time (in deciseconds) after the rounds starts, that the player disconnect report is issued.

#define SPAM_TRIGGER_WARNING	5	//Number of identical messages required before the spam-prevention will warn you to stfu
#define SPAM_TRIGGER_AUTOMUTE	10	//Number of identical messages required before the spam-prevention will automute you

#define MAX_KEYPRESS_COMMANDLENGTH 32 //Max length of a keypress command before it's considered to be a forged packet
#define MAX_KEYPRESS_AUTOKICK 50

#define STICKYBAN_DB_CACHE_TIME 10 SECONDS
#define STICKYBAN_ROGUE_CHECK_TIME 5

// allowed ghost roles this round, starts as everything allowed
GLOBAL_VAR_INIT(ghost_role_flags, (~0))

//Flags that control what ways ghosts can get back into the round
//ie fugitives, space dragon, etc. also includes dynamic midrounds as it's the same deal
#define GHOSTROLE_MIDROUND_EVENT	(1<<0)
//ie ashwalkers, free golems, beach bums
#define GHOSTROLE_SPAWNER			(1<<1)
//ie mind monkeys, sentience potion
#define GHOSTROLE_STATION_SENTIENCE	(1<<2)
//ie pais, posibrains
#define GHOSTROLE_SILICONS			(1<<3)
//ie mafia, ctf
#define GHOSTROLE_MINIGAME			(1<<4)

// Job deadmin flags
#define DEADMIN_POSITION_HEAD		(1<<0)
#define DEADMIN_POSITION_SECURITY	(1<<1)
#define DEADMIN_POSITION_SILICON	(1<<2)

/// State when an interview has been approved
#define INTERVIEW_APPROVED	"interview_approved"
/// State when an interview as been denied
#define INTERVIEW_DENIED 	"interview_denied"
/// State when an interview has had no action on it yet
#define INTERVIEW_PENDING	"interview_pending"
