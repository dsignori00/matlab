function root_path = get_indy_path()

mydir = pwd;
idcs = strfind(mydir,"indy_autonomous_challenge");
root_path = mydir(1:idcs(end)-1) + "indy_autonomous_challenge/";
end

