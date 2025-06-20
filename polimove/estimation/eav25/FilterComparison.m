% Parameters
N = 1024; % Number of frequency points
fs = 800; % Sampling frequency in Hz
f = linspace(0.1, fs, N); % Frequency axis from 0.1 to 200 Hz to avoid log of zero
M_values = [1, 2, 3, 4, 5, 8]; % Window sizes for the moving average filter

% Plot settings
plot_in_db = true; % Set to true for dB scale, false for linear magnitude
log_scale = true; % Set to true for logarithmic x-axis, false for linear x-axis

% Create the figure
figure;
hold on;
fc = 10; % Correct cutoff frequency at 10 Hz
H_pole = 1 ./ sqrt(1 + (f / fc).^2); % Frequency response of the single-pole filter
% Compute and plot the frequency response for each M (moving average filter)
for M = M_values
    % Frequency response of the moving average filter
    H = (sin(pi * M * f / fs) ./ (M * sin(pi * f / fs)));
    H(f == 0) = 1; % Handle the case when f = 0

    % Convert to dB if required
    if plot_in_db
        H_plot = 20 * log10(abs(H));
    else
        H_plot = abs(H);
    end

    % Plot the magnitude response
    plot(f, H_plot, 'DisplayName', ['MAF (window=', num2str(M), ')']);
end

% Frequency response of the single-pole low-pass filter with fc = 10 Hz
fc = 10; % Correct cutoff frequency at 10 Hz
H_pole = 1 ./ sqrt(1 + (f / fc).^2); % Frequency response of the single-pole filter

% Convert to dB if required
if plot_in_db
    H_pole_plot = 20 * log10(abs(H_pole));
else
    H_pole_plot = abs(H_pole);
end

% Plot the single-pole filter response
plot(f, H_pole_plot, 'k--', 'LineWidth', 1.5, 'DisplayName', 'LPF (1 pole, 10 Hz)');

% Set axis to log scale if required
if log_scale
    set(gca, 'XScale', 'log'); % Set x-axis to logarithmic scale
end

% Plot labels and title
xlabel('Frequency (Hz)');
if plot_in_db
    ylabel('Magnitude |H(f)| in dB');
else
    ylabel('Magnitude |H(f)|');
end
title('Frequency Response of Moving Average Filters and Single-Pole Filter');
legend show; % Show legend with M values and single-pole filter
grid on;
hold off;
