/*
Author:
Nicholas Clark (SENSEI)
__________________________________________________________________*/
#include "script_component.hpp"

POSTINIT;

// eventhandlers
[QGVARMAIN(settingsInitialized), {
    call FUNC(handleLoadData);
}] call CBA_fnc_addEventHandler;

[QGVAR(question), {_this call FUNC(handleQuestion)}] call CBA_fnc_addEventHandler;
[QGVAR(stop), {_this call FUNC(handleStop)}] call CBA_fnc_addEventHandler;
[QGVAR(hint), {_this call FUNC(handleHint)}] call CBA_fnc_addEventHandler;
[QGVAR(add), {
    _this call FUNC(addValue);
    TRACE_1("Client add value",_this);
}] call CBA_fnc_addEventHandler;

// start hostile handler after one cooldown cycle
[{
    [FUNC(handleHostile), GVAR(hostileCooldown), []] call CBA_fnc_addPerFrameHandler;
}, [], GVAR(hostileCooldown)] call CBA_fnc_waitAndExecute;

// setup clients
remoteExecCall [QFUNC(initClient),0,true];