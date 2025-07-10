function out = checkTeamID(x,validTeamIDs,validTeamNames) 
 if any(x==validTeamIDs)
     out = true;
 else
     msg = ['Only %d Teams are known.\nTeam IDs are: [']; 
     for i=1:length(validTeamIDs)    
         msg = [msg num2str(validTeamIDs(i)) ' '];
     end
     msg = [msg '\b] \nTeam names are: ['];  
     for i=1:length(validTeamIDs)    
         msg = [msg validTeamNames{i} ' '];
     end      
     msg = [msg '\b] \n'];  
         
     error(msg,length(validTeamIDs));
 end
end