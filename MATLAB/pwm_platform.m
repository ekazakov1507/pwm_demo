clc; clear all; close all;

clk = 250 * 1e6;
t = 0:1/clk:50*1e-6-1/clk;
f_dds_0 = 100*1e3;
sine_input = uint8(2^7/2*0.9*sin(2 * pi * f_dds_0 * t) + 2^7/2);

pwm_ref_steps = 1;
change_step_bound = length(t)/5;
change_step_bound
pwm_step_changer = uint8(zeros(1,length(t)));
pwm_step_changer(:) = 1;
pwm_channels = zeros(4,length(t));
[pwn_channels(1,:),pwn_channels(2,:),ref_pwm_c] = pwm_c(t,sine_input,pwm_step_changer);
# [pwn_channels(3,:),pwn_channels(4,:),ref_pwm_l] = pwm_l(t,sine_input,pwm_step_changer);

figure()
subplot(2,1,1);
plot(t, sine_input);
hold on
plot(t, ref_pwm_c);
subplot(2,1,2);
plot(t, pwn_channels(1,:));

