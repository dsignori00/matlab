%% INFO
figure('Name','Info');

if(isfield(log,'planner_manager'))
    % racetype
    tiledlayout(3,1,'Padding','compact');
    axes(f) = nexttile([1,1]); f=f+1; hold on;
    plot(log.planner_manager.stamp__tot, log.planner_manager.race_type,'Color',col.tt);
    ylim([-1 5]); grid on; ylabel('RaceType');
else 
    tiledlayout(2,1,'Padding','compact');
end

% decision maker
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(log.decision_maker.stamp__tot, log.decision_maker.current_state__type, 'Color',col.tt, 'HandleVisibility','off');
yticks(0:4);
ylim([-1 5]); grid on; ylabel('Decision Maker state');
labels = {'0 - RACING','1 - TAILGATING','2 - OVERTAKE','3 - ABORT','4 - CRITICAL'};
for i = 1:numel(labels)
    plot(nan, nan, 'DisplayName', labels{i}, 'Color', 'none');
end

% opponent count
axes(f) = nexttile([1,1]); f=f+1; hold on;
plotTT(tt.stamp, tt.count, 1, col.tt, 'tt');
if(compare); plotTT(tt2.stamp, tt2.count, 1, col.tt2, name2); end
grid on; ylabel('Opponent count'); xlabel('timestamp [s]'); legend show;