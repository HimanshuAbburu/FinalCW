*************************************;
*** begin scoring code for regression;
*************************************;

length _WARN_ $4;
label _WARN_ = 'Warnings' ;

length I_ORGYN $ 12;
label I_ORGYN = 'Into: ORGYN' ;
*** Target Values;
array REG3DRF [2] $12 _temporary_ ('1' '0' );
label U_ORGYN = 'Unnormalized Into: ORGYN' ;
format U_ORGYN BEST12.;
*** Unnormalized target values;
ARRAY REG3DRU[2]  _TEMPORARY_ (1 0);

drop _DM_BAD;
_DM_BAD=0;

*** Check AFFL for missing values ;
if missing( AFFL ) then do;
   substr(_warn_,1,1) = 'M';
   _DM_BAD = 1;
end;

*** Check AGE for missing values ;
if missing( AGE ) then do;
   substr(_warn_,1,1) = 'M';
   _DM_BAD = 1;
end;

*** Generate dummy variables for GENDER ;
drop _2_0 _2_1 ;
if missing( GENDER ) then do;
   _2_0 = .;
   _2_1 = .;
   substr(_warn_,1,1) = 'M';
   _DM_BAD = 1;
end;
else do;
   length _dm1 $ 1; drop _dm1 ;
   _dm1 = put( GENDER , $1. );
   %DMNORMIP( _dm1 )
   if _dm1 = 'F'  then do;
      _2_0 = 1;
      _2_1 = 0;
   end;
   else if _dm1 = 'M'  then do;
      _2_0 = 0;
      _2_1 = 1;
   end;
   else if _dm1 = 'U'  then do;
      _2_0 = -1;
      _2_1 = -1;
   end;
   else do;
      _2_0 = .;
      _2_1 = .;
      substr(_warn_,2,1) = 'U';
      _DM_BAD = 1;
   end;
end;

*** Generate dummy variables for REGION ;
drop _5_0 _5_1 _5_2 _5_3 ;
*** encoding is sparse, initialize to zero;
_5_0 = 0;
_5_1 = 0;
_5_2 = 0;
_5_3 = 0;
if missing( REGION ) then do;
   _5_0 = .;
   _5_1 = .;
   _5_2 = .;
   _5_3 = .;
   substr(_warn_,1,1) = 'M';
   _DM_BAD = 1;
end;
else do;
   length _dm10 $ 10; drop _dm10 ;
   _dm10 = put( REGION , $10. );
   %DMNORMIP( _dm10 )
   _dm_find = 0; drop _dm_find;
   if _dm10 <= 'SCOTTISH'  then do;
      if _dm10 <= 'NORTH'  then do;
         if _dm10 = 'MIDLANDS'  then do;
            _5_0 = 1;
            _dm_find = 1;
         end;
         else do;
            if _dm10 = 'NORTH'  then do;
               _5_1 = 1;
               _dm_find = 1;
            end;
         end;
      end;
      else do;
         if _dm10 = 'SCOTTISH'  then do;
            _5_2 = 1;
            _dm_find = 1;
         end;
      end;
   end;
   else do;
      if _dm10 = 'SOUTH EAST'  then do;
         _5_3 = 1;
         _dm_find = 1;
      end;
      else do;
         if _dm10 = 'SOUTH WEST'  then do;
            _5_0 = -1;
            _5_1 = -1;
            _5_2 = -1;
            _5_3 = -1;
            _dm_find = 1;
         end;
      end;
   end;
   if not _dm_find then do;
      _5_0 = .;
      _5_1 = .;
      _5_2 = .;
      _5_3 = .;
      substr(_warn_,2,1) = 'U';
      _DM_BAD = 1;
   end;
end;

*** If missing inputs, use averages;
if _DM_BAD > 0 then do;
   _P0 = 0.2590142243;
   _P1 = 0.7409857757;
   goto REG3DR1;
end;

*** Compute Linear Predictor;
drop _TEMP;
drop _LP0;
_LP0 = 0;

***  Effect: AFFL ;
_TEMP = AFFL ;
_LP0 = _LP0 + (    0.25700682997734 * _TEMP);

***  Effect: AGE ;
_TEMP = AGE ;
_LP0 = _LP0 + (   -0.05062678776138 * _TEMP);

***  Effect: GENDER ;
_TEMP = 1;
_LP0 = _LP0 + (    1.07862891533528) * _TEMP * _2_0;
_LP0 = _LP0 + (    0.05316862794164) * _TEMP * _2_1;

***  Effect: REGION ;
_TEMP = 1;
_LP0 = _LP0 + (    0.00088586141665) * _TEMP * _5_0;
_LP0 = _LP0 + (   -0.34057203088904) * _TEMP * _5_1;
_LP0 = _LP0 + (    0.01312321930412) * _TEMP * _5_2;
_LP0 = _LP0 + (   -0.08420870369266) * _TEMP * _5_3;

*** Naive Posterior Probabilities;
drop _MAXP _IY _P0 _P1;
_TEMP =     -1.4585944575381 + _LP0;
if (_TEMP < 0) then do;
   _TEMP = exp(_TEMP);
   _P0 = _TEMP / (1 + _TEMP);
end;
else _P0 = 1 / (1 + exp(-_TEMP));
_P1 = 1.0 - _P0;

REG3DR1:


*** Posterior Probabilities and Predicted Level;
label P_ORGYN1 = 'Predicted: ORGYN=1' ;
label P_ORGYN0 = 'Predicted: ORGYN=0' ;
P_ORGYN1 = _P0;
_MAXP = _P0;
_IY = 1;
P_ORGYN0 = _P1;
if (_P1 >  _MAXP + 1E-8) then do;
   _MAXP = _P1;
   _IY = 2;
end;
I_ORGYN = REG3DRF[_IY];
U_ORGYN = REG3DRU[_IY];

*************************************;
***** end scoring code for regression;
*************************************;
