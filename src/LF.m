function g = LF(Eo,Ee,E,np,nc,ne)
   Fs = 16000;
   g = zeros(nc,1);
   
   a = -(Fs/ne)*log((Eo/Ee)*sin(pi*(ne/np)));
   na = -(Eo/Ee)*(Fs/E)*(1-exp(-E*(nc-ne)/Fs));
   
   for n=0:(ne-1)
      k = n+1;
      g(k) = Eo*exp(a*n/Fs)*sin(pi*(n/np));
   end
   
   A = -(Eo*Fs)/(E*na);
   
   for n=(ne):(nc-1)
      k = n+1;
      e1 = exp(-E*(n-ne)/Fs);
      e2 = exp(-E*(nc-ne)/Fs);
      g(k) = A*(e1-e2);
	end
   
%    figure()
%    plot(g);
%    grid on; grid minor;
%    axis([0 (nc-1) 1.5*Ee -1.5*Ee]);
end