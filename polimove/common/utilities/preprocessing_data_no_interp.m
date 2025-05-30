function d_out=preprocessing_data_no_interp(data,Ts,low_pass_freq, track_flag)

d_out=data;

%% local interpolation

psi_bot_interp = interp1(data.psi_bot(:,1),data.psi_bot(:,2),data.lat_gnss_bot(:,1));
psi_top_interp = interp1(data.psi_top(:,1),data.psi_top(:,2),data.lat_gnss_top(:,1));

psi_hat_interp_bot = interp1(data.psi_hat(:,1),data.psi_hat(:,2),data.lat_gnss_bot(:,1),'previous');
psi_hat_interp_top = interp1(data.psi_hat(:,1),data.psi_hat(:,2),data.lat_gnss_top(:,1),'previous');

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
end

d_out.x_top = zeros(size(data.lat_gnss_top));
d_out.y_top = zeros(size(data.lat_gnss_top));
d_out.z_top = zeros(size(data.lat_gnss_top));
d_out.x_bot = zeros(size(data.lat_gnss_bot));
d_out.y_bot = zeros(size(data.lat_gnss_bot));
d_out.z_bot = zeros(size(data.lat_gnss_bot));

d_out.x_top(:,1) = data.lat_gnss_top(:,1);
d_out.y_top(:,1) = data.lat_gnss_top(:,1);
d_out.z_top(:,1) = data.lat_gnss_top(:,1);
d_out.x_bot(:,1) = data.lat_gnss_bot(:,1);
d_out.y_bot(:,1) = data.lat_gnss_bot(:,1);
d_out.z_bot(:,1) = data.lat_gnss_bot(:,1);

[d_out.x_bot(:,2),d_out.y_bot(:,2),d_out.z_bot(:,2)] = geodetic2enu(data.lat_gnss_bot(:,2),data.lon_gnss_bot(:,2),data.hgt_gnss_bot(:,2),origin_lat,origin_lon,origin_hgt,wgs84Ellipsoid);
[d_out.x_top(:,2),d_out.y_top(:,2),d_out.z_top(:,2)] = geodetic2enu(data.lat_gnss_top(:,2),data.lon_gnss_top(:,2),data.hgt_gnss_top(:,2),origin_lat,origin_lon,origin_hgt,wgs84Ellipsoid);


%% cog translation 

dx_bot=0; 
dy_bot=0.5;

dx_top=-1.2; 
dy_top=0;

[d_out.x_bot(:,2),d_out.y_bot(:,2)]= gps_2_cog(d_out.x_bot(:,2),d_out.y_bot(:,2),psi_hat_interp_bot,dy_bot,dx_bot);
[d_out.x_top(:,2),d_out.y_top(:,2)]= gps_2_cog(d_out.x_top(:,2),d_out.y_top(:,2),psi_hat_interp_top,dy_top,dx_top);


%% course angle

d_out.course_offline_top(:,1) = d_out.x_top(:,1);
d_out.course_offline_top(:,2) = [0; atan2(diff(d_out.y_top(:,2)),diff(d_out.x_top(:,2)))];
d_out.course_offline_bot(:,1) = d_out.x_bot(:,1);
d_out.course_offline_bot(:,2) = [0; atan2(diff(d_out.y_bot(:,2)),diff(d_out.x_bot(:,2)))];


%% vy_fbk offline - exact replica of online algorithm

t_bot_interp_est = interp1(d_out.x_bot(:,1),d_out.x_bot(:,1),data.x_hat(:,1),'previous');
x_bot_interp_est = interp1(d_out.x_bot(:,1),d_out.x_bot(:,2),data.x_hat(:,1),'previous');
y_bot_interp_est = interp1(d_out.y_bot(:,1),d_out.y_bot(:,2),data.x_hat(:,1),'previous');

d_out.vy_offline_bot(:,1) = data.x_hat(:,1);
d_out.vy_offline_bot(:,2) = nan(size(data.x_hat(:,1)));

d_out.beta_offline_bot(:,1) = data.x_hat(:,1);
d_out.beta_offline_bot(:,2) = nan(size(data.x_hat(:,1)));

ts = 0.01;
for i = 2:length(data.x_hat(:,1))
    if (data.x_hat(i,1) - t_bot_interp_est(i) < ts)
       delta_t = t_bot_interp_est(i) - t_bot_interp_est(i-1);
       delta_x = x_bot_interp_est(i) - x_bot_interp_est(i-1);
       delta_y = y_bot_interp_est(i) - y_bot_interp_est(i-1);
       
       d_out.vy_offline_bot(i,2) = -delta_x/delta_t*sin(data.psi_hat(i,2)) + delta_y/delta_t*cos(data.psi_hat(i,2));
    else
        d_out.vy_offline_bot(i,2) = d_out.vy_offline_bot(i-1,2);
    end
    
end

d_out.beta_offline_bot(:,2) = atan2(d_out.vy_offline_bot(:,2), data.vx_hat(:,2));

%% vy_fbk - novatel headers


GPS_SEC_IN_WEEK = 7 * 24 * 60 * 60;
UNIX_TO_GPS_OFFSET = 315964800;
gps_to_utc_offset = -18;
device_offset = 0;

d_out.timestamp_bot(:,1) = data.stamp_week_nr_bot(:,1);
d_out.timestamp_top(:,1) = data.stamp_week_nr_top(:,1);
d_out.timestamp_bot(:,2) = data.stamp_week_nr_bot(:,2) * GPS_SEC_IN_WEEK + data.stamp_week_ms_bot(:,2) * 1e-3...
    - device_offset + gps_to_utc_offset + UNIX_TO_GPS_OFFSET;
d_out.timestamp_top(:,2) = data.stamp_week_nr_top(:,2) * GPS_SEC_IN_WEEK + data.stamp_week_ms_top(:,2) * 1e-3...
    - device_offset + gps_to_utc_offset + UNIX_TO_GPS_OFFSET;


delta_t = [0; diff(d_out.timestamp_bot(:,2))];
delta_x = [0; diff(d_out.x_bot(:,2))];
delta_y = [0; diff(d_out.y_bot(:,2))];

d_out.vy_offline_ts_bot(:,1) = d_out.x_bot(:,1);
d_out.vy_offline_ts_bot(:,2) = -delta_x./delta_t.*sin(psi_hat_interp_bot) + delta_y./delta_t.*cos(psi_hat_interp_bot);
%      

%% Filtering


%d_out=lowpass_filter_struct(d_out,low_pass_freq,Ts);

end
