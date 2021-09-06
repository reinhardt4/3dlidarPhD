% TargetPlacer.m
% Author: Dr. Andrew Reinhardt
% Date: 8/9/2021
% 
% Purpose: Preliminary computations for creation of Checkerboard Target (for SLM or Physically Downrange)
% 
% Computes optimal range for calibration inclusive of RMS error within a UI/GUI interface

function TargetPlacer()

%Match to SLM or to physical target?
answer = questdlg('Match format to spatial light modulator?','Cancel','Yes','No');

switch answer
	
	case 'Yes'
		%If SLM option, computations will be focused on a directly illuminated, close range system
		msgbox('Will match dimensions to Spatial Light Modulator format...')
		
		prompt = 'Wavelength of laser? [nm]';
		Lambda = inputdlg(prompt);
		prompt = 'Min spot size of laser? [mm]';
		w0 = inputdlg(prompt);
		prompt = 'Effective focal distance of Spatial Light modulator? [mm]';
		w0 = inputdlg(prompt);
		zr = pi*w0.^2 ./(1e6*Lambda);
		wf = w0.*f./zr;
		prompt = 'Rows of pixels in Spatial Light Modulator? [detectors]';
		Nx_SLM = inputdlg(prompt);
		prompt = 'Columns of pixels in Spatial Light Modulator? [detectors]';
		Ny_SLM = inputdlg(prompt);
		prompt = 'Spatial Light Modulator physical dimensions along Rows? [mm]';
		Nx_SLM_cm = inputdlg(prompt);
		Ny_SLM_cm = Ny_SLM./Nx_SLM.*Nx_SLM_cm;
		prompt = 'Physical dimensions of detector array in x? [mm]';
		Nx_cm = inputdlg(prompt);
		prompt = 'Physical dimensions of detector array in y? [mm]';
		Ny_cm = inputdlg(prompt);
		%Is the beam large enough to encompass the FPA, assuming no propagation (minimum bounding)?
		if Nx_SLM_cm >= Nx_cm
			prompt = 'Maximum block size? [detectors]';
			MaxBlockSz = inputdlg(prompt);
			Ratio_min_x=Nx_cm./(10*wf);
			Ratio_min_y=Ny_cm./(10*wf);
			Range_x=sqrt(Ratio_min_x.^2-1).*zr;
			Range_y=sqrt(Ratio_min_y.^2-1).*zr;
		else
			msgbox('Spot is smaller than detector footprint, please try modifying focal length (or other parameters) and trying again!')
			return
		end
		
	case 'No'
		%otherwise, typical system using a imaging lens, FOV equation
		msgbox('Will match dimensions to Down-Range Physical Target...')
		
		
		prompt = 'Pixel Pitch? [um]';
		pxlpitch = inputdlg(prompt);

		prompt = 'number of rows of detectors? [Nx]';
		Nx = inputdlg(prompt);

		prompt = 'number of columns of detectors? [Ny]';
		Ny = inputdlg(prompt);

		prompt = 'Focal Length of Imaging Lens on Flash LiDAR? [mm]';
		fLens = inputdlg(prompt);

		prompt = 'Max Print Size (X-dim)? [cm]';
		MaxXDimPrint = inputdlg(prompt);

		prompt = 'Max Print Size (Y-dim)? [cm]';
		MaxYDimPrint = inputdlg(prompt);

		AngFOV_x = Nx.*pxlpitch./fLens*1e-3;
		AngFOV_y = Ny.*pxlpitch./fLens*1e-3;

		Range_x = 0.01*MaxXDimPrint./(200*tan(0.5*AngFOV_x));
		Range_y = 0.01*MaxYDimPrint./(200*tan(0.5*AngFOV_y));
		
	case 'Cancel'
		msgbox('Calculations Terminated by User!')
		return
		
end
% RMS of the range between x and y
RMS_xy_Range = 0.5*sqrt(abs(Range_x.^2-Range_y.^2));
% Mean of the range between x and y
Mu_xy_Range = 0.5*sqrt(abs(Range_x.^2+Range_y.^2));

msgbox(['The required range will vary from ' num2str(Mu_xy_Range-RMS_xy_Range) ' meters to ' num2str(Mu_xy_Range+RMS_xy_Range) 'meters'])

%Save outputs?  If yes, prompt dialog for saving.  If no, the function has ended
answer = questdlg('Save outputs?','Cancel','Yes','No');

switch answer
	
	case 'Yes'
		%Save outputs (RMS and mean range)
		msgbox('All files will be saved!')
		[filename, pathname, filterindex] = uiputfile( ...
		{'*.mat',...
		 'MATLAB Data Files (*.mat)'};
		 '*.*',  'All Files (*.*)');
		save(fullfile(pathname, filename), 'RMS_xy_Range','Mu_xy_Range')
		msgbox(['Variables -- RMS_xy_Range -- and -- Mu_xy_Range -- saved as ' filename])
	case 'No'
		msgbox('No outputs will be saved!')
	case 'Cancel'
		msgbox('Calculations Terminated by User!')	
		return
end