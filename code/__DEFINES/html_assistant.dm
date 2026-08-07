#define TOOLTIP_CSS_SETUP \
"<style>\
.tooltip {\
	position: relative;\
	display: inline-block;\
	border-bottom: 2px dotted;\
}\
\
.tooltip .tooltiptext {\
	visibility: hidden;\
	background-color: black;\
	color: #fff;\
	text-align: center;\
	border-radius: 3px;\
	border: 1px solid grey;\
	padding: 10px 17px;\
	\
	position: absolute;\
	z-index: 1;\
}\
\
.tooltip:hover .tooltiptext {\
	visibility: visible;\
}\
</style>"
// IE11 does not support the max-content attribute, so 'width: max-content;' doesn't work.

#define TOOLTIP_WRAPPER(hover_me, width_px, tooltip_text) \
"<div class='tooltip'>[hover_me]<span class='tooltiptext' style='width: [width_px]px'>[tooltip_text]</span></div>"

#define TOOLTIP_CONFIG_CALLER(hover_me, width_px, config_key) \
"[(GLOB.tooltips[config_key] ? "<div class='tooltip'>[hover_me]<span class='tooltiptext' style='width: [width_px]px'>[GLOB.tooltips[config_key]]</span></div>" : "[hover_me]")]"

#define OPEN_WIKI(wiki_url, text) (CONFIG_GET(string/wikiurl) ? "<a href='[CONFIG_GET(string/wikiurl)+"/"+wiki_url]' target='_blank'>[text]</a>" : "[text]")

#define HTML_SKELETON_INTERNAL(head, body) \
"<!DOCTYPE html><html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><meta http-equiv='X-UA-Compatible' content='IE=edge'>[head]</head><body>[body]</body></html>"

#define HTML_SKELETON_TITLE(title, body) HTML_SKELETON_INTERNAL("<title>[title]</title>", body)
#define HTML_SKELETON(body) HTML_SKELETON_INTERNAL("", body)
