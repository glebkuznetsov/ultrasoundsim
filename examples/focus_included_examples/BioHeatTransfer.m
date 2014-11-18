clc;
fprintf('==============================[ BioHeatTransfer.m ]===============================\n\n');
fprintf('This script calculates the pressure profile of an 80-element array and uses this\n');
fprintf('to calculate the power deposition and the localized temperature rise using the\n');
fprintf('bio-heat transfer equation. The script produces three plots: the pressure, the\n');
fprintf('power deposition, and the temperature rise at each point in the medium.\n\n');

% Set up the transducer array
width = 1e-3;
height = 10e-3;
kerf = 0.4e-3;
x_elements = 16;
y_elements = 5;
d = x_elements * (width+kerf); % Array aperture
N = 2; % F-number to focus at

% Focus the array
focus_x = 0;
focus_y = 0;
focus_z = d*N;

xdcr_array = create_rect_curved_strip_array(x_elements, y_elements, width, height, kerf, focus_z);

% Use a medium with these parameters
medium = set_medium('specificheatofblood',4000,'thermalconductivity',0.55,'attenuationdBcmMHz',0.5);
% Center frequency and wavelength
f0 = 1e6;
lambda = medium.soundspeed / f0;

% Calculation grid
xmin = -(x_elements/2) * (width + kerf)*1.2;
xmax = -xmin;
ymin = -(y_elements/2) * (height + kerf)*1.2;
ymax = -ymin;
zmin = 0;
zmax = focus_z * 2;

% Lambda/4 sampling
dx = lambda/4;
dy = lambda/4;
dz = lambda/4;

x = xmin:dx:xmax;
y = ymin:dy:ymax;
z = zmin:dz:zmax;
y_index = floor(length(y)/2) + 1;

cg = set_coordinate_grid([dx dy dz], xmin, xmax, ymin, ymax, 0, 0);
cg_asa = set_coordinate_grid([dx dy dz], xmin, xmax, ymin, ymax, zmin, zmax);

xdcr_array = set_phases(xdcr_array, focus_x, focus_y, focus_z, medium, f0, 200, 1);

ndiv = 30;

tic();
% Calculate pressure and intensity
fprintf('Calculating initial 2D pressure field... ');
tic();
p0 = cw_pressure(xdcr_array, cg, medium, ndiv, f0);
fprintf('done in %f s.\n', toc());
fprintf('Calculating 3D pressure with ASA... ');
pressure = cw_angular_spectrum(p0, cg_asa, medium, f0, 512, 'Pa');
fprintf('done in %f s.\n',toc());
power = cw_power(pressure, medium);

% Perform bio-heat transfer calculation
tic();
fprintf('Calculating temperature rise with BHTE... ');
% 450 iterations gets the error below 1%
temprise = bioheat_transfer(pressure, medium, dx, dy, dz, 450);
fprintf('done in %f s.\n', toc());

% Plot the pressure, intensity, and temperature
figure();
pcolor(z*1000, x*1000, squeeze(abs(pressure(:,y_index,:))));
title('Pressure (Pa) at y=0');
shading flat;
xlabel('z (mm)');
ylabel('x (mm)');

figure();
pcolor(z*1000, x*1000, squeeze(power(:,y_index,:)));
title('Power (W/m^2) at y=0');
shading flat;
xlabel('z (mm)');
ylabel('x (mm)');

figure();
pcolor(z*1000,x*1000,squeeze(temprise(:,y_index,:)));
shading flat;
title('Temperature rise at y = 0');
xlabel('z (mm)');
ylabel('x (mm)');
h = colorbar;
xlabel(h, 'degrees C');

figure();
draw_array(xdcr_array);

fprintf('Maximum temperature rise: %f deg. C\n', max(max(max(temprise))));
fprintf('Minimum temperature rise: %f deg. C\n', min(min(min(temprise))));