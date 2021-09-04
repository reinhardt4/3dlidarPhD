% DFSubtraction.m
% Author: Dr. Andrew Reinhardt
% Date: 8/9/2021
% 
% Purpose: Functional capability to perform dark-frame subtraction.
% 
% input: ND-array being DFNUC corrected; input arrays should be at least 2D
% DFNUC_Thermal: DFNUC array, if this array is 2D perform basic dark-frame subtraction, if this array is 3D, perform thermal compensationrefs. "Dark non-uniformity correction and characterization of a 3D flash lidar camera, AD Reinhardt, D Miller, A Lee, C Bradley, PF McManamon Laser Radar Technology and Applications XXIII 10636, 1063608" and 
% "Thermal drift compensation in dark-frame non-uniformtiy correction for InGaAs PIN 3D flash lidar camera, AE Hecht, AD Reinhardt, C Bradley, PF McManamon Laser Radar Technology and Applications XXVI 11744, 117440B"
%
% output: DFNUC corrected ND-array

function output=DFSubtraction(input,DFNUC_Thermal)

if isempty(size(DFNUC_Thermal,3))
	%if the DFNUC array has no 3rd dimension, correct as if without thermal compensation, i.e. simple dark-frame subtraction
	output = input - DFNUC_Thermal + mean(mean(DFNUC_Thermal,2),1);
else
	%if the DFNUC array has a third dimension, pass to the thermal IDX, and thermally compensated DFNUC
	idx=thermalIDX(input,DFNUC_Thermal);
	output = input - DFNUC_Thermal(:,:,idx) + mean(mean(DFNUC_Thermal(:,:,idx),2),1);
end
