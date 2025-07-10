function name = IACTeamName(team)
%IACTEAMNAME Provides easy access to IAC official teams Names.
%   name = IACTEAMNAME(team) returns a string with a valid Team Name to 
%   be used in plots labels etc. When 'team' contains a substring which 
%   is recognizable as one of Team Names it returns the correct Team Name 
%   as contained in the list. If 'team' is a valid Team ID  it returns the 
%   associated Team name as contained in the list (see IACTeamStruct for a 
%   list of the known Teams).
%
% Author:   Filippo Parravicini
% Version:  v1.0
% Date:     29/04/2021

    teamStruct = IACTeamStruct();

    p = inputParser;

    validTeamNames = {teamStruct.Name};
    validTeamIDs = [teamStruct.ID];
    isValidTeamName = @(x) (isa(x,'string')||isa(x,'char')) && any(validatestring(x,validTeamNames));
    isValidTeamID = @(x) isa(x,'numeric') && checkTeamID(x,validTeamIDs,validTeamNames);
    isValidTeam = @(x) isValidTeamName(x) || isValidTeamID(x);

    addRequired(p,'team', isValidTeam);

    parse(p,team)

    if isa(team,'numeric')
        idx = find(team==validTeamIDs);
    else
        idx = strcmp(validTeamNames,validatestring(team,validTeamNames));
        idx = find(idx);
    end

    name = teamStruct(idx).Name;
end