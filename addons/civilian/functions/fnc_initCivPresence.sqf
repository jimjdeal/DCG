/*
Author:
Nicholas Clark (SENSEI)

Description:
handles civilian unit spawns using Civilian Presence modules

Arguments:
0: location array <ARRAY>

Return:
nothing
__________________________________________________________________*/
#include "script_component.hpp"

private _count = count _this;
private _iterations01 = [];

[{
    params ["_args","_idPFH"];
    _args params ["_locations","_count","_iterations01"];
    (_locations select (count _iterations01)) params ["_name","_position","_radius","_type"];
    
    if (count _iterations01 isEqualTo _count) exitWith {
        [_idPFH] call CBA_fnc_removePerFrameHandler;
    };

    _position = ASLtoAGL _position;

    if (GVAR(blacklist) find _name isEqualTo -1) then {
        private _mrk = createMarker [CIV_LOCATION_ID(_name),_position];
        _mrk setMarkerColor ([CIVILIAN,true] call BIS_fnc_sideColor);
        _mrk setMarkerShape "ELLIPSE";
        _mrk setMarkerBrush "Border";
        _mrk setMarkerSize [_radius + GVAR(spawnDist), _radius + GVAR(spawnDist)];
        // [_mrk] call EFUNC(main,setDebugMarker);

        private _trg = createTrigger ["EmptyDetector", _position, true]; // local trigger creates 'Ref to nonnetwork object' spam in log
        _trg setTriggerActivation ["ANYPLAYER", "PRESENT", true];
        _trg setTriggerStatements ["this", format ["hint '%1: ON'",_name], format ["hint '%1: OFF'",_name]]; // @todo delay trigger check
        _trg setTriggerArea [_radius + GVAR(spawnDist), _radius + GVAR(spawnDist), 0, false]; // @todo test z-dist

        private _houses = (_position nearObjects ["House", _radius min 300]) apply {_x buildingPos -1} select {count _x > 0};
        [_houses] call dcg_main_fnc_shuffle;
        _houses resize ((ceil (count _houses * 0.25)) min GVAR(unitLimit));

        if (_houses isEqualTo []) then {WARNING_2("Unable to find houses at %1: %2",_name,_position)};

        // main module is immediately moved to ambient group, _grp is null after module creation
        private _grp = createGroup sideLogic;
        private _moduleMain = _grp createUnit ["ModuleCivilianPresence_F", _position, [], 0, "CAN_COLLIDE"];
        
        // main module does not init sometimes, even with 'BIS_fnc_initModules_disableAutoActivation'
        // force init with 'bis_fnc_initmodules_activate'
        _moduleMain setVariable ["BIS_fnc_initModules_disableAutoActivation",false,true]; // @todo check if public is required
        _moduleMain setVariable ["bis_fnc_initmodules_activate",true,true]; // @todo check if public is required

        // main options
        _moduleMain setVariable ["#area",[_position,_radius,_radius,0,false,-1]]; // gets passed to inAreaArray @todo test z-dist
        _moduleMain setVariable ["#debug",true];
        _moduleMain setVariable ["#useagents",true];
        _moduleMain setVariable ["#usepanicmode",true];
        _moduleMain setVariable ["#unitcount",count _houses];
        _moduleMain setVariable ["#unittypes",EGVAR(main,unitsCiv)];
        _moduleMain setVariable ["#oncreated",{true}];
        _moduleMain setVariable ["#ondeleted",{true}];

        // sync main module to trigger
        _moduleMain synchronizeObjectsAdd [_trg];

        private _iterations02 = [];

        // create spawn and waypoint positions in houses
        [{
            params ["_args","_idPFH"];
            _args params ["_trg","_houses","_iterations02"]; 

            if (count _iterations02 isEqualTo count _houses) exitWith {
                [_idPFH] call CBA_fnc_removePerFrameHandler;
            };

            _positionHouse = selectRandom (selectRandom _houses);

            // create new group, old group is null
            _grp = createGroup sideLogic;
            _moduleSpawn = _grp createUnit ["ModuleCivilianPresenceUnit_F", _positionHouse, [], 0, "CAN_COLLIDE"];

            _moduleSpawn setVariable ["BIS_fnc_initModules_disableAutoActivation",false,true]; // @todo check if public is required
            _moduleSpawn setVariable ["bis_fnc_initmodules_activate",true,true]; // @todo check if public is required

            _grp = createGroup sideLogic;
            _moduleWaypoint = _grp createUnit ["ModuleCivilianPresenceSafeSpot_F", _positionHouse, [], 0, "CAN_COLLIDE"];

            _moduleWaypoint setVariable ["BIS_fnc_initModules_disableAutoActivation",false,true]; // @todo check if public is required
            _moduleWaypoint setVariable ["bis_fnc_initmodules_activate",true,true]; // @todo check if public is required

            // waypoint options
            _moduleWaypoint setVariable ["#type",1];
            _moduleWaypoint setVariable ["#capacity",2];
            _moduleWaypoint setVariable ["#usebuilding",true];
            _moduleWaypoint setVariable ["#terminal",false];

            _mrk = createMarker [["wp",getpos _moduleWaypoint] joinString "_",getpos _moduleWaypoint];
            _mrk setMarkerType "mil_dot";
            _mrk setMarkerText "wp";

            _moduleSpawn synchronizeObjectsAdd [_trg];
            _moduleWaypoint synchronizeObjectsAdd [_trg];            

            _iterations02 pushBack 0;
        }, 0.25, [_trg,_houses,_iterations02]] call CBA_fnc_addPerFrameHandler;

        _iterations01 pushBack 0;
    };
}, 0.25, [_this,_count,_iterations01]] call CBA_fnc_addPerFrameHandler;

nil