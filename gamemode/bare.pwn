#include <a_samp>
#include <core>
#include <float>
#include <sampvoice>

main() {}

new SV_GSTREAM:gstream;
new SV_LSTREAM:lstream[MAX_PLAYERS] = { SV_NULL, ... };

public OnGameModeInit()
{
	//SvDebug(SV_TRUE);
	gstream = SvCreateGStream(0xffff0000, "G"); // blue color
	return 1;
}

public OnPlayerConnect(playerid)
{
	if(!SvGetVersion(playerid))
	{
		SendClientMessage(playerid, -1, "Seu VOIP não foi encontrado");
	}
	else if(!SvHasMicro(playerid))
	{
		SendClientMessage(playerid, -1, "VOIP: Seu microfone não foi carregado");
	}
	else
	{
 		lstream[playerid] = SvCreateDLStreamAtPlayer(40.0, SV_INFINITY, playerid, 0xff0000ff, "L");
  		SendClientMessage(playerid, -1, "Seu VOIP foi carregado com sucesso!");
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

public SV_VOID:OnPlayerActivationKeyRelease(SV_UINT:playerid,SV_UINT:keyid)
{
	if(keyid == 0x5A && lstream[playerid])
	{
		SvDetachSpeakerFromStream(lstream[playerid], playerid);
	}
	if(keyid == 0x42 && gstream)
	{
	    if(IsPlayerAdmin(playerid))
	    {
			SvDetachSpeakerFromStream(gstream, playerid);
		}
	}
}
