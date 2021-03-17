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

new g_iDetections[33];
new g_iMaxFPS[33];
new g_iCvarFPS[33];
new g_iCurrFPS[33];
new g_iCmdRate[33];
#define MAXPERFECT 12
#define MAXSEMIPERFECT 17

//Speedhack
#define FPS_TASK_ID 927560

new g_fps[33][11];
new g_i[33];
//---------------
//Start AC on new round
new bool:g_bAntiCheat [33];
//---------------------
#define TASK_UPDATEMENU 1554
public plugin_init () {
	register_plugin( "Anti-Cheat" , "1.3b" , "chick & TeeZ0" );
	register_forward ( FM_CmdStart , "fw_CmdStart" );
	register_forward ( FM_PlayerPreThink , "fw_PlayerPreThink" );
	register_forward ( FM_PlayerPostThink , "fw_PlayerPostThink" );
	RegisterHam ( Ham_Spawn , "player" , "fw_PlayerSpawn" , 1 );
	
	register_clcmd("say /anticheat", "fwAntiCheat", ADMIN_KICK);
}

public fwAntiCheat(id){
	new menu = menu_create("\rAnti-Cheat", "hAntiCheat");
	
	new players [ 32 ] , playercount , PlayerID;
	get_players ( players , playercount );
	for ( new i = 0; i < playercount; i++ )
	{
		PlayerID = players [ i ];
		
		if(!is_user_connected(PlayerID) || is_user_bot(PlayerID))
			continue;
			
		new playerName[32];
		get_user_name(PlayerID, playerName, 31);
		new szId[6];
		num_to_str(PlayerID, szId, 5);
		menu_additem(menu, playerName, szId);
	}
	
	menu_display(id, menu);
	
	return PLUGIN_HANDLED;
}

public hAntiCheat(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new name[32],szID[6],access,callback;
	menu_item_getinfo(menu, item, access, szID, 5, name, 31, callback)
	new PlayerID = str_to_num(szID);

	if(is_user_connected(PlayerID) && !is_user_bot(PlayerID)){
		new array[2];
		array[0] = id;
		array[1] = PlayerID;
		set_task(1.0, "AntiCheatPlayer", id+TASK_UPDATEMENU, array, sizeof(array), "b");
	}
	
	return PLUGIN_HANDLED;
}

public AntiCheatPlayer(info[], task_id){
	new PlayerID = info[1];
	new CallerID = info[0];
	query_client_cvar(PlayerID, "fps_max", "check_fps_max");

	new szNick[32], AuthID[64], IP[16];
	get_user_name(PlayerID, szNick, 32)
	get_user_authid(PlayerID, AuthID, 63);
	get_user_ip(PlayerID, IP, 15, 1);
	new Float:flRatio = ( float (g_iRatioBhop [PlayerID][FOG1]) + float (g_iRatioBhop [PlayerID][FOG2])) / float(g_iTotalBhop  [PlayerID][MOTD]) * 100;

	new first[312], len;
	new local = false;
	if(equal(IP, "loopback"))
		local = true;
	
	new currFps[10];
	num_to_str(g_iCurrFPS[PlayerID], currFps, 9);
	
	len = format(first, 311, "\rAntiCheat^n^n\rNick: \d%s^n\rSteamID: \d%s^n\rIP: \d%s^n^n\yPerfect Hops: \d%i / %i^n\ySemi-Perfect Hops: \d%i / %i^n",szNick, AuthID, IP, g_iPerfectBhop[PlayerID][FOG1],g_iMotdBhop[PlayerID][FOG1], g_iPerfectBhop [PlayerID][FOG2], g_iMotdBhop[PlayerID][FOG2]);
	len += format(first [ len ], 311, "\yTotal Bhops: \d%i^n\yRatio: \d%2.f^n\yDetections: \d%i^n\yFPS: \d%s^n\yMax FPS: \d%i^n\yFPS Cvar: \d%i", g_iTotalBhop [RATIO],flRatio, g_iDetections[PlayerID], local ? "LOCAL" : currFps, g_iMaxFPS[PlayerID], g_iCvarFPS[PlayerID]); 
	
	
	new menu = menu_create(first, "hAntiCheatPlayer");
	
	
	menu_additem(menu, "\wZpet");
	menu_additem(menu, "\wExit");
	menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER);
	menu_display(CallerID, menu);
	
	return PLUGIN_HANDLED;
}

