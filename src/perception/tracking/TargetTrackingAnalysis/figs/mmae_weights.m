%% MMAE WEIGHTS
figure('Name', 'MMAE Weights', 'NumberTitle', 'off');
tiledlayout(4,1,'Padding','compact');

Q_labels = {'Q(1)', 'Q(6)', 'Q(35)', 'Q(200)'};

ds = 10; % downsample factor

for w = 1:4
    axes(f) = nexttile([1,1]); f=f+1; hold on; %#ok<SAGROW>
    if isfield(tt,  'mmae_weights'); plot_tt(tt.stamp(1:ds:end),  tt.mmae_weights(1:ds:end,:,w),  tt.max_opp,  col.tt,  name1); end
    if compare  && isfield(tt2, 'mmae_weights'); plot_tt(tt2.stamp(1:ds:end), tt2.mmae_weights(1:ds:end,:,w), tt2.max_opp, col.tt2, name2); end
    if compare2 && isfield(tt3, 'mmae_weights'); plot_tt(tt3.stamp(1:ds:end), tt3.mmae_weights(1:ds:end,:,w), tt3.max_opp, col.tt3, name3); end
    grid on; ylabel(Q_labels{w}); ylim([0 1]); legend show;
end
xlabel('timestamp [s]');