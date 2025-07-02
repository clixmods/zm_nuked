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

#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_utility;

#insert scripts\shared\shared.gsh; // IS_TRUE
#insert scripts\shared\version.gsh; // IS_TRUE

#define TV_FAIL_FX "clix/elec_tv_fail" 
#precache( "fx", TV_FAIL_FX ); 

#define TV_ON           "tv_nuked_on"
#precache( "model", TV_ON );
#define TV_OFF          "tv_nuked"
#precache( "model", TV_OFF );
#define TV_GOOD         "tv_nuked_good"
#precache( "model", TV_GOOD );
#define TV_FAIL         "tv_nuked_fail"
#precache( "model", TV_FAIL );
#define TV_BUTTON       "tv_bouton"
#precache( "model", TV_BUTTON );

#define TV_ON_CODE_1    "tv_nuked_on_code_1"
#precache( "model", TV_ON_CODE_1 );
#define TV_ON_CODE_2    "tv_nuked_on_code_2"
#precache( "model", TV_ON_CODE_2 );
#define TV_ON_CODE_3    "tv_nuked_on_code_3"
#precache( "model", TV_ON_CODE_3);
#define TV_ON_CODE_4    "tv_nuked_on_code_4"
#precache( "model", TV_ON_CODE_4 );

#define FLAG_RANDOM_CODE_ACTIVE "random_code_active"

function init()
{
	struct_tv = struct::get("tv_spawn", "targetname" );
	level.tv = Spawn( "script_model", struct_tv.origin );
	level.tv.angles = struct_tv.angles;
	level.tv SetModel( TV_OFF );
	emplacement = level.tv GetTagOrigin( "tag_bouton_fdp" );
	emplacement_angles = level.tv GetTagAngles( "tag_bouton_fdp" );
	level.e_model_bouton = Spawn( "script_model", emplacement );
	level.e_model_bouton.angles = emplacement_angles;
	level.e_model_bouton SetModel( TV_BUTTON );

    level.e_model_bouton LinkTo(level.tv,"tag_bouton_fdp");
	level.e_model_bouton RotatePitch( 180, 0.01 );
	tv_validate = GetEnt("tv_bouton_validate","targetname");
	tv_validate_trig = GetEnt(tv_validate.target,"targetname");
	tv_validate_trig SetHintString("");
	tv_selection_trig = GetEnt("trig_selection","targetname");
	tv_selection_trig SetHintString("");

    tv_validate thread tv_validate_move(tv_validate_trig); 
	level thread validate_code(tv_validate_trig, level.e_model_bouton);
	level thread validate_selection(tv_selection_trig);
    level thread tv_selection_think();
    level thread tv_fail();
    level thread tv_nuked_on();
    level thread shutdown_tv();

    level thread set_random_code();

}

function shutdown_tv()
{
	while(1)
	{
		level waittill("check_code");
		wait 2; 
		if(level.code_possible == 0)
		{
			level.tv SetModel(TV_OFF);
			level.e_model_bouton StopLoopSound(1);
		}

	}
}

function tv_nuked_on()
{
	level waittill("code_available");

	level.tv SetModel(TV_ON);
	level.e_model_bouton PlayLoopSound( "amb_tv_on" ,  0.1 );
}

function tv_fail()
{
	while(1)
	{
		old = level.code_possible;

		level waittill("check_code");

		wait 0.5;

		if(level.code_possible == old)
		{
			//level.tv thread tv_show_fail();
		}
	}
}

function tv_show_fail()
{
	PlayFXOnTag(TV_FAIL_FX, level.e_model_bouton, "tag_origin");

	PlaySoundAtPosition ("word_wrong", level.e_model_bouton.origin);

	self SetModel(TV_FAIL);
	wait 0.5;

	self SetModel(TV_ON);
}

function code_result(result)
{
    if(result == FLAG_RANDOM_CODE_ACTIVE)
    {
        level.secret_code_entered = true;
    }
}

