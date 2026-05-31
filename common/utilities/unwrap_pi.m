function [out] = unwrap_pi(in)
%UNTITLED2 Unwrap angle between 180 and -180
   out = NaN(size(in));
   for i = 1:size(in, 1)
        for j = 1:size(in, 2)
            if ~isnan(in(i, j)) % Ignora i valori NaN
                while in(i, j)>180
                    in(i, j) = in(i, j)-360;
                end
                while in(i, j)<-180
                    in(i, j) = in(i, j)+360;
                end
                out(i, j) = in(i, j);
            end
        end
   end
end