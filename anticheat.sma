#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <fun>

//Banned?
new bool:g_bBanned [33];

//Flags
new g_OnGround [33];

//Frames
new g_iFrames [33],
	g_iMove[33][4];
	//Moves
#define LEFT 0
#define RIGHT 1
#define DOWN 2
#define UP 3
//-----

//Strafe detection
	//FW & SW move & MS
new Float:g_flForwardMove [33],
	Float:g_flSideMove [33];

	//Angles & strafeOn
new bool:g_bStrafeMod [33],
	Float:vOldAngles [33][3];
//----------------

//Bhop detection
new g_iTotalBhop [33][2],
	g_iPerfectBhop [33][2],
	g_iRatioBhop [33][3],
	g_iMotdBhop [33][3];

//Gstrafe detection
new g_iPerfectGstrafe [33][4];

#define FOG1 0
#define FOG2 1
#define FOG3 2
#define FOG4 3

#define MOTD 0
#define RATIO 1
//---------------
//Start AC on new round
new bool:g_bAntiCheat [33];
//---------------------

public plugin_init () {
	register_plugin( "Anti-Cheat" , "1.3b" , "chick & TeeZ0" );

	register_forward ( FM_CmdStart , "fw_CmdStart" );
	register_forward ( FM_PlayerPreThink , "fw_PlayerPreThink" );
	register_forward ( FM_PlayerPostThink , "fw_PlayerPostThink" );

	RegisterHam ( Ham_Spawn , "player" , "fw_PlayerSpawn" , 1 );
	register_event ( "DeathMsg" , "fw_DeathPlayer" , "a" );
}

public client_putinserver(id) {
	g_iPerfectGstrafe [id][FOG1] = 0;
	g_iPerfectGstrafe [id][FOG2] = 0;
	g_iPerfectGstrafe [id][FOG3] = 0;
	g_iPerfectGstrafe [id][FOG4] = 0;

	g_bBanned [id] = false;
	g_bAntiCheat [id] = false;
}

public fw_DeathPlayer ( id ) {
	set_user_godmode( id , 0 );
}

public fw_PlayerSpawn ( id ) {
	g_bAntiCheat [id] = false;
	set_user_godmode( id , 1 );
}

public fw_CmdStart ( id , uc_handle ) {
	if ( !is_user_alive(id) || is_user_bot(id) || pev ( id , pev_flags) & FL_FROZEN || pev ( id , pev_maxspeed ) < 150.0 || g_bBanned [id] || !g_bAntiCheat [id] )
		return FMRES_IGNORED;

	get_uc ( uc_handle , UC_SideMove , g_flSideMove[id] );
	get_uc ( uc_handle , UC_ForwardMove , g_flForwardMove[id] );

	return FMRES_IGNORED;
}

