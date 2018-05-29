function np = pitch(x)
   fs = 16000;
   f_min = 80;
   f_max = 180;
   np_min = ceil(fs/f_max);      %72
   np_max = floor(fs/f_min);     %200
   
   
   ns = length(x);
   rxx = xcorr(x);
   rxx = rxx(ns:end);
   rxx = rxx./(rxx(1));
   
   rxx_rg = rxx(np_min:np_max);
   [max_val max_pos] = max(rxx_rg);
   max_pos = max_pos - 1 + np_min;
   
   if(max_val>0.25)
      np = max_pos;
   else
      np = 0;
   end
   
   flag_plot = false;
   if(flag_plot)
      figure()
      plot(rxx);
      grid on; grid minor;
      title('autocorrelacion');
   end
   
end
   
   