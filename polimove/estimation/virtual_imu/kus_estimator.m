
L=3.115;

t=log.estimation__bag_timestamp;
vx=log.estimation__vx;
delta = interp1(log.vehicle_fbk_eva__bag_timestamp,log.vehicle_fbk_eva__steering_wheel_angle,t);
yaw_rate = log.estimation__yaw_rate;

yaw_rate_ol = delta.*vx/L;
A=0;
R=1;
Q=0.000001;
P=zeros(length(t),1);
kus=zeros(length(t),1);
P(1)=0.0001;
kus(1)=0.0005;

for i=2:length(t)
    % prediction
    kus(i)=kus(i-1);
    % if abs(delta(i))<0.02
    %     continue
    % end
    P(i)=P(i-1)+Q;

    % correction
    C=-delta(i)*vx(i)/(kus(i)*vx(i)+L/vx(i))^2;
    e=yaw_rate(i) - ( delta(i)/(L/vx(i)+kus(i)*vx(i)) );
    S = C*P(i)*C' + R;
    K = P(i)*C'/S;
    P(i)=(1 - K*C) * P(i);
    kus(i)=kus(i)+K*e;

end

f_c = 0.001;
omega_c = 2 * pi * f_c;
sys = tf(omega_c, [1 omega_c]);
dt = mean(diff(t));
t_sim = 0:dt:max(t);
kus_interp = interp1(t, kus, t_sim, 'linear', 'extrap');
kus_filtered = lsim(sys, kus_interp, t_sim);
kus_filtered_interp = interp1(t_sim, kus_filtered, t, 'linear', 'extrap');


figure;
hold on;
grid on;
plot(t,yaw_rate,'DisplayName','meas');
plot(t,yaw_rate_ol,'DisplayName','ol');
plot(t,delta./(L./vx+kus.*vx),'DisplayName','hat');
plot(t,delta./(L./vx+0.0005.*vx),'DisplayName','kus');
plot(t,delta./(L./vx+kus_filtered_interp.*vx),'DisplayName','filt');
legend show

figure;
hold on;
plot(t,kus);
plot(t,kus_filtered_interp);
grid on;


%% ay estimator

ome_hat = delta./(L./vx+kus.*vx);
ay = log.estimation__ay;
ay_hat = ome_hat.*vx;
pole_freq_=0.05;
out_=0;

ay_env=zeros(length(t),1);
for i=2:length(t)
    if (abs(ay_hat(i)) > out_)
        out_ = abs(ay_hat(i));
    else
        out_ = out_  - out_ * (t(i)-t(i-1)) * (2.0*pi*pole_freq_);
    end
    ay_env(i)=out_;
end


figure;
hold on;
grid on;
plot(t,ay,'DisplayName','meas');
plot(t,ay_hat,'DisplayName','ol');
plot(t,ay_env,'DisplayName','ol_with_rate');
yline(5)
legend show







