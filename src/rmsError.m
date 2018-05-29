function err = rmsError(x1,x2)
   difx = x1 - x2;
   difx_cuad = (difx).^2;
   err = sum(difx_cuad);