function track_bsplines = load_bsplines(file_names)

    N_tracks = length(file_names);

    track_bsplines = cell(N_tracks, 1);

    for i=1:N_tracks

        curr_track = load(file_names{i});

        track_bsplines{i} = curr_track;
        
    end

end

