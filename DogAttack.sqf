
_dog = _this select 0;
_target = _this select 1;
_group = _this select 2;
_exit = false;

[_dog] join grpnull;
_dog domove position _target;




// takes 0.000308838 ms
_Transpose = {
	private ["_dog","_target","_p"];
	_dog = _this select 0;
	_target = _this select 1;
	_p = _this select 2;
	_dog attachto [_target,[0,(-0.1 - (0.6 * (_p / 100))),(0.5 - (0.4 * (_p / 100)))]];
	_dog setVectorDirAndUp [[0,(0.5 + (0.16 * (_p/100))),(0.5 - (0.83 * (_p/100)))],[0,(-0.5 + (0.83 * (_p/100))),(0.5 + (0.16 * (_p/100)))]];
};





//Create a invisible unit for the dog to be attached to. Has to be a unit, not an object.
_PadG = creategroup East;
_doggypad = _padG createUnit ["C_MAN_1", [0,0,0], [], 0, "none"];
_doggypad forcespeed 0;_doggypad hideobject true;


// Make the dog chase the victim (simpified).
_counter = 0;
_dog domove position _target;
_nearenemies = [];
while {alive _dog} do {
	
	if (_dog distance _target > 30) exitwith {
		_dog domove (position (leader _group));
		_exit = true;
	};
	if (_dog distance _target < 2.9) exitwith {};
	if (_counter >= 10) then {
		_counter = 0;
		//_nearEnemies = ((getposATL (_dog)) nearentities ([(leader group _dog),30] call MC_NearEnemies));
		//if (count _NearEnemies == 0) then {
		//	_exit = true;
		//} else {
		//	_target = _nearenemies select 0;
			_dog domove position _target;
		//};
	};
	if (_exit) exitwith {};
	//if (count _nearenemies > 0) exitwith {};
	_counter = _counter + 1;
	sleep 0.1;
	//hintsilent format ["%1,%2,%3",_counter,_nearenemies];
};

if (!alive _dog || _exit) exitwith {
	[_dog] joinsilent _group;
};
_dog domove position _target;
sleep 0.001;

// Determine the relative direction between _target and _dog
_dirto = [_target,_dog] call BIS_Fnc_Dirto;
if (_dirto < 0) then {_dirto = _dirto + 360};
if (_dirto > 360) then {_dirto = _dirto - 360};


// Determine height of the jump, increments per step and dog's formation direction
_height = ((asltoatl (eyepos _target)) select 2) -1 ;
_inc = 0;
_inc1 = (_height / 500);
_Ddir = [_dog, _target] call BIS_fnc_dirto;
_dog setdir _DDir; _dog setformdir _DDir;

// Determine if the victim has to turn left or right to align with the dog / determine the amount of direction per step
_dirdiff = 0;
_turnright = false;
if ((getdir _dog) > (getdir _target)) then {
	_turnright = true;
	_dirdiff = ((getdir _dog) - (getdir _target));	
} else {	
	_dirdiff = ((getdir _target) - (getdir _dog));
};
if (_dirdiff < 0) then {_dirdiff = _dirdiff + 360};
if (_dirdiff > 360) then {_dirdiff = _dirdiff - 360};
_dirdiff = _dirdiff / 500;
{_target disableAI _x} foreach ["ANIM","MOVE","FSM"];

// Simulate the victim dropping his weapon
if (count weapons _target > 0) then {
	_WHolder = createvehicle ["groundweaponholder",(position _target),[],0,"can_collide"];
	_WHolder setposASL [(getposASL _target select 0),(getposASL _target select 1),(getposASL _target select 2) + 1];
	_WHolder addweaponCargo [(currentweapon _target),1];
	removeallweapons _target;
	[_WHolder] spawn {
		private ["_Wholder"];
		_WHolder = _this select 0;
		while {((getpos _WHolder select 2)) > 0} do {
			_WHolder setposASL [(getposASL _WHolder select 0),(getposASL _WHolder select 1),(getposASL _WHolder select 2) - 0.04];
			sleep 0.01;
		};
	};
};

// Attach dog to the invisible unit. 
_doggypad setdir (getdir _dog);
{_doggypad disableAI _x} foreach ["ANIM","FSM","MOVE","TARGET","AUTOTARGET"];
_doggypad setposASL (getposASL _dog);
_dog attachto [_doggypad,[0,0,0]];

// Let's make the dog sound aggressive
_dog playmove "dog_sprint";
_dog say3d "DogAttack";
_dogdir = getdir _dog;


// Stage 1: The Jump
for "_i" from 1 to 500 do {
	_doggypad setposASL ([[(getposASL _doggypad select 0),(getposASL _doggypad select 1),(((getposASL _doggypad) select 2) + _inc1)],0.005,_DDir] call BIS_fnc_Relpos);
	_dog setvectordirandUp [[0,(1 - _inc),_inc],[0,-(_inc),(1 - _inc)]];
	_inc = _inc + 0.001;
	if (_turnright) then {_target setdir (getdir _target + _dirdiff)} else {_target setdir (getdir _target - _dirdiff)};
	sleep 0.0005;
	//sleep 0.01;
};
detach _dog;
deletevehicle _doggypad;
sleep 0.01;

// Stage 2: Knock over the target
if (_target == player) then {[90] call BIS_fnc_Bloodeffect};
_target setdir _dogdir;
_dog attachto [_target,[0,-0.1,0.5]];
_dog playmove "dog_sprint";
_dog setVectorDirAndUp [[0,0.5,0.5],[0,-0.5,0.5]];
_target switchmove "amovpercmsprsnonwnondf_amovppnemstpsnonwnondnon";
[_target] spawn {
	private ["_unit"];
	_unit = _this select 0;
	for "_i" from 1 to 10 do {
		{_unit setHitPointDamage [_x, (_i / 10)]} foreach ["hithands","hithead","hitbody"];
		sleep 0.3;
	};
};
//sleep 1.0739; // To do: gradually change SetVectorDirandup from [[0,0.5,0.5],[0,-0.5,0.5]] to [[0,0.66,-0.33],[0,0.33,0.66]]

_p = 0;
_timer = time;
_att = [];
//for "_i" from 0 to 100 do {
while {_p <= 100} do {
	[_dog,_target,_p] call _Transpose;	
	//sleep 0.0009;
	sleep 0.00060000001 ;
	if (_p == 70) then {_dog switchmove "dog_bark"; _dog playmove "dog_bark"; _dog playmovenow "dog_bark";};
	_p = _p + 1;
};

//sleep (1.0739 - (time - _timer));


// Stage 3: Bite and kill
_dog switchmove "dog_bark"; _dog playmove "dog_bark"; _dog playmovenow "dog_bark";
_dog attachto [_target,[0,-0.7,0.1]]; 
_dog setvectordirandup [[0,0.66,-0.33],[0,0.33,0.66]];
sleep 0.2;
if (_target == player) then {
	disableuserinput true;
	[90] call BIS_fnc_Bloodeffect
};
_target switchmove "amovppnemstpsnonwnondnon";
_dogASL = getposASL _dog;
_dogdir = getdir _dog;
sleep 3;
disableuserinput false;
sleep 1;
detach _dog;
sleep 0.1;
_dog setdir _dogdir; _dog setformdir _dogdir;
sleep 0.5;
_dog disableai "anim";
_dog playmovenow "dog_sit_08";
_dog setvariable ["MC_DogAttack",false,true];
sleep 1;
[_dog] joinsilent _group;
{_x domove position _dog; _x setvariable ["MC_AbortCheck", true, true]} foreach units _group;



