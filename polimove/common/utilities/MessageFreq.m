function freq = messageFreq(sens_stamp)
    % Supponiamo che sens_stamp sia un vettore colonna
    % Assicurati che sia un vettore colonna
    sens_stamp = sens_stamp(:);
    
    N = length(sens_stamp);
    freq = NaN(N, 1);
    dt = diff(sens_stamp);
    
    % Per ogni misura a partire dalla sesta, calcola la frequenza media
    for i = 6:N
        last_5_dt = dt(i-5:i-1); 
        avg_dt = mean(last_5_dt);  % media dei 5 intervalli
        freq(i) = 1 / avg_dt;  % frequenza media
    end
end