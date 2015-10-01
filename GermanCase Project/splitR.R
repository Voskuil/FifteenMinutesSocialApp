splitThis <- function(X,Y){
  NominativeY = c();
  nomcount = 1;
  AccusativeY = c();
  acccount = 1;
  DativeY = c();
  datcount = 1;
  GenitiveY = c();
  gencount = 1;
  NominativeX = c();
  AccusativeX = c();
  DativeX = c();
  GenitiveX = c();
  for (i in 1:186){
    if (i <= 96){
      k = 97-i;
      if (k %% 4 == 1){
        NominativeY[nomcount] = Y[i];
        NominativeX[nomcount] = X[i];
        nomcount = nomcount + 1;
      } else if (k %% 4 == 2){
        AccusativeY[acccount] = Y[i];
        AccusativeX[acccount] = X[i];
        acccount = acccount + 1;
      } else if (k %% 4 == 3){
        DativeY[datcount] = Y[i];
        DativeX[datcount] = X[i];
        datcount = datcount + 1;
      } else {
        GenitiveY[gencount] = Y[i];
        GenitiveX[gencount] = X[i];
        gencount = gencount +1;}
    } else if (i <= 150){
        k = 151-i;
        if (k %% 3 == 1){
          NominativeY[nomcount] = Y[i];
          NominativeX[nomcount] = X[i];
          nomcount = nomcount + 1;
        } else if (k %% 3 == 2){
          AccusativeY[acccount] = Y[i];
          AccusativeX[acccount] = X[i];
          acccount = acccount + 1;
        } else {
          DativeY[datcount] = Y[i];
          DativeX[datcount] = X[i];
          datcount = datcount + 1;}
    } else if (i <= 174){
        k = 175-i;
        if (k %% 2 == 1){
          NominativeY[nomcount] = Y[i];
          NominativeX[nomcount] = X[i];
          nomcount = nomcount + 1;
        } else {
          AccusativeY[acccount] = Y[i];
          AccusativeX[acccount] = X[i];
          acccount = acccount + 1;}
    } else {
      NominativeY[nomcount] = Y[i];
      NominativeX[nomcount] = X[i];
      nomcount = nomcount + 1}
  }
  result = list(NominativeX,NominativeY,
                AccusativeX,AccusativeY,
                DativeX,DativeY,
                GenitiveX,GenitiveY);
  return(result)
}
