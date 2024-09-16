#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;

#using scripts\zm\_zm;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_ai_dogs_nuked.gsh;

#precache( "client_fx", DOG_DEFAULT_EYE_FX );
#precache( "client_fx", DOG_DEFAULT_TRAIL_FX );

#precache( "client_fx", DOG_ELECTRIC_EYE_FX );
#precache( "client_fx", DOG_ELECTRIC_TRAIL_FX );

#precache( "client_fx", DOG_NOVA_EYE_FX );
#precache( "client_fx", DOG_NOVA_TRAIL_FX );

#namespace zm_ai_dogs_nuked;

REGISTER_SYSTEM( "zm_ai_dogs_nuked", &__init__, undefined )

function __init__()
{
	init_dog_fx();
	
	clientfield::register( "actor", "dog_nuked_fx", VERSION_SHIP, 4, "int", &dog_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function init_dog_fx()
{
	level._effect[ "dog_nuked_eye_glow" ]			= DOG_DEFAULT_EYE_FX;
	level._effect[ "dog_nuked_trail_fire" ]		= DOG_DEFAULT_TRAIL_FX;	

	level._effect[ "dog_nuked_electric_eye_glow" ]			= DOG_DEFAULT_EYE_FX;
	level._effect[ "dog_nuked_electric_trail_fire" ]		= DOG_ELECTRIC_TRAIL_FX;

	level._effect[ "dog_nuked_nova_eye_glow" ]			= DOG_DEFAULT_EYE_FX;
	level._effect[ "dog_nuked_nova_trail_fire" ]		= DOG_NOVA_TRAIL_FX;
}

function dog_fx( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )//self = dog
{
	if( newVal == 1 )
	{
		self._eyeglow_fx_override = level._effect[ "dog_nuked_eye_glow" ];
		self zm::createZombieEyes( localClientNum );
		self mapshaderconstant( localClientNum, 0, "scriptVector2", 0, zm::get_eyeball_on_luminance(), self zm::get_eyeball_color() );
		self.n_trails_fx_id = PlayFxOnTag( localClientNum, level._effect[ "dog_nuked_trail_fire" ], self, "j_spine2" );
	}
	else if( newVal == 2 ) // elec
	{
		self._eyeglow_fx_override = level._effect[ "dog_nuked_eye_glow" ];
		self zm::createZombieEyes( localClientNum );
		self mapshaderconstant( localClientNum, 0, "scriptVector2", 0, zm::get_eyeball_on_luminance(), self zm::get_eyeball_color() );
		self.n_trails_fx_id = PlayFxOnTag( localClientNum, level._effect[ "dog_nuked_electric_trail_fire" ], self, "j_spine2" );
	}
	else if( newVal == 3 ) // nova
	{
		self._eyeglow_fx_override = level._effect[ "dog_nuked_eye_glow" ];
		self zm::createZombieEyes( localClientNum );
		self mapshaderconstant( localClientNum, 0, "scriptVector2", 0, zm::get_eyeball_on_luminance(), self zm::get_eyeball_color() );
		self.n_trails_fx_id = PlayFxOnTag( localClientNum, level._effect[ "dog_nuked_nova_trail_fire" ], self, "j_spine2" );
	}

	else 
	{
		self mapshaderconstant( localClientNum, 0, "scriptVector2", 0, zm::get_eyeball_off_luminance(), self zm::get_eyeball_color() );
		self zm::deleteZombieEyes(localClientNum);
		if( isdefined( self.n_trails_fx_id ) )
		{
			DeleteFX( localClientNum, self.n_trails_fx_id );
		}		
	}
}
