function [pwm, pwm_n, counter] = pwm_c(t, input, 
                                      counter_start=0, 
                                      counter_stop=255, 
                                      counter_step=1)
   counter = uint8(zeros(1, length(t)));
   counter_updown = 0;
   pwm = zeros(1, length(t));
   pwm_i = zeros(1, length(t));
   for i = 2:length(t)
      if counter_updown == 1 && counter(i-1) < counter_stop
        counter(i) = counter(i-1) + counter_step;
      elseif counter_updown == 0 && counter(i-1) > counter_start
        counter(i) = counter(i-1) - counter_step;
      elseif counter(i-1) == counter_start
        counter_updown = 1;
        counter(i) = counter(i-1) + counter_step;
      elseif counter(i-1) == counter_stop
        counter_updown = 0;
        counter(i) = counter(i-1) - counter_step;
      endif
      if counter(i) < input(i)
        pwm(i) = 1;
        pwm_n(i) = 0;
      else
        pwm(i) = 0;
        pwm_n(i) = 1;
      endif
   endfor
end;
