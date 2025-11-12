function [angle_in] =  unwrap_angle_smart(angle_in,angle_ref)
diff = angle_ref - angle_in;

while diff > pi
	angle_in = angle_in + 2*pi;
	diff = angle_ref - angle_in;
end

while diff < -pi
	angle_in =angle_in - 2*pi;
	diff = angle_ref - angle_in;
end

end