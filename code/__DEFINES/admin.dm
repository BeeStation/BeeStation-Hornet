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

#define R_DEFAULT R_AUTOADMIN

#define R_EVERYTHING (1<<15)-1 //the sum of all other rank permissions, used for +EVERYTHING

#define ADMIN_QUE(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];adminmoreinfo=[REF(user)]'>?</a>)"
#define ADMIN_FLW(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];adminplayerobservefollow=[REF(user)]'>FLW</a>)"
#define ADMIN_PP(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];adminplayeropts=[REF(user)]'>PP</a>)"
#define ADMIN_VV(atom) "(<a href='?_src_=vars;[HrefToken(TRUE)];Vars=[REF(atom)]'>VV</a>)"
#define ADMIN_SM(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];subtlemessage=[REF(user)]'>SM</a>)"
#define ADMIN_TP(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];traitor=[REF(user)]'>TP</a>)"
#define ADMIN_KICK(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];boot2=[REF(user)]'>KICK</a>)"
#define ADMIN_CENTCOM_REPLY(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];CentComReply=[REF(user)]'>RPLY</a>)"
#define ADMIN_SYNDICATE_REPLY(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];SyndicateReply=[REF(user)]'>RPLY</a>)"
#define ADMIN_SC(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];adminspawncookie=[REF(user)]'>SC</a>)"
#define ADMIN_SMITE(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];adminsmite=[REF(user)]'>SMITE</a>)"
#define ADMIN_LOOKUP(user) "[key_name_admin(user)][ADMIN_QUE(user)]"
#define ADMIN_LOOKUPFLW(user) "[key_name_admin(user)][ADMIN_QUE(user)] [ADMIN_FLW(user)]"
#define ADMIN_SET_SD_CODE "(<a href='?_src_=holder;[HrefToken(TRUE)];set_selfdestruct_code=1'>SETCODE</a>)"
#define ADMIN_FULLMONTY_NONAME(user) "[ADMIN_QUE(user)] [ADMIN_PP(user)] [ADMIN_VV(user)] [ADMIN_SM(user)] [ADMIN_FLW(user)] [ADMIN_TP(user)] [ADMIN_INDIVIDUALLOG(user)] [ADMIN_SMITE(user)]"
#define ADMIN_FULLMONTY(user) "[key_name_admin(user)] [ADMIN_FULLMONTY_NONAME(user)]"
#define ADMIN_JMP(src) "(<a href='?_src_=holder;[HrefToken(TRUE)];adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)"
#define COORD(src) "[src ? "([src.x],[src.y],[src.z])" : "nonexistent location"]"
#define AREACOORD(src) "[src ? "[get_area_name(src, TRUE)] ([src.x], [src.y], [src.z])" : "nonexistent location"]"
#define ADMIN_COORDJMP(src) "[src ? "[COORD(src)] [ADMIN_JMP(src)]" : "nonexistent location"]"
#define ADMIN_VERBOSEJMP(src) "[src ? "[AREACOORD(src)] [ADMIN_JMP(src)]" : "nonexistent location"]"
#define ADMIN_INDIVIDUALLOG(user) "(<a href='?_src_=holder;[HrefToken(TRUE)];individuallog=[REF(user)]'>LOGS</a>)"
#define ADMIN_RETRIEVE_BOH_ITEMS(boh) "(<a href='?_src_=holder;[HrefToken(TRUE)];retrieveboh=[REF(boh)]'>RETRIEVE CONSUMED ITEMS</a>)"

#define ADMIN_PUNISHMENT_LIGHTNING "Lightning bolt"
#define ADMIN_PUNISHMENT_BRAINDAMAGE "Brain damage"
#define ADMIN_PUNISHMENT_GIB "Gib"
#define ADMIN_PUNISHMENT_BSA "Bluespace Artillery Device"
#define ADMIN_PUNISHMENT_FIREBALL "Fireball"
#define ADMIN_PUNISHMENT_ROD "Immovable Rod"
#define ADMIN_PUNISHMENT_SUPPLYPOD_QUICK "Supply Pod (Quick)"
#define ADMIN_PUNISHMENT_SUPPLYPOD "Supply Pod"
#define ADMIN_PUNISHMENT_MAZING "Puzzle"
#define ADMIN_PUNISHMENT_FLOORCLUWNE "Floor Cluwne"
#define ADMIN_PUNISHMENT_CLUWNE "Make Cluwne"
#define ADMIN_PUNISHMENT_NUGGET "Nugget"

#define AHELP_UNCLAIMED 1
#define AHELP_ACTIVE 2
#define AHELP_CLOSED 3
#define AHELP_RESOLVED 4

#define ROUNDSTART_LOGOUT_REPORT_TIME	6000 //Amount of time (in deciseconds) after the rounds starts, that the player disconnect report is issued.

#define SPAM_TRIGGER_WARNING	5	//Number of identical messages required before the spam-prevention will warn you to stfu
#define SPAM_TRIGGER_AUTOMUTE	10	//Number of identical messages required before the spam-prevention will automute you

#define MAX_KEYPRESS_COMMANDLENGTH 32 //Max length of a keypress command before it's considered to be a forged packet
#define MAX_KEYPRESS_AUTOKICK 50

#define STICKYBAN_DB_CACHE_TIME 10 SECONDS
#define STICKYBAN_ROGUE_CHECK_TIME 5


#define POLICY_POLYMORPH "polymorph" //Shown to vicitm of staff of change and related effects.
#define POLICY_VERB_HEADER "policy_verb_header" //Shown on top of policy verb window
