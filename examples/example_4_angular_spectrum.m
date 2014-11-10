% Set up the array
ele_x = 128;
ele_y = 1;
width = 0.245e-3;
height = 7e-3;
kerf_x = 0.03e-3;
kerf_y = 0;
xdc = create_rect_planar_array(ele_x, ele_y, width, height, kerf_x, kerf_y);
f0 = 1e6;
medium = set_medium('lossless');
lambda = medium.soundspeed/f0;
% Set up the coordinate grid
xmin = -((ele_x/2) * (width+kerf_x))*1.2;
xmax = -xmin;
ymin = -((ele_y/2) * (height+kerf_y))*1.2;
ymax = -ymin;
zmin = 0;
zmax = 40*lambda;
focus_x = 0;
focus_y = 0;
focus_z = 20 * lambda;
dx = lambda/8;
dy = lambda/8;
dz = lambda/8;

x = xmin:dx:xmax;
y = ymin:dy:ymax;
z = zmin:dz:zmax;
% Determine where the source pressure will be calculated
z0 = lambda/4;
y_index = floor((ymax-ymin)/2/dy);
cg_p0 = set_coordinate_grid([dx dy 1], xmin,xmax,ymin,ymax,z0,z0);
cg_z = set_coordinate_grid([dx 1 dz],xmin,xmax,ymin,ymax,zmin,zmax);
% Focus the array
xdc = find_single_focus_phase(xdc,focus_x,focus_y,focus_z,medium,f0,200);
% Calculate the pressure
ndiv = 10;
disp('Calculating p0 with FNM... ');
tic();
p0 = cw_pressure(xdc, cg_p0, medium, ndiv, f0);
disp(['Done in ', num2str(toc()), ' seconds.']);
disp(['Calculating 3D pressure (', length(x) * length(y) * length(z), ' points) with ASA... ']); tic();
p_asa = cw_angular_spectrum(p0, cg_z, medium, f0, 1024);
disp(['Done in ', num2str(toc()), ' seconds.']);
figure(1);
pcolor(x*1000, y*1000, rot90(abs(squeeze(p0(:,:,1)))));
xlabel('x (mm)');
ylabel('y (mm)');
shading flat;
title(['p0 (Calculated with FNM at z = ', num2str(z0*1000), ' mm)']);
figure(2);
pcolor(z*1000, x*1000, abs(squeeze(p_asa(:,y_index,:))));
xlabel('z (mm)');
ylabel('x (mm)');
shading flat;
title('ASA Pressure (y=0)');
