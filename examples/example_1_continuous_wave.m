% Example 1 from http://www.egr.msu.edu/~fultras-web/files/documentation/quick-start.pdf

% FNM CW Example

width = 1e-3;
height = 5e-3;
elements_x = 32;
elements_y = 1;
kerf = 4e-4;
transducer_array = create_rect_planar_array(elements_x, elements_y, width, height, ...
		kerf, kerf);

% This sets up our transducer array with 20 0.7 mm x 3 mm elements spaced
% 0.5 mm edge-to-edge. Notice the kerf variable is used twice. This is
% because FOCUS lets you specify different x and y spacings for the transducer
% array. In this example, we only have a one-dimensional array, so the
% y-spacing doesn't matter. Next, we need to set up our coordinate grid.
define_media();
f0 = 1e6;
lambda = (lossless.soundspeed / f0);
xmin = -(2*width + kerf) * (elements_x/2+1);
xmax = (2*width + kerf) * (elements_x/2+1);
ymin = 0;
ymax = 0;
zmin = 0;
zmax = 50 * lambda;

focus_x = 0;
focus_y = 0;
focus_z = 25 * lambda;

xpoints = 400;
ypoints = 1;
zpoints = 300;

dx = (xmax-xmin)/xpoints;
dy = (ymax-ymin)/ypoints;
dz = (zmax-zmin)/zpoints;

x = xmin:dx:xmax;
y = ymin:dy:ymax;
z = zmin:dz:zmax;

delta = [dx dy dz];
coord_grid = set_coordinate_grid(delta, xmin, xmax, ymin, ymax, zmin, zmax);

% This sets up our coordinate grid to cover the full width of the
% transducer array in the x direction and to measure the pressure
% field to 50 wavelengths in the z direction. Now we need to focus the
% transducer array.
disp(['Focusing array at (', num2str(focus_x), ', ', num2str(focus_y), ...
', ', num2str(focus_z), ')']);

transducer_array = find_single_focus_phase(transducer_array, focus_x, ...
focus_y, focus_z, lossless, f0, 200);

% The next step is to run the FNM function and display the resulting
% pressure field.

ndiv=6;
tic();

disp('Calculating pressure field...');
p_cw=cw_pressure(transducer_array, coord_grid, lossless, ndiv, f0);
disp(['Simulation complete in ', num2str(toc()), ' seconds.'])

draw_array(transducer_array);

figure();
h = pcolor(x*100,z*100,rot90(squeeze(abs(p_cw)),3));
set(h,'edgecolor','none');
title('Pressure Field at y = 0 cm');
xlabel('x (cm)');
ylabel('z (cm)');

