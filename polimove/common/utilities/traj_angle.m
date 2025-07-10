function ang = traj_angle(traj)
    for i = 1:length(traj)-1
        diff_x = traj(i+1,1) - traj(i,1);
        diff_y = traj(i+1,2) - traj(i,2);
        ang(i) = atan2(diff_y,diff_x);
    end
    ang(i) = atan2(diff_y,diff_x);
    
end