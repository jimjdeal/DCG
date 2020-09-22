/*
Author:
Nicholas Clark (SENSEI)

Description:
initialize garrison addon

Arguments:
0: data loaded from server profile <ARRAY>

Return:
nothing
__________________________________________________________________*/
#include "script_component.hpp"

if !(isServer) exitWith {nil};

params [
    ["_data",[],[[]]]
];

// find initial areas
private _ao = [AO_COUNT_P1] call FUNC(setArea);

// retry on fail
if !(_ao) exitWith {
    [QGVAR(reinit),nil] call CBA_fnc_serverEvent;
};

// find suitable spawn areas
private _outpost = [OP_COUNT] call FUNC(setOutpost);

// retry on fail
if !(_outpost) exitWith {
    [QGVAR(reinit),nil] call CBA_fnc_serverEvent;
};

[] spawn FUNC(spawnArea);
[] spawn FUNC(spawnOutpost);

// draw ao on map

[GVAR(areas),{
    [
        [_key,[_value getVariable [QEGVAR(main,polygon),DEFAULT_POLYGON]]],
        {
            {
                [_x,[EGVAR(main,enemySide),false] call BIS_fnc_sideColor,"\A3\ui_f\data\map\markerbrushes\bdiagonal_ca.paa",true,findDisplay 12 displayCtrl 51,AO_POLY_ID(_this select 0)] call EFUNC(main,polygonFill);
            } forEach (_this select 1);
        }
    ] remoteExecCall [QUOTE(call),0,false];
}] call CBA_fnc_hashEachPair;

// set tasks
call FUNC(setTask);

// run handlers
[{
    [FUNC(handlePatrol),300,[]] call CBA_fnc_addPerFrameHandler;
},[],60] call CBA_fnc_waitAndExecute;

nil