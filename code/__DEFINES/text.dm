/// Does 4 spaces. Used as a makeshift tabulator.
#define FOURSPACES "&nbsp;&nbsp;&nbsp;&nbsp;"

/// Prepares a text to be used for maptext. Use this so it doesn't look hideous.
#define MAPTEXT(text) {"<span class='maptext'>[##text]</span>"}

/// Macro from Lummox used to get height from a MeasureText proc
#define WXH_TO_HEIGHT(x) text2num(copytext(x, findtextEx(x, "x") + 1))

#define CENTER(text) {"<center>[##text]</center>"}

#define SANITIZE_FILENAME(text) (GLOB.filename_forbidden_chars.Replace(text, ""))


/// type of a chat to send discord servers
#define CHAT_TYPE_OOC "chat_ooc"
#define CHAT_TYPE_DEADCHAT "chat_dead"

///Base layer of chat elements
#define CHAT_LAYER 1
///Highest possible layer of chat elements
#define CHAT_LAYER_MAX 2
/// Maximum precision of float before rounding errors occur (in this context)
#define CHAT_LAYER_Z_STEP 0.0001
/// The number of z-layer 'slices' usable by the chat message layering
#define CHAT_LAYER_MAX_Z (CHAT_LAYER_MAX - CHAT_LAYER) / CHAT_LAYER_Z_STEP

// which strip method 'stripped_input()' proc will use?
#define BYOND_ENCODE "byond_encode"
#define STRIP_HTML "strip_html"
#define STRIP_HTML_SIMPLE "strip_html_simple"
#define SANITIZE "sanitize"
#define SANITIZE_SIMPLE "sanitize_simple"
#define ADMIN_SCRUB "admin_scrub"
