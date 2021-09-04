% RW.m
% Author: Dr. Andrew Reinhardt
% Date: 8/9/2021
% 
% Purpose: Performs range walk error correction on a set of 3D flash LiDAR imager frames
% 
% input: ND-array, fully corrected of non-uniformity such as dark-frame and gain-errors; input array is the intensity return
% ft_params: fit parameters associated with the functions below.  Note that this can be modified for polynomial fits and other functions.
% ft: fit used, in this case three fits are provided, but other functions are possible to be used
%- ref. "Toward snapshot correction of 3D flash LiDAR imagers, , A Reinhardt, CP Bradley, A Hecht, PF McManamon Optical Engineering 60 (8), 083101"

function output=RW(input,ft_params,ft)

%fit of the form f(x)=a*exp(b*x)+c*exp(d*x)
if strcmp(ft,'exp2')

    output = ft_params.a.*exp(ft_params.b.*input)+ft_params.c.*exp(ft_params.d.*input);
%fit of the form f(x)=a*x^b+c
elseif strcmp(ft,'power2')
    
    output = ft_params.a.*input.^ft_params.b+ft_params.c;
%fit of the form f(x)=a*x^b
elseif strcmp(ft,'power1')
    
    output = ft_params.a.*input.^ft_params.b;
    
end