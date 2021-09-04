% NUC_RW_Corrrection_Process.m
% Author: Dr. Andrew Reinhardt
% Date: 8/9/2021
% 
% Purpose: Processes all raw files into a full correction and applies these files to an ND-array
% 
% Function acts as a UI to select inputs and process data, enabling correction process to proceed
% Prerequisites are Range walk, NUC correction tables, and an appropriately correctable frame or set of frames from the same imager
% outputs are the DFNUC in range, DFNUC in intensity, range fully corrected of NUC, intensity fully corrected of NUC, Range Walk corrected range return, and Range walk error for the return

function [out_RngDFNUC_corr, out_IntsDFNUC_corr, out_RngNUC_corr, out_IntsNUC_corr, out_RW_corr, out_RW] = NUC_RW_Corrrection_Process()

%dialog box asking how your data is constructed - is the correction data loaded via several separate files or a single file?
answer = questdlg('Is the data you wish to load composed of separate files for range and intensity returns, or one single file?', '','Cancel','Yes','No');

%Load the data
switch answer
	%If separate files
    case 'Yes'
        ii=1;
        
        msgbox('Load Range Walk Data...');
        [file,path] = uigetfile('*.mat');
        load(fullfile(path,file));
        msgbox('Range Walk Data Loaded!');
        
        msgbox('Load Range PRNUC Data...');
        [file,path] = uigetfile('*.mat');
        load(fullfile(path,file));
        msgbox('Range PRNUC Data Loaded!');
        
        msgbox('Load Intensity DFNUC Data...');
        [file,path] = uigetfile('*.mat');
        load(fullfile(path,file));
        msgbox('Intensity DFNUC Data Loaded!');
        
        msgbox('Load Intensity Data...');
        [file,path] = uigetfile('*.mat');
        load(fullfile(path,file));
        msgbox('Intensity Data Loaded!');
        
        msgbox('Load Range PRNUC Data...');
        [file,path] = uigetfile('*.mat');
        load(fullfile(path,file));
        msgbox('Range PRNUC Data Loaded!');
        
        msgbox('Load Range DFNUC Data...');
        [file,path] = uigetfile('*.mat');
        load(fullfile(path,file));
        msgbox('Range DFNUC Data Loaded!');
        
        msgbox('Load Range Data...');
        [file,path] = uigetfile('*.mat');
        load(fullfile(path,file));
        msgbox('Range Data Loaded!');
        
        PRNUC = cat(1,PRNUC_Intensity,PRNUC_Range);
        DFNUC_Thermal = cat(1,DFNUC_Intensity_Thermal,DFNUC_Range_Thermal);
        frameData = cat(1,IntensityData,RangeData);
	%If a single file for correction data
    case 'No'
        ii=2;
        
        msgbox('Load Range Walk Data...');
        [file,path] = uigetfile('*.mat');
        load(fullfile(path,file));
        msgbox('Range Walk Data Loaded!');
        
        msgbox('Load PRNUC Data...');
        [file,path] = uigetfile('*.mat');
        load(fullfile(path,file));
        msgbox('PRNUC Data Loaded!');
        
        msgbox('Load DFNUC Data...');
        [file,path] = uigetfile('*.mat');
        load(fullfile(path,file));
        msgbox('DFNUC Data Loaded!');
        
        msgbox('Load Frame Data...');
        [file,path] = uigetfile('*.mat');
        load(fullfile(path,file));
        msgbox('Frame Data Loaded!');
    case 'Cancel'
        msgbox('Process Terminated by User!');
        ii=0;
end

% Error catching
try
	%Proceed throughout and correct the data
    sz = size(frameData,1)*0.5;
	
    out_IntsDFNUC_corr = DFNUC(frameData(1:sz,:,:),DFNUC_Thermal(1:sz,:,:));
    out_IntsNUC_corr = NUC(frameData(1:sz,:,:),DFNUC_Thermal(1:sz,:,:),PRNUC(1:sz,:));
    
    msgbox('Intensity Fully Corrected!');
    
    out_RngDFNUC_corr = DFNUC(frameData(1+sz:sz*2,:,:),DFNUC_Thermal(1+sz:sz*2,:,:));
    out_RngNUC_corr = NUC(frameData(1+sz:sz*2,:,:),DFNUC_Thermal(1+sz:sz*2,:,:),PRNUC(1+sz:sz*2,:));
    
    msgbox('Range Corrected!');
    
    out_RW = RW(Intensity_NUC,ft_params,ft);
    
    out_RW_corr = out_RngNUC_corr - out_RW;
    
    msgbox('Range Fully Corrected!');
	%save variables or simply exit the function with variables in memory
	try
		clear answer ii sz file path frameData ft_params ft DFNUC_Thermal PRNUC
		[file,path] = uiputfile('*.mat');
		save(fullfile(path,file))
		msgbox('variables have been saved')
	catch
		msgbox('no files saved, will exit the function!')
		return
	end

%assuming that no data was loaded or another error occurred
catch
	if ii<=0
		msgbox('no data was loaded!  The process will now exit!')
		return
	end
	msgbox('a critical error has occurred, the process will now exit!')
	return
end