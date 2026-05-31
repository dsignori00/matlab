function [i1, i2] = timeWindowIdx(t, tlim)
% Returns indices of t within tlim = [tmin tmax]
    i1 = find(t > tlim(1), 1, 'first');
    i2 = find(t < tlim(2), 1, 'last');
end