public hAntiCheatPlayer(id, menu, item){
	if(item == 1){
		remove_task(id + TASK_UPDATEMENU);
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	if(item == 0){
		remove_task(id + TASK_UPDATEMENU);
		menu_destroy(menu);
		fwAntiCheat(id);	
		return PLUGIN_HANDLED;
	}

	return PLUGIN_HANDLED;
}

public client_putinserver(id) {
	g_iPerfectGstrafe [id][FOG1] = 0;
	g_iPerfectGstrafe [id][FOG2] = 0;
	g_iPerfectGstrafe [id][FOG3] = 0;
	g_iPerfectGstrafe [id][FOG4] = 0;
	g_bBanned [id] = false;
	g_bAntiCheat [id] = false;
	g_iMaxFPS [id] = 0;
	g_iCurrFPS[id] = 0;
	
	set_task(1.0, "resetCmdRate", id, "", 0, "b");
	set_task(0.1, "count", FPS_TASK_ID + id, "", 0, "b");

}

public client_disconnect(id) {
	remove_task(FPS_TASK_ID + id);
}

public count(id) {
	if ( g_i[id] < 9 )
		g_i[id]++;
	else
		g_i[id] = 0;
        
	g_fps[id][g_i[id]] = g_fps[id][10];
	g_fps[id][10] = 0;
}

public resetCmdRate(id){

	g_iCmdRate[id] = 0;
	
}

public fw_PlayerSpawn ( id ) {
	g_bAntiCheat [id] = false;
}



public check_fps_max(id, const szCvar, const szValue[]){
	g_iCvarFPS[id] = str_to_num(szValue);
}

public fw_CmdStart ( id , uc_handle ) {
	if ( !is_user_alive(id) || is_user_bot(id) || pev ( id , pev_flags) & FL_FROZEN || pev ( id , pev_maxspeed ) < 150.0 || g_bBanned [id] || !g_bAntiCheat [id] )
		return FMRES_IGNORED;
	
	
	get_uc ( uc_handle , UC_SideMove , g_flSideMove[id] );
	get_uc ( uc_handle , UC_ForwardMove , g_flForwardMove[id] );
	
	
	g_iCmdRate[id]++;
	
	g_iCurrFPS[id] = get_user_fps(id);
	
	if(g_iCurrFPS[id] > g_iMaxFPS[id])
		g_iMaxFPS[id] = g_iCurrFPS[id];
	
	
	if(g_iCurrFPS[id] + 100 < g_iCmdRate[id]){
		new name [32] , steamid [32];
		get_user_name ( id , name , charsmax(name) );
		get_user_authid ( id , steamid , charsmax(steamid) );
		//g_bBanned [id] = true;
		ColorChat ( 0 , "^1[^4Anti-Cheat^1] Player ^4%s^1(^4%s^1) is using speedhack! %i | %i" , name , steamid, g_iCurrFPS[id], g_iCmdRate[id]);
		//g_iDetections[id] ++;
	}
	
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
		g_iDetections[id] ++;
	}
	//----------------------------------------------------------------------------------------------------------------------
	//Checking by values of other button what is not pressed
	if ( g_iMove [id][LEFT] > 2 && !g_bStrafeMod [id] && button & IN_MOVELEFT && oldbuttons & IN_MOVELEFT && !(button & IN_FORWARD) && !(button & IN_BACK) ) {
		if ( g_flForwardMove[id] != 0.0 ) {
			new name [32] , steamid [32];
			get_user_name ( id , name , charsmax(name) );
			get_user_authid ( id , steamid , charsmax(steamid) );
			g_bBanned [id] = true;
			g_iDetections[id] ++;
			ColorChat ( 0 , "^1[^4Anti-Cheat^1] Player ^4%s^1(^4%s^1) is using strafehack! (0x0002x0)" , name , steamid );
		}
	}
	if ( g_iMove [id][RIGHT] > 2 && !g_bStrafeMod [id] && button & IN_MOVERIGHT && oldbuttons & IN_MOVERIGHT && !(button & IN_FORWARD) && !(button & IN_BACK) ) {
		if ( g_flForwardMove[id] != 0.0 ) {
			new name [32] , steamid [32];
			get_user_name ( id , name , charsmax(name) );
			get_user_authid ( id , steamid , charsmax(steamid) );
			g_bBanned [id] = true;
			g_iDetections[id] ++;
			ColorChat ( 0 , "^1[^4Anti-Cheat^1] Player ^4%s^1(^4%s^1) is using strafehack! (0x0002x1)" , name , steamid );
		}
	}
	if ( g_iMove [id][UP] > 2 && !g_bStrafeMod [id] && button & IN_FORWARD && oldbuttons & IN_FORWARD && !(button & IN_MOVELEFT) && !(button & IN_MOVERIGHT) ) {
		if ( g_flSideMove[id] != 0.0 ) {
			new name [32] , steamid [32];
			get_user_name ( id , name , charsmax(name) );
			get_user_authid ( id , steamid , charsmax(steamid) );
			g_bBanned [id] = true;
			g_iDetections[id] ++;
			ColorChat ( 0 , "^1[^4Anti-Cheat^1] Player ^4%s^1(^4%s^1) is using strafehack! (0x0002x2)" , name , steamid );
		}
	}
	if ( g_iMove [id][DOWN] > 2 && !g_bStrafeMod [id] && button & IN_BACK && oldbuttons & IN_BACK && !(button & IN_MOVELEFT) && !(button & IN_MOVERIGHT) ) {
		if ( g_flSideMove[id] != 0.0 ) {
			new name [32] , steamid [32];
			get_user_name ( id , name , charsmax(name) );
			get_user_authid ( id , steamid , charsmax(steamid) );
			g_bBanned [id] = true;
			g_iDetections[id] ++;
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
			g_iDetections[id] ++;
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
			g_iDetections[id] ++;
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
			g_iDetections[id] ++;
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
			g_iDetections[id] ++;
			ColorChat ( 0 , "^1[^4Anti-Cheat^1] Player ^4%s^1(^4%s^1) is using strafehelper! (0x0003x3)" , name , steamid );
		}
	}
	//----------------------------------------------------------------------------------------------------------------------
	return FMRES_IGNORED;
}
public fw_PlayerPreThink ( id ) {
	if ( !g_bAntiCheat [id] ) {
		if ( is_user_alive(id) && pev ( id , pev_flags ) & FL_ONGROUND && !(pev ( id , pev_flags ) & FL_FROZEN ) ) {
			g_bAntiCheat [id] = true;
		}
	}
	if ( !is_user_alive(id) || is_user_bot(id) || pev ( id , pev_maxspeed ) < 150.0 || g_bBanned [id] || !g_bAntiCheat [id] )
		return FMRES_IGNORED;
	g_fps[id][10]++;

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
			
		}
		else if ( g_iFrames [id] == 2 ) {
			//For detection perfects
			g_iPerfectBhop [id][FOG2]++;
			g_iPerfectBhop [id][FOG1] = 0;
			//For ratio
			g_iRatioBhop [id][FOG2]++;
		
		}
		else {
			//For detection perfects
			g_iPerfectBhop [id][FOG1] = 0;
			g_iPerfectBhop [id][FOG2] = 0;
			//For ratio
			g_iRatioBhop [id][FOG3]++;
			
		}
	}
	//Bhop by ratio
	if ( g_iTotalBhop [id][RATIO] >= 60 )
	{
		new Float:flRatio = ( float(g_iRatioBhop[id][FOG1]) + float(g_iRatioBhop [id][FOG2])) / float(g_iTotalBhop [id][RATIO]) * 100;
		if ( flRatio >= 99.0 )
		{
			
			new szName [ 32 ] , szSteamId [ 32 ];
			get_user_name ( id , szName , charsmax(szName) );
			get_user_authid ( id , szSteamId , charsmax(szSteamId) );
			ColorChat(0, "^3[^4Anti-Cheat^3]^1 %s (^4%s^1) is using bhop hack!", szName, szSteamId);
			g_iDetections[id] ++;
			g_bBanned[id] = true;
		}
		g_iTotalBhop [id][RATIO] = 0;
	}
	//End
	
	//Detect if player reached MAXPERFECT ( 12 ) perfect bhops.
	if ( g_iPerfectBhop [id] [FOG1] >= MAXPERFECT )
	{
			
	
		new szName [ 32 ] , szSteamId [ 32 ];
		get_user_name ( id , szName , charsmax(szName) );
		get_user_authid ( id , szSteamId , charsmax(szSteamId) );
		ColorChat(0, "^3[^4Anti-Cheat^3]^1 %s (^4%s^1) is using bhop hack!", szName, szSteamId);
		g_iDetections[id] ++;
		g_bBanned[id] = true;

	}
	
	//Detect if player reached MAXSEMIPERFECT ( 17 ) perfect bhops.
	if ( g_iPerfectBhop [id] [FOG2] >= MAXSEMIPERFECT )
	{
		

		new szName [ 32 ] , szSteamId [ 32 ];
		get_user_name ( id , szName , charsmax(szName) );
		get_user_authid ( id , szSteamId , charsmax(szSteamId) );
		ColorChat(0, "^3[^4Anti-Cheat^3]^1 %s (^4%s^1) is using bhop hack!", szName, szSteamId);
		g_iDetections[id] ++;
		g_bBanned[id] = true;
	
	}

	//Gstrafe detect
	//Detecting GS by FOG 1 & FOG 2
	if( flPlayerSpeed > 50.0 && g_iFrames[ id ] < 6 && button & IN_DUCK && ~get_user_oldbutton(id) & IN_DUCK  && pev( id, pev_flags ) & FL_ONGROUND  )
		{
		if( ( g_iFrames[ id ] == 1 && flPlayerSpeed < 400.0 )  )
		{
			g_iPerfectGstrafe [ id ] [FOG2] = 0;
			g_iPerfectGstrafe [ id ] [FOG1]++;
		} else if ( ( g_iFrames[ id ] == 2 && flPlayerSpeed < 400.0 ) )
		{
			g_iPerfectGstrafe [ id ] [FOG1] = 0;
			g_iPerfectGstrafe [ id ] [FOG2]++;
		} else
		{
			g_iPerfectGstrafe [ id ] [FOG1] = 0;
			g_iPerfectGstrafe [ id ] [FOG2] = 0;
		}
			
		if (  g_iPerfectGstrafe [ id ] [FOG1] >= MAXPERFECT || g_iPerfectGstrafe [ id ] [FOG2] >= MAXSEMIPERFECT ) {
			new name [ 64 ], steamid [ 64 ];
			get_user_name ( id, name, charsmax(name) );
			get_user_authid ( id, steamid, charsmax(steamid) );
			
			ColorChat(0, "^3[^4Anti-Cheat^3]^1 %s (^4%s^1) is using groundstrafe hack!", name, steamid);
			g_bBanned[id] = true;

			g_iDetections[id]++;
					
			
		}
	}
	
	// Detecting GS by Ratio
	if( flPlayerSpeed > 50.0 && g_iFrames[ id ] < 6 && button & IN_DUCK && ~get_user_oldbutton(id) & IN_DUCK  && pev( id, pev_flags ) & FL_ONGROUND  )
		{
		if ( g_iFrames [ id ] == 1 && flPlayerSpeed < 400.0 )
			g_iPerfectGstrafe [ id ] [FOG1] ++;
		if ( g_iFrames [ id ] == 2 && flPlayerSpeed < 400.0 )
			g_iPerfectGstrafe [ id ] [FOG2]++;
		if ( g_iFrames [ id ] > 2 && flPlayerSpeed < 400.0 )
			g_iPerfectGstrafe [ id ] [FOG3] ++;
		
		new g_iGstrafeRatio = g_iPerfectGstrafe [ id ] [FOG1] + g_iPerfectGstrafe [ id ] [FOG2] + g_iPerfectGstrafe [ id ] [FOG3];
			
		if ( g_iGstrafeRatio == 60 ) {
			new Float:g_Result = ( g_iPerfectGstrafe [ id ] [FOG1] + g_iPerfectGstrafe  [ id ] [FOG2] ) / float( g_iGstrafeRatio) * 100;
				
			if ( g_Result >= 95 ) {
				new name [ 32 ], steamid [ 32 ], ip [ 32 ];
				get_user_name ( id, name, charsmax(name) );
				get_user_authid ( id, steamid, charsmax(steamid) );
				get_user_ip ( id, ip, charsmax(ip), 0 );
			
				ColorChat(0, "^3[^4Anti-Cheat^3]^1 %s (^4%s^1) is using groundstrafe hack!", name, steamid);
				
				g_iDetections[id]++;
				
				g_bBanned[id] = true;
			}
			g_iPerfectGstrafe [ id ] [FOG1] = 0;
			g_iPerfectGstrafe [ id ] [FOG2] = 0;
			g_iPerfectGstrafe [ id ] [FOG3] = 0;
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

//Speedhack
stock get_user_fps(id) 
{
    new i;
    new j = 0;
    
    for ( i = 0 ; i < 9 ; i++ )
        j += g_fps[id][i];
    
    return j - 5;
} 

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1029\\ f0\\ fs16 \n\\ par }
*/
