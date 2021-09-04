% DFSubtraction.m
% Author: Dr. Andrew Reinhardt
% Date: 8/9/2021
% 
% Purpose: Functional capability to perform full NUC on ND-array.
% 
% input: ND-array to be fully corrected of non-uniformity such as dark-frame and gain-errors; input arrays should be at least 2D, though this code can be modified to work with a linear detector array
% DFNUC_Thermal: DFNUC array, if this array is 2D performs basic dark-frame subtraction as per DFSubtraction function, if this array is 3D, perform thermal compensation 
% PRNUC: photo-response non-uniformity correction table, i.e. gain-errors, should be 2D array
%- refs. "Dark non-uniformity correction and characterization of a 3D flash lidar camera, AD Reinhardt, D Miller, A Lee, C Bradley, PF McManamon Laser Radar Technology and Applications XXIII 10636, 1063608" and 
% "Thermal drift compensation in dark-frame non-uniformtiy correction for InGaAs PIN 3D flash lidar camera, AE Hecht, AD Reinhardt, C Bradley, PF McManamon Laser Radar Technology and Applications XXVI 11744, 117440B" and
% "Toward snapshot correction of 3D flash LiDAR imagers, , A Reinhardt, CP Bradley, A Hecht, PF McManamon Optical Engineering 60 (8), 083101"
%
% output: ND-array fully corrected of DFNUC and PRNUC

function output=NUC(input,DFNUC_Thermal,PRNUC)
try
	% output is the output of DFSubtraction divided by PRNUC lookup table
	output = DFSubtraction(input,DFNUC_Thermal)./PRNUC;
catch
	if ~isempty(size(PRNUC,3))
	%if the PRNUC has an extra dimension, remove it through by averaging
		msgbox('photo-response non-uniformity correction is not sized properly, using the mean of the set of frames and proceeding')
		PRNUC = mean(PRNUC,3);
		output = DFSubtraction(input,DFNUC_Thermal)./PRNUC;
	else
	%if any other errors occur, throw exception and exit
		msgbox('a critical error has occurred, will exit now!')
		return
	end
end
