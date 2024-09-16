#using scripts\codescripts\struct; 
#using scripts\shared\system_shared; 
#using scripts\shared\array_shared; 
#using scripts\shared\vehicle_shared; 
#using scripts\zm\_zm_score;
#using scripts\shared\flag_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\clientfield_shared;
#using scripts\shared\callbacks_shared; 
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\shared\laststand_shared;
#using scripts\shared\util_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\scene_shared;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_spawner;
#using scripts\shared\_burnplayer;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\zombie_death;
#using scripts\shared\ai_shared;
#using scripts\shared\exploder_shared;

#using scripts\zm\_zm_blockers;

#insert scripts\shared\shared.gsh;

#precache("string", "NUKED_STRING_OPEN_OUT_MAP");
#using_animtree("generic");

#namespace zm_nuked_floating_debris; // HARRY COMMENT

REGISTER_SYSTEM_EX( "zm_nuked_floating_debris", &__init__, &__main__, undefined ) // HARRY COMMENT

function __init__()
{
    
}

function __main__()
{
	debris = GetEntArray("floating_debris","targetname");	
	array::thread_all(debris, &generic_door);
}

function doors_open() // self = script_model , self.target = le trigger, trig.target = le clip
{
	model = self.model; 
	self SetModel("tag_origin");

	trig = GetEnt(self.target,"targetname");
	trig thread zm_blockers::debris_init();
	wait 1;
	
	trig Hide();
	while(level.perks_omega != true)
	{
		level waittill("rituel_from_ground");
		break;
	}

	IPrintLn("01111111");
	self SetModel(	model );	
	trig Show();
	IPrintLn("01111111");

	self UseAnimTree(#animtree);

	self AnimScripted( "optionalNotify", self.origin , self.angles, %idle_debris_anim);
	origin = self.origin;

	if(isdefined(trig.script_flag))
		level flag::wait_till(trig.script_flag);

	ritual_model = GetEnt("autel_under","targetname");
	ritual_model Delete();
	PlayFX( level._effect["poltergeist"], origin );
	exploder::stop_exploder("door_floating_debris");  
	self AnimScripted( "optionalNotify", self.origin , self.angles, %rise_debris_anim);
	wait 2;
	self Delete();
		
}


function generic_door() // self = script_model , self.target = le trigger, trig.target = le clip
{
	if(isdefined(self.script_noteworthy))
	{
		self thread doors_open();	
	}
	else
	{
		self UseAnimTree(#animtree);
		self AnimScripted( "optionalNotify", self.origin , self.angles, %idle_debris_anim);
		origin = self.origin;
		trigs = GetEntArray(self.target,"targetname");
		self Show();
		if(trigs.size == 1)
		{
			trigs = GetEnt(self.target,"targetname");
			trigs thread zm_blockers::debris_init();
			if(isdefined(trigs.script_flag))
				level flag::wait_till(trigs.script_flag);

			IPrintLnBold("flag = "+trigs.script_flag);
			IPrintLnBold("flag state = "+level.flag[trigs.script_flag]);

		}
		else 
		{
			foreach(trig in trigs) 
			{
				trig thread zm_blockers::debris_init();
				script_flag = trig.script_flag;
					

			}
			level flag::wait_till(script_flag);
			IPrintLnBold("flag = "+script_flag);
			IPrintLnBold("flag state = "+level.flag[script_flag]);
		}


		PlayFX( level._effect["poltergeist"], origin );
		self AnimScripted( "optionalNotify", self.origin , self.angles, %rise_debris_anim);
		wait 2;
		self Delete();
	}
}