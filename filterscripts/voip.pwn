//========= Includes ===========
#include <a_samp>
#include <core>
#include <float>
#include <zcmd>
#include <sscanf>
#include <sampvoice>
//==============================

//====== Defines ======
#define MAX_FREQUENCIAS	50 //Máximo De Frequencia Do Radio
//=====================
main()
{
print("\n----------------------------------");
print(" Sistema De Voip+Radio Por Voip By Fenix");
print("----------------------------------\n");
}
//======= News =========
new SV_GSTREAM:Frequencia[MAX_FREQUENCIAS] = SV_NULL;
new SV_GSTREAM:gstream;
new SV_LSTREAM:lstream[MAX_PLAYERS] = { SV_NULL, ... };
new FrequenciaConectada[MAX_PLAYERS];
//====================================================


//======= Publics =========
public OnGameModeInit()
{
	gstream = SvCreateGStream(0xffff0000, "G"); // blue color
    for(new i = 0; i < MAX_FREQUENCIAS; i++)
	{
		Frequencia[i] = SvCreateGStream(0xFF5800FF, "Radio-Voip");
	}
	print("\n----------------------------------");
	print(" Sistema De Voip+Radio Por Voip Carregado!");
	print("----------------------------------\n");
	
	return 1;
}

public OnGameModeExit()
{
   // DOF2_Exit();
    for(new i = 0; i < MAX_FREQUENCIAS; i++)
	{
		SvDeleteStream(Frequencia[i]);
	}
	//DOF2_Exit();
	return 1;
}

public OnPlayerConnect(playerid)
{
	if(!SvGetVersion(playerid))
	{
	    SendClientMessage(playerid, 0xFFFF00AA, "================ VOIP  ======================");
		SendClientMessage(playerid, 0xFFFF00AA, "[VOI-INFO]: Seu VOIP não foi encontrado!");
		SendClientMessage(playerid, 0xFFFF00AA, "=============================================");
	}
	else if(!SvHasMicro(playerid))
	{
	    SendClientMessage(playerid, 0xFFFF00AA, "================ VOIP  ======================");
		SendClientMessage(playerid, 0xFFFF00AA, "[VOIP=VOIP]: Seu microfone não foi carregado!");
		SendClientMessage(playerid, 0xFFFF00AA, "=============================================");
	}
	else
	{
 		lstream[playerid] = SvCreateDLStreamAtPlayer(40.0, SV_INFINITY, playerid, 0xff0000ff, "L");
 		SendClientMessage(playerid, 0xFFFF00AA, "================ VOIP  ======================");
  		SendClientMessage(playerid, 0xFFFF00AA, "[VOIP INFO]: Seu VOIP foi carregado com sucesso!");
	    SendClientMessage(playerid, 0xFFFF00AA, "==============================================");
		if (gstream) SvAttachListenerToStream(gstream, playerid);
		SvAddKey(playerid, 0x5A);//Z
		SvAddKey(playerid, 0x42);//B
	}
	return 1;

}

public OnPlayerDisconnect(playerid, reason)
{
    if(lstream[playerid])
	{
		SvDeleteStream(lstream[playerid]);
		lstream[playerid] = SV_NULL;
	}
	return 1;
}

public SV_VOID:OnPlayerActivationKeyPress(SV_UINT:playerid, SV_UINT:keyid)
{
	if(keyid == 0x5A && FrequenciaConectada[playerid] >= 1)
	{
		ApplyAnimation(playerid, "ped", "phone_talk", 4.1, 1, 1, 1, 0, 0, 0);
		if(!IsPlayerAttachedObjectSlotUsed(playerid, 9)) SetPlayerAttachedObject(playerid, 9, 19942, 2, 0.0300, 0.1309, -0.1060, 118.8998, 19.0998, 164.2999);
		SvAttachSpeakerToStream(Frequencia[FrequenciaConectada[playerid]], playerid);
	}
	if(keyid == 0x5A && lstream[playerid])
	{
		SvAttachSpeakerToStream(lstream[playerid], playerid); //local
	}
	if(keyid == 0x42 && gstream)
	{
	    if(IsPlayerAdmin(playerid))
	    {
			SvAttachSpeakerToStream(gstream, playerid); //global
		}
	}
}

