namespace Ghosts_Chailfield {
    import void Call_Ghosts_SetStartTime(CSmArenaRulesMode@ ps, uint startTime) from "Ghosts_Chailfield";
    import array<CGameCtnGhost@>@ GetCurrentGhosts(CGameCtnApp@ app) from "Ghosts_Chailfield";
    import bool IsSpectatingGhost() from "Ghosts_Chailfield";
    import uint GetSpectatingGhostInstanceId(CGameCtnApp@ app) from "Ghosts_Chailfield";
    import NGameGhostClips_SClipPlayerGhost@ GetGhostFromInstanceId(CGameCtnApp@ app, uint instanceId) from "Ghosts_Chailfield";
    import uint GetGhostVisEntityId(NGameGhostClips_SClipPlayerGhost@ g) from "Ghosts_Chailfield";
    import NGameGhostClips_SMgr@ GetGhostClipsMgr(CGameCtnApp@ app) from "Ghosts_Chailfield";
    // PB ghost that respawns at CPs with you; returns -1 if null issue or not found
    import int GetLaunchedCpGhostIx(NGameGhostClips_SMgr@ mgr) from "Ghosts_Chailfield";
    // PB ghost that respawns at CPs with you; returns -1 if null issue or not found
    import int GetLaunchedCpGhostInstanceId(NGameGhostClips_SMgr@ mgr) from "Ghosts_Chailfield";
    // PB ghost that respawns at CPs with you
    import NGameGhostClips_SClipPlayerGhost@ GetLaunchedCpGhost(NGameGhostClips_SMgr@ mgr) from "Ghosts_Chailfield";
}

import float CSmArenaRules_GetGhostAlpha(CSmArenaRules@ arenaRules) from "Ghosts_Chailfield";
import void CSmArenaRules_SetGhostAlpha(CSmArenaRules@ arenaRules, float maxGhostAlpha) from "Ghosts_Chailfield";

namespace Ghosts_Chailfield {
    import IInputChange@[]@ GetGhostInputData(CGameCtnGhost@ ghost) from "Ghosts_Chailfield";
    // import IGhostSample@[]@ GetGhostSampleData(CGameCtnGhost@ ghost) from "Ghosts_Chailfield";

    import CheckpointIxTime@[]@ GetGhostCheckpoints(CGameCtnGhost@ ghost) from "Ghosts_Chailfield";
}
