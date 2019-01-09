#define COMPONENT civilian
#define COMPONENT_PRETTY Civilian

#include "\d\dcg\addons\main\script_mod.hpp"

#define DEBUG_MODE_FULL
#define DISABLE_COMPILE_CACHE

#include "\d\dcg\addons\main\script_macros.hpp"

#define CIV_HANDLER_DELAY 10
#define CIV_ZDIST 50
#define CIV_LOCATION_ID(NAME) ([QUOTE(ADDON),NAME] joinString "_")

#define CIV_VILLAGE_COUNT 5
#define CIV_CITY_COUNT 10
#define CIV_CAPITAL_COUNT 20