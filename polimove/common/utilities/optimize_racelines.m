function [raceline_bsplines, raceline_clothoids] = optimize_racelines(track_bsplines, AX_MAX, AY_MAX)

    N_tracks = length(track_bsplines);

    raceline_bsplines = cell(N_tracks, 1);
    raceline_clothoids = cell(N_tracks, 1);

    for i=1:N_tracks
        raceline_bsplines{i} = optimize_raceline(track_bsplines{i}, AX_MAX, AY_MAX);
        raceline_clothoids{i} = optimize_raceline_clothoid(track_bsplines{i}, AX_MAX, AY_MAX);
    end

end

