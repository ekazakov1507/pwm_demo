clc; clear all; close all;

clk = 100 * 1e6;
t = 0:1/clk:100*1e-6-1/clk;
f_dds_0 = 15.52*1e3;
sine_input = uint16(2^16/2*sin(2 * pi * f_dds_0 * t) + 2^16/2);

% 1, 3, 5, 15, 17, 51, 85, 255, 257, 771, 1285, 3855, 4369, 13107, 21845, 65535
pwm_ref_steps = [1, 3, 5, 51,  255,  771];
change_step_bound = length(t)/5;
change_step_bound
pwm_steo_changer = uint16(zeros(1,length(t)));
pwm_steo_changer(1:change_step_bound-1) = 1;
pwm_steo_changer(change_step_bound:2*change_step_bound-1) = 5;
pwm_steo_changer(2*change_step_bound:3*change_step_bound-1) = 255;
pwm_steo_changer(3*change_step_bound:4*change_step_bound-1) = 1285;
pwm_channels = zeros(4,length(t));
[pwn_channels(1,:),pwn_channels(2,:),ref_pwm_l] = pwm_l(t,sine_input,pwm_steo_changer);
[pwn_channels(3,:),pwn_channels(4,:),ref_pwm_c] = pwm_c(t,sine_input,pwm_steo_changer);

figure()
subplot(4,1,1);
plot(t, sine_input);
hold on
plot(t, ref_pwm_l);
subplot(4,1,2);
plot(t, pwn_channels(1,:));
subplot(4,1,3);
plot(t, sine_input);
hold on
plot(t, ref_pwm_c);
subplot(4,1,4);
plot(t, pwn_channels(3,:));


