figure('Name','Line Coefficients');

t = tiledlayout(4,2,'TileSpacing','compact','Padding','compact');

% --- Grafici temporali ---
ax(f) = nexttile(1); f=f+1; hold on; grid on
plot(bag1.lines.stamp, bag1.lines.coeff(:,:,1)); ylabel('x0');

ax(f) = nexttile(3); f=f+1; hold on; grid on
plot(bag1.lines.stamp, bag1.lines.coeff(:,:,2)); ylabel('y0');

ax(f) = nexttile(5); f=f+1; hold on; grid on
plot(bag1.lines.stamp, bag1.lines.coeff(:,:,4)); ylabel('dx');

ax(f) = nexttile(7); f=f+1; hold on; grid on
plot(bag1.lines.stamp, bag1.lines.coeff(:,:,5)); ylabel('dy'); xlabel('timestamp [s]');

% --- Grafico 2D ---
axx(1) = nexttile([4,1]); hold on; grid on;
xlabel('x'); ylabel('y');
hp = quiver(0,0,0,0,0,'b','LineWidth',1.5);
hp_pts = plot(0,0,'ro','MarkerSize',6,'LineWidth',1.5);

% Store handles in base workspace so evalin can access them
assignin('base', 'hp', hp);
assignin('base', 'hp_pts', hp_pts);

% --- Slider sotto il grafico 2D ---
axis equal;
xlim(axx(1),[-5 5]);
ylim(axx(1),[-5 5]);
ax_pos = axx(1).Position;
slider_height = 0.04;
slider_spacing = 0.15;
slider_left = 0.032;

hSlider = uicontrol('Parent', gcf, 'Style', 'slider', ...
    'Min',1,'Max',length(bag1.lines.stamp),'Value',1, ...
    'SliderStep',[1/(length(bag1.lines.stamp)-1),0.1], ...
    'Units','normalized', ...
    'Position',[ax_pos(1)-slider_left, ax_pos(2)-slider_height-slider_spacing, ax_pos(3), slider_height], ...
    'Callback', @(src,~) update_2D(round(src.Value)));

assignin('base', 'hSlider', hSlider);  % store slider handle too
hXline = xline(0,'--','HandleVisibility','off');  
hYline = yline(0,'--','HandleVisibility','off'); 

% --- Funzione annidata per aggiornare il grafico 2D ---
function update_2D(idx)
    bag1 = evalin('base', 'bag1');  
    hp = evalin('base', 'hp');
    hp_pts = evalin('base', 'hp_pts');
    hSlider = evalin('base', 'hSlider');
    
    x0 = squeeze(bag1.lines.coeff(idx,:,1));
    y0 = squeeze(bag1.lines.coeff(idx,:,2));
    dx = squeeze(bag1.lines.coeff(idx,:,4));
    dy = squeeze(bag1.lines.coeff(idx,:,5));
    
    set(hp, 'XData', x0, 'YData', y0, 'UData', dx, 'VData', dy);
    set(hp_pts, 'XData', x0, 'YData', y0);
    set(hSlider, 'Value', idx);
    drawnow;
end

% --- Funzione annidata per sincronizzare al centro degli assi ---
function sync_2D_to_center(~, ~)
    ax = evalin('base', 'ax');  
    bag1 = evalin('base', 'bag1');  
    
    xlim_center = mean(ax(1).XLim);
    [~, idx] = min(abs(bag1.lines.stamp - xlim_center));
    update_2D(idx);
end

addlistener(ax(1), 'XLim', 'PostSet', @sync_2D_to_center);
update_2D(1);


