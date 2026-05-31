function y = lowpass_filter(signal, fs, fc)
% LOWPASS_FILTER Applica un filtro passa basso e mostra la FFT del segnale originale
%
%   y = lowpass_filter(signal, fs, fc)
%       signal : segnale di ingresso (vetto colonna o riga)
%       fs     : frequenza di campionamento [Hz]
%       fc     : frequenza di taglio del filtro [Hz]
%       y      : segnale filtrato

    %% FFT del segnale originale
    N = length(signal);
    f = (0:N-1)*(fs/N);  % asse delle frequenze
    SIGNAL = fft(signal);

    figure;
    subplot(2,1,1);
    plot(f, abs(SIGNAL));
    xlim([0 fs/2]); % Mostra fino a Nyquist
    xlabel('Frequenza [Hz]');
    ylabel('|X(f)|');
    title('FFT del segnale originale');

    %% Progettazione filtro passa basso (Butterworth)
    order = 4;  % ordine del filtro
    Wn = fc/(fs/2);  % frequenza normalizzata
    [b,a] = butter(order, Wn, 'low');

    %% Applicazione del filtro
    y = filtfilt(b, a, signal);  % filtra in avanti e indietro per evitare ritardo di fase

    %% Mostra segnale filtrato
    subplot(2,1,2);
    plot((0:N-1)/fs, y);
    xlabel('Tempo [s]');
    ylabel('Ampiezza');
    title(['Segnale filtrato passa basso fc = ' num2str(fc) ' Hz']);
end
