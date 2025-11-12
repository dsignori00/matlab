function [C, S] = fresnel_numeric(t)
    % Numerically compute Fresnel integrals for each t in vector
    C = arrayfun(@(x) integral(@(s) cos(pi/2 * s.^2), 0, x), t);
    S = arrayfun(@(x) integral(@(s) sin(pi/2 * s.^2), 0, x), t);
end

