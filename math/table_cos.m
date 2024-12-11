clc; clear all; close all;
pkg load communications;

clk = 250 * 1e6;
t = 0:1/clk:5*1e-6-1/clk;
f_dds_0 = 100*1e3;
cosine_input = uint16(2^16/2*0.9*cos(2 * pi * f_dds_0 * t) + 2^16/2);

%figure()
%plot(t, cosine_input)

bit_cosine_input = de2bi(cosine_input, 16)(:,10:16);
filename = 'cos-table.txt';
file = fopen(filename, 'w');
for i = 1:size(bit_cosine_input,1)
  bit_cosine_input(i,:) = flip(bit_cosine_input(i,:));
  %disp(i)
  %disp(strrep(num2str(bit_cosine_input(i,:)),' ',''))
  fprintf(file, '"%s",\n', strrep(num2str(bit_cosine_input(i,:)),' ',''));
endfor
fclose(file);