public fw_PlayerPostThink ( id , uc_handle ) {
	if ( !is_user_alive(id) || is_user_bot(id) || pev ( id , pev_flags) & FL_FROZEN || pev ( id , pev_maxspeed ) < 150.0 || g_bBanned [id] || !g_bAntiCheat [id] )
		return FMRES_IGNORED;

	new Float:flMaxSpeed;
	pev ( id , pev_maxspeed , flMaxSpeed );

	new button = pev ( id , pev_button );
	new oldbuttons = pev ( id , pev_oldbuttons );

	//Checking by check limits
	if ( g_flForwardMove[id] > flMaxSpeed || g_flSideMove[id] > flMaxSpeed || g_flForwardMove[id] < -flMaxSpeed || g_flSideMove[id] < -flMaxSpeed ) {
		new name [32] , steamid [32];
		get_user_name ( id , name , charsmax(name) );
		get_user_authid ( id , steamid , charsmax(steamid) );

		g_bBanned [id] = true;
		ColorChat ( 0 , "^1[^4Anti-Cheat^1] Player ^4%s^1(^4%s^1) is using strafehack! (0x0001x0)" , name , steamid , g_flForwardMove[id] , g_flSideMove[id] , flMaxSpeed );
	}
	//----------------------------------------------------------------------------------------------------------------------

	//Checking by values of other button what is not pressed
	if ( g_iMove [id][LEFT] > 2 && !g_bStrafeMod [id] && button & IN_MOVELEFT && oldbuttons & IN_MOVELEFT && !(button & IN_FORWARD) && !(button & IN_BACK) ) {
		if ( g_flForwardMove[id] != 0.0 ) {
			new name [32] , steamid [32];
			get_user_name ( id , name , charsmax(name) );
			get_user_authid ( id , steamid , charsmax(steamid) );

			g_bBanned [id] = true;
			ColorChat ( 0 , "^1[^4Anti-Cheat^1] Player ^4%s^1(^4%s^1) is using strafehack! (0x0002x0)" , name , steamid );
		}
	}
	if ( g_iMove [id][RIGHT] > 2 && !g_bStrafeMod [id] && button & IN_MOVERIGHT && oldbuttons & IN_MOVERIGHT && !(button & IN_FORWARD) && !(button & IN_BACK) ) {
		if ( g_flForwardMove[id] != 0.0 ) {
			new name [32] , steamid [32];
			get_user_name ( id , name , charsmax(name) );
			get_user_authid ( id , steamid , charsmax(steamid) );

			g_bBanned [id] = true;
			ColorChat ( 0 , "^1[^4Anti-Cheat^1] Player ^4%s^1(^4%s^1) is using strafehack! (0x0002x1)" , name , steamid );
		}
	}
	if ( g_iMove [id][UP] > 2 && !g_bStrafeMod [id] && button & IN_FORWARD && oldbuttons & IN_FORWARD && !(button & IN_MOVELEFT) && !(button & IN_MOVERIGHT) ) {
		if ( g_flSideMove[id] != 0.0 ) {
			new name [32] , steamid [32];
			get_user_name ( id , name , charsmax(name) );
			get_user_authid ( id , steamid , charsmax(steamid) );

			g_bBanned [id] = true;
			ColorChat ( 0 , "^1[^4Anti-Cheat^1] Player ^4%s^1(^4%s^1) is using strafehack! (0x0002x2)" , name , steamid );
		}
	}
	if ( g_iMove [id][DOWN] > 2 && !g_bStrafeMod [id] && button & IN_BACK && oldbuttons & IN_BACK && !(button & IN_MOVELEFT) && !(button & IN_MOVERIGHT) ) {
		if ( g_flSideMove[id] != 0.0 ) {
			new name [32] , steamid [32];
			get_user_name ( id , name , charsmax(name) );
			get_user_authid ( id , steamid , charsmax(steamid) );

			g_bBanned [id] = true;
			ColorChat ( 0 , "^1[^4Anti-Cheat^1] Player ^4%s^1(^4%s^1) is using strafehack! (0x0002x3)" , name , steamid );
		}
	}
	//----------------------------------------------------------------------------------------------------------------------

	//Prestrafe hack & weird strafehelper detection o.O but works :D
	if ( !g_bStrafeMod[id] && g_iMove [id][LEFT] > 3 && g_iMove [id][UP] > 2 && button & IN_MOVELEFT && button & IN_FORWARD && !(button & IN_BACK) && !(button & IN_MOVERIGHT) ) {
		flMaxSpeed *= 0.7055;
		if ( g_flSideMove [id] > -flMaxSpeed+2 || g_flSideMove [id] < -flMaxSpeed-2 || g_flForwardMove [id] > flMaxSpeed+2 || g_flForwardMove [id] < flMaxSpeed-2 ) {
			new name [32] , steamid [32];
			get_user_name ( id , name , charsmax(name) );
			get_user_authid ( id , steamid , charsmax(steamid) );

			g_bBanned [id] = true;
			ColorChat ( 0 , "^1[^4Anti-Cheat^1] Player ^4%s^1(^4%s^1) is using strafehelper! (0x0003x0)" , name , steamid );
		}
	}
	if ( !g_bStrafeMod [id] && g_iMove [id][RIGHT] > 3 && g_iMove [id][UP] > 2 && button & IN_MOVERIGHT && button & IN_FORWARD && !(button & IN_BACK) && !(button & IN_MOVELEFT) ) {
		flMaxSpeed *= 0.7055;
		if ( g_flSideMove [id] > flMaxSpeed+2 || g_flSideMove [id] < flMaxSpeed-2 || g_flForwardMove [id] > flMaxSpeed+2 || g_flForwardMove [id] < flMaxSpeed-2 ) {
			new name [32] , steamid [32];
			get_user_name ( id , name , charsmax(name) );
			get_user_authid ( id , steamid , charsmax(steamid) );

			g_bBanned [id] = true;
			ColorChat ( 0 , "^1[^4Anti-Cheat^1] Player ^4%s^1(^4%s^1) is using strafehelper! (0x0003x1)" , name , steamid );
		}
	}
	if ( !g_bStrafeMod [id] && g_iMove [id][LEFT] > 3 && g_iMove [id][DOWN] > 2 && button & IN_MOVELEFT && button & IN_BACK && !(button & IN_FORWARD) && !(button & IN_MOVERIGHT) ) {
		flMaxSpeed *= 0.7055;
		if ( g_flSideMove [id] > -flMaxSpeed+2 || g_flSideMove [id] < -flMaxSpeed-2 || g_flForwardMove [id] > -flMaxSpeed+2 || g_flForwardMove [id] < -flMaxSpeed-2 ) {
			new name [32] , steamid [32];
			get_user_name ( id , name , charsmax(name) );
			get_user_authid ( id , steamid , charsmax(steamid) );

			g_bBanned [id] = true;
			ColorChat ( 0 , "^1[^4Anti-Cheat^1] Player ^4%s^1(^4%s^1) is using strafehelper! (0x0003x2)" , name , steamid );
		}
	}
	if ( !g_bStrafeMod [id] && g_iMove [id][RIGHT] > 3 && g_iMove [id][DOWN] > 2 && button & IN_MOVERIGHT && button & IN_BACK && !(button & IN_FORWARD) && !(button & IN_MOVELEFT) ) {
		flMaxSpeed *= 0.7055;
		if ( g_flSideMove [id] > flMaxSpeed+2 || g_flSideMove [id] < flMaxSpeed-2 || g_flForwardMove [id] > -flMaxSpeed+2 || g_flForwardMove [id] < -flMaxSpeed-2 ) {
			new name [32] , steamid [32];
			get_user_name ( id , name , charsmax(name) );
			get_user_authid ( id , steamid , charsmax(steamid) );

			g_bBanned [id] = true;
			ColorChat ( 0 , "^1[^4Anti-Cheat^1] Player ^4%s^1(^4%s^1) is using strafehelper! (0x0003x3)" , name , steamid );
		}
	}
	//----------------------------------------------------------------------------------------------------------------------

	return FMRES_IGNORED;
}

