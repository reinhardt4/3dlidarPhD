% DFSubtraction.m
% Author: Dr. Andrew Reinhardt
% Date: 8/9/2021
% 
% Purpose: Experimental Control of 3D flash LiDAR imager using MATLAB

%%% Generalized Frame Grabber UI for frame grabbing off a 3D Flash LiDAR camera
%%% Operation requires, at minimum, MATLAB Image Acquisition, and Image Processing Toolboxes
%%% if using the MATLAB-only options, or C++/EXE software with Matrox Imaging Library 9/10 if using the C++
%%% compiled code options.
%%%
%%% Ensure that all third party software required to operate a flash LiDAR
%%% camera, and the appropriate frame grabber, is installed prior to
%%% operation of this software
%%%
%%% Note, this software will save data into a MAT file format.  The
%%% wait time parameter is based off experimentation and may need to be
%%% adjusted for each PC, and is left as a variable.
%%%

%%% initialize, clear frame grabbers

function FrameGrabber_UI()

delete(imaqfind)
clear
close all

try
	%UI list 1, determine whether MATLAB or C++ frame grab
	answer = questdlg('Frame Grab using MATLAB or call secondary software for grabbing?','Cancel','MATLAB','Other');

	switch answer
		
		case 'MATLAB'
			
			msgbox('Now proceeding to frame grab using MATLAB only...')
			indx1 = 1;
			
		case 'Other'
			msgbox('Now proceeding to frame grab using MATLAB and Secondary Software...')
			indx1 = 0;
			
		case 'Cancel'
			msgbox('Frame grabbing terminated by user!')
			
			
	end

	answer = questdlg('Save Range and Intensity returns separately?','Cancel','Separate','Keep Together');

	switch answer
		
		case 'Separate'
			
			msgbox('Will save Range and Intensity returns separately...')
			indx2 = 1;
			
		case 'Keep Together'
			msgbox('Will keep profiles together in final file...')
			indx2 = 0;
			
		case 'Cancel'
			msgbox('Frame grabbing terminated by user!')
			
			
	end
	
	%%%3D Imaging runs with MATLAB
	if indx1 == 1 && indx2 == 1 %MATLAB, Separate
		%Determine where you want to save the final MAT data and in what name
		[filenm,pathnm] = uiputfile('*.mat');
		%How many frames are to be processed?  Only valid for MATLAB options.
		prompt = 'Number of frames to collect?  This could be limited based on camera/PC performance!';
		NFramesSel = inputdlg(prompt);
		%Frames per second?  Estimate or overestimate is OK.
		prompt = 'Framing rate of the camera (FPS)?';
		FPSSel = inputdlg(prompt);
		FPS = str2double(FPSSel{1});
		try
			prompt = 'What multiplier should be used for waiting for this sensor or system (default 1.15)?';
			waitparam = inputdlg(prompt);
			waitparam = str2double(waitparam{1});
		catch
			waitparam = 1.15;
		end
		%Automatically select HW info for frame grabbing - this implies the
		%usage of a dedicated frame grabber card!  Ensure you have the proper
		%device drivers installed beforehand!
		info = imaqhwinfo;
		adaptors = info.InstalledAdaptors;
		if numel(adaptors)>1
			[indx3,~] = listdlg('PromptString',{'Select the adaptor you are using.',...
				'Only one option can be selected at a time.',''},...
				'SelectionMode','single','ListString',adaptors);
			adaptor = adaptors{indx3};
		else
			adaptor = adaptors;
		end
		info = imaqhwinfo(adaptor{1});
		devID = info.DeviceIDs;
		%UI interface to get Matrox dcf file
		if strcmp(adaptor{1},'matrox')
			[file,path] = uigetfile('*.dcf');
			%Videoinput using DCF file
			vid = videoinput(adaptor{1},devID{1},fullfile(path,file));
		else
			vid = videoinput(adaptor{1},devID{1});
		end
		%%% set up input video
		vid.FramesPerTrigger = N;
		start(vid)
		%Wait for video to start - this is necessary in triggered ToF sensors
		wait(vid,1.15*N/FPS)
		%getdata obtains a N-bit data array
		frameData = getdata(vid);
		frameData = squeeze(frameData);
		%%%Save the data
		save(fullfile(pathnm,filenm),'IntensityData','RangeData');
		
		%clean up
		delete(vid);
		msgfig = msgbox(['Success!  ' num2str(NFrames) ' frames have been grabbed.']);
		uiwait(msgfig)
		clear;

	elseif indx==1 && indx2==0 %MATLAB, Seperate
		%Determine where you want to save the final MAT data and in what name
		[filenm,pathnm] = uiputfile('*.mat');
		%How many frames are to be processed?  Only valid for MATLAB options.
		prompt = 'Number of frames to collect?  This could be limited based on camera/PC performance!';
		NFramesSel = inputdlg(prompt);
		%Frames per second?  Estimate or overestimate is OK.
		prompt = 'Framing rate of the camera (FPS)?';
		FPSSel = inputdlg(prompt);
		FPS = str2double(FPSSel{1});
		try
			prompt = 'What multiplier should be used for waiting for this sensor or system (default 1.15)?';
			waitparam = inputdlg(prompt);
			waitparam = str2double(waitparam{1});
		catch
			waitparam = 1.15;
		end
		%Automatically select HW info for frame grabbing - this implies the
		%usage of a dedicated frame grabber card!  Ensure you have the proper
		%device drivers installed beforehand!
		info = imaqhwinfo;
		adaptors = info.InstalledAdaptors;
		if numel(adaptors)>1
			[indx3,~] = listdlg('PromptString',{'Select the adaptor you are using.',...
				'Only one option can be selected at a time.',''},...
				'SelectionMode','single','ListString',adaptors);
			adaptor = adaptors{indx3};
		else
			adaptor = adaptors;
		end
		info = imaqhwinfo(adaptor{1});
		devID = info.DeviceIDs;
		%UI interface to get Matrox dcf file
		if strcmp(adaptor{1},'matrox')
			[file,path] = uigetfile('*.dcf');
			%Videoinput using DCF file
			vid = videoinput(adaptor{1},devID{1},fullfile(path,file));
		else
			vid = videoinput(adaptor{1},devID{1});
		end
		%%% set up input video
		vid.FramesPerTrigger = N;
		start(vid)
		%Wait for video to start - this is necessary in triggered ToF sensors, wait parameter may be sensor or system dependent
		wait(vid,waitparam*N/FPS)
		%getdata obtains a N-bit data array
		frameData = getdata(vid);
		frameData = squeeze(frameData);
		%%%Save the data
		save(fullfile(pathnm,filenm),'frameData'); 
		
		%clean up
		delete(vid);
		msgfig = msgbox(['Success!  ' num2str(NFrames) ' frames have been grabbed.']);
		uiwait(msgfig)
		clear;
		

	elseif indx==0 && indx2==1 %Other, Seperate
		prompt = 'What is the format of this imager (Rows-of-detectors)?';
		Nx = inputdlg(prompt);
		Nx = str2double(Nx{1});
		prompt = 'What is the format of this imager (Cols-of-detectors)?';
		Ny = inputdlg(prompt);
		Ny = str2double(Ny{1});
		%Determine where you want to save the final MAT data and in what name
		[filenm,pathnm] = uiputfile('*.mat');
		%%% use frame grabber EXE to grab frames
		system('frameGrabber.exe')
		%%%compile image files from frame grabber into single MAT file-clean up
		files=dir('*.tiff');
		%Prepare to loop over files, and convert them to a single MAT file
		ii=0;
		indx = length(files);
		IntensityData = NaN(Nx,Ny,indx);  RangeData = NaN(Nx,Ny,indx);
		for file=files'
			ii=ii+1;
			t=Tiff(file.name,'r');
			frameData=squeeze(read(t));
			if ii == 1
				ydim = size(frameData,1)*0.5;
				xdim = size(frameData,2);
				ClampDim = (xdim-ydim*3)/3;
			end
			IntensityData(:,:,ii) = frameData(1:128,:,:);  RangeData(:,:,ii) = frameData(129:256,:,:);
			%clean up TIFF files
			delete(file.name)
		end
		%save to a single MAT file
		save(fullfile(pathnm,filenm),'IntensityData','RangeData');
		
		%clean up
		delete(vid);
		msgfig = msgbox(['Success!  ' num2str(NFrames) ' frames have been grabbed.']);
		uiwait(msgfig)
		clear;
					   
	elseif indx==0 && indx2==0 && indx3 ==1 %Other, Together
		prompt = 'What is the format of this imager (Rows-of-detectors)?';
		Nx = inputdlg(prompt);
		Nx = str2double(Nx{1});
		prompt = 'What is the format of this imager (Cols-of-detectors)?';
		Ny = inputdlg(prompt);
		Ny = str2double(Ny{1});
		%Determine where you want to save the final MAT data and in what name
		[filenm,pathnm] = uiputfile('*.mat');
		%%% use frame grabber EXE to grab frames
		system('frameGrabber.exe')
		%%%compile image files from frame grabber into single MAT file-clean up
		files=dir('*.tiff');
		%Prepare to loop over files, and convert them to a single MAT file
		ii=0;
		indx = length(files);
		frameData = NaN(Nx*2,Ny,indx);
		for file=files'
			ii=ii+1;
			t=Tiff(file.name,'r');
			frameData(:,:,ii)=squeeze(read(t));
			if ii == 1
				ydim = size(frameData,1)*0.5;
				xdim = size(frameData,2);
				ClampDim = (xdim-ydim*3)/3;
			end
			frameData(:,:,ii) = frameData(:,ClampDim+1:CampDim+ydim,ii);
			%clean up TIFF files
			delete(file.name)
		end
		
		%save to a single MAT file
		save(fullfile(pathnm,filenm),'frameData'); 
		
		%clean up
		delete(vid);
		msgfig = msgbox(['Success!  ' num2str(indx) ' frames have been grabbed.']);
		uiwait(msgfig)
		clear;

	end
	%In case of issues, throw an error
catch
    msgbox('Something went wrong in the frame grabbing process, exiting now!')
	%Clean up in the case of an exception
    delete(vid);
    delete(imaqfind)
	clear
	close all
   return
end
%Clean up at the end
delete(imaqfind)
clear
close all