function [x, y] = covariance_ellipse(Sigma, mu, k, nPoints)
% COVARIANCE_ELLIPSE  Ellisse k-sigma da matrice di covarianza 2x2
%
%   Sigma   : matrice di covarianza 2x2
%   mu      : centro [mu_x; mu_y] oppure [mu_x mu_y]
%   k       : fattore sigma (es. 1, 2, 3)
%   nPoints : numero di punti (default 200)
%
%   x, y    : coordinate dell'ellisse (vettori riga)

    if nargin < 4
        nPoints = 200;
    end
    if nargin < 3 || isempty(k)
        k = 1;
    end

    % Controlli di validità
    if ~isequal(size(Sigma), [2 2]) || any(~isfinite(Sigma(:)))
        x = NaN; y = NaN; return;
    end

    if numel(mu) ~= 2 || any(~isfinite(mu))
        x = NaN; y = NaN; return;
    end
    mu = mu(:);  % colonna

    % Decomposizione agli autovalori
    Sigma = (Sigma + Sigma')/2;
    [V, D] = eig(Sigma);
    D(D < 0) = 0;

    % Autovalori (varianze principali)
    lambda = diag(D);

    if any(lambda <= 0)
        x = NaN; y = NaN; return;
    end

    % Semiassi dell'ellisse (k-sigma)
    a = k * sqrt(lambda(1));
    b = k * sqrt(lambda(2));

    % Parametrizzazione cerchio unitario
    t = linspace(0, 2*pi, nPoints);
    circle = [a*cos(t); b*sin(t)];

    % Rotazione + traslazione
    ellipse = V * circle + mu;

    x = ellipse(1,:);
    y = ellipse(2,:);
end

