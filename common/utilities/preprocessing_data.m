function d_out=preprocessing_data(data,Ts,low_pass_freq,track_flag)

d_out=data;



%% GPS

switch track_flag
    
    case 1  %LOR
        origin_lat =  39.81252192341712259349151281639933586120605468750000 ;
        origin_lon =  -86.34174318432118866439850535243749618530273437500000 ;
        origin_hgt= 0;
    case 2 %AIR STRIP
        origin_lat =  39.351219;
        origin_lon =  -85.258452;
        origin_hgt= 0;
    case 3 % IMS
        origin_lon= -86.238875;
        origin_lat= 39.79921873;
        origin_hgt= 0;
    case 4 % LVMS
        origin_lon = -115.010258;
        origin_lat = 36.2722818;
        origin_hgt = 594.6250982;
    case 5 %YUCCA
        origin_lon = -114.128951;
        origin_lat = 34.862904;
        origin_hgt = 0.0;
    case 6 %KSC
        origin_lon = -80.6830;
        origin_lat = 28.5975;
        origin_hgt =  2.37;
    case 7 % AMS
        origin_lat = 33.385;
        origin_lon = -84.317;
        origin_hgt =  254.3;
    case 8 % TMS
        origin_lat = 33.037;
        origin_lon = -97.283;
        origin_hgt =  192.5;
    case 9
        origin_lat = 45.618974079378670;
        origin_lon = 9.281181751068655;
        origin_hgt = 182.9000;
end

[d_out.x_bot,d_out.y_bot,d_out.z_bot] = geodetic2enu(data.lat_gnss_bot,data.lon_gnss_bot,data.hgt_gnss_bot,origin_lat,origin_lon,origin_hgt,wgs84Ellipsoid);
[d_out.x_top,d_out.y_top,d_out.z_top] = geodetic2enu(data.lat_gnss_top,data.lon_gnss_top,data.hgt_gnss_top,origin_lat,origin_lon,origin_hgt,wgs84Ellipsoid);


%% cog translation

dx_bot=0;
dy_bot=0.5;

dx_top=-1.2;
dy_top=0;

[d_out.x_bot,d_out.y_bot]= gps_2_cog(d_out.x_bot,d_out.y_bot,d_out.psi_hat,dy_bot,dx_bot);
[d_out.x_top,d_out.y_top]= gps_2_cog(d_out.x_top,d_out.y_top,d_out.psi_hat,dy_top,dx_top);


 d_out.e_est_long_post = (d_out.x_bot - d_out.x_hat); %.*cos(d_out.psi_hat) + (d_out.y_bot - d_out.y_hat).*sin(d_out.psi_hat);
 d_out.e_est_lat_post = (d_out.y_bot - d_out.y_hat); %.*cos(d_out.psi_hat) + (d_out.x_bot - d_out.x_hat).*sin(d_out.psi_hat); 
 d_out.e_est_post= sqrt(d_out.e_est_long_post.^2+ d_out.e_est_lat_post.^2);

%  s=tf('s');
% hp_freq=0.1;
% hp_tc = 1/(2*pi*hp_freq)^2*s^2/(s/2/pi/hp_freq + 1)^2;
% hp_td = c2d(hp_tc,Ts,'Tustin');
% hp_num = hp_td.Numerator{1};
% hp_den = hp_td.Denominator{1};
% 
% d_out.e_est_post_filt=filter(hp_num,hp_den,d_out.e_est_post);

%% Track idx

d_out.track_idx=d_out.track_idx(:,1);


%% Filtering


%d_out=lowpass_filter_struct(d_out,low_pass_freq,Ts);

end
