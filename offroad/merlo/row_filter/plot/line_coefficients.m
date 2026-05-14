figure('Name','Line Coefficients', 'NumberTitle','off');

t = tiledlayout(4,2,'TileSpacing','compact','Padding','compact');

% --- Grafici temporali ---
ax(f) = nexttile(1); f=f+1; hold on; grid on
if compare
    h1 = plot(bag1.lines.stamp, bag1.lines.coeff(:,:,1),"Color",colors.matlab{1}, 'DisplayName','Bag 1'); 
    h2 = plot(bag2.lines.stamp, bag2.lines.coeff(:,:,1),"Color",colors.matlab{2}, 'DisplayName','Bag 2'); 
    legend([h1(1),h2(1)]);
else
    plot(bag1.lines.stamp, bag1.lines.coeff(:,:,1));    
end
ylabel('x0'); 

ax(f) = nexttile(3); f=f+1; hold on; grid on
if compare
    h1 = plot(bag1.lines.stamp, bag1.lines.coeff(:,:,2),"Color",colors.matlab{1}, 'DisplayName','Bag 1'); 
    h2 = plot(bag2.lines.stamp, bag2.lines.coeff(:,:,2),"Color",colors.matlab{2}, 'DisplayName','Bag 2'); 
    legend([h1(1),h2(1)]);
else
    plot(bag1.lines.stamp, bag1.lines.coeff(:,:,2));    
end
ylabel('y0'); 

ax(f) = nexttile(5); f=f+1; hold on; grid on
if compare
    h1 = plot(bag1.lines.stamp, bag1.lines.coeff(:,:,4),"Color",colors.matlab{1}, 'DisplayName','Bag 1'); 
    h2 = plot(bag2.lines.stamp, bag2.lines.coeff(:,:,4),"Color",colors.matlab{2}, 'DisplayName','Bag 2'); 
    legend([h1(1),h2(1)]);
else
    plot(bag1.lines.stamp, bag1.lines.coeff(:,:,4));    
end
ylabel('dx'); 

ax(f) = nexttile(7); f=f+1; hold on; grid on
if compare
    h1 = plot(bag1.lines.stamp, bag1.lines.coeff(:,:,5),"Color",colors.matlab{1}, 'DisplayName','Bag 1'); 
    h2 = plot(bag2.lines.stamp, bag2.lines.coeff(:,:,5),"Color",colors.matlab{2}, 'DisplayName','Bag 2');
    legend([h1(1),h2(1)]);
else
    plot(bag1.lines.stamp, bag1.lines.coeff(:,:,5));    
end
ylabel('dy');
xlabel('Time [s]');

% --- Grafico 2D ---
axx(1) = nexttile([4,1]); hold on; grid on;
xlabel('x'); ylabel('y');
hp1 = quiver(0,0,0,0,0,'b','Color', colors.matlab{1},'LineWidth',1.5);
hp1_pts = plot(0,0,'o', 'Color', colors.matlab{1},'MarkerSize',6,'LineWidth',1.5);
assignin('base','hp1',hp1);
assignin('base','hp1_pts',hp1_pts);

if compare
    hp2 = quiver(0,0,0,0,0,'r','Color', colors.matlab{2},'LineWidth',1.5);
    hp2_pts = plot(0,0,'o', 'Color', colors.matlab{2},'MarkerSize',6,'LineWidth',1.5);
    assignin('base','hp2',hp2);
    assignin('base','hp2_pts',hp2_pts);
end

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

    bag1    = evalin('base', 'bag1');  
    hp1     = evalin('base', 'hp1');
    hp1_pts = evalin('base', 'hp1_pts');
    hSlider = evalin('base', 'hSlider');
    compare = evalin('base', 'compare');
    if compare
        bag2    = evalin('base', 'bag2');  
        hp2     = evalin('base', 'hp2');
        hp2_pts = evalin('base', 'hp2_pts');
    end

    % ---- Bag 1 ----
    x1  = squeeze(bag1.lines.coeff(idx,:,1));
    y1  = squeeze(bag1.lines.coeff(idx,:,2));
    dx1 = squeeze(bag1.lines.coeff(idx,:,4));
    dy1 = squeeze(bag1.lines.coeff(idx,:,5));

    set(hp1,     'XData',x1, 'YData',y1, 'UData',dx1, 'VData',dy1);
    set(hp1_pts, 'XData',x1, 'YData',y1);

    % ---- Bag 2 ----
    if compare
        x2  = squeeze(bag2.lines.coeff(idx,:,1));
        y2  = squeeze(bag2.lines.coeff(idx,:,2));
        dx2 = squeeze(bag2.lines.coeff(idx,:,4));
        dy2 = squeeze(bag2.lines.coeff(idx,:,5));

        set(hp2,     'XData',x2, 'YData',y2, 'UData',dx2, 'VData',dy2);
        set(hp2_pts, 'XData',x2, 'YData',y2);
    end

    set(hSlider,'Value',idx);
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


