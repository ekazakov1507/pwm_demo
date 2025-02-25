clc; clear all; close all;
pkg load communications;

BIT_BASE = 16; % uint 16
TABLE_RESOLUTION = 7; % bit

clk = 250 * 1e6;
t = 0 : 1 / clk : 5 * 1e-6 - 1 / clk;
f_dds_0 = 100 * 1e3;
cosine_input = uint16(2^BIT_BASE / 2 * 0.9 * cos(2 * pi * f_dds_0 * t) + 2^BIT_BASE / 2);

[tab_min, tab_min_ind] = min(cosine_input)
[tab_max, tab_max_ind] = max(cosine_input)
tab_min_bin = de2bi(tab_min, BIT_BASE)((BIT_BASE - TABLE_RESOLUTION + 1) :BIT_BASE)
tab_max_bin = de2bi(tab_max, BIT_BASE)((BIT_BASE - TABLE_RESOLUTION + 1) :BIT_BASE)
tab_min_bin = dec2bin(tab_min, BIT_BASE)((BIT_BASE - TABLE_RESOLUTION + 1) :BIT_BASE)
tab_max_bin = dec2bin(tab_max, BIT_BASE)((BIT_BASE - TABLE_RESOLUTION + 1) :BIT_BASE)

% figure()
% plot(t, cosine_input)

bin_cosine_input = de2bi(cosine_input, BIT_BASE)(:, (BIT_BASE - TABLE_RESOLUTION + 1) :BIT_BASE);
printf("Cos table \n");
printf("resolution %d bits\n", TABLE_RESOLUTION);
printf("min %d %d \t %s \n", tab_min/2^TABLE_RESOLUTION, tab_min_ind, num2str(tab_min_bin));
printf("max %d %d \t %s \n", tab_max, tab_max_ind, num2str(tab_max_bin));

printf("Save file \n");
filename = 'cos-table.txt';
file = fopen(filename, 'w');
for i = 1:size(bin_cosine_input, 1)
  bin_cosine_input(i, :) = flip(bin_cosine_input(i, :));
  % pritnf(i);
  % prinf(strrep(num2str(bin_cosine_input(i,:)),' ',''));
  fprintf(file, '"%s",\n', strrep(num2str(bin_cosine_input(i, :)),' ',''));
endfor
fclose(file);
printf("File saved %s \n", filename)


