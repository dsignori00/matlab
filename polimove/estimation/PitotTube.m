v_air=sqrt((log.vehicle_fbk_eva__pitot_abs_press-log.vehicle_fbk_eva__pitot_front_press)*100*2/1.225);

v_air=sqrt(abs(log.vehicle_fbk_eva__pitot_front_press)*100*2/1.225);
figure;
plot(log.vehicle_fbk_eva__bag_timestamp,v_air);
hold on;
plot(log.estimation__bag_timestamp,log.estimation__vx)