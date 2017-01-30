
_dog = _this select 0;
_waypointpos = _this select 1;

_group = group _dog;
[_dog] join grpnull;

_completed = false;
_dog forcespeed -1;
_dog domove _waypointpos;
_target = objnull;
_nearenemies = [];
hint format ["%1",_dog];
while {alive _dog} do {
	if (_completed) exitwith {};
	if (_dog distance _waypointpos < 7) exitwith {
		for "_i" from 1 to 7 do {
			_nearEnemies = ((getposATL (_dog)) nearentities ([(leader _group),30] call MC_NearEnemies));
			if (count _nearenemies > 0) exitwith {
				_target = _nearenemies select 0;
				[_dog,_target,_group] spawn MC_DogAttack;
			};
			sleep 1;
		};
		_dog domove position (leader _group);
		[_dog] joinsilent _group;
	};
	_nearEnemies = ((getposATL (_dog)) nearentities ([_dog,30] call MC_NearEnemies));
	if (count _nearenemies > 0) exitwith {
		_target = _nearenemies select 0;
		[_dog,_target,_group] spawn MC_DogAttack;
		hint "attack";
	};
	sleep 1;
	hintsilent format ["%1",_nearenemies];
};

