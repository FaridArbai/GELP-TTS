classdef FrameLPC
   % Clase que almacena los parámetros que permiten
   % generar un sonido sintético que aproxima al
   % sonido con el que se creó este objeto mediante
   % la llamada nombre_objeto = FrameLPC(x). Una vez
   % realizada dicha llamada, el presente objeto
   % almacena tres parámetros característicos: el
   % pitch, la ganancia y los coeficientes LPC.
   
   properties
      coefs;   % Vector de 21 coeficientes (término indep. y 20 coefs. LPC)
      np;      % Periodo de pitch normalizado a la frecuencia de muestreo
      Ax;      % Ganancia del sonido en unidades lineales
		Eo;		% Factor de forma del pulso glotal
		nc;		% Instante de cruce por cero (Comienzo del cierre)
		Ee;		% Amplitud del instante de máxima aceleración
		ne;		% Instante de máxima aceleración
		E;			% Factor de retorno, velocidad de cierre
   end
   
   methods
      function obj = FrameLPC(x)
         % Constructor de la Clase. Su llamada mediante la sintaxis 
         % nombre_objeto = FrameLPC(x) crea un objeto FrameLPC con
         % los datos miembro (properties) anteriormente descritos,
         % siendo directamente accesibles. Este constructor se 
         % encarga de inicializar estos tres parámetros para que
         % estén disponibles al usuario tras la llamada al
         % constructor para crear el objeto. La entrada x ha de 
         % ser un sonido muestreado a 16Khz, preferiblemente de
         % duración 20 ms. A partir de este sonido se generan los
         % datos miembro.
         
         %----------------------------------------------------------------------%
         % Generación de los datos miembro a partir del frame sonoro x de 20 ms %
         %----------------------------------------------------------------------%
         np = pitch(x);    % Numero de muestras que posee el pitch
         
         Ex = sum(x.^2);   % Energía de la señal sonora x  
         Ax = sqrt(Ex);    % Ganancia de la señal x
			
         xw = x.*hamming(length(x));   % Enventanamiento de la señal x
         
         ro = 0.95;
         pre_enfasis = [1 0 (ro.^2)];        
         xw = filter(1,pre_enfasis,xw);   % Pre-énfasis de la señal x
                                          % para compensar la radiación
                                          % labial previo análisis LPC.
                                          % La señal habrá de de-enfatizarse
                                          % posterior síntesis
                                          
         coefs = lpc(xw,20);  % Cálculo de los coeficientes LPC
         
         
         % Asignación de los valores calculados a los datos miembro del objeto
         
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