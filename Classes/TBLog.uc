class TBLog extends StatLogFile;

var string LogPrefix;
var string LogPath;
var string PlayerName;

function StartLog()
{
    local string FileName;
    local string str, str2;
	Local string MapName;
    local int i;

    str = Level.Game.GameReplicationInfo.ServerName;
	
	MapName = GetMapFileName();

    str2 = "";
    for (i = 0; i<Len(Str); i++)
        if (InStr("\\/*?:<>\"|", Mid(str, i, 1)) != -1)
            str2 = str2 $ "_";
        else
            str2 = str2 $ Mid(str, i, 1);

    FileName = LogPath$LogPrefix$" - "$str2$"."$GetShortAbsoluteTime() $ "_" $ MapName $ "_" $ PlayerName;
    StatLogFile = FileName$".tmp";
    StatLogFinal = FileName$".log";

    SetEncoding();
    OpenLog();
}

function SetEncoding() {
    local int EngineVersion;
    local string EngineRevision;

    EngineVersion = int(Level.EngineVersion);
    if (EngineVersion >= 469) {
        EngineRevision = Level.GetPropertyText("EngineRevision");
        EngineRevision = Left(EngineRevision, InStr(EngineRevision, " "));

        if (Len(EngineRevision) > 0 && EngineRevision != "a" && EngineRevision != "b") {
            SetPropertyText("Encoding", "FILE_ENCODING_UTF8_BOM");
        }
    }
}

function Timer() {}

defaultproperties
{
	StatLogFile="./TweakBlocker.log"
}