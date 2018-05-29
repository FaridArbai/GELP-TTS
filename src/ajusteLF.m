function [q,Eo,np,Ee,ne,E] = ajusteLF(g)
   nc = length(g);
   
   [Ee ne] = min(g);
   ne = ne-1;
   
   Eo = 0.1;
   E = 1000;
   np = ne-1;
   
   d_Eo = -1e-5;
   d_E = 100;
   d_np = -1;
   
   q = LF(Eo,Ee,E,np,nc,ne);
   
   flag_Eo = false;
   flag_E = false;
   flag_np = false;
   
   err = rmsError(g,q);
   err_ant = inf;
   
   v_Eo = [Eo];
   v_E = [E];
   v_np = [np];
   v_err = [err];
   v_dif_err = [0];
   
   while (true)
      err = rmsError(g,q);
      
      
      % Optimizacion Amplitud
      %---------------------------
      Eo = Eo + d_Eo;
      
      if(Eo>0)
         q = LF(Eo,Ee,E,np,nc,ne);
         
         if(isreal(q))
            err_Eo = rmsError(g,q);
         else
            err_Eo=inf;
         end
         
      else
         err_Eo=inf;
      end
      
      if(err_Eo < err)
         err = err_Eo;
      else
         d_Eo = -d_Eo;
         Eo = Eo + d_Eo;
      end
      
      
      %Optimizacion Amortiguacion
      %---------------------------
      E = E + d_E;
      
      if(E>0)
         q = LF(Eo,Ee,E,np,nc,ne);
         
         if(isreal(q))
            err_E = rmsError(g,q);
         else
            err_E=inf;
         end
         
      else
         err_E = inf;
      end
      
      if(err_E < err)
         err = err_E;
      else
         d_E = -d_E;
         E = E + d_E;
      end
      
      
      %Optimizacion Cruce
      %---------------------------
      np = np + d_np;
      
      if((np<ne)&&(np>0))
         q = LF(Eo,Ee,E,np,nc,ne);
         
         if(isreal(q))
            err_np = rmsError(g,q);
         else
            err_np=inf;
         end   
      else
         err_np = inf;
      end
      
      if( (err_np < err) )
         err = err_np;
      else
         d_np = -d_np;
         np = np + d_np;
      end
      
      %Error
      %----------------------------
      
      dif_err = err_ant-err;
      err_ant = err;
      
      dif_err_th = (10^-7);
      
      if( dif_err<dif_err_th )
         break;
      end
      
      
      %Graficas
      %----------------------------
      v_err = [v_err err];
      v_Eo = [v_Eo Eo];
      v_E = [v_E E];
      v_np = [v_np np];
      v_dif_err = [v_dif_err dif_err];
      
      display_parametros = false;
      display_pulso = false;
      display_diff_err = false;
      
      if (display_parametros)
      figure(10)
         subplot(221)
            plot(v_Eo); 
            grid on; grid minor;
         subplot(222)
            plot(v_E); 
            grid on; grid minor;
         subplot(223)
            plot(v_np); 
            grid on; grid minor;
         subplot(224)
            plot(10*log10(v_err)); 
            grid on; grid minor;
         pause(0.01);
      end
      
      if (display_pulso)
         figure(11)
            plot(g,'k');
            axis([0 (nc-1) 2*Ee -2*Ee]);
            hold on
               plot(q,'b');
               axis([0 (nc-1) 2*Ee -2*Ee]);
            hold off
            axis([0 (nc-1) 2*Ee -2*Ee]);
            grid on; grid minor;
         pause(0.001);
      end
   
      if (display_diff_err)
         figure(12)
         plot(10*log10(v_dif_err));
         grid on; grid minor;
         pause(0.001);
      end
   
   end
end
   
   
   
   