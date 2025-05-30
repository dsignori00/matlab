

vn_ax_now=timeseries(loga.vectornav__raw__common.imu_accel__x,loga.vectornav__raw__common.header__stamp__tot);
vn_ay_now=timeseries(loga.vectornav__raw__common.imu_accel__y,loga.vectornav__raw__common.header__stamp__tot);
vn_az_now=timeseries(loga.vectornav__raw__common.imu_accel__z,loga.vectornav__raw__common.header__stamp__tot);
vn_now=timeseries(sqrt(loga.vectornav__raw__common.imu_accel__x.^2+loga.vectornav__raw__common.imu_accel__y.^2+loga.vectornav__raw__common.imu_accel__z.^2),loga.vectornav__raw__common.header__stamp__tot);
g1_now=timeseries(sqrt(loga.g1pro__imu0.ax.^2+loga.g1pro__imu0.ay.^2+loga.g1pro__imu0.az.^2),loga.g1pro__imu0.header__stamp__tot);
[tex_t,ia,ic] = unique(loga.texense__imu.a_stamp__tot);
tex_ax = loga.texense__imu.a(ia,2)*9.81/1000;
tex_ay = -loga.texense__imu.a(ia,1)*9.81/1000;
tex_az = loga.texense__imu.a(ia,3)*9.81/1000;
tex_now=timeseries(sqrt(tex_ax.^2 + tex_ay.^2 + tex_az.^2),tex_t);

vn_ax_now2=timeseries(logb.vectornav__raw__common.imu_accel__x,logb.vectornav__raw__common.header__stamp__tot);
vn_ay_now2=timeseries(logb.vectornav__raw__common.imu_accel__y,logb.vectornav__raw__common.header__stamp__tot);
vn_az_now2=timeseries(logb.vectornav__raw__common.imu_accel__z,logb.vectornav__raw__common.header__stamp__tot);
vn_now2=timeseries(sqrt(logb.vectornav__raw__common.imu_accel__x.^2+logb.vectornav__raw__common.imu_accel__y.^2+logb.vectornav__raw__common.imu_accel__z.^2),logb.vectornav__raw__common.header__stamp__tot);
g1_now2=timeseries(sqrt(logb.g1pro__imu0.ax.^2+logb.g1pro__imu0.ay.^2+logb.g1pro__imu0.az.^2),logb.g1pro__imu0.header__stamp__tot);
[tex_t,ia,ic] = unique(logb.texense__imu.a_stamp__tot);
tex_ax = logb.texense__imu.a(ia,2)*9.81/1000;
tex_ay = -logb.texense__imu.a(ia,1)*9.81/1000;
tex_az = logb.texense__imu.a(ia,3)*9.81/1000;
tex_now2=timeseries(sqrt(tex_ax.^2 + tex_ay.^2 + tex_az.^2),tex_t);

vn_ax_old=timeseries(log.vectornav__raw__common__imu_accel__x,log.vectornav__raw__common__header__stamp__tot);
vn_ay_old=timeseries(log.vectornav__raw__common__imu_accel__y,log.vectornav__raw__common__header__stamp__tot);
vn_az_old=timeseries(log.vectornav__raw__common__imu_accel__z,log.vectornav__raw__common__header__stamp__tot);
vn_old=timeseries(sqrt(log.vectornav__raw__common__imu_accel__x.^2+log.vectornav__raw__common__imu_accel__y.^2+log.vectornav__raw__common__imu_accel__z.^2),log.vectornav__raw__common__header__stamp__tot);


vn_ax_old2=timeseries(log.vectornav__raw__common__imu_accel__x,log.vectornav__raw__common__header__stamp__tot);
vn_ay_old2=timeseries(log.vectornav__raw__common__imu_accel__y,log.vectornav__raw__common__header__stamp__tot);
vn_az_old2=timeseries(log.vectornav__raw__common__imu_accel__z,log.vectornav__raw__common__header__stamp__tot);
vn_old2=timeseries(sqrt(log.vectornav__raw__common__imu_accel__x.^2+log.vectornav__raw__common__imu_accel__y.^2+log.vectornav__raw__common__imu_accel__z.^2),log.vectornav__raw__common__header__stamp__tot);

