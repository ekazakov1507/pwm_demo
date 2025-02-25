clc; clear all; close all;

clk = 250 * 1e6;
t = 0 : 1 / clk : 50 * 1e-6 - 1 / clk;
f_0 = 100 * 1e3;
NUM_CHANNELS = 2;
INPUT_SIG_RESOLUTION = 8; % bits 
sine_input = uint8(2^INPUT_SIG_RESOLUTION/2 *0.9*sin(2 * pi * f_0 * t) + 2^INPUT_SIG_RESOLUTION/2);

cnt_min = 0;
cnt_max = intmax('uint8');
cnt_step = 1;
pwm_channels = zeros(4, length(t));
[pwn_channels(1,:),pwn_channels(2,:),ref_pwm_c] = pwm_c(t, sine_input, cnt_min, cnt_max, cnt_step);
# [pwn_channels(3,:),pwn_channels(4,:),ref_pwm_l] = pwm_l(t,sine_input,pwm_step_changer);

figure()
subplot(2,1,1);
plot(t, sine_input);
hold on
plot(t, ref_pwm_c);
subplot(2,1,2);
plot(t, pwn_channels(1,:));

