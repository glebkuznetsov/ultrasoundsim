% Script to demonstrate the array apodization capabilities added to FOCUS
% in version 0.299.
clc;
fprintf('==============================[ ArrayApodization.m ]==============================\n\n');
fprintf('This script demonstrates the array apodization capabilities added in FOCUS version\n');
fprintf('0.299. It calculates the pressure profiles of a 32-element array using the six\n');
fprintf('built-in apodization functions and displays the pressure and element amplitudes\n');
fprintf('for each simulation. The script also produces an image of the array.\n\n');

element_count = 32;

width = 1e-3;
height = 5e-3;
kerf = 0.3e-3;
% Total aperture width
d = element_count * (width+kerf);
% Create planar array
xdcr_array = create_rect_planar_array(element_count,1,width,height,kerf,0);
% Use medium medium
medium = set_medium('lossless');
% Center frequency and wavelength
f0 = 1e6;
lambda = medium.soundspeed / f0;
% Calculation grid parameters
xmin = -(element_count/2) * (width + kerf);
xmax = (element_count/2) * (width + kerf);
ymin = 0;
ymax = 0;
zmin = 0;
zmax = 0.62 * sqrt(d^3 / lambda); % Beginning of Fresnel region

dx = (xmax-xmin)/82;
dy = (ymax-ymin)/82;
dz = (zmax-zmin)/209;

x = xmin:dx:xmax;
y = ymin:dy:ymax;
z = zmin:dz:zmax;

cg = set_coordinate_grid([dx dy dz], xmin, xmax, ymin, ymax, zmin, zmax);
% Pre-allocate apodization vectors
ap_uniform = ones(32,1);
ap_bartlett = ones(32,1);
ap_chebyshev = ones(32,1);
ap_hamming = ones(32,1);
ap_hann = ones(32,1);
ap_tri = ones(32,1);
% Set accuracy and start clock
ndiv = 15;
tic();
% Calculate pressures
% Uniform
disp('Calculating pressure for uniform apodization...');
p_ref = cw_pressure(xdcr_array, cg, medium, ndiv, f0, 'fnm sse');
% Bartlett
disp('Calculating pressure for Bartlett apodization...');
xdcr_array = set_apodization(xdcr_array, 'bartlett');
p_b = cw_pressure(xdcr_array, cg, medium, ndiv, f0, 'fnm sse');
for i=1:32
    ap_bartlett(i) = xdcr_array(i).amplitude;
end
% Chebyshev
disp('Calculating pressure for Chebyshev apodization...');
xdcr_array = set_apodization(xdcr_array, 'chebyshev');
p_c = cw_pressure(xdcr_array, cg, medium, ndiv, f0, 'fnm sse');
for i=1:32
    ap_chebyshev(i) = xdcr_array(i).amplitude;
end
% Hamming
disp('Calculating pressure for Hamming apodization...');
xdcr_array = set_apodization(xdcr_array, 'hamming');
p_ham = cw_pressure(xdcr_array, cg, medium, ndiv, f0, 'fnm sse');
for i=1:32
    ap_hamming(i) = xdcr_array(i).amplitude;
end
% Hann
disp('Calculating pressure for Hann apodization...');
xdcr_array = set_apodization(xdcr_array, 'hann');
p_han = cw_pressure(xdcr_array, cg, medium, ndiv, f0, 'fnm sse');
for i=1:32
    ap_hann(i) = xdcr_array(i).amplitude;
end
% Triangle
disp('Calculating pressure for triangle apodization...');
xdcr_array = set_apodization(xdcr_array, 'triangle');
p_t = cw_pressure(xdcr_array, cg, medium, ndiv, f0, 'fnm sse');
for i=1:32
    ap_tri(i) = xdcr_array(i).amplitude;
end

fprintf('Simulation complete in %f seconds.\n', toc());
% Plot array apodization vectors
figure(1);
% Uniform
subplot(2,3,1);
plot(1:32, ap_uniform);
title('Uniform apodization');
ylabel('Amplitude');
xlabel('Transducer');
% Bartlett
subplot(2,3,2);
plot(1:32, ap_bartlett);
title('Bartlett apodization');
ylabel('Amplitude');
xlabel('Transducer');
% Chebyshev
subplot(2,3,3);
plot(1:32, ap_chebyshev);
title('Chebyshev apodization');
ylabel('Amplitude');
xlabel('Transducer');
% Hamming
subplot(2,3,4);
plot(1:32, ap_hamming);
title('Hamming apodization');
ylabel('Amplitude');
xlabel('Transducer');
% Hann
subplot(2,3,5);
plot(1:32, ap_hann);
title('Hann apodization');
ylabel('Amplitude');
xlabel('Transducer');
% Triangle
subplot(2,3,6);
plot(1:32, ap_tri);
title('Triangle apodization');
ylabel('Amplitude');
xlabel('Transducer');

% Plot pressures
% Uniform
figure(2);
subplot(2,3,1);
pcolor(z*1000, x*1000, abs(squeeze(p_ref(:,1,:))));
title('Uniform apodization');
ylabel('x (mm)');
xlabel('z (mm)');
shading flat;
% Bartlett
subplot(2,3,2);
pcolor(z*1000, x*1000, abs(squeeze(p_b(:,1,:))));
title('Bartlett apodization');
ylabel('x (mm)');
xlabel('z (mm)');
shading flat;
% Chebyshev
subplot(2,3,3);
pcolor(z*1000, x*1000, abs(squeeze(p_c(:,1,:))));
title('Chebyshev apodization');
ylabel('x (mm)');
xlabel('z (mm)');
shading flat;
% Hamming
subplot(2,3,4);
pcolor(z*1000, x*1000, abs(squeeze(p_ham(:,1,:))));
title('Hamming apodization');
ylabel('x (mm)');
xlabel('z (mm)');
shading flat;
% Hann
subplot(2,3,5);
pcolor(z*1000, x*1000, abs(squeeze(p_han(:,1,:))));
title('Hann apodization');
ylabel('x (mm)');
xlabel('z (mm)');
shading flat;
% Triangle
subplot(2,3,6);
pcolor(z*1000, x*1000, abs(squeeze(p_t(:,1,:))));
title('Triangular apodization');
ylabel('x (mm)');
xlabel('z (mm)');
shading flat;
% Show the array
figure(3);
draw_array(xdcr_array);