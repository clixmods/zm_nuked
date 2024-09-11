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
	system::register("nuked_perks", &__init__,undefined, undefined);
}

function __init__()
{
	clientfield::register( "scriptmover", "clientfield_perk_intro_fx", VERSION_SHIP, 1, "int", &perk_intro_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function perk_intro_fx(localClientNum, oldValue, newValue, bNewEnt, bInitialSnap, fieldName, wasDemoJump) // self = machine
{
	switch(newValue)
	{
		case 1:	
		//self.fx PlayLoopSound( "zmb_perks_incoming_loop", 6 ); // A METTRE DANS LE FX DIRECTMEENT

		self.fx = PlayFXOnTag( localClientNum, TRAIL_PERK, self, self.origin + vectorscale((0,0,1),10));
		self.fx LinkTo( self );
		//self LinkTo( level.perk_arrival_vehicle, "tag_origin", ( 0, -1, 0 ), ( 0, -1, 0 ) );
		break;

		case 0:
		//PlayFXOnTag( localClientNum, "haz/fx_haz_shield_break", level.ai, level.ai.origin + vectorscale((0,0,1),10));
		StopFX( localClientNum, self.fx );
		self.fx Delete();
		break;
	}
}







