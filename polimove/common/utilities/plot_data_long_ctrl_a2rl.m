

%% Space

% plot long controller in space
h                   = figure('numbertitle', 'off');
h.Name              = "LONG Bag " + i + ": " + "Long. control - Space";
tcl                 = tiledlayout(2,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';
ax_space(end+1)=nexttile(1);
hold on
ylabel('vx[kph]')
scatter3(data.closest_idx_ref*0.5,data.long_vel_ref*3.6,data.time,[],fillmissing(data.closest_idx_ref, "nearest"),'.')
ax_space(end+1)=nexttile(2);
hold on
ylabel('vx[kph]')
scatter3(data.closest_idx_ref*0.5,data.vx_hat*3.6,data.time,[],fillmissing(data.closest_idx_ref, "nearest"),'.')
xlabel('Space [m]')

