function [x_cog,y_cog]= gps2_cog(x_raw,y_raw,psi_raw,dy,dx)

x_cog=x_raw+cos(psi_raw)*dx+sin(psi_raw)*dy;
y_cog=y_raw+sin(psi_raw)*dx-cos(psi_raw)*dy;