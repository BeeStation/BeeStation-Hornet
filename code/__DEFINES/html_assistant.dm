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
  width: 120px;\
  background-color: black;\
  color: #fff;\
  text-align: center;\
  border-radius: 3px;\
  border: 1px solid grey;\
  padding: 5px 0;\
\
  /* Position the tooltip */\
  position: absolute;\
  z-index: 1;\
}\
\
.tooltip:hover .tooltiptext {\
  visibility: visible;\
}\
</style>"

#define TOOLTIP_WRAPPER(hover_me, tooltip_text) \
"<div class=\"tooltip\">[hover_me]<span class=\"tooltiptext\">[tooltip_text]</span></div>"
