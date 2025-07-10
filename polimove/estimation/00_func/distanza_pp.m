function d = distanza_pp(p1,p2)
%d = Distanza(p1,p2)
%Return the cartesian distance between two points
%Input: 
%       p1  =   [x,y] coordinates of first point
%       p2  =   [x,y] coordinates of second point
%Output: 
%       d   =   Distance
d = norm(p1-p2);
end

