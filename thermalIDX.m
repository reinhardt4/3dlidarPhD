% thermalIDX.m
% Author: Dr. Andrew Reinhardt
% Date: 8/9/2021
% 
% Purpose: Generates array of indices for usage in thermal-drift compensation of DFNUC.
% 
% input: array being corrected
% input arrays can be 3D, 4D, or 5D
% 3D arrays should have a structure of (x,y,frames)
% 4D arrays should have a structure of (x,y,frames,rotations), refs. "Toward snapshot correction of 3D flash LiDAR imagers, A Reinhardt, CP Bradley, A Hecht, PF McManamon Optical Engineering 60 (8), 083101" and
% "Evaluating and Correcting 3D Flash LiDAR Imagers, AD Reinhardt University of Dayton"
% 5D arrays should have a structure of (x,y,frames,rotations,variations-in-intensity), refs. "Toward snapshot correction of 3D flash LiDAR imagers, A Reinhardt, CP Bradley, A Hecht, PF McManamon Optical Engineering 60 (8), 083101" and
% "Evaluating and Correcting 3D Flash LiDAR Imagers, AD Reinhardt University of Dayton"
% DFNUC_Thermal: thermal compensation lookup table, refs. "Toward snapshot correction of 3D flash LiDAR imagers, A Reinhardt, CP Bradley, A Hecht, PF McManamon Optical Engineering 60 (8), 083101" and 
% "Thermal drift compensation in dark-frame non-uniformtiy correction for InGaAs PIN 3D flash lidar camera, AE Hecht, AD Reinhardt, C Bradley, PF McManamon Laser Radar Technology and Applications XXVI 11744, 117440B"
%
% output: array of indices for thermal compensation of DFNUC

function output=thermalIDX(input,DFNUC_Thermal)

%% Process inputs
%Assume no more dimensions than 5, no less than 3, catch errors if this happens and popup dialog box
try
	if length(size(input))==4
		Temp1=nanmedian(double(input),4);
	elseif length(size(input))==5
		Temp1=nanmedian(nanmedian(double(input),4),5);
	else
		Temp1=double(input);
	end
catch
	%display specific warning messages and return (exit) from the function if an error is caught
	if length(size(input))>5
		msgbox('please use an array with the appropriate structure!  See readme for more information.')
		return
	elseif length(size(input))<3
		msgbox('please use an array with enough data to perform calculations - 3D, 4D, or 5D arrays are supported!')
		return
	elseif isempty(input)
		msgbox('please select an input that is not empty!')
		return
	end
	%Under any and all circumstances the function should return, even if no specific error is caught
	msgbox('critical error detected in running the function, will exit now!')
	return
end

%% Apply inputs
try
	% temporary indices
	Temp2 = 1:size(DFNUC_Thermal,3);
	% index array
	Temp3=repmat(Temp2,size(Temp1,3),1);
	% Preallocate memory before looping
	Temp5=zeros(size(Temp1,3),length(Temp2));
	for ii = Temp2
	    Temp4 = double(Temp1)-DFNUC_Thermal(:,:,ii);
	    Temp5(:,ii)=nanstd(nanstd(Temp4,[],2),[],1);
	end
	%Generate indices and reshape
	output = Temp3(Temp5==min(Temp5,[],2));
	output=reshape(output,size(Temp1,3),length(output)/size(Temp1,3));

catch
	%display specific warning messages and return (exit) from the function if an error is caught
	%The most likely error to occur in this block is if a lookup table of the wrong size is accidentally used
	if length(size(DFNUC_Thermal,3))<=1
		msgbox('interpolated thermal compensation lookup table must have more than 2-dimensions!')
		return
	end
	%Under any and all circumstances the function should return, even if no specific error is caught
	msgbox('critical error detected in running the function, will exit now!')
	return
end
