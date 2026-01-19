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
legend;

% opponent count
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(tt.stamp, tt.count, 'Color',col.tt);
if(compare); plot(tt2.stamp, tt2.count, 'Color', col.tt2); end
grid on; ylabel('Opponent count');