function add_code_to_tv(a,b,c,d,condition,result)
{
	if(isdefined(condition))
	{
        level waittill(condition);
    }

	level notify("code_available");
	level.code_possible++;

	while(1)
	{	
		level waittill("check_code");

		if(level.code_a == a && level.code_b == b && level.code_c == c && level.code_d == d)
		{
			level.tv thread tv_good();
			level thread code_result(result);
			level.code_possible--;
			break;
		}
		else
		{
			level.tv thread tv_show_fail();
		}
	}

}

function tv_good()
{
	PlaySoundAtPosition ("word_right", level.e_model_bouton.origin);
	self SetModel("tv_nuked_good");
	wait 1;
	self SetModel("tv_nuked_on");
}

function tv_validate_move(trig) // AVRIL 18/04/19
{
	goal = struct::get("validate_move", "targetname");
	origin = self.origin;
	while(1)
	{
		trig waittill("trigger", player);
		PlaySoundAtPosition("bouton_press", self.origin);
		self MoveTo(goal.origin,0.5);
		wait 0.5;
		self MoveTo(origin,0.5);
	}
}

function validate_code(trig, selection)
{
	while(1)
    {
        currentNumberPosition = 0;

        trig waittill("trigger", player);

        level.code_a = selection.position;
        currentNumberPosition++;
        show_code_on_screen(currentNumberPosition);

        trig waittill("trigger", player);

        level.code_b = selection.position;
        currentNumberPosition++;
        show_code_on_screen(currentNumberPosition);

        trig waittill("trigger", player);

        level.code_c = selection.position;
        currentNumberPosition++;
        show_code_on_screen(currentNumberPosition);

        trig waittill("trigger", player);

        level.code_d = selection.position;
        currentNumberPosition++;
        show_code_on_screen(currentNumberPosition);

        level notify("check_code");

        wait 2;
    }
}

function validate_selection(tv_selection_trig)
{
	while(1)
	{
		tv_selection_trig waittill("trigger", player);

		level notify( "update_tv_selection" );

		wait 0.5;
	}
}

function tv_selection_think() // AVRIL 18/04/19
{
    tv_selection = GetEnt("tv_bouton_selection","targetname");
    level.e_model_bouton.position = 0;

    while ( 1 )
    {
        level waittill( "update_tv_selection" );
        level thread update_tv_clock( level.e_model_bouton );
    }
}

function update_tv_clock( tv_selection )
{
	tv_selection.position++;

	if(tv_selection.position >= 10)
	{
		tv_selection.position = 0;
	}

	tv_selection RotatePitch( -36, 0.1 );
	tv_selection PlaySound( "tv_code_switch" );
	tv_selection waittill( "rotatedone" );
}

function show_code_on_screen(index)
{
	switch(index)
    {
        case 1:
            level.tv SetModel( TV_ON_CODE_1 );
            break;
        case 2:
            level.tv SetModel( TV_ON_CODE_2 );
            break;
        case 3:
            level.tv SetModel( TV_ON_CODE_3 );
            break;
        case 4:
            level.tv SetModel( TV_ON_CODE_4 );
            break;
    }
}

