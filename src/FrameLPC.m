classdef FrameLPC
   % Clase que almacena los par�metros que permiten
   % generar un sonido sint�tico que aproxima al
   % sonido con el que se cre� este objeto mediante
   % la llamada nombre_objeto = FrameLPC(x). Una vez
   % realizada dicha llamada, el presente objeto
   % almacena tres par�metros caracter�sticos: el
   % pitch, la ganancia y los coeficientes LPC.
   
   properties
      coefs;   % Vector de 21 coeficientes (t�rmino indep. y 20 coefs. LPC)
      np;      % Periodo de pitch normalizado a la frecuencia de muestreo
      Ax;      % Ganancia del sonido en unidades lineales
		Eo;		% Factor de forma del pulso glotal
		nc;		% Instante de cruce por cero (Comienzo del cierre)
		Ee;		% Amplitud del instante de m�xima aceleraci�n
		ne;		% Instante de m�xima aceleraci�n
		E;			% Factor de retorno, velocidad de cierre
   end
   
   methods
      function obj = FrameLPC(x)
         % Constructor de la Clase. Su llamada mediante la sintaxis 
         % nombre_objeto = FrameLPC(x) crea un objeto FrameLPC con
         % los datos miembro (properties) anteriormente descritos,
         % siendo directamente accesibles. Este constructor se 
         % encarga de inicializar estos tres par�metros para que
         % est�n disponibles al usuario tras la llamada al
         % constructor para crear el objeto. La entrada x ha de 
         % ser un sonido muestreado a 16Khz, preferiblemente de
         % duraci�n 20 ms. A partir de este sonido se generan los
         % datos miembro.
         
         %----------------------------------------------------------------------%
         % Generaci�n de los datos miembro a partir del frame sonoro x de 20 ms %
         %----------------------------------------------------------------------%
         np = pitch(x);    % Numero de muestras que posee el pitch
         
         Ex = sum(x.^2);   % Energ�a de la se�al sonora x  
         Ax = sqrt(Ex);    % Ganancia de la se�al x
			
         xw = x.*hamming(length(x));   % Enventanamiento de la se�al x
         
         ro = 0.95;
         pre_enfasis = [1 0 (ro.^2)];        
         xw = filter(1,pre_enfasis,xw);   % Pre-�nfasis de la se�al x
                                          % para compensar la radiaci�n
                                          % labial previo an�lisis LPC.
                                          % La se�al habr� de de-enfatizarse
                                          % posterior s�ntesis
                                          
         coefs = lpc(xw,20);  % C�lculo de los coeficientes LPC
         
         
         % Asignaci�n de los valores calculados a los datos miembro del objeto
         
         obj.np = np;         
         obj.Ax = Ax;         
         obj.coefs = coefs; 
			if(np>0)
				[q,Eo,nc,Ee,ne,E] = ajusteLF(cpif(x,np));
				obj.Eo = Eo;
				obj.ne = ne;
				obj.nc = nc;
				obj.Ee = Ee;
				obj.E = E;
			end
			
      end
   end
end