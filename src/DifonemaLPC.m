classdef DifonemaLPC
   % Clase que representa el sonido de un difonema. Como un difonema
   % se divide en varios frames de 20ms., esta clase almacena un
   % vector llamado "frames" que almacena un objeto FrameLPC por
   % cada frame que compone el difonema.
   %
   % La creaci�n de un objeto DifonemaLPC se hace mediante la sintaxis
   % nombre_objeto = DifonemaLPC(x), donde x es una se�al sonora que
   % representa un difonema muestreado a 16KHz. Dicha llamada devuelve
   % un objeto DifonemaLPC en el que el campo nombre_objeto.frames es
   % un vector que en la posici�n i tiene un objeto FrameLPC que 
   % codifica el frame de 20ms. n�mero i dentro del difonema original.
   %
   
   properties
      frames;     % Vector de objetos FrameLPC que codifican cada frame
                  %  del difonema x proporcionado en la llamada al
                  %  constructor de la clase DifonemaLPC(x).
                  
      n_frames;   % N�mero de frames que componen el difonema x 
                  %  proporcionado en la llamada al constructor
                  %  de la clase DifonemaLPC(x)
   end
   
   methods
      function obj = DifonemaLPC(x)
         % Constructor de la clase. Permite crear un objeto DifonemaLPC con
         % los campos frames y n_frames mediante la sintaxis 
         % nombre_objeto = DifonemaLPC(x), donde x ha de ser una se�al
         % sonora de un difonema muestreado a 16Khz y de longitud superior
         % a 20ms.
         
         %---------------------------------------------------------%
         % Generaci�n de los datos miembro a partir del difonema x %
         %---------------------------------------------------------%
         
         ns_x = length(x);       % Numero de muestras del difonema x
         Fs = 16000;             % Frecuencia de muestreo
         lt_w = 20e-3;           % Longitud de los frames componentes del difonema x
         ns_w = lt_w*Fs;         % Numero de muestras de los frames (320 m.)
         olap = floor(ns_w/4);   % Numero de muestras de solapamiento (80 m.)
         
         n_frames = floor((ns_x-olap)/(ns_w-olap));
            % n_frames es el n�mero entero de frames que, con una longitud ns_w y un
            % solapamiento de olap muestras, permiten conformar todo el difonema salvo
            % un �ltimo residuo en el que no cabe ning�n frame, el cual es descartado.
            % Dicho residuo es estrictamente inferior a 15 ms. ergo resulta despreciable.
         
         ns_xw = n_frames*(ns_w-olap) + olap;
            % ns_xw es el n�mero de muestras que va a tener un enventanamiento de la
            % se�al x, el cual se hace para eliminar el residuo en el que no cabe 
            % ning�n frame. 
            
         x = x(1:ns_xw);   % Se�al enventanada para eliminar el residuo final
         
         %-----------------------------------------------------------------------------%
         % Para cada frame solapado que compone el difonema x crear un objeto FrameLPC % 
         % que almacene los par�metros de s�ntesis y almacenar dicho objeto en la      %
         % posici�n i�sima del vector frames.                                          %
         %-----------------------------------------------------------------------------%
         for nw=1:n_frames
            % C�lculo del puntero i0 que contiene la posici�n 
            % en la que empieza el frame solapado dentro de x.
            if(nw==1)   
               i0 = 1;                    % El primer frame empieza en i0=1
            else
               i0 = i0 + ns_w - (olap);   % El resto de frames empiezan "olap" muestras antes
                                          %  del final del �ltimo frame.
            end
            
            iF = i0 + ns_w -1;            % Puntero que contiene el final del frame
            
            xw = x(i0:iF);                % Extracci�n de las ns_w muestras del frame
            
            frame_codificado = FrameLPC(xw); % Creaci�n del objeto FrameLPC que almacena los
                                             %  par�metros LPC del frame xw.
            
            frames(nw) = frame_codificado;   % Inserci�n del objeto FrameLPC en el vector de objetos
                                             %  que almacenar� los par�metros LPC de todos los frames 
                                             %  de este difonema.
         end
         
         
         % Asignaci�n de los valores calculados a los datos miembro del objeto
         
         obj.frames = frames;
         obj.n_frames = n_frames;
      end
   end
end