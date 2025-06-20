figure;hold on;
scatter(log.vectornav__raw__common.magpres_mag__x,log.vectornav__raw__common.magpres_mag__y,10,log.vectornav__raw__common.bag_stamp,'filled');
scatter(log.vectornav__raw__common.magpres_mag__y,log.vectornav__raw__common.magpres_mag__z,10,log.vectornav__raw__common.bag_stamp,'filled');
scatter(log.vectornav__raw__common.magpres_mag__z,log.vectornav__raw__common.magpres_mag__x,10,log.vectornav__raw__common.bag_stamp,'filled');
axis equal
grid on
legend show


%%
figure;hold on;axis equal;grid on;
% scatter(log.vectornav__raw__common.magpres_mag__x+0.45,1.1*log.vectornav__raw__common.magpres_mag__y-0.05,10,'filled','r');
scatter(log.vectornav__raw__common.magpres_mag__x+0.13,1.1*log.vectornav__raw__common.magpres_mag__y+0.03,10,'filled','r');
xlim([-0.6 0.6])
ylim([-0.5 0.5])

%%
figure;
hold on; grid on;
plot(log.estimation.bag_stamp,wrapTo180(log.estimation.heading*180/pi));
plot(log.vectornav__raw__common.bag_stamp,atan2((1.1*log.vectornav__raw__common.magpres_mag__y+0.03),log.vectornav__raw__common.magpres_mag__x+0.13)*180/pi+90);
