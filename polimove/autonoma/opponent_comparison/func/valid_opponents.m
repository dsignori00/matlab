function v2v = valid_opponents(v2v)
    v2v.x(:,v2v.max_opp+1:end)=[];
    v2v.y(:,v2v.max_opp+1:end)=[];
    v2v.vx(:,v2v.max_opp+1:end)=[];
    v2v.yaw(:,v2v.max_opp+1:end)=[];
end