public fw_PlayerPreThink ( id ) {

	set_hudmessage( 250 , 0 , 0 , -1.0 , 0.25 , 0 , 0.1 , 0.2 , 0.05 , 0.05 );
	show_hudmessage( id , "Max fog1: %i^nMax fog2: %i^nMax fog3: %i^nMax fog4: %i" , g_iPerfectGstrafe[id][FOG1] , g_iPerfectGstrafe[id][FOG2] , g_iPerfectGstrafe[id][FOG3] , g_iPerfectGstrafe[id][FOG4] );

	if ( !g_bAntiCheat [id] ) {
		if ( is_user_alive(id) && pev ( id , pev_flags ) & FL_ONGROUND && !(pev ( id , pev_flags ) & FL_FROZEN ) ) {
			g_bAntiCheat [id] = true;
		}
	}

	if ( !is_user_alive(id) || is_user_bot(id) || pev ( id , pev_maxspeed ) < 150.0 || g_bBanned [id] || !g_bAntiCheat [id] )
		return FMRES_IGNORED;

	new button = pev ( id , pev_button );
	new oldbuttons = pev ( id , pev_oldbuttons );

	g_OnGround [id] = pev ( id , pev_flags ) & FL_ONGROUND;

	//Strafe modificator
	new Float:vAngles [3];
	pev ( id , pev_v_angle , vAngles );

	if ( vAngles [0] == vOldAngles [id][0] || vAngles [1] == vOldAngles [id][1] )
		g_bStrafeMod [id] = true;
	else
		g_bStrafeMod [id] = false;
	//------------------

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	//Frames on ground
	if ( g_OnGround[id] )
		g_iFrames [id]++;
	else
		g_iFrames [id] = 0;
	//MOVELEFT FRAMES
	if ( button & IN_MOVELEFT )
		g_iMove [id][LEFT]++;
	else
		g_iMove [id][LEFT] = 0;
	//MOVERIGHT FRAMES
	if ( button & IN_MOVERIGHT )
		g_iMove [id][RIGHT]++;
	else
		g_iMove [id][RIGHT] = 0;
	//MOVEFORWARD FRAMES
	if ( button & IN_FORWARD )
		g_iMove [id][UP]++;
	else
		g_iMove [id][UP] = 0;
	//MOVEBACK FRAMES
	if ( button & IN_BACK )
		g_iMove [id][DOWN]++;
	else
		g_iMove [id][DOWN] = 0;

	new Float:flVelocity[ 3 ];
	pev ( id , pev_velocity , flVelocity );
	new Float:flPlayerSpeed = floatsqroot( flVelocity[ 0 ] * flVelocity[ 0 ] + flVelocity[ 1 ] * flVelocity[ 1 ] );

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	//Bhop detection
		//By perfect bhops
	if ( flPlayerSpeed > 50.0 && g_iFrames[id] < 6 && button & IN_JUMP && ~oldbuttons & IN_JUMP && g_OnGround [id] ) {
		g_iTotalBhop [id][MOTD]++;
		g_iTotalBhop [id][RATIO]++;
		if ( g_iFrames [id] == 1 ) {
			//For detection perfects
			g_iPerfectBhop [id][FOG1]++;
			g_iPerfectBhop [id][FOG2] = 0;
			//For ratio
			g_iRatioBhop [id][FOG1]++;
			//For MOTD
			g_iMotdBhop [id][FOG1]++;
		}
		else if ( g_iFrames [id] == 2 ) {
			//For detection perfects
			g_iPerfectBhop [id][FOG2]++;
			g_iPerfectBhop [id][FOG1] = 0;
			//For ratio
			g_iRatioBhop [id][FOG2]++;
			//For MOTD
			g_iMotdBhop [id][FOG2]++;
		}
		else {
			//For detection perfects
			g_iPerfectBhop [id][FOG1] = 0;
			g_iPerfectBhop [id][FOG2] = 0;
			//For ratio
			g_iRatioBhop [id][FOG3]++;
			//For MOTD
			g_iMotdBhop [id][FOG3]++;
		}
	}

	if ( flPlayerSpeed > 50.0 && g_iFrames[id] < 5 && button & IN_DUCK && ~oldbuttons & IN_JUMP && g_OnGround [id] ) {
		if ( g_iFrames[id] == 1 ) {
			g_iPerfectGstrafe [id][FOG1]++;
			g_iPerfectGstrafe [id][FOG2] = 0;
			g_iPerfectGstrafe [id][FOG3] = 0;
			g_iPerfectGstrafe [id][FOG4] = 0;
		} else if ( g_iFrames[id] == 2 ) {
			g_iPerfectGstrafe [id][FOG2]++;
			g_iPerfectGstrafe [id][FOG1] = 0;
			g_iPerfectGstrafe [id][FOG3] = 0;
			g_iPerfectGstrafe [id][FOG4] = 0;
		} else if ( g_iFrames[id] == 3 ) {
			g_iPerfectGstrafe [id][FOG3]++;
			g_iPerfectGstrafe [id][FOG1] = 0;
			g_iPerfectGstrafe [id][FOG2] = 0;
			g_iPerfectGstrafe [id][FOG4] = 0;
		} else {
			g_iPerfectGstrafe [id][FOG4]++;
			g_iPerfectGstrafe [id][FOG1] = 0;
			g_iPerfectGstrafe [id][FOG2] = 0;
			g_iPerfectGstrafe [id][FOG3] = 0;
		}
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	//Strafe modificator//
	vOldAngles [id][0] = vAngles [0];
	vOldAngles [id][1] = vAngles [1];
	//-----------------//

	return FMRES_IGNORED;
}

stock ColorChat(const id, const input[], any:...) 
{ 
    new count = 1, players[32] 
    static msg[ 191 ] 
    vformat(msg, 190, input, 3) 
     
    replace_all(msg, 190, "^x01" , "^1") //white
    replace_all(msg, 190, "^x03" , "^3") //team
    replace_all(msg, 190, "^x04" , "^4") //green
     
    if (id) players[0] = id; else get_players(players , count , "ch") 
    { 
    for (new i = 0; i < count; i++) 
    { 
            if (is_user_connected(players[i])) 
            { 
                message_begin(MSG_ONE_UNRELIABLE , get_user_msgid("SayText"), _, players[i]) 
                write_byte(players[i]); 
                write_string(msg); 
                message_end(); 
            } 
        } 
    } 
} 