public SV_VOID:OnPlayerActivationKeyRelease(SV_UINT:playerid, SV_UINT:keyid)
{
	if(keyid == 0x5A && FrequenciaConectada[playerid] >= 1)
	{
		SvDetachSpeakerFromStream(Frequencia[FrequenciaConectada[playerid]], playerid);
		PlayAudioStreamForPlayer(playerid, "https://dl.dropboxusercontent.com//s/b7zvucbh0iv7yla/radioon.mp3?dl=0");
		SetTimerEx("SoundRadio", 3000, false, "id", playerid);// Som Radio Fivem
		ClearAnimations(playerid);
		if(IsPlayerAttachedObjectSlotUsed(playerid, 9)) RemovePlayerAttachedObject(playerid, 9);
	}
}
//======================================================================================================

//======== Comandos ========

CMD:frequencia(playerid, params[])
{
	new freq;
	if(sscanf(params, "d", freq)) return SendClientMessage(playerid, -1,"Uso: /frequencia [FREQ. 1-50 (0 Desligar)]");
	if(freq > 50 || freq < 0) return SendClientMessage(playerid, 0xFF0000FF, "Frequencia Invalida!");
	if(freq == 0)
	{
    FrequenciaConectada[playerid] = 0;
	SendClientMessage(playerid, 0xFF0000FF, "Radio-Voip Desligado!");
	SvDetachListenerFromStream(Frequencia[freq], playerid);
	} else {
		new string[128];
		format(string, 128, "[Radio-Voip] Frequencia conectada: (%d).", freq);
		PlayAudioStreamForPlayer(playerid, "https://dl.dropboxusercontent.com//s/b7zvucbh0iv7yla/radioon.mp3?dl=0");
		SendClientMessage(playerid, 0x00AE00FF, string);

		format(string, 128, "[Radio-Voip] %s saiu da frequencia(%d)", Get_Nome(playerid), FrequenciaConectada[playerid]);
		MsgFrequencia(FrequenciaConectada[playerid], 0xBF0000FF, string);
		format(string, 128, "[Radio-Voip] %s conectou na frequencia(%d)", Get_Nome(playerid), freq);
		MsgFrequencia(freq, 0xFF6C00FF, string);

		SetTimerEx("ConectarNaFrequencia", 100, false, "id", playerid, freq);
	}
	return 1;
}

//======= Stocks ========

stock Get_Nome(playerid)
{
	new namep[MAX_PLAYER_NAME+1];
	GetPlayerName(playerid, namep, MAX_PLAYER_NAME+1);
	return namep;
}

stock MsgFrequencia(freq, color, msg[])
{
	for(new i=0;i<MAX_PLAYERS;i++)
	{
		if(IsPlayerConnected(i))
		{
			if(FrequenciaConectada[i] > 0 && FrequenciaConectada[i] == freq)
			{
				SendClientMessage(i, color, msg);
			}
		}
	}
	return 1;
}

forward ConectarNaFrequencia(playerid, freq);
public ConectarNaFrequencia(playerid, freq)
{
	FrequenciaConectada[playerid] = freq;
	SvAttachListenerToStream(Frequencia[freq], playerid);
	return 1;
}


forward SoundRadio(playerid);
public SoundRadio(playerid)
{
	StopAudioStreamForPlayer(playerid); // Stop the audio stream
	return 1;
}
//===============================================================
//================= Fim Do Sistema ==============================
//================ By FenixGaming ===============================
//============== Equipe Fenix Ajudando Seu Servidor Samp! =======
//===============================================================
