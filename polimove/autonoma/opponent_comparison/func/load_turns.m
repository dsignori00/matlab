function idxs = load_turns(db)
    switch db
        case 'Suzuka'
            idxs = [1328,1653,2233,2443,2738,3123,3363,4575,4898,5549,5823,6375,7631,7912,9927,10802,10869,11093];
        case 'YasMarinaSim'
            idxs = [600,1090,1495,2000,2683,5102,5222,5610,7270,7990,8265,8525,8746,8969,9574,10020];
        case 'YasNorthSim'
            idxs = [600,1090,1495,2000,2683,5020,5375];
        otherwise
            idxs = [];
            disp('Turns not defined for this database');
    end
end