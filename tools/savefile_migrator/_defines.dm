/* ------ CONFIG ------- */
// DB info
#define DB_HOST "127.0.0.1"
#define DB_PORT	3306
#define DB_USER "ss13"
#define DB_PASSWORD "ss13"
#define DB_NAME "ss13"
#define DB_PREFIX "__SS13_"

// Path on system to the player_saves directory in server data folder (probably copy saves somewhere else just in case)
#define SAVEFILE_DIRECTORY "C:/TGS/Server/GameStaticFiles/Configuration/data/player_saves/"

/* ------ END CONFIG ------- */

// Probably don't edit these
#define DB_PREFS_TABLE "[DB_PREFIX]preferences"
#define DB_CHAR_TABLE "[DB_PREFIX]character"

#define INVOKE_ASYNC world.ImmediateInvokeAsync
#define UNTIL(X) while(!(X)) sleep(world.tick_lag)

#define GLOBAL_PROC	"some_magic_bullshit"

#define rustg_sql_connect_pool(options) call(rust_g, "sql_connect_pool")(options)
#define rustg_sql_query_async(handle, query, params) call(rust_g, "sql_query_async")(handle, query, params)
#define rustg_sql_query_blocking(handle, query, params) call(rust_g, "sql_query_blocking")(handle, query, params)
#define rustg_sql_connected(handle) call(rust_g, "sql_connected")(handle)
#define rustg_sql_disconnect_pool(handle) call(rust_g, "sql_disconnect_pool")(handle)
#define rustg_sql_check_query(job_id) call(rust_g, "sql_check_query")("[job_id]")

#define RUSTG_JOB_NO_RESULTS_YET "NO RESULTS YET"
#define RUSTG_JOB_NO_SUCH_JOB "NO SUCH JOB"
#define RUSTG_JOB_ERROR "JOB PANICKED"

#define COLOR_WHITE            "#EEEEEE"
#define COLOR_SILVER           "#C0C0C0"
#define COLOR_GRAY             "#808080"
#define COLOR_FLOORTILE_GRAY   "#8D8B8B"
#define COLOR_ALMOST_BLACK	   "#333333"
#define COLOR_BLACK            "#000000"
#define COLOR_HALF_TRANSPARENT_BLACK    "#0000007A"
#define COLOR_RED              "#FF0000"
#define COLOR_RED_LIGHT        "#FF3333"
#define COLOR_MAROON           "#800000"
#define COLOR_YELLOW           "#FFFF00"
#define COLOR_OLIVE            "#808000"
#define COLOR_LIME             "#32CD32"
#define COLOR_GREEN            "#008000"
#define COLOR_CYAN             "#00FFFF"
#define COLOR_TEAL             "#008080"
#define COLOR_BLUE             "#0000FF"
#define COLOR_BLUE_LIGHT       "#33CCFF"
#define COLOR_NAVY             "#000080"
#define COLOR_PINK             "#FFC0CB"
#define COLOR_MAGENTA          "#FF00FF"
#define COLOR_PURPLE           "#800080"
#define COLOR_ORANGE           "#FF9900"
#define COLOR_BEIGE            "#CEB689"
#define COLOR_BLUE_GRAY        "#75A2BB"
#define COLOR_BROWN            "#BA9F6D"
#define COLOR_DARK_BROWN       "#997C4F"
#define COLOR_DARK_ORANGE      "#C3630C"
#define COLOR_GREEN_GRAY       "#99BB76"
#define COLOR_RED_GRAY         "#B4696A"
#define COLOR_PALE_BLUE_GRAY   "#98C5DF"
#define COLOR_PALE_GREEN_GRAY  "#B7D993"
#define COLOR_PALE_RED_GRAY    "#D59998"
#define COLOR_PALE_PURPLE_GRAY "#CBB1CA"
#define COLOR_PURPLE_GRAY      "#AE8CA8"

//wrapper macros for easier grepping
#define DIRECT_OUTPUT(A, B) A << B
#define DIRECT_INPUT(A, B) A >> B
#define SEND_IMAGE(target, image) DIRECT_OUTPUT(target, image)
#define SEND_SOUND(target, sound) DIRECT_OUTPUT(target, sound)
#define SEND_TEXT(target, text) DIRECT_OUTPUT(target, text)
#define WRITE_FILE(file, text) DIRECT_OUTPUT(file, text)
#define READ_FILE(file, text) DIRECT_INPUT(file, text)

#define SYSTEM_TYPE_INFINITY					1.#INF //only for isinf check

/// isnum() returns TRUE for NaN. Also, NaN != NaN. Checkmate, BYOND.
#define isnan(x) ( (x) != (x) )

#define isinf(x) (isnum((x)) && (((x) == SYSTEM_TYPE_INFINITY) || ((x) == -SYSTEM_TYPE_INFINITY)))

/// NaN isn't a number, damn it. Infinity is a problem too.
#define isnum_safe(x) ( isnum((x)) && !isnan((x)) && !isinf((x)) )

/// Don't set this very much higher then 1024 unless you like inviting people in to dos your server with message spam
#define MAX_MESSAGE_LEN			1024
#define MAX_NAME_LEN			42
#define MAX_BROADCAST_LEN		512
#define MAX_CHARTER_LEN			80

//Returns the hex value of a decimal number
//len == length of returned string
#define num2hex(X, len) num2text(X, len, 16)

//Returns an integer given a hex input, supports negative values "-ff"
//skips preceding invalid characters
#define hex2num(X) text2num(X, 16)

#define SANITIZE_LIST(L) ( islist(L) ? L : list() )
