/**
 * Adds given input character to a hidden variable in terminal settings of the given computer.
 *
 * Arguments:
 * 1: Computer <OBJECT>
 * 2: Character <STRING>
 *
 * Results:
 * None
 */

params ["_computer", "_inputChar"];

private _terminal = _computer getVariable "AE3_terminal";

private _terminalPasswordBuffer = "";

if (!isNil { _terminal get "AE3_terminalInputBuffer" }) then 
{
	_terminalPasswordBuffer = _terminal get "AE3_terminalInputBuffer";
};

_terminalPasswordBuffer = _terminalPasswordBuffer + _inputChar;

_terminal set ["AE3_terminalInputBuffer", _terminalPasswordBuffer];

_computer setVariable ["AE3_terminal", _terminal];