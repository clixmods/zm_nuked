#using scripts\shared\ai_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\postfx_shared;
#using scripts\shared\util_shared;

#using scripts\shared\system_shared;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;


#define TRAIL_PERK  "dlc5/moon/fx_meteor_trail"
#precache( "client_fx", TRAIL_PERK );

//#precache( "model", "p7_zm_vending_packapunch_on" );

function autoexec __init__sytem__()
{
	system::register("zm_nuked_pap", &__init__,undefined, undefined);
}

function __init__()
{
	clientfield::register( "scriptmover", "fx_trail_clientfield", 12000, 1, "int", &fx_pap, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "toplayer", "fx_trail_clientfield_toplayer", VERSION_SHIP, 1, "int", &trail_pap, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );

}

function fx_pap(localClientNum, oldValue, newValue, bNewEnt, bInitialSnap, fieldName, wasDemoJump)
{
	level.trail_pap = self;
}

function trail_pap(localClientNum, oldValue, newValue, bNewEnt, bInitialSnap, fieldName, wasDemoJump)
{
	switch(newValue)
	{
		case 1:	
		if(level.debug_nuked == true)
			IPrintLnBold("PLAY trail FX");

		level.trail_pap.fx = PlayFXOnTag( localClientNum, TRAIL_PERK, level.trail_pap, level.trail_pap.origin + vectorscale((0,0,1),10));
		break;
		case 0:
		if(level.debug_nuked == true)
			IPrintLnBold("STOP trail FX");
			
		//PlayFXOnTag( localClientNum, "haz/fx_haz_shield_break", level.ai, level.ai.origin + vectorscale((0,0,1),10));
		StopFX( localClientNum, level.trail_pap.fx );
		level.trail_pap.fx Delete();
		break;
	}
}




