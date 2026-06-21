function link_axes()
    if evalin('caller', "exist('axes','var')") && ~evalin('caller', "isempty(axes)")
        ax_handles = evalin('caller', 'axes');
        plot_axes = ax_handles(isgraphics(ax_handles,'axes'));
    
        if ~isempty(plot_axes)
            if evalin('caller', "exist('tt','var')") && evalin('caller', "isfield(tt,'stamp')")
                tt = evalin('caller', 'tt');
                shared_xlim = [min(tt.stamp, [], 'omitnan') max(tt.stamp, [], 'omitnan')];
                if all(isfinite(shared_xlim)) && shared_xlim(1) < shared_xlim(2)
                    set(plot_axes, 'XLim', shared_xlim);
                end
            end

            if evalin('caller', "exist('link_axes_mode','var')")
                link_axes_mode = evalin('caller', 'link_axes_mode');
            else
                link_axes_mode = 'all';
            end

            switch link_axes_mode
                case 'all'
                    linkaxes(plot_axes,'x');
    
                case 'figure'
                    fig_handles = arrayfun(@(ax) ancestor(ax,'figure'), plot_axes);
                    for fig = reshape(unique(fig_handles), 1, [])
                        fig_axes = plot_axes(fig_handles == fig);
                        if numel(fig_axes) > 1
                            linkaxes(fig_axes,'x');
                        end
                    end
    
                case 'none'
                    % Keep independent axes for fastest plotting.
    
                otherwise
                    warning('Unknown link_axes_mode "%s". Use "none", "figure", or "all".', link_axes_mode);
            end
        end
    end
end
