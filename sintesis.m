function s = sintesis(str)
   % Recibe como parámetro un string compuesto por digitos
   % y devuelve la sintetización de dicho texto en base a
   % un algoritmo basado en LPC. Adicionalmente, reproduce
   % la señal sintetizada y muestra gráficas relativas a
   % la evolución temporal del pitch y de la ganancia.
   
   %-----------------------------------------------------%
   %  %-----------------------------------------------%  %
   %  % 1. Obtención de la codificación de cada frame %  %
   %  %-----------------------------------------------%  %
   %-----------------------------------------------------%
      
      v_str_difonemas = vectorDifonemas(str);       % Vector donde cada componente es un string con un difonema
                                                            %     que compone la frase. (e.g. [Xd;do;os;sX]).
                                                           
      n_difonemas = length(v_str_difonemas);                % Número de difonemas que componen la frase
      
		data_is_loaded = exist('difonemasLPC','var');

		if(data_is_loaded==false)	
 			container = load('./contenedor_codificacion_difonemas.mat');   % Contenedor que almacena la variable difonemasLPC
%       
 			difonemasLPC = container.difonemasLPC;                % Variable difonemasLPC: Es un mapa de objetos "DifonemaLPC"
%                                                             %     indexado por el string asociado a cada difonema. El
%                                                             %     valor que se almacena por cada índice o llave es el
%                                                             %     objeto DifonemaLPC que contiene la codificación del
%                                                             %     difonema correspondiente. Por ejemplo, difonemasLPC('ze')
%                                                             %     devuelve un objeto DifonemaLPC que contiene los campos
%                                                             %     n_frames (numero de frames) y frames (vector de objetos
%                                                             %     FrameLPC). n_frames representa cuantas ventanas de 20ms
%                                                             %     solapadas componían el difonema y original, mientras que
%                                                             %     el vector frames contiene los parámetros de cada ventana
%                                                             %     de modo que el componente iésimo del vector frames es un
%                                                             %     objeto FrameLPC que contiene 3 datos: periodo de pitch,
%                                                             %     coeficientes LPC y ganancia de dicho frame dentro del
%                                                             %     DifonemaLPC al que corresponde.
		assignin('base','difonemasLPC',difonemasLPC);
		
		else
			difonemasLPC = evalin('base','difonemasLPC');
		end
		
      %------------------------------------------------------------------------------------------%                                               
      %  Para cada difonema que compone la frase almacenar el objeto DifonemaLPC correspondiente %                      
      %------------------------------------------------------------------------------------------%
      for i=1:n_difonemas
         str_difonema = cell2mat(v_str_difonemas(i));            % String con el difonema numero i 
         v_difonemasLPC(i) = difonemasLPC(str_difonema); % Vector que en cada componente i almacena el objeto DifonemaLPC
                                                         %     del difonema i.
      end
      
   %-----------------------------------------------%
   %  %-----------------------------------------%  %
   %  % 2. Suavizado de la ganancia y del pitch %  %
   %  %-----------------------------------------%  %
   %-----------------------------------------------%
     
      v_np = [];  % Vector con las muestras del pitch de cada frame
      v_Ax = [];  % Vector con las muestras de la ganancia de cada frame
      
      %-------------------------------------------------------------------------------------------------------------%
      % Para cada difonema de la frase obtener el DifonemaLPC y extraer pitch y ganancia de cada uno de sus frames  %
      %-------------------------------------------------------------------------------------------------------------%
      for j=1:n_difonemas
         difonemaLPC = v_difonemasLPC(j); % DifonemaLPC del difonema j-ésimo de la frase
         n_frames = difonemaLPC.n_frames; % Numero de frames que componen el difonema j-ésimo
         frames = difonemaLPC.frames;     % Vector con la codificación de cada frame del difonema
         
         for i=1:n_frames
            frame = frames(i);   % FrameLPC que posee la codificación del frame i-ésimo del difonema j-ésimo
            
            np = frame.np;       % pitch del frame i-ésimo dentro del difonema j-ésimo
            Ax = frame.Ax;       % ganancia del frame i-ésimo dentro del difonema j-ésimo
            
            v_np = [v_np;np];    % Relleno dinámico del vector de muestras de pitch
            v_Ax = [v_Ax;Ax];    % Relleno dinámico del vector de muestras de ganancia
         end
      end
      
      v_np_original = v_np;   % Almacenamiento de los valores originales para 
      v_Ax_original = v_Ax;   %  la posterior comparación en las gráficas
      
      %------------------------------------------------%
      % Definición de los parámetros para el suavizado %
      %------------------------------------------------%
         nb_Ax = 1;     % Tamaño de la ventana de media móvil anticausal para la ganancia
         
         nb_np = 21;     % Tamaño de la ventana de media móvil anticausal para el pitch
         
         ns_med_np = 3; % Tamaño de la ventana de mediana para el pitch
         
         b_Ax = ones(1,nb_Ax)./nb_Ax;  % Coeficientes b de media móvil para la ganancia (Ventana uniforme)
      
      %---------------------------%
      % 2.1. Suavizado del pitch  %
      %---------------------------%
      
            %-----------------------------------------------------------------%
            % Eliminación de estimaciones espúreas mediante filtro de mediana %
            %-----------------------------------------------------------------%
               v_np = medfilt1(v_np, ns_med_np);

            %---------------------------------------------%
            % Suavizado de las muestras no nulas de pitch %
            %---------------------------------------------%
               tail = floor(nb_np/2);     % Numero de muestras a la dcha/izqda del puntero i0

               i0 = tail + 1;             % Inicialización del puntero que apunta a la muestra
                                          %  correspondiente al centro de la ventana, i.e. la
                                          %  que va a ser suavizada. Todas aquellas cuyo valor
                                          %  original no fuese 0 serán promediadas con las
                                          %  demás muestras no-nulas que se encuentran dentro 
                                          %  de la ventana de valores contenidos en el rango
                                          %  de indices [i0-tail,i0+tail].

               i_lim = length(v_np)-tail; % Límite del puntero i0 que indica el fin del suavizado
               
               v_np_cp = v_np;            % Copia de las muestras originales que actuarán como 
                                          %  entrada al filtro. Las muestras de entrada x(n) se
                                          %  tomarán de v_np_cp y las de salida y(n) se insertarán
                                          %  en v_np.
               
               %------------------------------------------------------------%
               % Recorrido del puntero y suavizado de las muestras no nulas %
               %------------------------------------------------------------%
               while(i0<i_lim)
                  np_apuntado = v_np_cp(i0);    % Extracción del centro de la ventana para evitar
                                                %  el suavizado de muestras nulas
                  
                  if(np_apuntado>0)
                     n_no_nulos = 0;            % Inicialización del contador de elemntos no-nulos

                     w_np = zeros(nb_np,1);     % Se inicializa la ventana de muestras del rango
                                                %  [i0-tail,i0+tail] que van a contribuir al
                                                %  suavizado de la muestra del índice i0.
                     
                     %---------------------------------------------------------------------%
                     % Almacenamiento de cada muestra y conteo del no. del elem. no nulos. %
                     %---------------------------------------------------------------------%
                     for i=1:nb_np
                        k = i0 - tail + i -1;            % Indice k que apunta al elemento correspondiente
                                                         %  en el vector de muestras de pitch para incluirlo
                                                         %  en la pos. i de la ventana

                        np = v_np_cp(k);                 % Extracción del elemento k del vector de pitch
                                                            
                        w_np(i) = np;                    % Inclusión en la ventana

                        if(np~=0)
                           n_no_nulos = n_no_nulos + 1;  % Cuenta de elem. no-nulos en la ventana
                        end
                     end
                     
                     %------------------------------------------------------------------%
                     % Suavizado de la muestra apuntada por i0 si la ventana es no-nula %
                     %------------------------------------------------------------------%
                     if(n_no_nulos>0)
                        np_promediado = sum(w_np)/n_no_nulos;  % Promediado de todos los los elem. no nulos.
                        np_promediado = round(np_promediado);  % Redondeo del resultado.
                        v_np(i0) = np_promediado;              % Inserción de la muestra suavizada en el vector
                                                               %  de salida v_np.
                     end
                  end
                  
                  i0 = i0 + 1;   % Incremento del puntero i0 para desplazar la ventana 1 muestra sobre el vector de pitch
               end
            
         %-------------------------------%
         % 2.2. Suavizado de la ganancia %
         %-------------------------------% 
         
            tail = floor(nb_Ax/2);  % Numero de muestras que quedan a la dcha/izqda de la ventana
            
            %------------------------------------------------------------------------------------%
            % Para cada ventana centrada en i0 con longitud 1+2*tail suavizar la muestra central |
            %------------------------------------------------------------------------------------%
            for i0=(tail+1):(length(v_Ax)-tail)
               iA0 = i0 - tail;        % Puntero al inicio de la ventana
               iAF = i0 + tail;        % Puntero al final de la ventana
               w_Ax = v_Ax(iA0:iAF);   % Muestras dentro de la ventana
               Ax = sum(w_Ax.*b_Ax');  % Promediado de la vetana
               v_Ax(i0) = Ax;          % Sustitución de la muestra 
            end
         
         %----------------------%
         % Figuras comparativas %
         %----------------------%
         
%             figure(1)
%                subplot(211)
%                   plot(v_np);
%                   title('Pitch Suavizado')
%                   xlabel('frame')
%                   ylabel('Periodo normalizado')
%                   grid on; grid minor;
%                subplot(212)
%                   plot(v_np_original);
%                   title('Pitch Original');
%                   xlabel('frame')
%                   ylabel('Periodo normalizado')
%                   grid on; grid minor;
% 
%             figure(2)
%                subplot(211)
%                   plot(v_Ax);
%                   title('Ganancia suavizada')
%                   xlabel('frame');
%                   ylabel('Amplitud (V)');
%                   grid on; grid minor;
%                subplot(212)
%                   plot(v_Ax_original);
%                   title('Ganancia original')
%                   xlabel('frame')
%                   ylabel('Amplitud (V)');
%                   grid on; grid minor;

   %-----------------------------------------------%
   %  %-----------------------------------------%  %
   %  % 3. Generación de la señal sintetizada   %  %
   %  %-----------------------------------------%  %
   %-----------------------------------------------%
   
      Fs = 16000;             % Frecuencia de muestreo (16 KHz)
      lt_w = 20e-3;           % Longitud temporal de los frames (20 ms)
      ns_w = lt_w*Fs;         % Longitud muestral de los frames (320 m.)
      olap = floor(ns_w/4);   % Muestras de solapamiento de coeficientes (80 m.)
      
      s = [];                 % Señal sintética final, dinámicamente alojada por cada difonema sintetizado
      indx_frame_global = 1;  % Indice del frame dentro de la sucesión de todos los frames, empieza en 1
                              %  y acaba en el número total de frames que se han procesado en toda la frase.
                              %  Se usa para extraer el pitch y la ganancia de los vectores anteriormente
                              %  suavizados cada vez que se sintetiza un frame.
                              
      %----------------------------------------------------------------------------------------------------%
      % Para cada difonema extraer su vector de FrameLPC y sintetizarlo usando los coefs. de cada FrameLPC %
      %----------------------------------------------------------------------------------------------------%
      for indx_difonema=1:n_difonemas
         difonemaLPC = v_difonemasLPC(indx_difonema); % DifonemaLPC asociado al difonema sintetizar; contiene
                                                      %   un vector "frames" en el que cada componente es un
                                                      %   objeto FrameLPC que contiene los coefs. LPC del
                                                      %   frame asociado.
         
         frames_difonema = difonemaLPC.frames;        % Vector de FrameLPC que contiene la codificación LPC
                                                      %   de cada frame que componía el difonema.
                                                      
         n_frames_difonema = difonemaLPC.n_frames;    % Número de frames que componían el difonema original
         
         s_difonema = [];                             % Variable temporal que almacenará la sintetización del
                                                      %   difonema analizado, cuyo valor se concatenará
                                                      %   secuencialmente al vector s[] permitiendo la
                                                      %   generación de la señal sintética en base a la
                                                      %   sintetización de cada difonema por separado.
         
         %------------------------------------------------------------------------%
         % Para cada FrameLPC del difonema sintetizar el sonido original mediante %
         %  los coeficientes LPC contenidos en el frame y los valores de ganancia %       
         %  y pitch previamente suavizados.                                       %
         %------------------------------------------------------------------------%
         for indx_frame=1:n_frames_difonema
            frame = frames_difonema(indx_frame);   % FrameLPC del que se van a extraer los coefs. LPC para
                                                   %   sintetizar el sonido asociado al frame original.
            
            np = v_np(indx_frame_global);          % Muestra de pitch para el vector de excitación de este
                                                   %  frame. (Vector de excitación = señal glotal).
            
            Ax = v_Ax(indx_frame_global);          % Muestra de ganancia para el v. de exc. de este frame.
            
            indx_frame_global=indx_frame_global+1; % Incremento del índice de frame global para obtener las
                                                   %  muestras del siguiente frame global en la interación 
                                                   %  siguiente.
            
            coefs = frame.coefs;                   % Extracción de los coeficientes LPC asociados al frame
                                                   %   actual. Tras generar el vector de excitación, se
                                                   %   filtrará con estos coeficientes.
            
            %-------------------------------------%
            % GENERACIÓN DEL VECTOR DE EXCITACIÓN %
            %-------------------------------------%
            
            %
            % Términos clave:
            %  
            %  * nse_w = Número de muestras efectivas del frame original. Hace referencia a cuantas 
            %              muestras no solapadas habían sido codificadas en el frame original. Para
            %              todos los frames este valor será de ns_w - olap (longitud de 20ms menos
            %              la longitud del solape), salvo para el primer frame que será de ns_w
            %              (20 ms) dado que no se solapa con ningún frame anterior. 
            %
            %  * dw_act = Incremento adicional en el tamaño de la ventana actual efectuado para que
            %              esta sea un múltiplo entero del pitch. Representa el número de muestras
            %              que hay que sumar a nse_w para obtener un múltiplo entero del periodo
            %              de pitch. Haciendo esta operación nos garantizamos que al final de la
            %              ventana el pulso sonoro se habrá relajado y no habrá un salto de fase
            %              considerable con la excitación de la ventana del siguiente frame.
            %
            %  * dw_ant = dw_act del frame anterior tal que el dw_ant de la iteración n es el dw_act
            %              de la iteración n-1.
            %
            %  * l1 : Tamaño efectivo restante de la ventana del frame actual tras el incremento de
            %           la ventana anterior. Si el tamaño efectivo de la ventana actual es nse_w
            %           y el incremento de la ventana del frame anterior es dw_ant, entonces
            %           l1 = nse_w - dw_ant.
            %
            %  * ltot : Tamaño final de la ventana, que se calcula como el múltiplo del periodo de
            %            pitch inmediatamente superior al tamaño de la ventana restante l1. Por
            %            lo tanto ltot = ceil(l1/np)*np, donde ceil es la función cielo o techo
            %            de un número decimal. ltot estará formado por el tamaño de la ventana
            %            efectiva que resta del incremento de la ventana anterior 
            %            (l1 = nse_w-dw_ant) y el incremento que ha sufrido la ventana actual.
            %  
            %  * l2 : Incremento que ha sufrido la ventana actual. Se calcula como ltot-l1 y, en
            %           particular, dw_act = l2. El cálculo de este parámetro sirve como 
            %           información para el siguiente frame (n+1), en el cual el valor de l2 
            %           pasará a ser dw_ant, valor necesario para que se pueda computar el
            %           tamaño efectivo restante de la siguiente ventana.
            %
            
            %-----------------------------------------------------------%
            %                 Inicio de la generación                   %
            %-----------------------------------------------------------%
               if(indx_frame==1)       % El frame 1 es el único no solapado con otro anterior
                  nse_w = ns_w;           % Número de muestras efectivas será igual al Nº de m. totales (20 ms.)
                  dw_ant = 0;             % Condición inicial sobre el frame 1 del difonema: No hubo ventanas anteriores
               else                    % El resto de frames tienen un solapamiento de olap muestras con el anterior
                  nse_w = ns_w - olap;    % El número de muestras efect. es el total menos las solapadas (320 - 80 ms.)
               end

               %-----------------%
               % SONIDOS SONOROS %
               %-----------------%
               if(np>0)
                  l1 = nse_w - dw_ant;             % Tamaño restante de la ventana efectiva actual debido al incremento
                                                   %  de la ventana anterior. Este valor l1 habrá que ampliarlo para
                                                   %  que el tamaño final de la ventana actual sea múltiplo de np.
                                          
                  ltot = siguienteMultiplo(l1,np); % Longitud final de la ventana actual. Siguiente múltiplo de
                                                   %  np mayor o igual que l1.
                  
                  l2 = ltot-l1;                    % Incremento de la ventana actual más allá de las nse_w muestras. Es el no. de
                                                   %  muestras que se han añadido para que el tamaño sea múltiplo de np y afectará
                                                   %  a la ventana siguiente pues dw_ant(n+1) = l2(n)

                  dw_act = l2;                     % Incremento de la ventana actual.

                  u = zeros(ltot,1);               % Inicialización del vector de excitación
						
						
						if(frame.np>0)
							reshape_dif = np - frame.np;
							Eo = frame.Eo;
							np_cruce = (frame.nc) + reshape_dif;
							Ee = frame.Ee;
							ne = (frame.ne) + reshape_dif;
							E = frame.E;
							
							u_periodo = LF(Eo,Ee,E,np_cruce,np,ne);
							u_periodo = circshift(u_periodo,-ne);
						else
							u_periodo = [1;zeros((np-1),1)];
						end
						
						n_periodos = ltot/np + 10;						% Número de periodos que componen el vector de excitación 
                  
                  %---------------------------------------------------------------%
                  % Por cada np muestras de la ventana actual, insertar u_periodo %
                  %---------------------------------------------------------------%
                  for indx_periodo=0:(n_periodos-1)
                     iu0 = 1 + (indx_periodo)*np;  % Indice inicial de inserción
                     iuF = iu0 + np - 1;           % Indice final de inserción
                     u(iu0:iuF) = u_periodo;       % Inserción de u_periodo en el periodo correspondiente.
                  end
               %----------------%
               % SONIDOS SORDOS %
               %----------------%
               else
                  dw_act = 0;          % Los sonidos sordos no se incrementan
                  u = randn(nse_w,1);  % Vector de inicialización aleatorio
               end
            %-----------------------------------------------------------%
            %                    Fin de la generación                   %
            %-----------------------------------------------------------%
				
				if(np>0)
					a = lpc(u,20);
				else
					a = 1;
				end
				
            s_frame = filter(a,coefs,u);  % Sintetización del frame actual
				
				s_frame = s_frame((10*np+1):end);
            
            Es_frame = sum(s_frame.^2);   % Normalización en energía de la señal sintetizada para
            As_frame = sqrt(Es_frame);    %  evitar factores de escala que afecten a la inserción
            s_frame = s_frame./As_frame;  %  de la ganancia.
            
            s_frame = s_frame.*Ax;        % Inserción de la ganancia correspondiente
            
            s_difonema = [s_difonema; s_frame]; % Concatenación dinámica de cada frame sintetizado
            
            dw_ant = dw_act;              % Dado que pasamos a la siguiente iteración, el valor del incremento
                                          %  actual pasa a ser el del incremento "anterior". Esto es, 
                                          %  dw_ant(n+1) = dw_act(n)
         end
         
         s = [s;s_difonema];  % Finalizada la sintetización y concatenación de cada frame del difonema actual,
                              %  se concatena el resultado a la síntesis global y se pasa a la siguiente iteración
                              %  para procesar los frames de cada difonema. 
      end
      
      ro = 0.95;                   % De-enfatización de la señal resultante para 
      pre_enfasis = [1 0 (ro.^2)];        %  eliminar el efecto de preenfasis realizado
      s = filter(pre_enfasis,1,s);  %  en la generación de cada frame.
		
      H_lo=design(fdesign.lowpass('N,F3dB',4,(3400/8000)),'butter');
		
		s = filter(H_lo,s);
		
      soundscx(s);   % Reproducción de la señal resultante a 16KHz
   
end