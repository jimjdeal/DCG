/*
Author:
Nicholas Clark (SENSEI)

Description:
handles approval value when object dies

Arguments:
0: victim object <OBJECT>
1: killer object <OBJECT>

Return:
boolean
__________________________________________________________________*/
#include "script_component.hpp"

if !(isMultiplayer) exitWith {};

params [
    ["_unit", objNull, [objNull]],
    ["_killer", objNull, [objNull]]
];

// ACE workaround, https://github.com/acemod/ACE3/issues/3790
if (isNull _killer || {_unit isEqualTo _killer}) then {
    _killer = _unit getVariable ["ace_medical_lastDamageSource", _killer];
};

if (isNull _unit || {isNull _killer} || {_killer isEqualTo _unit} || {side _killer isEqualTo CIVILIAN}) exitWith {
    TRACE_2("Exit handleKilled",_killer,_unit);
    false
};

private _unitValue = 0;

call {
    if (_unit isKindOf "Man" && {!(side group _unit isEqualTo CIVILIAN)}) exitWith {
        _unitValue = AP_MAN;
    };
    if (_unit isKindOf "Man" && {side group _unit isEqualTo CIVILIAN}) exitWith {
        _unitValue = AP_CIV;
    };
    if (_unit isKindOf "Car") exitWith {
        _unitValue = AP_CAR;
    };
    if (_unit isKindOf "Tank") exitWith {
        _unitValue = AP_TANK;
    };
    if (_unit isKindOf "Air") exitWith {
        _unitValue = AP_AIR;
    };
    if (_unit isKindOf "Ship") exitWith {
        _unitValue = AP_SHIP;
    };
};

if (side group _unit isEqualTo EGVAR(main,playerSide) || {side group _unit isEqualTo CIVILIAN}) then {
    _unitValue = _unitValue * -1;
};

if (isServer) then {
    [getPos _unit, _unitValue] call FUNC(addValue);
} else {
    missionNamespace setVariable [QGVAR(addPVEH),[getPos _unit, _unitValue]];
    publicVariableServer QGVAR(addPVEH);
};

true
