function [pwm, pwm_i, counter] = pwm_c(t,modulated,counter_step)
   counter = uint16(zeros(1,length(t)));
   counter_updown = 0;
   pwm = zeros(1,length(t));
   pwm_i = zeros(1,length(t));
   for i = 2:length(t)
      if counter_updown == 1 && counter(i-1) < 65535
        counter(i) = counter(i-1) + counter_step(i-1);
      elseif counter_updown == 0 && counter(i-1) > 0
        counter(i) = counter(i-1) - counter_step(i-1);
      elseif counter(i-1) == 0
        counter_updown = 1;
        counter(i) = counter(i-1) + counter_step(i-1);
      elseif counter(i-1) == 65535
        counter_updown = 0;
        counter(i) = counter(i-1) - counter_step(i-1);
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
