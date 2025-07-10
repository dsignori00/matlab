function id = IACTeamID(team)
%IACTEAMID Provides easy access to IAC official teams IDs.
%   id = IACTEAMID(team) When 'team' contains a substring which 
%   is recognizable as one of Team Names it returns the correct Team ID 
%   as contained in the list (see IACTeamStruct for a list of the known 
%   Teams).
%
% Author:   Filippo Parravicini
% Version:  v1.0
% Date:     29/04/2021

    teamStruct = IACTeamStruct();

    p = inputParser;

    validTeamNames = {teamStruct.Name};
    isValidTeamName = @(x) (isa(x,'string')||isa(x,'char')) && any(validatestring(x,validTeamNames));

    addRequired(p,'team', isValidTeamName);

    parse(p,team)


    idx = strcmp(validTeamNames,validatestring(team,validTeamNames));
    idx = find(idx);

    id = teamStruct(idx).ID;
end