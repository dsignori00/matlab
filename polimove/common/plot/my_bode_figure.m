function [fig_handle,subp_handle] = my_bode_figure(latex_title,lag_enable,legend_enable)
    
    num_subp = 2 + lag_enable;
    
    fig_handle = figure;
    subp_handle(1) = subplot(num_subp,1,1); 
    title(latex_title,'Interpreter','latex')
    hold on, grid on, box on
    leg = legend;
    if legend_enable
        leg.Visible = 'on';
    else
        leg.Visible = 'off';
    end
    leg.Interpreter = 'latex';
    ylabel('Magnitude [dB]','Interpreter','latex'); xlabel('Frequency [Hz]','Interpreter','latex');
    set(subp_handle(1),'XScale','log','TickLabelInterpreter','latex','XLimSpec', 'Tight');
    subp_handle(2) = subplot(num_subp,1,2);
    hold on, grid on, box on
    set(subp_handle(2),'XScale','log','TickLabelInterpreter','latex','XLimSpec', 'Tight');
    ylabel('Phase [deg]','Interpreter','latex'); xlabel('Frequency [Hz]','Interpreter','latex');
    if lag_enable
        subp_handle(3) = subplot(num_subp,1,3);
        hold on, grid on, box on
        set(subp_handle(3),'XScale','log','TickLabelInterpreter','latex','XLimSpec', 'Tight');
        ylabel('Lag [ms]','Interpreter','latex'); xlabel('Frequency [Hz]','Interpreter','latex');
    end
    