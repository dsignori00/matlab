function [x,y] = calculate_ellipse(std_x,std_y, mu_x, mu_y)

a = std_x;
b = std_y;

x1 = [linspace(-a,a,1000)];
x2 = [linspace(a,-a,1000)];

y  = [b*sqrt(1-x1.^2/a^2), -b*sqrt(1-x2.^2/a^2)];

x = [x1,x2];

x = x + mu_x;
y = y + mu_y;


end