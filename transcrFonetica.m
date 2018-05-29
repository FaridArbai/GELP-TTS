function str_transcr = transcrFonetica(str)
   %1. Delimitar el string
      str = [' ', str(1:end), ' '];
      
   %2. Sustituir digitos por palabras
      v_palabras_digitos={
                     'cero';
                     'uno';
                     'dos';
                     'tres';
                     'cuatro';
                     'cinco';
                     'seis';
                     'siete';
                     'ocho';
                     'nueve'
                    };     
                 
      for i=0:1:9
         k = i+1;
         digito = sprintf('%d',i);
         palabra_digito = v_palabras_digitos(k); 
         palabra_digito = cell2mat(palabra_digito);
         str = strrep(str,digito,palabra_digito);
      end
      
   %3. Transcripción fonetica : Codificación
   
      %3.1. Espacios por X
         str = strrep(str,' ','X');
         
      %3.2. v por b
         str = strrep(str,'v','b');
         
      %3.3. ch por x
         str = strrep(str,'ch','x');
         
      %3.4. c por z o k según proceda
         v_pos_c = findstr(str,'c');
         n_c = length(v_pos_c);
         
         for i=1:n_c
            pos_c = v_pos_c(i);
            letra_siguiente = str(pos_c+1);
            
            if(letra_siguiente=='e'||letra_siguiente=='i')
               str(pos_c) = 'z';
            else
               str(pos_c) = 'k';
            end
         end
      
   str_transcr = str;
end