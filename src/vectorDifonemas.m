function [v_dif] = vectorDifonemas(str)
	
	data_is_loaded = exist('transcripciones','var');
	
	if(data_is_loaded==false)
		container = load('./contenedor_transcripciones.mat');
		transcripciones = container.transcripciones;
		assignin('base','transcripciones',transcripciones);
	else
		transcripciones = evalin('base','transcripciones');
		
	end
	
	str = strrep(str, ',',' ,');
	str = strrep(str, '.',' .');
	str = strrep(str, '0','zero ');
	str = strrep(str, '1','one ');
	str = strrep(str, '2','two ');
	str = strrep(str, '3','three ');
	str = strrep(str, '4','four ');
	str = strrep(str, '5','five ');
	str = strrep(str, '6','six ');
	str = strrep(str, '7','seven ');
	str = strrep(str, '8','eight ');
	str = strrep(str, '9','nine ');
	
   str = upper(str);
	
	words = strsplit(str);
	n_words = length(words);
	v_transcr(1) = {'pau'};
	
	k = 2;
	
	for i=1:n_words
		word = cell2mat(words(i));
		is_alpha = (sum(isletter(word))==length(word))&(length(word)>0);
		
		if(is_alpha==false)
			v_transcr(k) = {'pau'};
			k=k+1;
		else
			try
				transcr = transcripciones(word);
			catch
				transcr = transcripciones('NULL');
			end
			
			transcrs = strsplit(transcr);
			n_transcrs = length(transcrs);

			for i=1:n_transcrs
				transcr = cell2mat(transcrs(i));
				transcr = lower(transcr);
				index_letters = find(isletter(transcr));
				transcr = transcr(index_letters);

				v_transcr(k) = {transcr};
				k = k+1;
			end
		end
	end
	
	v_transcr(k) = {'pau'};
	
	n_transcrs = length(v_transcr);
	
	v_dif = {};
	
	for i=1:(n_transcrs-1);
		fon1 = cell2mat(v_transcr(i));
		fon2 = cell2mat(v_transcr(i+1));
		dif = strcat(fon1,'-',fon2);
		v_dif(i) = {dif};
	end
	
end