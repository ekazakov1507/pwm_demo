function [pwm, pwm_i, counter] = pwm_l(t,modulated,counter_step)
   counter = uint16(zeros(1,length(t)));
   pwm = zeros(1,length(t));
   pwm_i = zeros(1,length(t));
   for i = 2:length(t)
      counter(i) = counter(i-1) + counter_step(i-1);
      if counter(i) == 2^16-1
        counter(i) = 0;
      endif
      if counter(i) < modulated(i)
        pwm(i) = 1;
        pwm_i(i) = 0;
      else
        pwm(i) = 0;
        pwm_i(i) = 1;
      endif
   endfor
end;
