function [g] = cpif(s,np)  
   FS = 16000;
   
   t_fr = 0.02;      %488
   ns_fr = t_fr*FS;
   
   t_init = 0.004;
   n_init = t_init*FS;  
   
   t_fin = (t_fr - 0.003);
   n_fin = t_fin*FS;    %440
   
   s = s(1:ns_fr);
   
   c_s = lpc(s,20);
   
   e2 = filter(c_s,1,s);
   
   e = e2(n_init:n_fin);
   [val pos] = min(e);
   c0 = n_init + pos -1;
   
   p = 20;
   
   G = zeros(2*p+1,length(s));   % Pulsos
   a1 = zeros(2*p+1,1);          % lags
   C = zeros(2*p+1,p+1);         % Coeficientes por iteracion
   
   for i=0:2*p
      k=i+1;
      c = c0 + i - p;

      i0 = c-p;
      iF = c+p-1;

      sw = s(i0:iF);
      
      c_sw = arcov(sw,p);
      
      C(k,:) = c_sw; 

      g = filter(c_sw,1,s);

      G(k,:) = g';

      c_g = arcov(g,1);
      a1(k,1) = abs(c_g(1,2));
   end
   
   [val pos] = max(a1);
   
   indx_opt = pos;
   c_opt = C(indx_opt,:);
   
   g_opt = G(indx_opt,:)';
   
   i0 = c0-2*p-1;
   iF = c0+2*p+1;
   
   g_rg_c0 = g_opt(i0:iF);
	
   
   n_fin = c0 + np -1;
	n_inicio = c0;
	
	if(n_fin>ns_fr)
		n_fin = ns_fr;
		n_inicio = ns_fr - np + 1;
	end
	
	g = g_opt(n_inicio:n_fin);
	
	[val pos] = min(g);
	
	dist_to_anchor = floor(3*np/4) - pos;
	
	g = circshift(g,dist_to_anchor);
	
	
	

	
	
	
end









