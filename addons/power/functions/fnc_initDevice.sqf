/**
 * Initializes a device.
 * 
 * Arguments:
 * 0: Device <OBJECT>
 * 1: Device name <STRING> (Optional)
 * 2: Powerstate (0 = off, 1 = on, n+1 = custom) <INT>  (Optional)
 * 3: Init function <CODE> (Optional)
 * 4: Turn on function <CODE> (Optional)
 * 5: Turn off function <CODE> (Optional)
 *
 * Results:
 * None
*/

params ["_entity", ["_name", "Device"], ["_powerState", 0], ["_initFnc", {}], ["_turnOnFnc", {}], ["_turnOnCondition", {true}], ["_turnOffFnc", {}], ["_turnOffCondition", {true}], ["_standbyFnc", {}], ["_standbyCondition", {true}]];

private _turnOnWrapper = {
	params['_target', ['_args', []]];

	_turnOnFnc =  _target getVariable "AE3_power_fnc_turnOn";
	_result = [_target] + _args call _turnOnFnc;
	if(isNil '_result') then {_result = false};

	if(_result) then
	{
		_target setVariable ['AE3_power_powerState', 1, true];
	};
	
};

private _turnOffWrapper = {
	params['_target', ['_args', []]];

	_turnOffFnc =  _target getVariable "AE3_power_fnc_turnOff";
	_result = [_target] + _args call _turnOffFnc;
	if(isNil '_result') then {_result = false};

	if(_result) then
	{
		_target setVariable ['AE3_power_powerState', 0, true];
	};
	
};

private _standbyWrapper = {
	params['_target', ['_args', []]];

	_standbyFnc =  _target getVariable "AE3_power_fnc_standbyOff";
	_result = [_target] + _args call _standbyFnc;
	if(isNil '_result') then {_result = false};

	if(_result) then
	{
		_target setVariable ['AE3_power_powerState', 2, true];
	};
	
};

if(!isDedicated) then
{
	// Add check power state action
	private _parentAction = ["AE3_DeviceAction", _name, "", {}, {true}] call ace_interact_menu_fnc_createAction;
	private _power = ["AE3_PowerAction", "Check Power State", "", {[_target] call AE3_power_fnc_checkPowerStateAction}, {true}] call ace_interact_menu_fnc_createAction;

	[_entity, 0, ["ACE_MainActions"], _parentAction] call ace_interact_menu_fnc_addActionToObject;
	[_entity, 0, ["ACE_MainActions", "AE3_DeviceAction"], _power] call ace_interact_menu_fnc_addActionToObject;

	// Add turn on/off action
	if (!((_turnOnFnc isEqualTo {}) || (_turnOffFnc isEqualTo {}))) then
	{
		
		_turnOn = ["AE3_TurnOnAction", "Turn On", "", 
					{
						params ['_target', '_player', '_params']; 
						_target setVariable ['AE3_power_mutex', true, true];
						[_target] spawn {
							params['_target'];
							[_target] call (_target getVariable "AE3_power_fnc_turnOnWrapper");
							_target setVariable ['AE3_power_mutex', false, true];
						};
						
					}, 
					{
						((_target call (_target getVariable ["AE3_power_fnc_turnOnCondition", {true}]) and
							(alive _target) and 
						(_target getVariable 'AE3_power_powerState' != 1) and 
						!(_target getVariable ['AE3_power_mutex', false]) and 
						(_target getVariable ['AE3_interaction_closeState', 0] == 0))) //and 
						},
					{}] call ace_interact_menu_fnc_createAction;

		_turnOff = ["AE3_TurnOffAction", "Turn Off", "", 
						{
							params ['_target', '_player', '_params']; 
							
							_target setVariable ['AE3_power_mutex', true, true];
							[_target] spawn {
								params['_target'];
								[_target] call (_target getVariable "AE3_power_fnc_turnOffWrapper");
								_target setVariable ['AE3_power_mutex', false, true];
							};
						}, 
						{((_target call (_target getVariable ["AE3_power_fnc_turnOffCondition", {true}])) and (alive _target) and  (_target getVariable 'AE3_power_powerState' != 0) and !(_target getVariable ['AE3_power_mutex', false]) and (_target getVariable ['AE3_interaction_closeState', 0] == 0))}, // and ([_target] call (_target getVariable ["AE3_power_fnc_turnOffCondition", {true}])))
						{}] call ace_interact_menu_fnc_createAction;

		[_entity, 0, ["ACE_MainActions", "AE3_DeviceAction"], _turnOn] call ace_interact_menu_fnc_addActionToObject;
		[_entity, 0, ["ACE_MainActions", "AE3_DeviceAction"], _turnOff] call ace_interact_menu_fnc_addActionToObject;

		// Standby action
		if(!(_standbyFnc isEqualTo {})) then
		{
			_standby = ["AE3_StandbyAction", "Standby", "", 
						{
							params ['_target', '_player', '_params']; 
							
							_target setVariable ['AE3_power_mutex', true, true];
							[_target] spawn {
								params['_target'];
								[_target] call (_target getVariable "AE3_power_fnc_standbyWrapper");
								_target setVariable ['AE3_power_mutex', false, true];
							};
						}, 
						{((_target call (_target getVariable ["AE3_power_fnc_standbyCondition", {true}])) and (alive _target) and (_target getVariable 'AE3_power_powerState' == 1) and !(_target getVariable ['AE3_power_mutex', false]) and (_target getVariable ['AE3_interaction_closeState', 0] == 0))}, // and ([_target] call (_target getVariable ["AE3_power_fnc_standbyCondition", {true}]))
						{}] call ace_interact_menu_fnc_createAction;
			
			[_entity, 0, ["ACE_MainActions", "AE3_DeviceAction"], _standby] call ace_interact_menu_fnc_addActionToObject;
		};

	};
};

if(isServer) then
{
	_entity setVariable ["AE3_power_powerState", _powerState, true];
	_entity setVariable ["AE3_power_fnc_turnOn", _turnOnFnc, true];
	_entity setVariable ["AE3_power_fnc_turnOnCondition", _turnOnCondition, true];
	_entity setVariable ["AE3_power_fnc_turnOnWrapper", _turnOnWrapper, true];
	_entity setVariable ["AE3_power_fnc_turnOff", _turnOffFnc, true];
	_entity setVariable ["AE3_power_fnc_turnOffCondition", _turnOffCondition, true];
	_entity setVariable ["AE3_power_fnc_turnOffWrapper", _turnOffWrapper, true];
	_entity setVariable ["AE3_power_fnc_standby", _standbyFnc, true];
	_entity setVariable ["AE3_power_fnc_standbyCondition", _standbyCondition, true];
	_entity setVariable ["AE3_power_fnc_standbyWrapper", _standbyWrapper, true];
};

[_entity] call _initFnc;