function set_random_code()
{
    // Init random code 
	code_wavegun_rack_random = [];
	code_wavegun_rack_random[1] = "vox_nuked_special_a" ;
	code_wavegun_rack_random_code_a[1] = 0;
	code_wavegun_rack_random_code_b[1] = 5;
	code_wavegun_rack_random_code_c[1] = 6;
	code_wavegun_rack_random_code_d[1] = 9;

	code_wavegun_rack_random[2] = "vox_nuked_special_b" ;
	code_wavegun_rack_random_code_a[2] = 4;
	code_wavegun_rack_random_code_b[2] = 6;
	code_wavegun_rack_random_code_c[2] = 8;
	code_wavegun_rack_random_code_d[2] = 1;

	code_wavegun_rack_random[3] = "vox_nuked_special_c" ;
	code_wavegun_rack_random_code_a[3] = 5;
	code_wavegun_rack_random_code_b[3] = 6;
	code_wavegun_rack_random_code_c[3] = 8;
	code_wavegun_rack_random_code_d[3] = 3;

	code_wavegun_rack_random[4] = "vox_nuked_special_d" ;
	code_wavegun_rack_random_code_a[4] = 6;
	code_wavegun_rack_random_code_b[4] = 4;
	code_wavegun_rack_random_code_c[4] = 8;
	code_wavegun_rack_random_code_d[4] = 9;

	code_wavegun_rack_random[5] = "vox_nuked_special_e" ;
	code_wavegun_rack_random_code_a[5] = 9;
	code_wavegun_rack_random_code_b[5] = 1;
	code_wavegun_rack_random_code_c[5] = 8;
	code_wavegun_rack_random_code_d[5] = 2;

	code_wavegun_rack_random[6] = "vox_nuked_special_f" ;
	code_wavegun_rack_random_code_a[6] = 9;
	code_wavegun_rack_random_code_b[6] = 7;
	code_wavegun_rack_random_code_c[6] = 9;
	code_wavegun_rack_random_code_d[6] = 4;

	code_wavegun_rack_random[7] = "vox_nuked_special_g" ;
	code_wavegun_rack_random_code_a[7] = 0;
	code_wavegun_rack_random_code_b[7] = 6;
	code_wavegun_rack_random_code_c[7] = 9;
	code_wavegun_rack_random_code_d[7] = 0;

	code_wavegun_rack_random[8] = "vox_nuked_special_h" ;
	code_wavegun_rack_random_code_a[8] = 1;
	code_wavegun_rack_random_code_b[8] = 1;
	code_wavegun_rack_random_code_c[8] = 1;
	code_wavegun_rack_random_code_d[8] = 9;

	code_wavegun_rack_random[9] = "vox_nuked_special_i" ;
	code_wavegun_rack_random_code_a[9] = 3;
	code_wavegun_rack_random_code_b[9] = 9;
	code_wavegun_rack_random_code_c[9] = 5;
	code_wavegun_rack_random_code_d[9] = 4;

	code_wavegun_rack_random[10] = "vox_nuked_special_j" ;
	code_wavegun_rack_random_code_a[10] = 5;
	code_wavegun_rack_random_code_b[10] = 3;
	code_wavegun_rack_random_code_c[10] = 1;
	code_wavegun_rack_random_code_d[10] = 4;

	code_wavegun_rack_random[11] = "vox_nuked_special_k" ;
	code_wavegun_rack_random_code_a[11] = 5;
	code_wavegun_rack_random_code_b[11] = 3;
	code_wavegun_rack_random_code_c[11] = 1;
	code_wavegun_rack_random_code_d[11] = 9;

	code_wavegun_rack_random[12] = "vox_nuked_special_l" ;
	code_wavegun_rack_random_code_a[12] = 6;
	code_wavegun_rack_random_code_b[12] = 5;
	code_wavegun_rack_random_code_c[12] = 8;
	code_wavegun_rack_random_code_d[12] = 7;

	code_wavegun_rack_random[13] = "vox_nuked_special_m" ;
	code_wavegun_rack_random_code_a[13] = 6;
	code_wavegun_rack_random_code_b[13] = 9;
	code_wavegun_rack_random_code_c[13] = 6;
	code_wavegun_rack_random_code_d[13] = 9;

    // Choose a random code
	i = RandomInt(code_wavegun_rack_random.size);

    trigger = Spawn( "trigger_damage", level.e_model_bouton.origin, 0, 15, 72);

	sound_pos = trigger.origin;

	code_generate = false;

    level.secret_code_entered = false;

    // Allow player to knockout the TV until the code is validate
	while(level.secret_code_entered != true)
	{
		trigger waittill( "damage", amount, attacker, direction_vec, point, type, tagName, ModelName, Partname, weapon );
		
        if ( IsSubStr(weapon.name,"t6_tazer_knuckles") )
        {
            PlaySoundAtPosition(code_wavegun_rack_random[i],sound_pos);

            if(!code_generate)
            {
                level thread add_code_to_tv(
                    code_wavegun_rack_random_code_a[i],
                    code_wavegun_rack_random_code_b[i],
                    code_wavegun_rack_random_code_c[i],
                    code_wavegun_rack_random_code_d[i],
                    undefined,
                    FLAG_RANDOM_CODE_ACTIVE); 

                code_generate = true;
            }
            
            // Wait for the code to be played before allowing the player to knock out the TV again
            wait 40;
        }
			
        

	}
 
}