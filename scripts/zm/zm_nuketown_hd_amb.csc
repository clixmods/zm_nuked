#using scripts\shared\ai_shared;
#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#using scripts\shared\filter_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#define TORNADO_1  "clix/fx/tornado_small"
#precache( "client_fx", TORNADO_1 );
#define TORNADO_2  "clix/fx/tornado_small_very"
#precache( "client_fx", TORNADO_2 );

function autoexec init()
{
	clientfield::register( "world", "setup_skybox", VERSION_SHIP, 5, "int", &change_skybox, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", "clientfield_tornado_fx", VERSION_SHIP, 2, "int", &tornado_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	
	callback::on_localplayer_spawned( &on_localplayer_spawned );



}

function tornado_fx(localClientNum, oldValue, newValue, bNewEnt, bInitialSnap, fieldName, wasDemoJump) // self = machine
{
	switch(newValue)
	{
		case 2:	

		self.fx = PlayFXOnTag(localClientNum, TORNADO_2,self,"tag_origin");
		
		break;


		case 1:	

		self.fx = PlayFXOnTag(localClientNum, TORNADO_1,self,"tag_origin");

		break;

		case 0:
		StopFX( localClientNum, self.fx );
		self.fx Delete();
		break;
	}
}

function on_localplayer_spawned( localClientNum )
{
    filter::init_filter_hazmat(localClientNum);
    //self thread print_entity_count(localClientNum); 
}

function print_entity_count( n_local_client_num )
{
    
    while(1)
        {
            n_current_entity_count = 0;
            for ( i = 0; i < 24; i++ )
            {
                a_array = undefined;
                a_array = getEntArrayByType( n_local_client_num, i );
                iPrintLnBold( "CURRENT " +i+  " ENTITY COUNT : " + a_array.size );
                for ( a=0;a<a_array.size;a++ )
            	{
            		iPrintLnBold( "CURRENT " +a_array[a].classname+ " ENTITY COUNT : " );
            	}

                if ( isDefined( a_array ) && isArray( a_array ) && a_array.size > 0 )
                    n_current_entity_count += a_array.size;

                wait 1;
                    
            }
            iPrintLnBold( "CURRENT ENTITY COUNT : " + n_current_entity_count );
         wait 1;
        }
}


function change_skybox( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{

	//turn to original skybox.
	if ( newVal == 1 )
	{
		IPrintLnBold("SKYBOX, bank = ");
		//wait 5;
		for ( localClientNum = 0; localClientNum < level.localPlayers.size; localClientNum++ )
		{
			SetLitFogBank( localClientNum, -1, 0, -1 );
			SetWorldFogActiveBank( localClientNum, 1 );
			filter::enable_filter_hazmat(localClientNum,1,1,1,1);

			SetSavedDvar( "enable_global_wind", 1 );
   			SetSavedDvar( "wind_global_vector", "1 0 0" );
    		SetSavedDvar( "wind_global_low_altitude", 0 );
    		SetSavedDvar( "wind_global_hi_altitude", 0 );
    		SetSavedDvar( "wind_global_low_strength_percent", 0 );

			SetDvar( "enable_global_wind", 1 );
   			SetDvar( "wind_global_vector", "1 0 0" );
    		SetDvar( "wind_global_low_altitude", 0 );
    		SetDvar( "wind_global_hi_altitude", 0 );
    		SetDvar( "wind_global_low_strength_percent", 0 );

			oit = GetDvarInt( "r_OIT", 1 );	
			vol = GetDvarInt( "r_volumetric_lighting_enabled", 1 );
			SetDvar( "r_OIT", 0 );	
			SetDvar( "r_volumetric_lighting_enabled", 0 );	
			wait 2;
			if( oit != 0)
			{
				SetDvar( "r_OIT", oit );	
			}
			if( vol != 0)
			{
				SetDvar( "r_volumetric_lighting_enabled", vol );
			}	

			wait 2;
			setdvar( "r_lightGridEnableTweaks", 1 );
			setdvar( "r_lightGridIntensity", 1.25 );
			setdvar( "r_lightGridContrast", 0.18 );
			setdvar( "scr_fog_exp_halfplane", 639.219 );
			setdvar( "scr_fog_exp_halfheight", 18691.3 );
			setdvar( "scr_fog_nearplane", 138.679 );
			setdvar( "scr_fog_red", 0.806694 );
			setdvar( "scr_fog_green", 0.962521 );
			setdvar( "scr_fog_blue", 0.9624 );
			setdvar( "scr_fog_baseheight", 1145.21 );
			setdvar( "visionstore_glowTweakEnable", 0 );
			setdvar( "visionstore_glowTweakRadius0", 5 );
			setdvar( "visionstore_glowTweakRadius1", "" );
			setdvar( "visionstore_glowTweakBloomCutoff", 0.5 );
			setdvar( "visionstore_glowTweakBloomDesaturation", 0 );
			setdvar( "visionstore_glowTweakBloomIntensity0", 1 );
			setdvar( "visionstore_glowTweakBloomIntensity1", "" );
			setdvar( "visionstore_glowTweakSkyBleedIntensity0", "" );
			setdvar( "visionstore_glowTweakSkyBleedIntensity1", "" );
			//SetDvar( "r_oit", 0 );
			//SetDvar( "r_makeDark_enable", false );
			
		}
	}
	
	//turn to earth destroyed skybox.
	if ( newVal == 2 )
	{
		IPrintLnBold("SKYBOX, bank = ");
		//wait 5;
		for ( localClientNum = 0; localClientNum < level.localPlayers.size; localClientNum++ )
		{
			SetLitFogBank( localClientNum, -1, 1, -1 );
			SetWorldFogActiveBank( localClientNum, 2 );
			oit = GetDvarInt( "r_OIT", 1 );	
			vol = GetDvarInt( "r_volumetric_lighting_enabled", 1 );
			SetDvar( "r_OIT", 0 );	
			SetDvar( "r_volumetric_lighting_enabled", 0 );	
			wait 2;
			if( oit != 0)
			{
				SetDvar( "r_OIT", oit );	
			}
			if( vol != 0)
			{
				SetDvar( "r_volumetric_lighting_enabled", vol );
			}
			wait 5; 
			setdvar( "r_lightGridEnableTweaks", 1 );
			setdvar( "r_lightGridIntensity", 1.25 );
			setdvar( "r_lightGridContrast", 0.18 );
			setdvar( "scr_fog_exp_halfplane", 639.219 );
			setdvar( "scr_fog_exp_halfheight", 18691.3 );
			setdvar( "scr_fog_nearplane", 138.679 );
			setdvar( "scr_fog_red", 0.806694 );
			setdvar( "scr_fog_green", 0.962521 );
			setdvar( "scr_fog_blue", 0.9624 );
			setdvar( "scr_fog_baseheight", 1145.21 );
			setdvar( "visionstore_glowTweakEnable", 0 );
			setdvar( "visionstore_glowTweakRadius0", 5 );
			setdvar( "visionstore_glowTweakRadius1", "" );
			setdvar( "visionstore_glowTweakBloomCutoff", 0.5 );
			setdvar( "visionstore_glowTweakBloomDesaturation", 0 );
			setdvar( "visionstore_glowTweakBloomIntensity0", 1 );
			setdvar( "visionstore_glowTweakBloomIntensity1", "" );
			setdvar( "visionstore_glowTweakSkyBleedIntensity0", "" );
			setdvar( "visionstore_glowTweakSkyBleedIntensity1", "" );	

		}
	}

	if ( newVal == 3 )
	{
		IPrintLnBold("SKYBOX, bank = ");
		//wait 5;
		for ( localClientNum = 0; localClientNum < level.localPlayers.size; localClientNum++ )
		{
			SetLitFogBank( localClientNum, -1, 2, -1 );
			SetWorldFogActiveBank( localClientNum, 4);
			oit = GetDvarInt( "r_OIT", 1 );	
			vol = GetDvarInt( "r_volumetric_lighting_enabled", 1 );
			SetDvar( "r_OIT", 0 );	
			SetDvar( "r_volumetric_lighting_enabled", 0 );	
			wait 10;
			if( oit != 0)
			{
				SetDvar( "r_OIT", oit );	
			}
			if( vol != 0)
			{
				SetDvar( "r_volumetric_lighting_enabled", vol );
			}	
		}
	}

	//turn to alpha omega skybox.
	if ( newVal == 4 )
	{
		IPrintLnBold("SKYBOX, bank = ");
		//wait 5;
		for ( localClientNum = 0; localClientNum < level.localPlayers.size; localClientNum++ )
		{
			SetLitFogBank( localClientNum, -1, 3, -1 );
			SetWorldFogActiveBank( localClientNum, 8 );
			oit = GetDvarInt( "r_OIT", 1 );	
			vol = GetDvarInt( "r_volumetric_lighting_enabled", 1 );
			SetDvar( "r_OIT", 0 );	
			SetDvar( "r_volumetric_lighting_enabled", 0 );	
			wait 10;
			if( oit != 0)
			{
				SetDvar( "r_OIT", oit );	
			}
			if( vol != 0)
			{
				SetDvar( "r_volumetric_lighting_enabled", vol );
			}
		}
	}

	if(newVal == 5)
	{
		umbra_settometrigger( localClientNum, "" );	//reset script umbra override
		while( 1 )
		{
			//iPrintLnBold("sqdfsfq");

			umbra_settometrigger( localClientNum, "umbra_11" );
			umbra_settometrigger( localClientNum, "umbra_24" );
			umbra_settometrigger( localClientNum, "umbra_13" );
			umbra_settometrigger( localClientNum, "umbra_16" );
			umbra_settometrigger( localClientNum, "umbra_14" );
			umbra_settometrigger( localClientNum, "etage_house2_umbra" );
			umbra_settometrigger( localClientNum, "umbra_15" );
			umbra_settometrigger( localClientNum, "umbra_8" );
			umbra_settometrigger( localClientNum, "umbra_10" );
			umbra_settometrigger( localClientNum, "umbra_25" );
			umbra_settometrigger( localClientNum, "umbra_7" );
			umbra_settometrigger( localClientNum, "umbra_20" );
			umbra_settometrigger( localClientNum, "umbra_5" );
			umbra_settometrigger( localClientNum, "umbra_27" );
			umbra_settometrigger( localClientNum, "umbra_26" );
			umbra_settometrigger( localClientNum, "umbra_2" );
			umbra_settometrigger( localClientNum, "umbra_1" );
			umbra_settometrigger( localClientNum, "umbra_6" );
			umbra_settometrigger( localClientNum, "umbra_4" );
			umbra_settometrigger( localClientNum, "umbra_17" );
			umbra_settometrigger( localClientNum, "openhouse5_backyard_umbra" );
			umbra_settometrigger( localClientNum, "outofmap_umbra" );
			umbra_settometrigger( localClientNum, "umbra_22" );
			umbra_settometrigger( localClientNum, "umbra_23" );
			umbra_settometrigger( localClientNum, "gersh_umbra" );
				umbra_settometrigger( localClientNum, "openhouse3_backyard_umbra" );
			umbra_settometrigger( localClientNum, "umbra_3" );
			umbra_settometrigger( localClientNum, "openhouse3_backyard_way_yellow_umbra" );
				umbra_settometrigger( localClientNum, "umbra_28" );
			umbra_settometrigger( localClientNum, "umbra_24" );
			umbra_settometrigger( localClientNum, "umbra_24" );
				umbra_settometrigger( localClientNum, "umbra_24" );
			umbra_settometrigger( localClientNum, "umbra_24" );
			umbra_settometrigger( localClientNum, "umbra_24" );


			WAIT_SERVER_FRAME;
		}
		
	}


}


function change_skybox_bank(notify_wait, bank_mask)
{
	while(1)
	{
		level waittill(notify_wait);
		players = getlocalplayers();
		for(i = 0; i < players.size;i++)
		{
			players[i] thread change( i, bank_mask ,notify_wait );
		}

	}	
}

function change(clientnum, bank_mask, notify_wait)
{
	IPrintLnBold("SKYBOX, bank = "+bank_mask+" notify = "+notify_wait);
	SetLitFogBank( clientnum, -1, bank_mask, -1 ); //SetLitFogBank(<localClientNum>, <scriptid>, <bank>, <time>)
	SetWorldFogActiveBank( clientnum, bank_mask ); //<client> SetWorldFogActiveBank(<bankMask>)	
	SetExposureActiveBank(clientnum , bank_mask);// SetExposureActiveBank(<localClientNum>, <bank mask>)
			// void SetPBGActiveBank(<localClientNum>, <bank mask>)
}