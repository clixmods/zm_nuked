#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\vehicle_shared;


#using scripts\zm\_zm_laststand; // BOT
#insert scripts\shared\shared.gsh; // BOT
#using scripts\zm\_zm_score; // BOT
#using scripts\zm\_zm_perks; // BOT
#using scripts\zm\_zm; // BOT
#using scripts\shared\bots\_bot;
#using scripts\shared\bots\_bot_combat;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\shared\ai\zombie_death;

//#insert scripts\shared\version.gsh;

#using scripts\zm\nuked_utility;
#insert scripts\shared\version.gsh;

#define TORNADO_1  "clix/fx/tornado_small"
#precache( "fx", TORNADO_1 );
#define TORNADO_2  "clix/fx/tornado_small_very"
#precache( "fx", TORNADO_2 );


function autoexec init()
{
	clientfield::register( "world",	"setup_skybox",	VERSION_SHIP, 5, "int" );
	clientfield::register( "scriptmover", "clientfield_tornado_fx", VERSION_SHIP, 2, "int" );
	//level thread friend();
	//level.weapon_restricted_for_bot = &restricted_weapon;
	//level thread music_bg_nuked();
	level thread bg_music_think();
	//level thread play_music();
	level thread twod_amb_nuked();
	level thread tornado_amb_init();
	level thread random_quake();
	
	level clientfield::set( "setup_skybox", 1 );
}

function random_quake()
{
	level endon("start_credit_nuked");
	origin = Spawn("script_model", (0,0,0));
	origin SetModel("tag_origin");
	while(1)
	{
		i = RandomIntRange(1,5);
		wait RandomIntRange( 30, 60 );
		foreach(player in GetPlayers())
		{
			Earthquake( 0.1, 45, player.origin, 10000 );
		}
		origin PlaySound("earthquake_sound");
		
		nuked_utility::wait_for_next_round( level.round_number + i );
	}
}

function bg_music_think()
{
	while(1)
	{
		level waittill("end_of_round");
		level.origin_bg_mus StopLoopSound(1);
		level waittill("start_of_round");
		wait 38;
		level notify("play_bg_music");
	}
}

/*
function play_music()
{
	//level endon("round_ended");
	level.origin_bg_mus = Spawn("script_model", (0,0,0));
	level.origin_bg_mus SetModel("tag_origin");
	while(1)
	{
		IPrintLn("attend que play_bg_music");
		level waittill("play_bg_music");
		level.origin_bg_mus PlayLoopSound("project_skadi_classified",1);
	}
}
*/
/*
function music_bg_nuked()
{
	level endon("start_credit_nuked");
	level waittill("emox_menu_closed");
	level.origin_bg_mus = Spawn("script_model", (0,0,0));
	level.origin_bg_mus SetModel("tag_origin");
	wait(38);
	while(1)
	{	
		
		if(level.debug_nuked == true)
			IPrintLn("mus_a_city_in_ruin_v3_mas2_intro lancer" );
		origin PlaySound("mus_a_city_in_ruin_v3_mas2_intro");
		wait(117);
		

		if(level.debug_nuked == true)
			IPrintLn("mus_dyn_alerted_intro lancer" );
		origin PlaySound("mus_dyn_alerted_intro");
		wait(95);
	

		if(level.debug_nuked == true)
			IPrintLn("samantha lullaby lancer" );
		origin PlaySound("sam_moon_mus");
		wait(129);

		if(level.debug_nuked == true)
			IPrintLn("makin_stealth lancer" );
		
		origin PlaySound("makin_stealth");
		wait(88);

		//if(level.debug_nuked == true)
		if(level.debug_nuked == true)
			IPrintLn("project_skadi_classified lancer" );

		level.origin_bg_mus PlaySound("project_skadi_classified");
		wait(214);

		if(level.debug_nuked == true)
			IPrintLn("zcoast_proto_mix lancer" );

		level.origin_bg_mus PlaySound("zcoast_proto_mix");
		wait(176);

		

	
	}
	
	
}
*/
function twod_amb_nuked()
{
	level endon("start_credit_nuked");
	origin = Spawn("script_model", (0,0,0));
	origin SetModel("tag_origin");
	origin PlayLoopSound("amb_thunder_nuked_low");
	while(1)
	{
		if(level.debug_nuked == true)
			IPrintLn("tonerre lancer" );

		origin PlaySound("amb_thunder_nuked_2d");
		wait(RandomIntRange( 15, 40 ));
	}

}

function tornado_amb_init()
{
	level endon("start_credit_nuked");
	if(level.debug_nuked == true)
		IPrintLnBold("tornado_amb_init");

 	level thread setup_tornado("tornado_1_veh", "1" ,1);
 	level thread setup_tornado("tornado_2_veh", "2" ,2);
	level thread setup_tornado("tornado_3_veh", "3" ,3);
	level thread setup_tornado("tornado_4_veh", "4" ,4);
}

function setup_tornado(b, i,number)
{
	level endon("start_credit_nuked");
	//level endon("trig_touched_tornado_"+i);
	veh = GetEnt(b,"targetname"); // veh
	n_path_start = GetVehicleNode( "tornado_"+i, "targetname" );
    while(1)
    {
    
    	a = RandomIntRange(1,3);
    	
    	if(!isdefined(veh))
    	{
    		break;
    	}
    	//veh.angles = ( 270, -1, 0 );
    	veh clientfield::set( "clientfield_tornado_fx", a );

    	
    	veh.fx = Spawn( "script_model", veh.origin );
    	veh.fx.angles = ( 270, -1, 0 );
    	veh.fx SetModel( "tag_origin" );
    	veh.fx clientfield::set( "clientfield_tornado_fx", a );
    	// if(a == 1)
    	//	PlayFXOnTag( TORNADO_1,veh.fx,"tag_origin");
    	
    	//if(a == 2)
    	// 	PlayFXOnTag( TORNADO_2,veh.fx,"tag_origin");
		
		level.trig_tornado[number].origin = veh.origin;
    	level.trig_tornado[number] EnableLinkTo();
    	level.trig_tornado[number] LinkTo( veh );
    	level.trig_tornado[number] Show();
    	
    	//level.trig_tornado[number].angles = veh.angles;
    	IPrintLn("trig"+level.trig_tornado[i].targetname);
    	veh.fx LinkTo( veh );
    	
    	veh LinkTo( n_path_start, "tag_origin", ( 0, -1, 0 ),( 270, -1, 0 ));
    	veh AttachPath( n_path_start );
    


    	if(level.debug_nuked == true)
	   		IPrintLnBold("tornade setup"+a);

    	
		//veh.fx PlayLoopSound("fire_tornado",0.1);
    	veh StartPath();
   

    	veh waittill( "reached_end_node" );
    	level.trig_tornado[number] Unlink();
    	level.trig_tornado[i] Hide();
 		//veh.fx StopLoopSound(1);
    	veh.fx Unlink();

    	veh Unlink();
		veh.fx Delete();
		veh clientfield::set( "clientfield_tornado_fx", 0 );
		wait(RandomIntRange(15, 45));

    }
}


